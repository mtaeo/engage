defmodule EngageWeb.UserSettingsLive do
  use Phoenix.LiveView, layout: {EngageWeb.LayoutView, "live.html"}
  alias Engage.UserSettings.Profile
  use Phoenix.HTML
  import EngageWeb.ErrorHelpers
  
  def mount(_params, session, socket) do
    user = session["current_user"]
    bio = "bio here"
    profile_changeset = Profile.changeset(%Profile{}, %{username: "username here", email: user.email, bio: bio, theme: "dark"})
    
    socket = assign(socket, user: user, username: user.email, profile_changeset: profile_changeset)
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
    profile_changeset = Profile.changeset(%Profile{}, params["profile_changeset"])
    socket = assign(socket, username: profile_changeset.user, profile_changeset: profile_changeset)
    
    # TODO: logic for updating user info
    
    {:noreply, socket}
  end
  
  def handle_event("submit_avatar", params, socket) do
    IO.inspect(params)
    
    # TODO: logic for updating avatar
    
    {:noreply, socket}
  end
  
  def handle_event("submit_password", _params, socket) do
    #%{
    #  "old_password" => old_password,
    #  "new_password" => new_password,
    #  "new_password_repear" => new_password_repeat
    #} = params
    
    # TODO: logic for updating password
    
    {:noreply, socket}
  end
end