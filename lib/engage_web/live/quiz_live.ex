defmodule EngageWeb.QuizLive do
  use Phoenix.LiveView, layout: {EngageWeb.LayoutView, "live.html"}
  import EngageWeb.LiveHelpers

  def mount(_params, session, socket) do
    socket =
      live_auth_check(socket, session, fn socket, user ->
        live_template_assigns(socket, user)
      end)

    {:ok,
     assign(socket,
       quiz_started: false,
       quiz_title: "Quiz Title"
     )}
  end

  def handle_event("start-quiz", _, socket) do
    {:noreply, assign(socket, quiz_started: true)}
  end

  defp todays_date do
    today = DateTime.utc_now()
    Enum.join([today.day, today.month, today.year], ".")
  end
end
