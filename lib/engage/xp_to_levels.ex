defmodule Engage.XpToLevels do
  import Ecto.Query, warn: false
  alias Engage.Repo
  alias Engage.Games.{XpToLevel}

  def get_all_xp_to_levels() do
    Repo.all(XpToLevel)
  end

  def calculate_level_for_xp(total_xp) do
    query = from x in XpToLevel, where: ^total_xp - x.min_xp >= 0, select: max(x.level)

    query
    |> Repo.one()
  end

  def calculate_upper_xp_for_level(level) do
    query = from x in XpToLevel, where: ^(level + 1) == x.level, select: x.min_xp

    query
    |> Repo.one()
  end

  def calculate_lower_xp_for_level(level) do
    query = from x in XpToLevel, where: ^level == x.level, select: x.min_xp

    query
    |> Repo.one()
  end
end
