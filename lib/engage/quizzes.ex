defmodule Engage.Quizzes do
  import Ecto.Query, warn: false
  alias Engage.Repo
  alias Engage.Challenges.Quiz.{Quiz, Question, Take, TakeAnswer}

  def get_all_quizzes() do
    Repo.all(Quiz)
    |> Repo.preload(questions: :answers)
  end

  def get_daily_quiz() do
    Repo.one(
      from q in Quiz,
        where: fragment("timezone('utc', now())::date = ?::date", q.utc_start_date)
    )
    |> Repo.preload(questions: :answers)
  end

  def get_all_questions(quiz_id) when is_integer(quiz_id) do
    Repo.all(from q in Question, where: q.quiz_id == ^quiz_id)
  end

  def get_take(user_id, quiz_id)
      when is_integer(user_id) and
             is_integer(quiz_id) do
    Repo.one(
      from t in Take,
        where:
          t.user_id == ^user_id and
            t.quiz_id == ^quiz_id
    )
    |> Repo.preload(:take_answers)
  end

  def start_quiz(user_id, quiz_id)
      when is_integer(user_id) and
             is_integer(quiz_id) do
    case get_take(user_id, quiz_id) do
      nil ->
        {:ok, take} =
          Repo.insert(%Take{
            user_id: user_id,
            quiz_id: quiz_id
          })

        take

      take ->
        take
    end
  end

  def get_take_answers(take_id) when is_integer(take_id) do
    Repo.all(from ta in TakeAnswer, where: ta.take_id == ^take_id)
  end

  def get_take_answers_status(take_id) when is_integer(take_id) do
    get_take_answers(take_id)
    |> Repo.preload([:answer])
    |> Enum.map(fn ta -> ta.answer.is_correct end)
  end

  def insert_take_answer(take_id, question_id, answer_id)
      when is_integer(take_id) and
             is_integer(question_id) and
             is_integer(answer_id) do
    Repo.insert(%TakeAnswer{
      take_id: take_id,
      question_id: question_id,
      answer_id: answer_id
    })
  end

  def get_score(user_id, quiz_id) do
    take = get_take(user_id, quiz_id)

    take_answers =
      Repo.all(from ta in TakeAnswer, where: ta.take_id == ^take.id)
      |> Repo.preload([:answer])

    Enum.count(Enum.filter(take_answers, fn ta -> ta.answer.is_correct end))
  end

  def update_take_score(%Take{} = take, score) when is_integer(score) do
    if take.is_finished do
      {:error, nil}
    else
      Repo.update(
        Take.score_changeset(
          take,
          %{score: score, is_finished: true}
        )
      )
    end
  end
end
