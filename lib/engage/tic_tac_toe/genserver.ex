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

  @spec get_player_by_name(atom | pid | {atom, any} | {:via, atom, any}, any) :: any
  def get_player_by_name(genserver_name, player_name) do
    GenServer.call(genserver_name, {:get_player_by_name, player_name})
  end

  def view(genserver_name) do
    GenServer.call(genserver_name, :view)
  end

  def is_alive?(genserver_name) do
    GenServer.call(genserver_name, :is_alive)
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
    {:reply, state, state}
  end

  def handle_call({:make_move, player, coordinate}, _from, state) do
    state = put_in(state.board.state[coordinate], player.value)
    Phoenix.PubSub.broadcast(Engage.PubSub, Atom.to_string(state.genserver_name), state.board)
    {:reply, state, state}
  end

  def handle_call({:get_player_by_name, player_name}, _from, state) do
    {_, player} = Enum.find(state.players, fn {_, v} -> v.name === player_name end)
    {:reply, player, state}
  end

  def handle_call(:view, _from, state) do
    {:reply, state.board, state}
  end

  def handle_call(:is_alive, _from, state) do
    {:reply, true, state}
  end

  def init(state) do
    {:ok, state}
  end
end
