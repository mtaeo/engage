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

  def handle_event("open-game", %{"game-name" => game_name}, socket) do
    {:noreply, push_redirect(socket, to: "/game-info/#{game_name}")}
  end
end
