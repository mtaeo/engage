defmodule EngageWeb.GameListLive do
  use Phoenix.LiveView, layout: {EngageWeb.LayoutView, "live.html"}
  alias Engage.Games

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_event("tic-tac-toe", _, socket) do
    {:noreply, push_redirect(socket, to: "/game-info/tic-tac-toe")}
  end
end
