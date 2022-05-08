defmodule EngageWeb.LandingPageView do
  use EngageWeb, :view
  alias Engage.Users.User

  defp header_session_links(assigns, nil) do
    ~H"""
    <%= link "Login", to: Routes.user_session_path(assigns, :new), class: "px-4 py-1 rounded-xl border-2 text-neutral-200 border-neutral-200 hover:text-neutral-400 hover:border-neutral-400 transition-colors" %>
    
    <%= link "Register", to: Routes.user_registration_path(assigns, :new), class: "px-4 py-1 rounded-xl border-2 text-neutral-200 border-neutral-200 hover:text-neutral-400 hover:border-neutral-400 transition-colors" %>
    """
  end

  defp header_session_links(assigns, %User{} = _current_user) do
    ~H"""
    <%= link "Open App", to: Routes.game_list_path(assigns, :index), class: "px-4 py-1 rounded-xl border-2 text-neutral-200 border-neutral-200 hover:text-neutral-400 hover:border-neutral-400 transition-colors" %>
    """
  end
  
  defp entry_button(assigns, nil, text) do
    ~H"""
    <%= link text, to: Routes.user_registration_path(assigns, :new), class: "block px-6 py-3 rounded-xl text-white bg-accent-500 hover:bg-accent-400 transition-colors" %>
    """
  end
  
  defp entry_button(assigns, %User{} = _current_user, text) do
    ~H"""
    <%= link text, to: Routes.game_list_path(assigns, :index), class: "block px-6 py-3 rounded-xl text-white bg-accent-500 hover:bg-accent-400 transition-colors" %>
    """
  end
end
