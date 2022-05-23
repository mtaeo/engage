defmodule EngageWeb.Util do
  alias Phoenix.LiveView.JS
  
  def toggle_class(target, class) do
    %JS{}
    |> JS.add_class(class, to: "#{target}:not(.#{class})")
    |> JS.remove_class(class, to: "#{target}.#{class}")
  end
  
  def toggle_sidebar() do
    toggle_class("#sidebar", "sidebar-toggled")
  end
end