defmodule EngageWeb.UserProfileLive do
  use Phoenix.LiveView, layout: {EngageWeb.LayoutView, "live.html"}
  alias EngageWeb.Router.Helpers, as: Routes
  alias Engage.Helpers.Gravatar
  alias Engage.Users
  alias Engage.Users.User
  alias Engage.XpToLevels

  def mount(_params, _session, socket) do
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

    socket =
      assign(socket,
        username: fetched_user.username,
        coins: fetched_user.coins,
        profile_image_src: Gravatar.get_image_src_by_email(fetched_user.email),
        level: level,
        user_xp: fetched_user.total_xp,
        upper_xp: upper_xp,
        level_up_percentage: fetched_user.total_xp / (upper_xp || fetched_user.total_xp) * 100
      )

    {:noreply, socket}
  end
end
