defmodule EngageWeb.UserProfileLive do
  use Phoenix.LiveView, layout: {EngageWeb.LayoutView, "live.html"}
  alias Engage.Helpers.Gravatar
  alias Engage.Users

  def mount(%{"username" => username}, _session, socket) do
    {:ok, setup(socket, username)}
  end

  defp setup(socket, username) do
    fetched_user = Users.get_user_by_username(username)

    if fetched_user !== nil do
      assign(socket,
        username: fetched_user.username,
        profile_image_src: Gravatar.get_image_src_by_email(fetched_user.email)
      )
    else
      assign(socket,
        username: nil,
        profile_image_src: Gravatar.get_default_image_src()
      )
    end
  end
end
