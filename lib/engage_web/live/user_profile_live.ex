defmodule EngageWeb.UserProfileLive do
  use Phoenix.LiveView, layout: {EngageWeb.LayoutView, "live.html"}
  
  def mount(%{"username" => username}, session, socket) do
    socket = assign(socket, username: username)
    {:ok, socket}
  end
end