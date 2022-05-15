defmodule EngageWeb.GameListLive do
  use Phoenix.LiveView, layout: {EngageWeb.LayoutView, "live.html"}
  alias Engage.Games
  import EngageWeb.LiveHelpers

  def mount(_params, session, socket) do
    socket =
      live_auth_check(socket, session, fn socket, user ->
        live_template_assigns(socket, user)
      end)

    {:ok, socket}
  end

  # TODO: Improve scalability by refactoring to use index of game card pressed

  def handle_event("tic-tac-toe", _, socket) do
    {:noreply, push_redirect(socket, to: "/game-info/tic-tac-toe")}
  end

  def handle_event("memory", _, socket) do
    {:noreply, push_redirect(socket, to: "/game-info/memory")}
  end
end
