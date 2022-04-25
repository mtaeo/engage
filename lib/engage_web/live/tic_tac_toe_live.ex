defmodule EngageWeb.TicTacToeLive do
  use EngageWeb, :live_view
  alias EngageWeb.TopNavigationComponent
  alias EngageWeb.SidebarNavigationComponent

  def mount(_params, _session, socket) do
    IO.inspect(socket)
    {:ok, socket}
  end
end
