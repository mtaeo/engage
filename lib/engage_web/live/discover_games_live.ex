defmodule EngageWeb.DiscoverGamesLive do
  use Phoenix.LiveView, layout: {EngageWeb.LayoutView, "live.html"}
  alias Engage.Games
  import EngageWeb.LiveHelpers

  def mount(_params, session, socket) do
    socket =
      live_auth_check(socket, session, fn socket, user ->
        live_template_assigns(socket, user)
      end)

    {:ok, assign(socket, games: Games.get_all_games())}
  end

  def handle_event("select-emotion", %{"emotion" => emotion}, socket) do
    emotion = String.to_atom(emotion)
    {:noreply, push_redirect(socket, to: route_for_emotion(socket.assigns.games, emotion))}
  end

  defp route_for_emotion(games, emotion) when is_atom(emotion) do
    selected_game = Enum.random(Enum.filter(games, fn g -> g.emotion == emotion end))
    "/game-info/#{selected_game.name}"
  end

  defp emotions() do
    [:angry, :scared, :happy, :sad]
  end
end
