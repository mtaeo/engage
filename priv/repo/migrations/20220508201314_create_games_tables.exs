defmodule Engage.Repo.Migrations.CreateGamesTables do
  use Ecto.Migration

  def change do
    create_game_type_query = "CREATE TYPE game_type AS ENUM ('singleplayer', 'multiplayer')"
    drop_game_type_query = "DROP TYPE game_type"
    execute(create_game_type_query, drop_game_type_query)

    create table(:games) do
      add :name, :string, null: false
      add :type, :game_type, null: false
      add :xp_multiplier, :integer, null: false
    end

    create constraint("games", :name_must_not_be_empty, check: "name <> ''")
    create constraint("games", :xp_multiplier_must_be_positive, check: "xp_multiplier >= 0")

    create_game_outcome_query = "CREATE TYPE game_outcome AS ENUM ('won', 'lost', 'draw')"
    drop_game_outcome_query = "DROP TYPE game_outcome"
    execute(create_game_outcome_query, drop_game_outcome_query)

    create table(:game_events) do
      add :game_id, references(:games), null: false
      add :user_id, references(:users), null: false
      add :outcome, :game_outcome, null: false
      timestamps(updated_at: false)
    end

  end
end
