defmodule EngageWeb.JoinGameLive do
  use Phoenix.LiveView, layout: {EngageWeb.LayoutView, "live.html"}
  import EngageWeb.LiveHelpers

  def mount(_params, session, socket) do
    socket =
      live_auth_check(socket, session, fn socket, user ->
        live_template_assigns(socket, user)
      end)

    {:ok, assign(socket, code: "", error: nil)}
  end

  def handle_event("update", %{"code" => code}, socket) do
    socket = assign(socket, code: code)
    {:noreply, socket}
  end

  def handle_event("join", %{"code" => code}, socket) do
    if Process.whereis(String.to_atom(code)) do
      state = :sys.get_state(String.to_atom(code))

      route = if state.game_started? do
        "/games/#{state.game_name}/#{code}"
      else
        "/game-lobby/#{state.game_name}/#{code}"
      end

      {:noreply, push_redirect(socket, to: route)}
    else
      {:noreply, assign(socket, error: "Invalid game code!")}
    end
  end
end
