defmodule EngageWeb.UserGameStatsLive do
  use Phoenix.LiveView, layout: {EngageWeb.LayoutView, "live.html"}
  import EngageWeb.LiveHelpers
  alias Engage.{Games, GameEvents, Users}
  alias EngageWeb.Router.Helpers, as: Routes

  def mount(_params, session, socket) do
    socket =
      live_auth_check(socket, session, fn socket, user ->
        live_template_assigns(socket, user)
        |> setup(user)
      end)

    {:ok, socket}
  end

  defp setup(socket, user) do
    games =
      Games.get_all_games()
      |> Enum.filter(fn g -> g.name !== "rock-paper-scissors" end)

    game_events = GameEvents.get_game_statistics_for_user_id(user.id)

    arch_enemy = get_arch_enemy(game_events)

    most_dominated_enemy =
      if arch_enemy, do: get_most_dominated_enemy(game_events, arch_enemy.id), else: nil

    labels = Enum.map(games, fn g -> g.display_name end)

    values =
      Enum.map(Enum.group_by(game_events, fn ge -> ge.game.name end), fn {_k, v} ->
        Enum.count(v)
      end)

    socket
    |> assign(
      user: user,
      arch_enemy: arch_enemy,
      most_dominated_enemy: most_dominated_enemy,
      chart_data: %{
        labels: labels,
        values: values
      }
    )
  end

  defp get_arch_enemy(game_events) do
    {arch_enemy_id, _lost_games_count} =
      game_events
      |> Enum.filter(fn ge -> ge.outcome == :lost or ge.outcome == :draw end)
      |> Enum.group_by(fn ge -> ge.opponent_user_id end)
      |> Enum.map(fn {k, v} -> {k, Enum.count(v)} end)
      |> Enum.into(%{})
      |> Enum.max_by(fn {_opponent_id, lost_games_count} -> lost_games_count end, fn ->
        {nil, nil}
      end)

    if arch_enemy_id do
      arch_enemy = Users.get_user(arch_enemy_id)

      arch_enemy
      |> Map.merge(%{
        avatar_src:
          Engage.Helpers.Gravatar.get_image_src_by_email(
            arch_enemy.email,
            arch_enemy.gravatar_style
          )
      })
    else
      nil
    end
  end

  defp get_most_dominated_enemy(game_events, arch_enemy_id) do
    {most_dominated_id, _won_games_count} =
      game_events
      |> Enum.filter(fn ge -> ge.outcome == :won and ge.opponent_user_id != arch_enemy_id end)
      |> Enum.group_by(fn ge -> ge.opponent_user_id end, fn ge -> ge end)
      |> Enum.map(fn {k, v} -> {k, Enum.count(v)} end)
      |> Enum.into(%{})
      |> Enum.max_by(fn {_opponent_id, won_games_count} -> won_games_count end, fn ->
        {nil, nil}
      end)

    if most_dominated_id do
      most_dominated_user = Users.get_user(most_dominated_id)

      most_dominated_user
      |> Map.merge(%{
        avatar_src:
          Engage.Helpers.Gravatar.get_image_src_by_email(
            most_dominated_user.email,
            most_dominated_user.gravatar_style
          )
      })
    else
      nil
    end
  end
end
