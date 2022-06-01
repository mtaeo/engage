defmodule Engage.Challenges.Quiz.TakeAnswer do
  use Ecto.Schema
  alias Engage.Challenges.Quiz.{Take, Question, Answer}

  schema "take_answers" do
    belongs_to :takes, Take
    belongs_to :questions, Question
    belongs_to :answers, Answer
    timestamps(updated_at: false)
  end
end
