defmodule Engage.Challenges.Quiz.Take do
  use Ecto.Schema
  alias Engage.Users.User
  alias Engage.Challenges.Quiz.{Quiz, TakeAnswer}

  schema "takes" do
    belongs_to :user, User
    belongs_to :quiz, Quiz
    field :score, :integer, default: 0
    has_many :take_answers, TakeAnswer
    timestamps(updated_at: false)
  end
end
