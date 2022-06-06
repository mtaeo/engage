defmodule EngageWeb.LeaderboardLive do
  use Phoenix.LiveView, layout: {EngageWeb.LayoutView, "live.html"}
  import EngageWeb.LiveHelpers
  alias Engage.Users
  alias EngageWeb.Router.Helpers, as: Routes

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
          rank: index + 1,
          avatar_src:
            Engage.Helpers.Gravatar.get_image_src_by_email(user.email, user.gravatar_style)
        })
      end)

    {:ok, assign(socket, users: users)}
  end

  defp top_three(users) do
    temp =
      users
      |> Stream.take(3)
      |> Enum.reverse()

    [nil, nil, nil | temp]
    |> Enum.reverse()
    |> Enum.take(3)
  end
end
