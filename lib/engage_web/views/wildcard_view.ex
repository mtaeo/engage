defmodule EngageWeb.WildcardView do
  use EngageWeb, :view
  alias EngageWeb.Router.Helpers, as: Routes

  defp redirect_to(conn) do
    if conn.assigns.current_user do
      Routes.game_list_path(conn, :index)
    else
      Routes.landing_page_path(conn, :index)
    end
  end
end
