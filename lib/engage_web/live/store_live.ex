defmodule EngageWeb.StoreLive do
  use Phoenix.LiveView, layout: {EngageWeb.LayoutView, "live.html"}
  import EngageWeb.LiveHelpers
  alias Engage.{Cosmetics, UserCosmetics, Games}
  alias Engage.Cosmetics.Cosmetic

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

  def handle_event("buy-cosmetic", %{"cosmetic" => cosmetic}, socket) when is_map(cosmetic) do

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

  defp user_owner_of_cosmetic?(user_id, cosmetic_id)
       when is_integer(user_id) and
              is_integer(cosmetic_id) do
    false
  end

  defp user_equipped_cosmetic?(user_id, cosmetic_id)
       when is_integer(user_id) and
              is_integer(cosmetic_id) do
                false
  end
end
