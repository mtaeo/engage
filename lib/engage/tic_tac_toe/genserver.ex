defmodule Engage.TicTacToe.GenServer do
  use GenServer
  alias Engage.TicTacToe.Player
  alias Engage.TicTacToe.Coordinate
  alias Engage.TicTacToe.GameBoard

  def start_link(state \\ %{players: %{first: nil, second: nil}, board: %GameBoard{}}) do
    GenServer.start_link(
      __MODULE__,
      state,
      name: :test
      # name: Module.concat(__MODULE__, "test")
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
        state.players.first == nil ->
          player = %Player{name: player_name, value: :x}
          put_in(state.players.first, player)

        state.players.second == nil ->
          player = %Player{name: player_name, value: :o}
          put_in(state.players.second, player)

        true ->
          state
      end

    # Phoenix.PubSub.broadcast(Engage.PubSub, "test", state)
    {:reply, state, state}
  end

  def handle_call({:make_move, player, coordinate}, _from, state) do
    state = put_in(state.board.state[coordinate], player.value)
    Phoenix.PubSub.broadcast(Engage.PubSub, "test", state.board)
    {:reply, state, state}
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
end
