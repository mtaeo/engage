defmodule Engage.TicTacToe.GenServer do
  use GenServer
  alias Engage.TicTacToe.Player
  alias Engage.TicTacToe.Coordinate
  alias Engage.TicTacToe.GameBoard

  def start_link(state \\ %{players: %{first: nil, second: nil}, board: %GameBoard{}}) do
    GenServer.start_link(
      __MODULE__,
      state,
      name: __MODULE__
      # name: Module.concat(__MODULE__, "test")
    )
  end

  def add_player(genserver_name, %Player{} = player) do
    GenServer.call(genserver_name, {:add_player, player})
  end

  def view(genserver_name) do
    GenServer.call(genserver_name, :view)
  end

  def make_move(genserver_name, {%Player{} = player, %Coordinate{} = coordinate}) do
    GenServer.call(genserver_name, {:make_move, player, coordinate})
  end

  # Server API

  def handle_call({:add_player, player}, _from, state) do
    state =
      cond do
        state.players.first == nil ->
          put_in(state.players.first, player)

        state.players.second == nil ->
          put_in(state.players.second, player)

        true ->
          state
      end

    {:reply, state, state}
  end

  def handle_call({:make_move, player, coordinate}, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:view, _from, state) do
    {:reply, state, state}
  end

  def init(state) do
    {:ok, state}
  end
end
