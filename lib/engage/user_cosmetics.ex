defmodule Engage.UserCosmetics do
  import Ecto.Query, warn: false
  alias Engage.Repo
  alias Engage.Cosmetics.UserCosmetic

  def get_all_user_cosmetics_for_user_id(user_id) when is_integer(user_id) do
    Repo.all(from uc in UserCosmetic, where: uc.user_id == ^user_id)
    |> Repo.preload([:user, cosmetic: :game])
  end

  def get_all_user_cosmetics_for_user_id_and_game_id(user_id, game_id)
      when is_integer(user_id) and
             is_integer(game_id) do
    Repo.all(from uc in UserCosmetic, where: uc.user_id == ^user_id and uc.game_id == ^game_id)
    |> Repo.preload([:user, cosmetic: :game])
  end

  def get_all_user_cosmetics_for_user_id_and_game_id(user_id, nil) do
    Repo.all(from uc in UserCosmetic, where: uc.user_id == ^user_id and is_nil(uc.game_id))
    |> Repo.preload([:user, cosmetic: :game])
  end

end
