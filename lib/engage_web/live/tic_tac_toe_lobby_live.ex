defmodule EngageWeb.TicTacToeLobbyLive do
  use EngageWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_event("join-game", %{"game_id" => game_id}, socket) do
    genserver_name = String.to_atom(game_id)

    if Process.whereis(genserver_name) do
      route = "/games/tic-tac-toe/#{game_id}"
      {:noreply, push_redirect(socket, to: route)}
    else
      # TODO: Let user know that an active game doesn't exist
      {:noreply, socket}
    end
  end

  def handle_event("create-game", _, socket) do
    # TODO: Generate random 4 character long letter + number combination
    game_id = "12wq"
    route = "/games/tic-tac-toe/#{game_id}"
    {:noreply, push_redirect(socket, to: route)}
  end
end
