defmodule EngageWeb.StoreLive do
  use Phoenix.LiveView, layout: {EngageWeb.LayoutView, "live.html"}
  import EngageWeb.LiveHelpers
  import Ecto.Changeset
  alias Phoenix.LiveView.JS
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

    socket =
      socket
      |> assign(
        games: games,
        games_cosmetics: games_cosmetics
      )
      |> push_event("init-scrollx", %{class: "js-scrollx"})

    {:ok, socket}
  end

  def handle_event("buy-cosmetic", %{"cosmetic-id" => cosmetic_id}, socket) do
    cosmetic_id = String.to_integer(cosmetic_id)

    socket =
      case UserCosmetics.purchase_cosmetic(socket.assigns.user.id, cosmetic_id) do
        {:ok, _uc} ->
          push_redirect(socket, to: Routes.store_path(socket, :index))

        {:error, changeset} ->
          coins_error_message =
            traverse_errors(changeset, fn {msg, opts} -> {msg, opts} end).coins

          {message, _validations} = List.first(coins_error_message)

          message = message || "There was an error while purchasing your cosmetic!"

          socket
          |> put_flash(:error, message)
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

  defp item_button(user, cosmetic) do
    assigns = %{}

    classes =
      "p-2 rounded-full bg-accent-500 hover:bg-accent-400 text-neutral-50 shadow-equal shadow-theme-neutral-5 dark-t:shadow-theme-neutral-1 transition-colors absolute right-2 top-0 -translate-y-1/2"

    cond do
      owner_of_cosmetic?(user, cosmetic) and equipped_cosmetic?(user, cosmetic) ->
        ~H"""
        <button phx-click="unequip-cosmetic" phx-value-cosmetic-id={cosmetic.id} class={classes}>
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" class="w-6 h-6">
            <path stroke-linecap="round" stroke-linejoin="round" d="M20 12H4" />
          </svg>
        </button>
        """

      owner_of_cosmetic?(user, cosmetic) ->
        ~H"""
        <button phx-click="equip-cosmetic" phx-value-cosmetic-id={cosmetic.id} class={classes}>
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" class="w-6 h-6">
            <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4" />
          </svg>
        </button>
        """

      true ->
        ~H"""
        <button phx-click="buy-cosmetic" phx-value-cosmetic-id={cosmetic.id} class={classes}>
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" class="w-6 h-6">
            <path stroke-linecap="round" stroke-linejoin="round" d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z" />
          </svg>
        </button>
        """
    end
  end

  defp owner_of_cosmetic?(%User{} = user, %Cosmetic{} = cosmetic) do
    UserCosmetics.user_owns_cosmetic?(user.id, cosmetic.id)
  end

  defp equipped_cosmetic?(%User{} = user, %Cosmetic{} = cosmetic) do
    UserCosmetics.user_equipped_cosmetic?(user.id, cosmetic.id)
  end
end
