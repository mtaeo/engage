defmodule EngageWeb.UserProfileProxyLive do
  use Phoenix.LiveView, layout: {EngageWeb.LayoutView, "live.html"}
  alias EngageWeb.Router.Helpers, as: Routes

  def mount(_params, session, socket) do
    {:ok, assign(socket, username: session["current_user"].username)}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, push_redirect(socket, to: Routes.user_profile_path(socket, :index, socket.assigns.username))}
  end

  def render(assigns) do
    ~H"""

    """
  end
end
