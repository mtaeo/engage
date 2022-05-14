defmodule EngageWeb.Plugs.EnsureAuthorized do
  import Plug.Conn
  import Phoenix.Controller
  alias EngageWeb.Router.Helpers, as: Routes

  def init(opts), do: opts

  def call(conn, _opts) do
    case conn.assigns.current_user.role do
      :admin ->
        conn

      _ ->
        conn
        |> put_flash(:error, "You can't access that page")
        |> redirect(to: Routes.game_list_path(conn, :index))
        |> halt()
    end
  end
end
