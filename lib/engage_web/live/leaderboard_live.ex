defmodule EngageWeb.LeaderboardLive do
  use Phoenix.LiveView, layout: {EngageWeb.LayoutView, "live.html"}
  import EngageWeb.LiveHelpers
  alias Engage.Users

  def mount(_params, session, socket) do
    socket =
      live_auth_check(socket, session, fn socket, user ->
        live_template_assigns(socket, user)
        |> assign(user: user)
      end)

    users =
      Users.get_users_for_leaderboard()
      |> Enum.with_index()
      |> Enum.map(fn {user, index} ->
        Map.merge(user, %{
          rank: index + 1
        })
      end)

    {:ok, assign(socket, users: users)}
  end
end
