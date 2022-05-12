defmodule Engage.Games.Game do
  use Ecto.Schema

  schema "games" do
    field :name, :string
    field :type, Ecto.Enum, values: [:singleplayer, :multiplayer]
    field :xp_multiplier, :integer, default: 1
  end
end
