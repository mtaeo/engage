defmodule Engage.Games.GameEvent do
  use Ecto.Schema
  import Ecto.Changeset
  alias Engage.Games.Game
  alias Engage.Users.User

  schema "game_events" do
    field :outcome, Ecto.Enum, values: [:won, :lost, :draw]
    timestamps(updated_at: false)
    belongs_to :game, Game
    belongs_to :user, User, foreign_key: :user_id
    belongs_to :opponent_user, User, foreign_key: :opponent_user_id
  end

  def changeset(game_event, _attrs, _opts \\ []) do
    game_event
    |> validate_game_id()
    |> validate_user_id()
  end

  defp validate_game_id(changeset) do
    changeset |> validate_required([:game_id])
  end

  defp validate_user_id(changeset) do
    changeset |> validate_required([:user_id])
  end
end
