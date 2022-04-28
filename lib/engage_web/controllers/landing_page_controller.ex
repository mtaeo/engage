defmodule EngageWeb.LandingPageController do
  use EngageWeb, :controller
  alias Engage.Users.User

  def index(conn, _params) do
    render(conn, "index.html", current_user: conn.assigns[:current_user])
  end
end
