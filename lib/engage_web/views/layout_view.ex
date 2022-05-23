defmodule EngageWeb.LayoutView do
  use EngageWeb, :view
  alias EngageWeb.Util

  # Phoenix LiveDashboard is available only in development by default,
  # so we instruct Elixir to not warn if the dashboard route is missing.
  @compile {:no_warn_undefined, {Routes, :live_dashboard_path, 2}}

  defp app_theme(conn) do
    conn.assigns
    |> case do
      %{theme: theme} -> theme
      %{current_user: %{theme: theme}} -> theme
      _ -> :automatic
    end
    |> case do
      :dark -> "theme-dark"
      :light -> "theme-light"
      :automatic -> "theme-auto"
      # this should never be reached
      _ -> "theme-auto"
    end
  end
end
