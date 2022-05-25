defmodule EngageWeb.StoreLive do
  use Phoenix.LiveView, layout: {EngageWeb.LayoutView, "live.html"}
  import EngageWeb.LiveHelpers
  import Ecto.Changeset
  alias Engage.Users.User
  alias Engage.{UserCosmetics, Cosmetics, Games}
  alias Engage.Cosmetics.Cosmetic
  alias EngageWeb.Router.Helpers, as: Routes

  def mount(_params, session, socket) do
    socket =
      live_auth_check(socket, session, fn socket, user ->
        live_template_assigns(socket, user)
        |> assign(user: user)
      end)

    games = Games.get_all_games()

    games_cosmetics =
      Enum.map(games, fn g ->
        cosmetics = Cosmetics.get_all_cosmetics_by_game_id(g.id)
        {g, cosmetics}
      end)

    {:ok,
     assign(socket,
       games: games,
       games_cosmetics: games_cosmetics
     )}
  end

  def handle_event("buy-cosmetic", %{"cosmetic-id" => cosmetic_id}, socket) do
    cosmetic_id = String.to_integer(cosmetic_id)

    socket =
      case UserCosmetics.purchase_cosmetic(socket.assigns.user.id, cosmetic_id) do
        {:ok, _uc} ->
          push_redirect(socket, to: Routes.store_path(socket, :index))

        {:error, changeset} ->
          coins_error_message = traverse_errors(changeset, fn {msg, opts} -> {msg, opts} end).coins
          {message, _validations} = List.first(coins_error_message)

          message = message || "There was an error while purchasing your cosmetic!"
          socket
          |> put_flash(:error,  message)
      end

    {:noreply, socket}
  end

  def handle_event("equip-cosmetic", %{"cosmetic-id" => cosmetic_id}, socket) do
    cosmetic_id = String.to_integer(cosmetic_id)

    socket =
      case UserCosmetics.equip_cosmetic(socket.assigns.user.id, cosmetic_id) do
        {:ok, _uc} ->
          push_redirect(socket, to: Routes.store_path(socket, :index))

        {:error, _changeset} ->
          socket
          |> put_flash(:error, "There was an error while equipping your cosmetic!")
      end

    {:noreply, socket}
  end

  def handle_event("unequip-cosmetic", %{"cosmetic-id" => cosmetic_id}, socket) do
    cosmetic_id = String.to_integer(cosmetic_id)

    socket =
      case UserCosmetics.unequip_cosmetic(socket.assigns.user.id, cosmetic_id) do
        {:ok, _uc} ->
          push_redirect(socket, to: Routes.store_path(socket, :index))

        {:error, _changeset} ->
          socket
          |> put_flash(:error, "There was an error while unequipping your cosmetic!")
      end

    {:noreply, socket}
  end

  defp content_for_cosmetic(%Cosmetic{} = cosmetic) do
    content_for_cosmetic_application(cosmetic, cosmetic.application)
  end

  defp content_for_cosmetic_application(%Cosmetic{} = cosmetic, "x-color") do
    assigns = %{}

    ~H"""
    <svg version="1.1" viewBox="0 0 4 4" xmlns="http://www.w3.org/2000/svg">
      <path style={"stroke: #{cosmetic.value};"} fill="none" stroke-linecap="round" stroke-width="0.4" d="">
        <animate attributeName="d" values="M1 1 l0 0;M1 1 l2 2;M1 1 l2 2 M1 3 l0 0;M1 1 l2 2 M1 3 l2-2" fill="freeze" dur="0.5s" calcMode="spline" keySplines="0 0 0.58 1;0 0 0 0;0 0 0.58 1" keyTimes="0;0.5;0.5;1" repeatCount="1" />
      </path>
    </svg>
    """
  end

  defp content_for_cosmetic_application(%Cosmetic{} = cosmetic, "o-color") do
    assigns = %{}

    ~H"""
    <svg version="1.1" viewBox="0 0 4 4" xmlns="http://www.w3.org/2000/svg">
      <circle style={"stroke: #{cosmetic.value};"} cx="2" cy="2" r="1.125" fill="none" stroke-linecap="round" stroke-width="0.4" stroke-dasharray="7.065" stroke-dashoffset="7.065" transform="rotate(-90 2 2)">
        <animate attributeName="stroke-dashoffset" values="7.065;0" fill="freeze" dur="0.75s" calcMode="spline" keySplines="0 0 0.58 1" repeatCount="1" />
      </circle>
    </svg>
    """
  end

  defp owner_of_cosmetic?(%User{} = user, %Cosmetic{} = cosmetic) do
    UserCosmetics.user_owns_cosmetic?(user.id, cosmetic.id)
  end

  defp equipped_cosmetic?(%User{} = user, %Cosmetic{} = cosmetic) do
    UserCosmetics.user_equipped_cosmetic?(user.id, cosmetic.id)
  end
end
