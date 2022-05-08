defmodule Engage.Repo.Migrations.CreateXpTables do
  use Ecto.Migration

  def change do
    create table(:xp_to_level) do
      add :min_xp, :integer, null: false
      add :level, :integer, null: false
    end

    create constraint("xp_to_level", :min_xp_must_be_positive, check: "min_xp >= 0")
    create constraint("xp_to_level", :level_must_be_greater_than_or_equal_to_1, check: "level >= 1")

    create table(:xp_events) do
      add :game_event_id, references(:game_events), null: false
      add :gained_xp, :int, null: false
    end

    create constraint("xp_events", :gained_xp_must_be_positive, check: "gained_xp >= 0")
  end
end
