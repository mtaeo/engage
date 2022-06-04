defmodule Engage.Cosmetics.Cosmetic do
  use Ecto.Schema
  import Ecto.Changeset
  alias Engage.Games.Game

  schema "cosmetics" do
    field :name, :string
    field :display_name, :string
    field :category, Ecto.Enum, values: [:game_item, :game_bg, :profile]
    belongs_to :game, Game
    field :price, :integer
    field :exclusion_group, :string
    field :data, :string
  end

  def changeset(cosmetic, attrs, _opts \\ []) do
    cosmetic
    |> cast(attrs, [:name, :display_name, :game_id, :category, :exclusion_group, :data, :price])
    |> validate_required([:name, :display_name, :category, :exclusion_group, :data])
    |> validate_price()
  end

  def validate_price(changeset) do
    changeset
    |> validate_required([:price])
    |> validate_number(:price, [greater_than_or_equal_to: 0])
  end
end
