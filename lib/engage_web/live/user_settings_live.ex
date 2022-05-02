defmodule EngageWeb.UserSettingsLive do
  use Phoenix.LiveView, layout: {EngageWeb.LayoutView, "live.html"}
  use Phoenix.HTML
  alias Ecto.Changeset
  alias Engage.UserSettings.Profile
  alias Engage.UserSettings.ChangePassword
  import EngageWeb.ErrorHelpers

  def mount(_params, session, socket) do
    user = session["current_user"]

    profile = %Profile{
      username: "username here",
      email: user.email,
      bio: "bio here",
      theme: "dark"
    }

    socket = assign(socket, profile: profile, profile_changeset: Profile.changeset(profile))

    change_password = %ChangePassword{}

    socket =
      assign(socket,
        change_password: change_password,
        change_password_changeset: ChangePassword.changeset(%ChangePassword{})
      )

    socket = assign(socket, avatar_uri: "https://unsplash.it/seed/#{profile.username}/200/200")

    {:ok, socket}
  end

  def handle_event("validate_profile", %{"profile" => profile_params}, socket) do
    profile_changeset =
      socket.assigns.profile
      |> Profile.changeset(profile_params)
      |> Map.put(:action, :validate)

    {:noreply,
     assign(socket,
       profile_changeset: profile_changeset
     )}
  end

  def handle_event(
        "validate_change_password",
        %{"change_password" => change_password_params},
        socket
      ) do
    change_password_changeset =
      socket.assigns.change_password
      |> ChangePassword.changeset(change_password_params)
      |> Map.put(:action, :validate)
    
    {:noreply, assign(socket, change_password_changeset: change_password_changeset)}
  end

  def handle_event("submit_profile", _params, socket) do
    # TODO: logic for updating profile in DB

    {:noreply, socket}
  end

  def handle_event("submit_avatar", _params, socket) do
    # TODO: logic for updating avatar

    {:noreply, socket}
  end

  def handle_event("submit_change_password", _params, socket) do
    # TODO: logic for updating password in DB

    {:noreply, socket}
  end

  defp changeset_valid?(changeset) do
    changeset.errors == []
  end
  
  defp themes do
    [
      Dark: :dark,
      Light: :light,
      Automatic: :auto
    ]
  end
end
