defmodule Engage.Cosmetics do
  import Ecto.Query, warn: false
  alias Engage.Repo
  alias Engage.Users.User
  alias Engage.Cosmetics.{Cosmetic, UserCosmetic}

  def get_all_cosmetics do
    Repo.all(Cosmetic)
    |> Repo.preload([:game])
  end

  def get_cosmetic_by_id(id) when is_integer(id) do
    Repo.one(from c in Cosmetic, where: c.id == ^id)
  end

  def get_all_cosmetics_by_game_id(game_id) when is_integer(game_id) do
    Repo.all(from c in Cosmetic, where: c.game_id == ^game_id)
    |> Repo.preload([:game])
  end

  def get_all_cosmetics_by_application(application) when is_binary(application) do
    Repo.all(from c in Cosmetic, where: c.application == ^application)
    |> Repo.preload([:game])
  end
end
