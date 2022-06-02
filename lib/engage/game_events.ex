defmodule Engage.GameEvents do
  import Ecto.Query, warn: false
  alias Engage.Repo
  alias Engage.Games.{GameEvent}

  def get_game_event_by_id(game_event_id) do
    Repo.get_by(GameEvent, id: game_event_id)
    |> Repo.preload([:game, :user])
  end

  def insert_game_event(%GameEvent{} = attrs) do
    attrs
    |> Repo.insert()
  end
end
