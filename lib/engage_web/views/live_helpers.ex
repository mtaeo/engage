defmodule EngageWeb.LiveHelpers do
  alias Phoenix.LiveView
  alias Phoenix.LiveView.Socket, as: Socket
  alias Engage.XpToLevels
  alias EngageWeb.Router.Helpers, as: Routes
  alias Engage.Users

  @type session :: map()
  @type user :: map()

  @spec live_auth_check(Socket.t(), session) :: Socket.t()
  @spec live_auth_check(Socket.t(), session, (Socket.t(), user -> Socket.t())) :: Socket.t()
  def live_auth_check(socket, session, success \\ fn s, _ -> s end) do
    # Current implementation replaces the current_user stored in the session
    # with a freshly fetched User from the database
    case session do
      %{"current_user" => user} ->
        fetched_user = Users.get_user!(user.id)
        success.(socket, fetched_user)

      _ ->
        LiveView.redirect(socket,
          to: Routes.landing_page_path(socket, :index)
        )
    end
  end

  @spec live_template_assigns(Socket, user) :: Socket
  def live_template_assigns(socket, user) do
    level = XpToLevels.calculate_level_for_xp(user.total_xp)
    upper_xp = XpToLevels.calculate_upper_xp_for_level(level)

    LiveView.assign(socket,
      coins: user.coins,
      level: level,
      level_progress: user.total_xp / (upper_xp || user.total_xp) * 100
    )
  end
end
