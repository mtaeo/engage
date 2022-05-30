defmodule EngageWeb.UserProfileLive do
  use Phoenix.LiveView, layout: {EngageWeb.LayoutView, "live.html"}
  alias EngageWeb.Router.Helpers, as: Routes
  alias Engage.Helpers.Gravatar
  alias Engage.Users
  alias Engage.Users.User
  alias Engage.XpToLevels
  import EngageWeb.LiveHelpers

  def mount(_params, session, socket) do
    socket =
      live_auth_check(socket, session, fn socket, user ->
        live_template_assigns(socket, user)
      end)

    {:ok, socket}
  end

  def handle_params(%{"username" => username}, _url, socket) do
    socket
    |> setup(Users.get_user_by_username(username))
  end

  defp setup(socket, nil) do
    {:noreply,
     push_redirect(socket,
       to: Routes.game_list_path(socket, :index)
     )}
  end

  defp setup(socket, %User{} = fetched_user) do
    level = XpToLevels.calculate_level_for_xp(fetched_user.total_xp)
    upper_xp = XpToLevels.calculate_upper_xp_for_level(level)
    current_level_xp = fetched_user.total_xp - XpToLevels.calculate_lower_xp_for_level(level)

    socket =
      assign(socket,
        profile: %{
          username: fetched_user.username,
          coins: fetched_user.coins,
          bio: fetched_user.bio,
          avatar_src:
            Gravatar.get_image_src_by_email(fetched_user.email, fetched_user.gravatar_style),
          level: level,
          current_level_xp: current_level_xp,
          upper_xp: upper_xp,
          level_up_progress: current_level_xp / (upper_xp || fetched_user.total_xp)
        }
      )

    {:noreply, socket}
  end
end
