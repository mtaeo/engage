defmodule Engage.Cosmetics.UserCosmetic do
  use Ecto.Schema
  import Ecto.Changeset
  alias Engage.Users.User
  alias Engage.Cosmetics.Cosmetic

  schema "users_cosmetics" do
    belongs_to :cosmetic, Cosmetic
    belongs_to :user, User
    field :is_equipped, :boolean, default: false
  end

  def equip_cosmetic_changeset(user_cosmetic, attrs, _opts \\ []) do
    user_cosmetic
    |> cast(attrs, [:is_equipped])
  end
end
