defmodule EngageWeb.PageController do
  use EngageWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
