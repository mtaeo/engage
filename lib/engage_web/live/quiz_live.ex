defmodule EngageWeb.QuizLive do
  use Phoenix.LiveView, layout: {EngageWeb.LayoutView, "live.html"}
  import EngageWeb.LiveHelpers
  alias Engage.Quizzes
  alias Engage.Challenges.Quiz.Answer

  def mount(_params, session, socket) do
    socket =
      live_auth_check(socket, session, fn socket, user ->
        socket
        |> live_template_assigns(user)
        |> setup(user)
      end)

    {:ok, socket}
  end

  def handle_info(:next_question, socket) do
    socket =
      socket
      |> update(:question_index, &(&1 + 1))
      |> assign(chosen_answer_id: nil)

    {:noreply, socket}
  end

  def handle_event("start-quiz", _, socket) do
    take = Quizzes.start_quiz(socket.assigns.user.id, socket.assigns.quiz.id)

    {:noreply,
     assign(socket,
       take: take
     )}
  end

  def handle_event("chose-answer", %{"answer-id" => answer_id}, socket) do
    answer_id = String.to_integer(answer_id)
    question = Enum.at(socket.assigns.quiz.questions, socket.assigns.question_index)
    Quizzes.insert_take_answer(socket.assigns.take.id, question.id, answer_id)

    :timer.send_after(2500, self(), :next_question)

    {:noreply, assign(socket, chosen_answer_id: answer_id)}
  end

  defp setup(socket, user) do
    quiz = Quizzes.get_daily_quiz()
    take = Quizzes.get_take(user.id, quiz.id)
    initial_take_answers = if take, do: Quizzes.get_take_answers(take.id)
    question_index = if initial_take_answers, do: Enum.count(initial_take_answers), else: 0

    assign(socket,
      user: user,
      quiz: quiz,
      take: take,
      initial_take_answers: initial_take_answers,
      question_index: question_index,
      chosen_answer_id: nil
    )
  end

  defp update_take_score(assigns, score)
       when is_map(assigns) and
              is_integer(score) do
    Quizzes.update_take_score(assigns.take, score)
  end

  defp current_view(quiz, take, question_index) do
    cond do
      quiz === nil -> :no_quiz_today
      take === nil -> :quiz_begin
      Enum.at(quiz.questions, question_index) === nil -> :quiz_over
      true -> :question
    end
  end

  defp answer_classes(%Answer{} = answer, chosen_answer_id) do
    correct? = answer.is_correct
    this? = answer.id === chosen_answer_id
    default = "border-theme-8 hover:border-theme-6"

    cond do
      chosen_answer_id === nil ->
        default

      this? and correct? ->
        "bg-green-500 border-green-500"

      this? and not correct? ->
        "bg-red-500 border-red-500"

      not this? and correct? ->
        "bg-green-500 border-green-500 animate-pulse-attention"

      true ->
        default
    end
  end

  defp todays_date do
    today = DateTime.utc_now()
    Enum.join([today.day, today.month, today.year], ".")
  end

  defp copy_results(answers) do
    emojis =
      for a <- answers, into: "" do
        if a, do: "🟩", else: "🟥"
      end

    content =
      """
      Engage Daily Quiz #{todays_date()}
      #{emojis} #{Enum.count(answers, & &1)}/#{length(answers)}
      #engage https://play-engage.com
      """
      |> String.replace("\n", "\\n")

    "window.util.clipboardInsert('#{content}')"
  end
end
