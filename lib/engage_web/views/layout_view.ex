defmodule EngageWeb.LayoutView do
  use EngageWeb, :view

  # Phoenix LiveDashboard is available only in development by default,
  # so we instruct Elixir to not warn if the dashboard route is missing.
  @compile {:no_warn_undefined, {Routes, :live_dashboard_path, 2}}

  defp app_theme(conn) do
    conn.assigns
    |> case do
      %{theme: theme} -> theme
      %{current_user: %{theme: theme}} -> theme
      _ -> :light
    end
    |> case do
      :automatic -> "theme-auto"
      :light -> "theme-light"
      :dark -> "theme-dark"
      # this should never be reached
      _ -> "theme-light"
    end
  end
end
