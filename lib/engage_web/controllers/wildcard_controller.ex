defmodule EngageWeb.WildcardController do
  use EngageWeb, :controller
  alias EngageWeb.Router.Helpers, as: Routes

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
