defmodule EngageWeb.UserRegistrationController do
  use EngageWeb, :controller

  alias Engage.Users
  alias Engage.Users.User
  alias EngageWeb.UserAuth
  alias EngageWeb.Router.Helpers, as: Routes

  def new(conn, _params) do
    changeset = Users.change_user_registration(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Users.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Users.deliver_user_confirmation_instructions(
            user,
            &Routes.user_confirmation_url(conn, :edit, &1)
          )

        conn
        |> redirect(to: Routes.user_confirmation_path(conn, :new))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
