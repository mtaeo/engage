defmodule Engage.Users.UserNotifier do
  use Phoenix.Swoosh,
    view: EngageWeb.UserNotifierView,
    layout: {EngageWeb.LayoutView, :email}

  import Swoosh.Email
  alias Engage.Mailer

  # Delivers the email using the application mailer.
  defp deliver(conn, recipient, subject, template_name, assigns) when is_map(assigns) do
    assigns =
      assigns
      |> Map.merge(%{
        conn: conn,
        recipient_email: recipient,
        title: subject
      })

    email =
      new()
      |> from({"Engage", "play.engage.dev@gmail.com"})
      |> to(recipient)
      |> subject("[Engage] " <> subject)
      |> render_body(template_name, assigns)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(conn, user, url) do
    deliver(
      conn,
      user.email,
      "Confirmation instructions",
      "confirm_account.html",
      %{
        username: user.username,
        link: url
      }
    )
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(conn, user, url) do
    deliver(
      conn,
      user.email,
      "Reset password instructions",
      "reset_password.html",
      %{
        username: user.username,
        link: url
      }
    )
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(conn, user, url) do
    deliver(
      conn,
      user.email,
      "Update email instructions",
      "update_email.html",
      %{
        username: user.username,
        link: url
      }
    )
  end
end
