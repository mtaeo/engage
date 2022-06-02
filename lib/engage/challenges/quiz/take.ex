defmodule Engage.Challenges.Quiz.Take do
  use Ecto.Schema
  import Ecto.Changeset
  alias Engage.Users.User
  alias Engage.Challenges.Quiz.{Quiz, TakeAnswer}

  schema "takes" do
    belongs_to :user, User
    belongs_to :quiz, Quiz
    field :score, :integer, default: 0
    field :is_finished, :boolean, default: false
    has_many :take_answers, TakeAnswer
    timestamps(updated_at: false)
  end

  def score_changeset(take, attrs, _opts \\ []) do
    take
    |> cast(attrs, [:score, :is_finished])
    |> validate_score()
    |> validate_finished()
  end

  defp validate_score(changeset) do
    changeset
    |> validate_required([:score])
    |> validate_number(:score, greater_than_or_equal_to: 0)
  end

  defp validate_finished(changeset) do
    changeset
    |> validate_acceptance(:is_finished)
  end
end
