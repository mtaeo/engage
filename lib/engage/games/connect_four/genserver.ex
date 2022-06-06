defmodule Engage.Games.ConnectFour.GenServer do
  use GenServer
  alias Engage.Games.GameEvent
  alias Engage.Games.ConnectFour.{GameBoard, Player}

  @game_name "connect-four"
  @cols 7

  def start(
        genserver_name,
        state \\ %{
          players: %{first: nil, second: nil},
          board: %GameBoard{}
        }
      )
      when is_atom(genserver_name) do
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

  def make_move(genserver_name, {%Player{} = player, index}) do
    GenServer.call(genserver_name, {:make_move, player, index})
  end

  def make_move(genserver_name, {nil, _index}) do
    GenServer.call(genserver_name, :view)
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

  def handle_call({:make_move, %Player{} = player, col}, _from, state) do
    {nth, _player} = get_player_nth_by_name_helper(state, player.name)

    state =
      if state.game_started? and
           is_nil(state.board.outcome) and
           nth == state.board.current_player and
           all_players_joined?(state) do
        insert_chip(state, nth, col)
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

    :timer.send_after(0, {:send_board, state})
    :timer.send_after(0, {:send_players, state})
    {:noreply, state}
  end

  defp all_players_joined?(state) do
    state.players.first !== nil and state.players.second !== nil
  end

  defp set_next_players_turn(state) do
    next_player =
      case state.board.current_player do
        :first -> :second
        :second -> :first
      end

    put_in(state.board.current_player, next_player)
  end

  defp insert_chip(state, nth, col)
       when is_atom(nth) and
              is_integer(col) do
    index = get_lowest_index_for_column(state, col)

    state =
      if is_nil(index) do
        state
      else
        state =
          put_in(state.board.state[index], nth)
          |> check_for_winner_and_update_scores(nth)

        :timer.send_after(0, {:send_board, state})

        state
      end

    state
  end

  defp get_lowest_index_for_column(state, col) when is_integer(col) do
    available_slots =
      Enum.filter(state.board.state, fn {i, v} -> is_nil(v) and rem(i, @cols) == col end)

    if Enum.empty?(available_slots) do
      nil
    else
      {index, _v} =
        available_slots
        |> Enum.max_by(fn {i, _v} -> i end)

      index
    end
  end

  defp check_for_winner_and_update_scores(state, nth) do
    case decide_winner(state, nth) do
      :first ->
        state = put_in(state.board.outcome, :first)
        state = update_in(state.players.first.score, &(&1 + 1))
        insert_game_event_into_db(state.game_id, state.players.first.id, state.players.second.id)
        :timer.send_after(3000, {:replay, state})
        state

      :second ->
        state = put_in(state.board.outcome, :second)
        state = update_in(state.players.second.score, &(&1 + 1))
        insert_game_event_into_db(state.game_id, state.players.second.id, state.players.first.id)
        :timer.send_after(3000, {:replay, state})
        state

      :draw ->
        state = put_in(state.outcome, :draw)

        insert_draw_game_event_into_db(
          state.game_id,
          state.players.second.id,
          state.players.first.id
        )

        :timer.send_after(3000, {:replay, state})
        state

      nil ->
        set_next_players_turn(state)
    end
  end

  defp decide_winner(state, nth) do
    if board_full?(state) do
      :draw
    else
      is_winner? =
        Enum.any?(
          Enum.map(winning_combinations(), fn w ->
            Enum.all?(w, fn i ->
              {:ok, n} = Map.fetch(state.board.state, i)
              n == nth
            end)
          end)
        )

      if is_winner?, do: nth, else: nil
    end
  end

  defp board_full?(state) do
    Enum.count(Enum.filter(state.board.state, fn {_i, v} -> not is_nil(v) end)) === 0
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

  defp get_player_nth_by_name_helper(state, player_name) do
    Enum.find(state.players, {nil, nil}, fn {_, v} -> v.name === player_name end)
  end

  defp get_player_nth_by_id(state, player_id) when is_integer(player_id) do
    {nth, _player} =
      Enum.find(state.players, {nil, nil}, fn {_nth, player} -> player.id === player_id end)

    nth
  end

  # I'm sorry
  # TODO: Refactor
  defp winning_combinations() do
    [
      [0, 1, 2, 3],
      [41, 40, 39, 38],
      [7, 8, 9, 10],
      [34, 33, 32, 31],
      [14, 15, 16, 17],
      [27, 26, 25, 24],
      [21, 22, 23, 24],
      [20, 19, 18, 17],
      [28, 29, 30, 31],
      [13, 12, 11, 10],
      [35, 36, 37, 38],
      [6, 5, 4, 3],
      [0, 7, 14, 21],
      [41, 34, 27, 20],
      [1, 8, 15, 22],
      [40, 33, 26, 19],
      [2, 9, 16, 23],
      [39, 32, 25, 18],
      [3, 10, 17, 24],
      [38, 31, 24, 17],
      [4, 11, 18, 25],
      [37, 30, 23, 16],
      [5, 12, 19, 26],
      [36, 29, 22, 15],
      [6, 13, 20, 27],
      [35, 28, 21, 14],
      [0, 8, 16, 24],
      [41, 33, 25, 17],
      [7, 15, 23, 31],
      [34, 26, 18, 10],
      [14, 22, 30, 38],
      [27, 19, 11, 3],
      [35, 29, 23, 17],
      [6, 12, 18, 24],
      [28, 22, 16, 10],
      [13, 19, 25, 31],
      [21, 15, 9, 3],
      [20, 26, 32, 38],
      [36, 30, 24, 18],
      [5, 11, 17, 23],
      [37, 31, 25, 19],
      [4, 10, 16, 22],
      [2, 10, 18, 26],
      [39, 31, 23, 15],
      [1, 9, 17, 25],
      [40, 32, 24, 16],
      [9, 17, 25, 33],
      [8, 16, 24, 32],
      [11, 17, 23, 29],
      [12, 18, 24, 30],
      [1, 2, 3, 4],
      [5, 4, 3, 2],
      [8, 9, 10, 11],
      [12, 11, 10, 9],
      [15, 16, 17, 18],
      [19, 18, 17, 16],
      [22, 23, 24, 25],
      [26, 25, 24, 23],
      [29, 30, 31, 32],
      [33, 32, 31, 30],
      [36, 37, 38, 39],
      [40, 39, 38, 37],
      [7, 14, 21, 28],
      [8, 15, 22, 29],
      [9, 16, 23, 30],
      [10, 17, 24, 31],
      [11, 18, 25, 32],
      [12, 19, 26, 33],
      [13, 20, 27, 34]
    ]
  end
end
