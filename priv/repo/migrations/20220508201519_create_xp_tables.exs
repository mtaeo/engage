defmodule Engage.Repo.Migrations.CreateXpTables do
  use Ecto.Migration

  def change do
    create table(:xp_to_level) do
      add :min_xp, :integer, null: false
      add :level, :integer, null: false
    end

    create constraint("xp_to_level", :min_xp_must_be_positive, check: "min_xp >= 0")
    create constraint("xp_to_level", :level_must_be_greater_than_or_equal_to_1, check: "level >= 1")
  end
end
