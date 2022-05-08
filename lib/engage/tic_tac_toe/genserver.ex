defmodule Engage.TicTacToe.GenServer do
  use GenServer
  alias Engage.TicTacToe.Player
  alias Engage.TicTacToe.Coordinate
  alias Engage.TicTacToe.GameBoard

  def start(
        genserver_name,
        state \\ %{players: %{first: nil, second: nil}, board: %GameBoard{}}
      )
      when is_atom(genserver_name) do
    GenServer.start(
      __MODULE__,
      Map.put(state, :genserver_name, genserver_name),
      name: genserver_name
    )
  end

  def add_player(genserver_name, player_name) do
    GenServer.call(genserver_name, {:add_player, player_name})
  end

  def get_player_by_name(genserver_name, player_name) do
    GenServer.call(genserver_name, {:get_player_by_name, player_name})
  end

  def view(genserver_name) do
    GenServer.call(genserver_name, :view)
  end

  def make_move(genserver_name, {%Player{} = player, %Coordinate{} = coordinate}) do
    GenServer.call(genserver_name, {:make_move, player, coordinate})
  end

  # Server API

  def handle_call({:add_player, player_name}, _from, state) do
    state =
      cond do
        state.players.first === nil ->
          player = %Player{name: player_name, value: :x}
          put_in(state.players.first, player)

        state.players.second === nil and state.players.first.name !== player_name ->
          player = %Player{name: player_name, value: :o}
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

  def handle_call({:make_move, player, coordinate}, _from, state) do
    state =
      if is_valid_turn?(state, player, coordinate) do
        state = put_in(state.board.state[coordinate], player.value)
        state = put_in(state.board.turn_number, state.board.turn_number + 1)
        state = put_in(state.board.outcome, check_for_winner(state))

        Phoenix.PubSub.broadcast(
          Engage.PubSub,
          Atom.to_string(state.genserver_name),
          state.board
        )

        state
      else
        state
      end

    {:reply, state.board, state}
  end

  def handle_call({:get_player_by_name, player_name}, _from, state) do
    {_, player} = Enum.find(state.players, fn {_, v} -> v.name === player_name end)
    {:reply, player, state}
  end

  def handle_call(:view, _from, state) do
    {:reply, state.board, state}
  end

  def init(state) do
    {:ok, state}
  end

  defp is_valid_turn?(state, player, coordinate) do
    not is_game_over?(state) and
      have_all_players_joined?(state) and
      is_players_turn?(state, player) and
      is_field_not_occupied?(state, coordinate)
  end

  defp have_all_players_joined?(state) do
    state.players.first !== nil and state.players.second !== nil
  end

  defp is_players_turn?(state, player) do
    player === get_player(state, state.board.turn_number)
  end

  defp get_player(state, turn_number) do
    if rem(turn_number, 2) === 0 do
      state.players.first
    else
      state.players.second
    end
  end

  defp is_game_over?(state) do
    check_for_winner(state) !== nil
  end

  defp is_board_full?(state) do
    Enum.all?(state.board.state, fn {_, v} -> v !== nil end)
  end

  defp check_for_winner(state) do
    cond do
      not is_nil(check_for_winner(:rows, state)) ->
        check_for_winner(:rows, state)

      not is_nil(check_for_winner(:cols, state)) ->
        check_for_winner(:cols, state)

      not is_nil(check_for_winner(:primary_diagonal, state)) ->
        check_for_winner(:primary_diagonal, state)

      not is_nil(check_for_winner(:secondary_diagonal, state)) ->
        check_for_winner(:secondary_diagonal, state)

      is_board_full?(state) ->
        :draw

      true ->
        nil
    end
  end

  defp check_for_winner(:rows, state) do
    results =
      for i <- 0..2 do
        sum =
          for j <- 0..2, reduce: 0 do
            acc -> acc + get_value(state.board.state[%Coordinate{x: i, y: j}])
          end

        decide_winner(sum)
      end

    Enum.find(results, fn e -> e !== nil end)
  end

  defp check_for_winner(:cols, state) do
    results =
      for i <- 0..2 do
        sum =
          for j <- 0..2, reduce: 0 do
            acc -> acc + get_value(state.board.state[%Coordinate{x: j, y: i}])
          end

        decide_winner(sum)
      end

    Enum.find(results, fn e -> e !== nil end)
  end

  defp check_for_winner(:primary_diagonal, state) do
    sum =
      for i <- 0..2, reduce: 0 do
        acc -> acc + get_value(state.board.state[%Coordinate{x: i, y: i}])
      end

    decide_winner(sum)
  end

  # TODO: Refactor
  defp check_for_winner(:secondary_diagonal, state) do
    sum = 0
    sum = sum + get_value(state.board.state[%Coordinate{x: 0, y: 2}])
    sum = sum + get_value(state.board.state[%Coordinate{x: 1, y: 1}])
    sum = sum + get_value(state.board.state[%Coordinate{x: 2, y: 0}])

    decide_winner(sum)
  end

  defp decide_winner(sum) do
    x_sum_winner = 3
    o_sum_winner = -3

    case sum do
      ^x_sum_winner ->
        :x

      ^o_sum_winner ->
        :o

      _ ->
        nil
    end
  end

  defp get_value(nil) do
    0
  end

  defp get_value(:x) do
    1
  end

  defp get_value(:o) do
    -1
  end

  defp is_field_not_occupied?(state, coordinate) do
    state.board.state[coordinate] === nil
  end
end
