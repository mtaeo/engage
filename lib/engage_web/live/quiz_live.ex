defmodule EngageWeb.QuizLive do
  use Phoenix.LiveView, layout: {EngageWeb.LayoutView, "live.html"}
  import EngageWeb.LiveHelpers
  alias Engage.Quizzes

  def mount(_params, session, socket) do
    socket =
      live_auth_check(socket, session, fn socket, user ->
        live_template_assigns(socket, user)
      end)

    {:ok,
     assign(socket,
      user: session["current_user"],
       quiz_started: false,
       quiz: Quizzes.get_daily_quiz
     )}
  end

  def handle_event("start-quiz", _, socket) do
    Quizzes.start_quiz(socket.assigns.user.id, socket.assigns.quiz.id)
    {:noreply, assign(socket, quiz_started: true)}
  end

  defp todays_date do
    today = DateTime.utc_now()
    Enum.join([today.day, today.month, today.year], ".")
  end
end
