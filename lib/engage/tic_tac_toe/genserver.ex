defmodule Engage.TicTacToe.GenServer do
  use GenServer
  alias Engage.TicTacToe.Player
  alias Engage.TicTacToe.Coordinate
  alias Engage.TicTacToe.GameBoard

  def start_link(
        genserver_name,
        state \\ %{players: %{first: nil, second: nil}, board: %GameBoard{}}
      )
      when is_atom(genserver_name) do
    GenServer.start_link(
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

  def is_alive?(genserver_name) do
    GenServer.call(genserver_name, :is_alive)
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
        state.players.first == nil ->
          player = %Player{name: player_name, value: :x}
          put_in(state.players.first, player)

        state.players.second == nil ->
          player = %Player{name: player_name, value: :o}
          put_in(state.players.second, player)

        true ->
          state
      end

    # Phoenix.PubSub.broadcast(Engage.PubSub, Atom.to_string(state.genserver_name), state)
    {:reply, state.board, state}
  end

  def handle_call({:make_move, player, coordinate}, _from, state) do
    state =
      if is_players_turn?(state, player) and is_field_not_occupied?(state, coordinate) do
        state = put_in(state.board.state[coordinate], player.value)
        state = put_in(state.board.turn_number, state.board.turn_number + 1)

        IO.inspect("accept")

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

  defp is_field_not_occupied?(state, coordinate) do
    IO.inspect("check:")
    IO.inspect(state.board.state[coordinate] === nil)
    state.board.state[coordinate] === nil
  end
end
