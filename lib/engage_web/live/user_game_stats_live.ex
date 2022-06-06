defmodule EngageWeb.UserGameStatsLive do
  use Phoenix.LiveView, layout: {EngageWeb.LayoutView, "live.html"}
  import EngageWeb.LiveHelpers
  alias EngageWeb.Router.Helpers, as: Routes

  def mount(_params, session, socket) do
    socket =
      live_auth_check(socket, session, fn socket, user ->
        live_template_assigns(socket, user)
        |> assign(user: user)
      end)

    {:ok, socket}
  end
end
