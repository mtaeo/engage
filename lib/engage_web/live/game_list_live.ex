defmodule EngageWeb.GameListLive do
  use Phoenix.LiveView, layout: {EngageWeb.LayoutView, "live.html"}

  def mount(_params, _session, socket) do
    {:ok, assign(socket, shouldShowModal: false)}
  end

  def handle_event("tic-tac-toe", _, socket) do
    {:noreply, push_redirect(socket, to: "/games/tic-tac-toe")}
  end

  defp game_list do
    [
      %{
        title: "Tic-Tac-Toe",
        image_path: "/images/tic_tac_toe.jpeg",
        shadow_color: "shadow-red-600"
      },
      %{
        title: "Memory",
        image_path: "/images/memory.jpeg",
        shadow_color: "shadow-cyan-500"
      }
    ]
  end
end
