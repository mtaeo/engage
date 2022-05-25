defmodule Engage.Cosmetics.Cosmetic do
  use Ecto.Schema
  import Ecto.Changeset
  alias Engage.Games.Game

  schema "cosmetics" do
    belongs_to :game, Game
    field :application, :string
    field :value, :string
    field :price, :integer
  end

  def changeset(cosmetic, attrs, _opts \\ []) do
    cosmetic
    |> cast(attrs, [:game_id, :application, :value, :price])
    |> validate_application()
    |> validate_value()
    |> validate_price()
  end

  def validate_application(changeset) do
    changeset |> validate_required([:application])
  end

  def validate_value(changeset) do
    changeset |> validate_required([:value])
  end

  def validate_price(changeset) do
    changeset
    |> validate_required([:price])
    |> validate_number(:price, [greater_than_or_equal_to: 0])
  end
end
