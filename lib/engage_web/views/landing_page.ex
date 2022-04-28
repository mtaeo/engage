defmodule EngageWeb.LandingPageView do
  use EngageWeb, :view
  alias Engage.Users.User

  defp build_based_on_authentication(conn, nil) do
    content_tag(:div) do
      [
        link("Login",
          to: Routes.user_session_path(conn, :new),
          class: "underline hover:text-neutral-300 transition-colors"
        ),
        " | ",
        link("Register",
          to: Routes.user_registration_path(conn, :new),
          class: "underline hover:text-neutral-300 transition-colors"
        )
      ]
    end
  end

  defp build_based_on_authentication(conn, %User{} = _current_user) do
    link("Start Playing",
      to: Routes.homescreen_path(conn, :index),
      class:
        "block px-6 py-3 rounded-xl text-white bg-accent-500 hover:bg-accent-400 transition-colors"
    )
  end
end
