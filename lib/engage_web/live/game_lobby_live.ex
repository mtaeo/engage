defmodule EngageWeb.GameLobbyLive do
  use Phoenix.LiveView, layout: {EngageWeb.LayoutView, "live.html"}
  import EngageWeb.LiveHelpers
  alias Engage.Games
  alias Engage.Games.{TicTacToe, Memory}
  alias EngageWeb.Router.Helpers, as: Routes

  def mount(_params, session, socket) do
    socket =
      live_auth_check(socket, session, fn socket, user ->
        live_template_assigns(socket, user)
      end)

    {:ok, socket}
  end

  def handle_params(%{"game" => game_name, "code" => game_code}, _url, socket) do
    socket =
      case Games.get_game_by_name(game_name) do
        nil ->
          push_redirect(socket, to: Routes.game_list_path(socket, :index))

        game ->
          assign(socket,
            game: game,
            game_code: game_code
          )
      end

    {:noreply, socket}
  end

  def handle_event("start-game", _, socket) do
    {:noreply, socket}
  end
end
