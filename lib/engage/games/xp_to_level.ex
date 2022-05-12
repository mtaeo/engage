defmodule Engage.Games.XpToLevel do
  use Ecto.Schema

  schema "xp_to_level" do
    field :min_xp, :integer
    field :level, :integer
  end
end
