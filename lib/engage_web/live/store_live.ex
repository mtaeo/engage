defmodule EngageWeb.StoreLive do
  use Phoenix.LiveView, layout: {EngageWeb.LayoutView, "live.html"}
  import EngageWeb.LiveHelpers
  alias Engage.{Cosmetics, UserCosmetics}

  def mount(_params, session, socket) do
    socket =
      live_auth_check(socket, session, fn socket, user ->
        live_template_assigns(socket, user)
        |> assign(user: user)
      end)

      IO.inspect(Cosmetics.get_all_cosmetics, label: "All cosmetics")
      IO.inspect(Cosmetics.get_all_cosmetics_by_game_id(1), label: "Game ID 1")
      IO.inspect(UserCosmetics.get_all_user_cosmetics_for_user_id(socket.assigns.user.id), label: "For user #{socket.assigns.user.id}")

    {:ok, socket}
  end

end
