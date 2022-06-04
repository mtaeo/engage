defmodule Engage.UserCosmetics do
  import Ecto.Query, warn: false
  alias Engage.Repo
  alias Engage.Users.User
  alias Engage.Cosmetics.{Cosmetic, UserCosmetic}

  def get_all_user_cosmetics_for_user_id(user_id) when is_integer(user_id) do
    Repo.all(from uc in UserCosmetic, where: uc.user_id == ^user_id)
    |> Repo.preload(:cosmetic)
  end

  def get_all_user_cosmetics_for_user_id_and_game_id(user_id, game_id)
      when is_integer(user_id) and
             is_integer(game_id) do
    Repo.all(from uc in UserCosmetic, where: uc.user_id == ^user_id)
    |> Repo.preload(:cosmetic)
    |> Enum.filter(fn uc -> uc.cosmetic.game_id == game_id end)
  end

  def get_all_user_cosmetics_for_user_id_and_game_id(user_id, nil) do
    Repo.all(from uc in UserCosmetic, where: uc.user_id == ^user_id)
    |> Repo.preload(:cosmetic)
    |> Enum.filter(fn uc -> is_nil(uc.cosmetic.game_id) end)
  end

  def get_all_equipped_user_cosmetics_for_user_id_and_game_id(user_id, game_id) do
    get_all_user_cosmetics_for_user_id_and_game_id(user_id, game_id)
    |> Enum.filter(fn uc -> uc.is_equipped end)
  end

  def purchase_cosmetic(user_id, cosmetic_id)
      when is_integer(user_id) and
             is_integer(cosmetic_id) do
    user = Repo.one(from u in User, where: u.id == ^user_id)
    cosmetic = Repo.one(from c in Cosmetic, where: c.id == ^cosmetic_id)

    if user_owns_cosmetic?(user_id, cosmetic_id) do
      {:error, nil}
    else
      changeset =
        User.purchase_cosmetic_changeset(
          user,
          %{coins: user.coins - cosmetic.price}
        )

      if changeset.valid? do
        Repo.transaction(fn ->
          Repo.update(changeset)

          Repo.insert(%UserCosmetic{
            user_id: user_id,
            cosmetic_id: cosmetic_id
          })
        end)
      else
        {:error, changeset}
      end
    end
  end

  def equip_cosmetic(user_id, cosmetic_id) do
    cosmetic = Repo.one(from c in Cosmetic, where: c.id == ^cosmetic_id)

    user_cosmetic =
      Repo.one(
        from uc in UserCosmetic, where: uc.user_id == ^user_id and uc.cosmetic_id == ^cosmetic_id
      )

    uc_query =
      from uc in UserCosmetic,
        join: c in Cosmetic,
        on: uc.cosmetic_id == c.id,
        where:
          uc.user_id == ^user_id and
            c.exclusion_group == ^cosmetic.exclusion_group

    Repo.transaction(fn ->
      Repo.update_all(uc_query, set: [is_equipped: false])
      Repo.update(UserCosmetic.equip_cosmetic_changeset(user_cosmetic, %{is_equipped: true}))
    end)
  end

  def unequip_cosmetic(user_id, cosmetic_id) do
    user_cosmetic =
      Repo.one(
        from uc in UserCosmetic, where: uc.user_id == ^user_id and uc.cosmetic_id == ^cosmetic_id
      )

    Repo.update(UserCosmetic.equip_cosmetic_changeset(user_cosmetic, %{is_equipped: false}))
  end

  def user_owns_cosmetic?(user_id, cosmetic_id) do
    Repo.one(
      from uc in UserCosmetic, where: uc.user_id == ^user_id and uc.cosmetic_id == ^cosmetic_id
    ) !== nil
  end

  def user_equipped_cosmetic?(user_id, cosmetic_id) do
    user_cosmetic =
      Repo.one(
        from uc in UserCosmetic, where: uc.user_id == ^user_id and uc.cosmetic_id == ^cosmetic_id
      )

    user_cosmetic.is_equipped
  end
end
