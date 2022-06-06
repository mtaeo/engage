defmodule EngageWeb.UserOauthController do
  use EngageWeb, :controller

  alias Engage.Users
  alias EngageWeb.UserAuth

  plug Ueberauth
  @rand_pass_length 32

  def request(conn, _params) do
    redirect(conn, to: "/auth/guest/callback")
  end

  def callback(conn, %{"provider" => "guest"}) do
    username = generate_unique_username("guest")

    user_params = %{
      username: username,
      email: username <> "@play-engage.com",
      role: :guest,
      password: random_password(),
    }

    case Users.fetch_or_create_user(user_params) do
      {:ok, user} ->
        UserAuth.log_in_user(conn, user)

      _ ->
        conn
        |> put_flash(:error, "Authentication failed")
        |> redirect(to: "/")
    end
  end

  def callback(%{assigns: %{ueberauth_auth: %{info: user_info}}} = conn, %{"provider" => _}) do
    name = user_info.nickname || user_info.first_name || user_info.name

    user_params = %{
      username: generate_unique_username(name),
      email: user_info.email,
      password: random_password()
    }

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

  defp generate_unique_username(name) do
    generated_username = Engage.Helpers.CodeGenerator.generate_username(name)

    if Users.exists_username?(generated_username) do
      generate_unique_username(name)
    else
      generated_username
    end
  end
end
