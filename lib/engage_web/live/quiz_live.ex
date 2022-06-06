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
      |> assign(chosen_answer_id: nil, is_user_input_allowed: true)

    {:noreply, socket}
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end

  def handle_event("start-quiz", _, socket) do
    take = Quizzes.start_quiz(socket.assigns.user.id, socket.assigns.quiz.id)

    {:noreply,
     assign(socket,
       take: take
     )}
  end

  def handle_event("chose-answer", %{"answer-id" => answer_id}, socket) do
    socket =
      if socket.assigns.is_user_input_allowed do
        answer_id = String.to_integer(answer_id)
        question = Enum.at(socket.assigns.quiz.questions, socket.assigns.question_index)
        Quizzes.insert_take_answer(socket.assigns.take.id, question.id, answer_id)

        :timer.send_after(2500, self(), :next_question)
        assign(socket, chosen_answer_id: answer_id, is_user_input_allowed: false)
      else
        socket
      end

    {:noreply, socket}
  end

  def handle_event("clipboard-insert", _, socket) do
    :timer.send_after(3500, :clear_flash)

    {:noreply,
     socket
     |> put_flash(:info, "Copied quiz results to clipboard.")}
  end

  defp setup(socket, user) do
    quiz = Quizzes.get_daily_quiz()

    quiz =
      if quiz,
        do:
          put_in(
            quiz.questions,
            Enum.map(quiz.questions, fn question ->
              put_in(question.answers, Enum.shuffle(question.answers))
            end)
          ),
        else: nil

    take = if quiz, do: Quizzes.get_take(user.id, quiz.id), else: nil
    initial_take_answers = if take, do: Quizzes.get_take_answers(take.id)
    question_index = if initial_take_answers, do: Enum.count(initial_take_answers), else: 0

    assign(socket,
      user: user,
      quiz: quiz,
      take: take,
      initial_take_answers: initial_take_answers,
      question_index: question_index,
      chosen_answer_id: nil,
      is_user_input_allowed: true
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
    content = generate_content(answers)
    "window.util.clipboardInsert('#{content}')"
  end

  defp generate_content(answers) do
    emojis =
      for a <- answers, into: "" do
        if a, do: "🟩", else: "🟥"
      end

    """
    Engage Daily Quiz #{todays_date()}
    #{emojis} #{Enum.count(answers, & &1)}/#{length(answers)}
    #engage https://www.play-engage.com
    """
    |> String.replace("\n", "\\n")
  end
end
