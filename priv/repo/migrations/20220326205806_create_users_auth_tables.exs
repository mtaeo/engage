defmodule Engage.Repo.Migrations.CreateUsersAuthTables do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create_user_role_query = "CREATE TYPE user_role AS ENUM ('user', 'moderator', 'admin')"
    drop_user_role_query = "DROP TYPE user_role"
    execute(create_user_role_query, drop_user_role_query)

    create_gravatar_style_query = "CREATE TYPE gravatar_style AS ENUM ('mp', 'identicon', 'monsterid', 'wavatar', 'retro', 'robohash')"
    drop_gravatar_style_query = "DROP TYPE gravatar_style"
    execute(create_gravatar_style_query, drop_gravatar_style_query)

    create table(:users) do
      add :username, :citext, null: false
      add :email, :citext, null: false
      add :bio, :text
      add :total_xp, :int, null: false, default: 0
      add :coins, :int, null: false, default: 0
      add :role, :user_role, null: false
      add :gravatar_style, :gravatar_style, null: false
      add :hashed_password, :string, null: false
      add :confirmed_at, :naive_datetime
      timestamps()
    end

    create constraint("users", :total_xp_must_be_positive, check: "total_xp >= 0")
    create constraint("users", :coins_must_be_positive, check: "coins >= 0")
    create unique_index(:users, [:username])

    create table(:users_tokens) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      timestamps(updated_at: false)
    end

    create index(:users_tokens, [:user_id])
    create unique_index(:users_tokens, [:context, :token])
  end
end
