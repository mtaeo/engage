defmodule EngageWeb.Router do
  use EngageWeb, :router
  import Phoenix.LiveDashboard.Router
  import EngageWeb.UserAuth
  alias EngageWeb.Plugs.EnsureAuthorized

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {EngageWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", EngageWeb do
    pipe_through :browser

    get "/", LandingPageController, :index
  end

  ## Authorization routes

  scope "/admin" do
    pipe_through [:browser, EnsureAuthorized]

    live_dashboard "/dashboard", metrics: EngageWeb.Telemetry
  end

  ## Authentication routes

  scope "/", EngageWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
    get "/users/log-in", UserSessionController, :new
    post "/users/log-in", UserSessionController, :create
    get "/users/reset-password", UserResetPasswordController, :new
    post "/users/reset-password", UserResetPasswordController, :create
    get "/users/reset-password/:token", UserResetPasswordController, :edit
    put "/users/reset-password/:token", UserResetPasswordController, :update

    get "/auth/:provider", UserOauthController, :request
    get "/auth/:provider/callback", UserOauthController, :callback
  end

  scope "/", EngageWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/users/settings-old", UserSettingsController, :edit
    put "/users/settings-old", UserSettingsController, :update
    get "/users/settings/confirm-email/:token", UserSettingsController, :confirm_email

    live "/games", GameListLive, :index
    live "/game-info/:game", GameInfoLive, :index
    live "/game-lobby/:game/:code", GameLobbyLive, :index
    live "/join", JoinGameLive, :index
    live "/games/tic-tac-toe/:id", TicTacToeLive, :index
    live "/games/memory/:id", MemoryLive, :index
    live "/games/rock-paper-scissors/:id", RockPaperScissorsLive, :index
    live "/games/connect-four/:id", ConnectFourLive, :index
    live "/store", StoreLive, :index
    live "/leaderboard", LeaderboardLive, :index
    live "/challenges/quiz", QuizLive, :index
    live "/discover", DiscoverGamesLive, :index
    live "/stats", UserGameStatsLive, :index

    live "/proxy/user", UserProfileProxyLive, :index
    live "/user/:username", UserProfileLive, :index
    live "/users/settings", UserSettingsLive, :index
  end

  scope "/", EngageWeb do
    pipe_through [:browser]

    delete "/users/log-out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :edit
    post "/users/confirm/:token", UserConfirmationController, :update
  end

  # Wildcard route
  scope "/", EngageWeb do
    pipe_through [:browser]

    get "/*path", WildcardController, :index
  end
end
