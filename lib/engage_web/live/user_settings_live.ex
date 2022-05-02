defmodule EngageWeb.UserSettingsLive do
  use Phoenix.LiveView, layout: {EngageWeb.LayoutView, "live.html"}
  use Phoenix.HTML
  alias Engage.UserSettings.Profile
  alias Engage.UserSettings.ChangePassword
  import EngageWeb.ErrorHelpers

  def mount(_params, session, socket) do
    user = session["current_user"]
    bio = "bio here"

    profile_changeset =
      Profile.changeset(%Profile{}, %{
        username: "username here",
        email: user.email,
        bio: bio,
        theme: "dark"
      })

    password_changeset = ChangePassword.changeset(%ChangePassword{})

    socket =
      assign(
        socket,
        user: user,
        username: user.email,
        profile_changeset: profile_changeset,
        password_changeset: password_changeset
      )

    {:ok, socket}
  end

  defp themes do
    [
      Dark: :dark,
      Light: :light,
      Automatic: :auto
    ]
  end

  def handle_event("submit_profile", params, socket) do
    profile_changeset = Profile.changeset(%Profile{}, params["profile"])

    socket =
      assign(socket,
        username: profile_changeset.changes.username,
        profile_changeset: profile_changeset
      )

    # TODO: logic for updating user info

    {:noreply, socket}
  end

  def handle_event("submit_avatar", _params, socket) do

    # TODO: logic for updating avatar

    {:noreply, socket}
  end

  def handle_event("submit_change_password", params, socket) do
    password_changeset = ChangePassword.changeset(%ChangePassword{}, params["change_password"])

    socket = assign(socket, password_changeset: ChangePassword.changeset(%ChangePassword{}))

    # TODO: logic for updating password

    {:noreply, socket}
  end
end
