defmodule EngageWeb.UserSettingsLive do
  use Phoenix.LiveView, layout: {EngageWeb.LayoutView, "live.html"}
  use Phoenix.HTML
  alias Ecto.Changeset
  alias Engage.UserSettings.Profile
  alias Engage.UserSettings.ChangePassword
  alias Engage.Helpers.Gravatar
  import EngageWeb.ErrorHelpers
  import EngageWeb.LiveHelpers

  def mount(_params, session, socket) do
    socket =
      live_auth_check(socket, session, fn socket, user ->
        socket = live_template_assigns(socket, user)

        profile = %Profile{
          username: user.username,
          email: user.email,
          bio: "bio here",
          theme: "dark"
        }

        change_password = %ChangePassword{}

        socket
        |> assign(
          profile: profile,
          profile_changeset: Profile.changeset(profile)
        )
        |> assign(
          change_password: change_password,
          change_password_changeset: ChangePassword.changeset(%ChangePassword{})
        )
        |> assign(avatar_uri: Gravatar.get_image_src_by_email(user.email))
      end)

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
