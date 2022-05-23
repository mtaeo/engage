defmodule Engage.Cosmetics.UserCosmetic do
  use Ecto.Schema
  alias Engage.Users.User
  alias Engage.Cosmetics.Cosmetic

  schema "users_cosmetics" do
    belongs_to :cosmetic, Cosmetic
    belongs_to :user, User
  end
end
