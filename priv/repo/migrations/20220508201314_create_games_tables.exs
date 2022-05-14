defmodule Engage.Repo.Migrations.CreateGamesTables do
  use Ecto.Migration

  def change do
    create_game_type_query = "CREATE TYPE game_type AS ENUM ('singleplayer', 'multiplayer')"
    drop_game_type_query = "DROP TYPE game_type"
    execute(create_game_type_query, drop_game_type_query)

    create table(:games) do
      add :name, :string, null: false
      add :type, :game_type, null: false
      add :xp_multiplier, :decimal, null: false
    end

    create constraint("games", :name_must_not_be_empty, check: "name <> ''")
    create constraint("games", :xp_multiplier_must_be_positive, check: "xp_multiplier >= 0")

    create_game_outcome_query = "CREATE TYPE game_outcome AS ENUM ('won', 'lost', 'draw')"
    drop_game_outcome_query = "DROP TYPE game_outcome"
    execute(create_game_outcome_query, drop_game_outcome_query)

    create table(:game_events) do
      add :game_id, references(:games), null: false
      add :user_id, references(:users), null: false
      add :opponent_user_id, references(:users)
      add :outcome, :game_outcome, null: false
      timestamps(updated_at: false)
    end

    create_game_event_inserted_trigger_func = """
      CREATE FUNCTION game_event_inserted_trigger_func()
      RETURNS trigger
      AS $$
      DECLARE
        xp integer NOT NULL := 0;
        xp_multiplier integer NOT NULL := 1;
      BEGIN
        CASE NEW.outcome
          WHEN 'won' THEN
          xp := 5;
          WHEN 'lost' THEN
          xp := 1;
          WHEN 'draw' THEN
          xp := 2;
          ELSE
          xp := 0;
        END CASE;

        SELECT g.xp_multiplier FROM games g WHERE id = NEW.game_id INTO xp_multiplier;

        UPDATE users
        SET total_xp = total_xp + (xp * xp_multiplier)
        WHERE id = NEW.user_id;

        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
    """
    drop_game_event_inserted_trigger_func = "DROP FUNCTION IF EXISTS game_event_inserted_trigger_func"
    execute(create_game_event_inserted_trigger_func, drop_game_event_inserted_trigger_func)

    create_game_event_inserted_trigger = "CREATE TRIGGER game_event_inserted AFTER INSERT ON game_events FOR EACH ROW EXECUTE PROCEDURE game_event_inserted_trigger_func()"
    drop_game_event_inserted_trigger = "DROP TRIGGER IF EXISTS game_event_inserted ON game_events"
    execute(create_game_event_inserted_trigger, drop_game_event_inserted_trigger)
  end
end
