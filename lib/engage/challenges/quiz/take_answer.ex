defmodule Engage.Challenges.Quiz.TakeAnswer do
  use Ecto.Schema
  alias Engage.Challenges.Quiz.{Take, Question, Answer}

  schema "take_answers" do
    belongs_to :take, Take
    belongs_to :question, Question
    belongs_to :answer, Answer
    timestamps(updated_at: false)
  end
end
