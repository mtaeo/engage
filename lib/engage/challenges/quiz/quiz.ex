defmodule Engage.Challenges.Quiz.Quiz do
  use Ecto.Schema
  alias Engage.Challenges.Quiz.Question

  schema "quizzes" do
    field :display_name, :string
    field :utc_start_date, :utc_datetime
    field :category, :string
    field :seconds_per_question, :integer
    has_many :questions, Question
    timestamps()
  end
end
