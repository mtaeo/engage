defmodule EngageWeb.JoinGameLive do
  use Phoenix.LiveView, layout: {EngageWeb.LayoutView, "live.html"}
  
  def mount(_params, _session, socket) do
    {:ok, assign(socket, code: "", error: nil)}
  end
  
  def handle_event("update", %{"code" => code}, socket) do
    socket = assign(socket, code: code)
    {:noreply, socket}
  end
  
  def handle_event("join", %{"code" => code}, socket) do
    if Process.whereis(String.to_atom(code)) do
      route = "/games/tic-tac-toe/#{code}"
      {:noreply, push_redirect(socket, to: route)}
    else
      {:noreply, assign(socket, error: "Invalid game code!")}
    end
  end
end