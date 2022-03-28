defmodule EngageWeb.UserOauthController do
  use EngageWeb, :controller

  alias Engage.Users
  alias EngageWeb.UserAuth

  plug Ueberauth
  @rand_pass_length 32

  def request(_conn, _params) do
    # render(conn, "request.html", callback_url: Helpers.callback_url(conn))
  end

  def callback(%{assigns: %{ueberauth_auth: %{info: user_info}}} = conn, %{"provider" => _}) do
    user_params = %{email: user_info.email, password: random_password()}

    case Users.fetch_or_create_user(user_params) do
      {:ok, user} ->
        UserAuth.log_in_user(conn, user)

      _ ->
        conn
        |> put_flash(:error, "Authentication failed")
        |> redirect(to: "/")
    end
  end

  def callback(conn, _params) do
    conn
    |> put_flash(:error, "Authentication failed")
    |> redirect(to: "/")
  end

  defp random_password do
    :crypto.strong_rand_bytes(@rand_pass_length) |> Base.encode64()
  end
end
