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

  defp game_list do
    [
      %{
        display_name: "Tic Tac Toe",
        name: "tic-tac-toe",
        description: "The classic pen-and-paper game for 2 players.",
        xp_multiplier: 3,
        image_path: "/images/tic_tac_toe.jpeg",
        shadow_color: "shadow-red-600",
        game_view: EngageWeb.TicTacToeLive
      },
      %{
        display_name: "Memory",
        name: "memory",
        description: "",
        xp_multiplier: 3,
        image_path: "/images/memory.jpeg",
        shadow_color: "shadow-cyan-500",
        game_view: nil
      }
    ]
  end
end
