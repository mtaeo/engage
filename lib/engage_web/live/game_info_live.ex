defmodule EngageWeb.GameInfoLive do
  use Phoenix.LiveView, layout: {EngageWeb.LayoutView, "live.html"}
  alias EngageWeb.Router.Helpers, as: Routes
  alias Engage.Games
  alias Engage.Helpers.CodeGenerator
  import EngageWeb.LiveHelpers

  def mount(_params, session, socket) do
    socket =
      live_auth_check(socket, session, fn socket, user ->
        live_template_assigns(socket, user)
      end)

    {:ok, socket}
  end

  def handle_params(%{"game" => game_name}, _url, socket) do
    socket =
      case Games.get_game_by_name(game_name) do
        nil ->
          push_redirect(socket, to: Routes.game_list_path(socket, :index))

        game ->
          assign(socket, game: game)
      end

    {:noreply, socket}
  end

  def handle_event("create-game", _, socket) do
    game_id = CodeGenerator.generate(:four_alphanumeric_characters)
    route = "/games/#{socket.assigns.game.name}/#{game_id}"
    {:noreply, push_redirect(socket, to: route)}
  end
end
