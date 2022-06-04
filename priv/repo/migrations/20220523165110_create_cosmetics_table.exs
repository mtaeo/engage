defmodule Engage.Repo.Migrations.CreateCosmeticsTable do
  use Ecto.Migration

  def change do

    create_cosmetics_category_query = "CREATE TYPE cosmetic_category AS ENUM ('game_item', 'game_bg', 'profile')"
    drop_cosmetics_category_query = "DROP TYPE cosmetic_category"
    execute(create_cosmetics_category_query, drop_cosmetics_category_query)

    create table(:cosmetics) do
      add :name, :citext, null: false
      add :display_name, :string, null: false
      add :category, :cosmetic_category, null: false
      add :game_id, references(:games)
      add :price, :integer, null: false
      add :exclusion_group, :citext
      add :data, :citext, null: false
    end

    create constraint("cosmetics", :exclusion_group_must_not_be_empty, check: "exclusion_group <> ''")
    create constraint("cosmetics", :data_must_not_be_empty, check: "data <> ''")
    create constraint("cosmetics", :price_must_be_positive, check: "price >= 0")
  end
end
