defmodule Engage.Games.Memory.Genserver do
  alias Engage.Games.Generic.Coordinate
  alias Engage.Games.Memory.GameBoard
  use GenServer

  @game_name "Memory"

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
        game_id: Engage.Games.get_game_by_name(@game_name).id
      }),
      name: genserver_name
    )
  end

  # Server API

  def init(state) do
    {:ok, state}
  end
end
