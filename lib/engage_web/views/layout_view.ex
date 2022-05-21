defmodule EngageWeb.LayoutView do
  use EngageWeb, :view

  # Phoenix LiveDashboard is available only in development by default,
  # so we instruct Elixir to not warn if the dashboard route is missing.
  @compile {:no_warn_undefined, {Routes, :live_dashboard_path, 2}}

  defp app_theme(conn) do
    case conn.assigns do
      %{theme: :automatic} -> "theme-auto"
      %{theme: :light} -> "theme-light"
      %{theme: :dark} -> "theme-dark"
      # unauthorized users must endure a light theme
      _ -> "theme-light"
    end
  end
end
