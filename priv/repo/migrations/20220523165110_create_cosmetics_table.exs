defmodule Engage.Repo.Migrations.CreateCosmeticsTable do
  use Ecto.Migration

  def change do
    create table(:cosmetics) do
      add :game_id, references(:games)
      add :application, :string, null: false
      add :value, :string, null: false
      add :price, :integer, null: false
    end

    create constraint("cosmetics", :application_must_not_be_empty, check: "application <> ''")
    create constraint("cosmetics", :value_must_not_be_empty, check: "value <> ''")
    create constraint("cosmetics", :price_must_be_positive, check: "price >= 0")
  end
end
