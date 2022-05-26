defmodule EngageWeb.UserSettingsLive do
  use Phoenix.LiveView, layout: {EngageWeb.LayoutView, "live.html"}
  use Phoenix.HTML
  alias Ecto.Changeset
  alias Engage.UserSettings.ChangePassword
  alias Engage.Helpers.Gravatar
  alias Engage.Users
  alias Engage.Users.User
  alias EngageWeb.Router.Helpers, as: Routes
  import EngageWeb.ErrorHelpers
  import EngageWeb.LiveHelpers

  def mount(_params, session, socket) do
    socket =
      live_auth_check(socket, session, fn socket, user ->
        socket = live_template_assigns(socket, user)

        profile_changeset = User.profile_changeset(user)
        change_password = %ChangePassword{}
        avatar_changeset = User.avatar_changeset(user)

        socket
        |> assign(user: user, user_role: user.role)
        |> assign(profile_changeset: profile_changeset)
        |> assign(
          change_password: change_password,
          change_password_changeset: ChangePassword.changeset(%ChangePassword{})
        )
        |> assign(avatar_uri: Gravatar.get_image_src_by_email(user.email, user.gravatar_style))
        |> assign(avatar_changeset: avatar_changeset)
      end)

    {:ok, socket}
  end

  def handle_event("validate_profile", %{"user" => profile_attrs}, socket) do
    profile_changeset =
      socket.assigns.user
      |> User.profile_changeset(profile_attrs)
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

  def handle_event("submit_profile", %{"user" => profile_attrs}, socket) do
    socket =
      case Users.update_user_profile(socket.assigns.user, profile_attrs) do
        {:ok, user} ->
          socket
          |> put_flash(:info, "Successfuly updated account information!")
          |> assign(profile_changeset: User.profile_changeset(user))
          |> redirect(to: Routes.user_settings_path(socket, :index))

        {:error, changeset} ->
          socket
          |> assign(profile_changeset: changeset)
      end

    {:noreply, socket}
  end

  def handle_event("submit_avatar", %{"user" => avatar_style}, socket) do
    socket =
      case Users.update_user_avatar(socket.assigns.user, avatar_style) do
        {:ok, user} ->
          socket
          |> assign(
            avatar_changeset: User.avatar_changeset(user),
            avatar_uri: Gravatar.get_image_src_by_email(user.email, user.gravatar_style)
          )

        {:error, changeset} ->
          socket
          |> put_flash(:error, "Error updating user profile avatar.")
          |> assign(avatar_changeset: changeset)
      end

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
      Automatic: :automatic
    ]
  end

  defp gravatar_styles do
    [
      "Mystery Person": :mp,
      Identicon: :identicon,
      Monsterid: :monsterid,
      Wavatar: :wavatar,
      Retro: :retro,
      Robohash: :robohash
    ]
  end
end
