defmodule EngageWeb.UserGameStatsLive do
  use Phoenix.LiveView, layout: {EngageWeb.LayoutView, "live.html"}
  import EngageWeb.LiveHelpers

  def mount(_params, session, socket) do
    socket =
      live_auth_check(socket, session, fn socket, user ->
        live_template_assigns(socket, user)
        |> setup(user)
      end)

    {:ok, socket}
  end

  defp setup(socket, user) do
    labels = 1..12 |> Enum.to_list()
    values = Enum.map(labels, fn _ -> get_reading() end)

    socket
    |> assign(
      user: user,
      chart_data: %{
        labels: labels,
        values: values
      }
    )
  end

  defp get_reading() do
    Enum.random(70..100)
  end
end
