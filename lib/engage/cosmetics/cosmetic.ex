defmodule Engage.Cosmetics.Cosmetic do
  use Ecto.Schema
  import Ecto.Changeset
  alias Engage.Games.Game

  schema "cosmetics" do
    belongs_to :game, Game
    field :application, :string
    field :value, :string
  end

  def changeset(cosmetic, _attrs, _opts \\ []) do
    cosmetic
    |> validate_application()
    |> validate_value()
  end

  def validate_application(changeset) do
    changeset |> validate_required([:application])
  end

  def validate_value(changeset) do
    changeset |> validate_required([:value])
  end
end
