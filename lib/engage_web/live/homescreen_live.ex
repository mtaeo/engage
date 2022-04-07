defmodule EngageWeb.HomescreenLive do
  use Phoenix.LiveView
  alias EngageWeb.TopNavigationComponent
  alias EngageWeb.SidebarNavigationComponent

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
