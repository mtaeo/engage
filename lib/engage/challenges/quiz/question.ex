defmodule Engage.Challenges.Quiz.Question do
  use Ecto.Schema
  alias Engage.Challenges.Quiz.{Quiz, Answer}

  schema "questions" do
    belongs_to :quiz, Quiz
    field :text, :string
    has_many :answers, Answer
    timestamps()
  end
end
