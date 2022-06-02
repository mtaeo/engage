defmodule EngageWeb.QuizLive do
  use Phoenix.LiveView, layout: {EngageWeb.LayoutView, "live.html"}
  import EngageWeb.LiveHelpers
  alias Engage.Quizzes
  alias Engage.Challenges.Quiz.Answer

  def mount(_params, session, socket) do
    socket =
      live_auth_check(socket, session, fn socket, user ->
        live_template_assigns(socket, user)
      end)

    user = session["current_user"]
    quiz = Quizzes.get_daily_quiz()
    take = Quizzes.get_take(user.id, quiz.id)
    initial_take_answers = if take, do: Quizzes.get_take_answers(take.id)
    question_index = if initial_take_answers, do: Enum.count(initial_take_answers), else: 0

    {:ok,
     assign(socket,
       user: user,
       quiz: quiz,
       take: take,
       initial_take_answers: initial_take_answers,
       question_index: question_index,
       chosen_answer_id: nil
     )}
  end

  def handle_info(:next_question, socket) do
    socket =
      socket
      |> update(:question_index, fn qi -> qi + 1 end)
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

    {:noreply,
     assign(socket,
       chosen_answer_id: answer_id
     )}
  end

  defp todays_date do
    today = DateTime.utc_now()
    Enum.join([today.day, today.month, today.year], ".")
  end

  defp chosen_answer_indicator_classes(%Answer{} = answer, chosen_answer_id) do
    if is_nil(chosen_answer_id) do
      ""
    else
      if answer.is_correct do
        "bg-green-600"
      else
        if answer.id == chosen_answer_id do
          "bg-red-600"
        end
      end
    end
  end
end
