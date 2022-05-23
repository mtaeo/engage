defmodule Engage.Repo.Migrations.CreateUsersCosmeticsTable do
  use Ecto.Migration

  def change do
    create table(:users_cosmetics) do
      add :user_id, references(:users), null: false
      add :cosmetic_id, references(:cosmetics), null: false
    end
  end
end
