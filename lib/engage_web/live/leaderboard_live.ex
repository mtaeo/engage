defmodule EngageWeb.LeaderboardLive do
  use Phoenix.LiveView, layout: {EngageWeb.LayoutView, "live.html"}
  import EngageWeb.LiveHelpers
  alias Engage.Users
  alias Engage.XpToLevels

  def mount(_params, session, socket) do
    socket =
      live_auth_check(socket, session, fn socket, user ->
        live_template_assigns(socket, user)
        |> assign(user: user)
      end)

    users =
      Users.get_all_users_sorted_by_level_desc()
      |> Enum.with_index()
      |> Enum.map(fn {user, index} ->
        Map.merge(user, %{
          level: XpToLevels.calculate_level_for_xp(user.total_xp),
          rank: index + 1
        })
      end)

      IO.inspect(users)

    {:ok, assign(socket, users: users)}
  end
end
