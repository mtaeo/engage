defmodule Engage.Repo.Migrations.CreateDailyChallengeQuizTable do
  use Ecto.Migration

  def change do
    create table(:quizzes) do
      add :display_name, :string, null: false
      add :utc_start_date, :utc_datetime, null: false
      add :category, :string, null: false
      add :seconds_per_question, :int
      timestamps()
    end

    create constraint("quizzes", :seconds_per_question_must_be_positive,
             check: "seconds_per_question >= 0"
           )

    create table(:questions) do
      add :quiz_id, references(:quizzes)
      add :text, :string, null: false
      timestamps()
    end

    create table(:answers) do
      add :question_id, references(:questions)
      add :text, :string, null: false
      add :is_correct, :boolean, null: false
      timestamps()
    end

    create table(:takes) do
      add :user_id, references(:users)
      add :quiz_id, references(:quizzes)
      add :score, :int
      add :is_finished, :boolean, null: false
      timestamps(updated_at: false)
    end

    create constraint("takes", :score_must_be_positive, check: "score >= 0")

    create_take_updated_trigger_func = """
      CREATE FUNCTION take_updated_trigger_func()
      RETURNS trigger
      AS $$
      DECLARE
        xp integer NOT NULL := 10;
        won_coins integer NOT NULL := 10;
      BEGIN

        UPDATE users
        SET total_xp = total_xp + (xp * NEW.score),
            coins = coins + (won_coins * NEW.score)
        WHERE id = NEW.user_id;

        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
    """

    drop_take_updated_trigger_func = "DROP FUNCTION IF EXISTS take_updated_trigger_func"
    execute(create_take_updated_trigger_func, drop_take_updated_trigger_func)

    create_take_updated_trigger =
      "CREATE TRIGGER take_updated AFTER UPDATE ON takes FOR EACH ROW EXECUTE PROCEDURE take_updated_trigger_func()"

    drop_take_updated_trigger = "DROP TRIGGER IF EXISTS take_updated ON takes"
    execute(create_take_updated_trigger, drop_take_updated_trigger)

    create table(:take_answers) do
      add :take_id, references(:takes)
      add :question_id, references(:questions)
      add :answer_id, references(:answers)
      timestamps(updated_at: false)
    end
  end
end
