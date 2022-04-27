defmodule EngageWeb.TicTacToeLobbyLive do
  use EngageWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_event("join-game", %{"game_id" => game_id}, socket) do
    route = "/games/tic-tac-toe/#{game_id}"
    {:noreply, push_redirect(socket, to: route)}
  end

  def handle_event("create-game", _, socket) do
    route = "/games/tic-tac-toe/1234"
    {:noreply, push_redirect(socket, to: route)}
  end
end
