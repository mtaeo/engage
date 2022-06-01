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
      timestamps(updated_at: false)
    end

    create table(:take_answers) do
      add :take_id, references(:takes)
      add :question_id, references(:questions)
      add :answer_id, references(:answers)
      timestamps(updated_at: false)
    end

  end
end
