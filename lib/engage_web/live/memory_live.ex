defmodule EngageWeb.MemoryLive do
  use Phoenix.LiveView, layout: {EngageWeb.LayoutView, "game.html"}

  def mount(_params, _session, socket) do
    {:ok, socket}
  end


end
