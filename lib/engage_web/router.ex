defmodule EngageWeb.Router do
  use EngageWeb, :router

  import EngageWeb.UserAuth

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
    
    live "/tmp/home", HomescreenLive, :index # TODO: pick a meaninful route
    live "/user/:username", UserProfileLive, :index
  end

  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: EngageWeb.Telemetry
    end
  end

  ## Authentication routes

  scope "/", EngageWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
    get "/users/reset_password", UserResetPasswordController, :new
    post "/users/reset_password", UserResetPasswordController, :create
    get "/users/reset_password/:token", UserResetPasswordController, :edit
    put "/users/reset_password/:token", UserResetPasswordController, :update

    get "/auth/:provider", UserOauthController, :request
    get "/auth/:provider/callback", UserOauthController, :callback
  end

  scope "/", EngageWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/users/settings_old", UserSettingsController, :edit # NOTE: remove before merge
    put "/users/settings", UserSettingsController, :update # NOTE: remove before merge
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email
    
    live "/users/settings", UserSettingsLive, :index
  end

  scope "/", EngageWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :edit
    post "/users/confirm/:token", UserConfirmationController, :update
  end
end
