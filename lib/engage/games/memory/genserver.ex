defmodule Engage.Games.Memory.GenServer do
  use GenServer
  alias Engage.Games.GameEvent
  alias Engage.Games.Memory.{GameBoard, Player}

  @game_name "memory"
  @card_delay 2000

  # TODO: Refactor to be more reusable between all game GenServers

  def start(
        genserver_name,
        state \\ %{
          players: %{first: nil, second: nil},
          board: %GameBoard{}
        }
      )
      when is_atom(genserver_name) do
    state = shuffle_cards(state)

    GenServer.start(
      __MODULE__,
      Map.merge(state, %{
        genserver_name: genserver_name,
        game_id: Engage.Games.get_game_by_name(@game_name).id,
        game_name: @game_name,
        game_started?: false
      }),
      name: genserver_name
    )
  end

  def add_player(genserver_name, player_id, player_name) do
    GenServer.call(genserver_name, {:add_player, player_id, player_name})
  end

  def get_player_nth_by_name(genserver_name, player_name) do
    GenServer.call(genserver_name, {:get_player_nth_by_name, player_name})
  end

  def view(genserver_name) do
    GenServer.call(genserver_name, :view)
  end

  def make_move(genserver_name, {%Player{} = player, index}) when is_number(index) do
    GenServer.call(genserver_name, {:make_move, player, index})
  end

  def start_game(genserver_name, %Player{} = player) do
    GenServer.call(genserver_name, {:start_game, player})
  end

  def kick_player(genserver_name, nth, kicked_player_id) do
    GenServer.call(genserver_name, {:kick_player, nth, kicked_player_id})
  end

  def game_started?(genserver_name) do
    GenServer.call(genserver_name, :game_started?)
  end

  # Server API

  def handle_call({:add_player, player_id, player_name}, _from, state) do
    state =
      cond do
        state.players.first === nil ->
          player = %Player{id: player_id, name: player_name}
          put_in(state.players.first, player)

        state.players.second === nil and state.players.first.id !== player_id ->
          player = %Player{id: player_id, name: player_name}
          state = put_in(state.players.second, player)

          Phoenix.PubSub.broadcast(
            Engage.PubSub,
            Atom.to_string(state.genserver_name),
            state.players
          )

          state

        true ->
          state
      end

    {:reply, state.players, state}
  end

  def handle_call({:make_move, player, index}, _from, state) do
    {nth, _player} = get_player_nth_by_name_helper(state, player.name)

    state =
      if nth == state.board.current_player and
           all_players_joined?(state) and
           not two_cards_face_up?(state) do
        reveal_card(state, player, index)
      else
        state
      end

    {:reply, state.board, state}
  end

  def handle_call({:get_player_nth_by_name, player_name}, _from, state) do
    {nth, _player} = get_player_nth_by_name_helper(state, player_name)
    {:reply, nth, state}
  end

  def handle_call({:start_game, player}, _from, state) when not is_nil(player) do
    {state, game_started?} =
      if player === state.players.first and all_players_joined?(state) do
        state = put_in(state.game_started?, true)
        :timer.send_after(0, {:game_started, state})
        {state, true}
      else
        {state, false}
      end

    {:reply, game_started?, state}
  end

  def handle_call({:kick_player, owner_nth, kicked_player_id}, _from, state) do
    state =
      if owner_nth === :first and
           state.players[owner_nth].id !== kicked_player_id and
           not state.game_started? do
        kicked_nth = get_player_nth_by_id(state, kicked_player_id)
        state = put_in(state.players[kicked_nth], nil)
        :timer.send_after(0, {:send_players, state})
        state
      else
        state
      end

    {:reply, nil, state}
  end

  def handle_call(:view, _from, state) do
    {:reply, state.board, state}
  end

  def handle_call(:game_started?, _from, state) do
    {:reply, state.game_started?, state}
  end

  def init(state) do
    {:ok, state}
  end

  def handle_info({:send_board, state}, _state) do
    Phoenix.PubSub.broadcast(
      Engage.PubSub,
      Atom.to_string(state.genserver_name),
      state.board
    )

    {:noreply, state}
  end

  def handle_info({:send_players, state}, _state) do
    Phoenix.PubSub.broadcast(
      Engage.PubSub,
      Atom.to_string(state.genserver_name),
      state.players
    )

    {:noreply, state}
  end

  def handle_info({:game_started, state}, _state) do
    Phoenix.PubSub.broadcast(
      Engage.PubSub,
      Atom.to_string(state.genserver_name),
      :game_started
    )

    {:noreply, state}
  end

  def handle_info({:replay, state}, _state) do
    state =
      state
      |> put_in([:board], %GameBoard{})
      |> shuffle_cards

    state = put_in(state.players.first.matched_pairs_current_game, 0)
    state = put_in(state.players.second.matched_pairs_current_game, 0)

    :timer.send_after(0, {:send_board, state})
    :timer.send_after(0, {:send_players, state})
    {:noreply, state}
  end

  defp reveal_card(state, player, index) do
    state = put_in(state.board.state[index].face_up?, true)
    :timer.send_after(0, {:send_board, state})
    check_for_matching_cards(state, player)
  end

  defp check_for_matching_cards(state, player) do
    if two_cards_face_up?(state) do
      if face_up_cards_match?(state) do
        {nth, _player} = get_player_nth_by_name_helper(state, player.name)
        state = update_in(state.players[nth].matched_pairs_current_game, &(&1 + 1))
        state = match_face_up_cards(state, player)
        :timer.send_after(0, {:send_board, state})
        :timer.send_after(0, {:send_players, state})
        check_for_winner_and_update_scores(state)
      else
        state = set_next_players_turn(state)
        state = hide_all_unmatched_cards(state)
        :timer.send_after(@card_delay, {:send_board, state})
        state
      end
    else
      state
    end
  end

  defp two_cards_face_up?(state) do
    Enum.count(get_unmatched_face_up_cards(state)) === 2
  end

  defp all_players_joined?(state) do
    state.players.first !== nil and state.players.second !== nil
  end

  defp face_up_cards_match?(state) do
    face_up_cards = get_unmatched_face_up_cards(state)
    {_k, first_card} = Enum.at(face_up_cards, 0)
    Enum.all?(face_up_cards, fn {_k, card} -> card.symbol == first_card.symbol end)
  end

  defp get_unmatched_face_up_cards(state) do
    Enum.into(
      Enum.filter(state.board.state, fn {_k, card} ->
        card.face_up? == true and card.matched_by_user_id == nil
      end),
      %{}
    )
  end

  defp match_face_up_cards(state, player) do
    updated_cards_list =
      Enum.map(get_unmatched_face_up_cards(state), fn {k, card} ->
        {k, Map.replace(card, :matched_by_user_id, player.id)}
      end)

    put_in(
      state.board.state,
      Map.merge(
        state.board.state,
        Enum.into(updated_cards_list, %{})
      )
    )
  end

  defp hide_all_unmatched_cards(state) do
    updated_cards_list =
      Enum.map(
        get_unmatched_face_up_cards(state),
        fn {k, card} -> {k, Map.replace(card, :face_up?, false)} end
      )

    put_in(
      state.board.state,
      Map.merge(
        state.board.state,
        Enum.into(updated_cards_list, %{})
      )
    )
  end

  defp set_next_players_turn(state) do
    next_player =
      case state.board.current_player do
        :first -> :second
        :second -> :first
      end

    put_in(state.board.current_player, next_player)
  end

  defp shuffle_cards(state) do
    count = Enum.count(state.board.state)
    keys = Enum.take_random(Map.keys(state.board.state), count)
    cards = Enum.take_random(Map.values(state.board.state), count)

    put_in(state.board.state, Enum.zip(keys, cards) |> Enum.into(%{}))
  end

  defp check_for_winner_and_update_scores(state) do
    case decide_winner(state) do
      :first ->
        state = update_in(state.players.first.score, &(&1 + 1))
        insert_game_event_into_db(state.game_id, state.players.first.id, state.players.second.id)
        :timer.send_after(@card_delay, {:replay, state})
        state

      :second ->
        state = update_in(state.players.second.score, &(&1 + 1))
        insert_game_event_into_db(state.game_id, state.players.second.id, state.players.first.id)
        :timer.send_after(@card_delay, {:replay, state})
        state

      :draw ->
        insert_draw_game_event_into_db(state.game_id, state.players.second.id, state.players.first.id)
        :timer.send_after(@card_delay, {:replay, state})
        state

      nil ->
        state
    end
  end

  defp decide_winner(state) do
    first_player_score = state.players.first.matched_pairs_current_game
    second_player_score = state.players.second.matched_pairs_current_game

    cond do
      first_player_score > second_player_score and
          first_player_score + second_player_score === num_of_card_pairs(state) ->
        :first

      second_player_score > first_player_score and
          second_player_score + first_player_score === num_of_card_pairs(state) ->
        :second

      first_player_score === second_player_score and
        first_player_score + second_player_score === num_of_card_pairs(state) ->
          :draw

      true ->
        nil
    end
  end

  defp num_of_card_pairs(state) do
    div(Enum.count(state.board.state), 2)
  end

  defp get_player_nth_by_name_helper(state, player_name) do
    Enum.find(state.players, fn {_, v} -> v.name === player_name end)
  end

  defp insert_game_event_into_db(game_id, winner_id, loser_id) do
    Engage.GameEvents.insert_game_event(%GameEvent{
      outcome: :won,
      game_id: game_id,
      user_id: winner_id,
      opponent_user_id: loser_id
    })

    Engage.GameEvents.insert_game_event(%GameEvent{
      outcome: :lost,
      game_id: game_id,
      user_id: loser_id,
      opponent_user_id: winner_id
    })
  end

  defp insert_draw_game_event_into_db(game_id, first_player_id, second_player_id) do
    Engage.GameEvents.insert_game_event(%GameEvent{
      outcome: :draw,
      game_id: game_id,
      user_id: first_player_id,
      opponent_user_id: second_player_id
    })

    Engage.GameEvents.insert_game_event(%GameEvent{
      outcome: :draw,
      game_id: game_id,
      user_id: second_player_id,
      opponent_user_id: first_player_id
    })
  end

  defp get_player_nth_by_id(state, player_id) when is_integer(player_id) do
    {nth, _player} = Enum.find(state.players, fn {_nth, player} -> player.id === player_id end)
    nth
  end
end
