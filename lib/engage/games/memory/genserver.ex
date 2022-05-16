defmodule Engage.Games.Memory.GenServer do
  use GenServer
  alias Engage.Games.Memory.{GameBoard, Player}

  @game_name "memory"
  @show_card_delay 2000

  # TODO: Refactor to be more reusable between all game GenServers

  def start(
        genserver_name,
        state \\ %{
          players: %{first: nil, second: nil},
          board: %GameBoard{},
          nth_player_turn: :first
        }
      )
      when is_atom(genserver_name) do
    state = shuffle_cards(state)

    GenServer.start(
      __MODULE__,
      Map.merge(state, %{
        genserver_name: genserver_name,
        game_id: Engage.Games.get_game_by_name(@game_name).id
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
      if nth == state.nth_player_turn and
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

  def handle_call(:view, _from, state) do
    {:reply, state.board, state}
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

  def handle_info(:replay, state) do
    state =
      state
      |> put_in([:board], %GameBoard{})
      |> shuffle_cards
      |> put_in([:players, :first, :matched_pairs_current_game], 0)
      |> put_in([:players, :second, :matched_pairs_current_game], 0)

    :timer.send_after(0, {:send_board, state})
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
        :timer.send_after(@show_card_delay, {:send_board, state})
        state
      else
        state = set_next_players_turn(state)
        state = hide_all_unmatched_cards(state)
        :timer.send_after(@show_card_delay, {:send_board, state})
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
    next_nth_player_turn =
      case state.nth_player_turn do
        :first -> :second
        :second -> :first
      end

    put_in(state.nth_player_turn, next_nth_player_turn)
  end

  defp shuffle_cards(state) do
    count = Enum.count(state.board.state)
    keys = Enum.take_random(Map.keys(state.board.state), count)
    cards = Enum.take_random(Map.values(state.board.state), count)

    put_in(state.board.state, Enum.zip(keys, cards) |> Enum.into(%{}))
  end

  defp get_player_nth_by_name_helper(state, player_name) do
    Enum.find(state.players, fn {_, v} -> v.name === player_name end)
  end
end
