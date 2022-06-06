defmodule Engage.Challenges.Quiz.Answer do
  use Ecto.Schema
  alias Engage.Challenges.Quiz.Question

  schema "answers" do
    belongs_to :question, Question
    field :text, :string
    field :is_correct, :boolean, default: false
    timestamps()
  end
end
