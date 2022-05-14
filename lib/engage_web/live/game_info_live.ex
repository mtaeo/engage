defmodule EngageWeb.GameInfoLive do
  use Phoenix.LiveView, layout: {EngageWeb.LayoutView, "live.html"}
  alias EngageWeb.Router.Helpers, as: Routes
  alias Engage.Games

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"game" => game_name}, _url, socket) do
    {:noreply, assign(socket, game: Games.get_game_by_name(game_name))}
  end

  def handle_event("create-game", _, socket) do
    game_id = Engage.Helpers.CodeGenerator.generate(:four_alphanumeric_characters)
    route = "/games/#{socket.assigns.game.name}/#{game_id}"
    {:noreply, push_redirect(socket, to: route)}
  end
end
