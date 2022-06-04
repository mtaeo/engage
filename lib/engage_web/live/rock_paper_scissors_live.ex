defmodule EngageWeb.RockPaperScissorsLive do
  use Phoenix.LiveView, layout: {EngageWeb.LayoutView, "game.html"}
  import EngageWeb.LiveHelpers
  alias Phoenix.LiveView.JS
  alias EngageWeb.Router.Helpers, as: Routes
  alias Engage.Games.RockPaperScissors
  alias Engage.Games.Chat
  alias Engage.Games.Chat.Message
  alias Engage.Helpers.Gravatar
  alias EngageWeb.Util

  def mount(_params, session, socket) do
    socket =
      live_auth_check(socket, session, fn socket, user ->
        setup(socket, user)
      end)

    {:ok, socket}
  end

  def handle_params(%{"id" => game_code}, _uri, socket) do
    game_genserver_name = String.to_atom(game_code)
    chat_genserver_name = String.to_atom("chat_" <> game_code)
    RockPaperScissors.GenServer.start(game_genserver_name)
    Chat.GenServer.start(chat_genserver_name)
    Phoenix.PubSub.subscribe(Engage.PubSub, game_code)
    Phoenix.PubSub.subscribe(Engage.PubSub, "chat_" <> game_code)

    players =
      RockPaperScissors.GenServer.add_player(
        game_genserver_name,
        socket.assigns.player_id,
        socket.assigns.player_name
      )

    nth =
      RockPaperScissors.GenServer.get_player_nth_by_name(
        game_genserver_name,
        socket.assigns.player_name
      )

    messages = Chat.GenServer.view(chat_genserver_name)

    socket =
      if RockPaperScissors.GenServer.game_started?(game_genserver_name) do
        assign(socket,
          nth: nth,
          game_code: game_code,
          players: players,
          messages: messages,
          game_genserver_name: game_genserver_name,
          chat_genserver_name: chat_genserver_name
        )
        |> scroll_chat()
      else
        route = "/game-lobby/rock-paper-scissors/#{game_code}"
        push_redirect(socket, to: route)
      end

    {:noreply, socket}
  end

  def handle_event("choose-symbol", %{"symbol" => symbol}, socket) when is_binary(symbol) do
    symbol = String.to_atom(symbol)
    nth = socket.assigns.nth

    RockPaperScissors.GenServer.make_move(
      socket.assigns.game_genserver_name,
      socket.assigns.players[nth],
      symbol
    )

    {:noreply, socket}
  end

  def handle_event("send-message", %{"message-text" => text}, socket) do
    message = %Message{
      sender: socket.assigns.player_name,
      text: String.trim(text),
      avatar_src: socket.assigns.player_avatar
    }

    Chat.GenServer.send_message(
      socket.assigns.chat_genserver_name,
      message
    )

    socket =
      if String.trim(text) !== "" do
        clear_message_box(socket)
      else
        socket
      end

    {:noreply, socket}
  end

  def handle_event("clipboard-insert", _, socket) do
    :timer.send_after(3500, :clear_flash)

    {:noreply,
     socket
     |> put_flash(:info, "Copied game code \"#{socket.assigns.game_code}\" to clipboard.")}
  end

  def handle_info(players, socket) when is_map(players) do
    {:noreply, assign(socket, players: players)}
  end

  def handle_info(messages, socket) when is_list(messages) do
    socket =
      socket
      |> assign(messages: messages)
      |> scroll_chat()

    {:noreply, socket}
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end

  defp setup(socket, user) do
    assign(socket,
      player_id: user.id,
      player_name: user.username,
      player_avatar: Gravatar.get_image_src_by_email(user.email, user.gravatar_style),
      players: %{first: nil, second: nil},
      messages: []
    )
  end

  defp symbol_button(socket, symbol, picked) when is_atom(symbol) and is_atom(picked) do
    assigns = %{}

    classes =
      cond do
        picked === nil ->
          "translate-x-0"

        symbol === picked ->
          case symbol do
            :rock -> "translate-x-[calc(100%+0.75rem)]"
            :paper -> "translate-x-0"
            :scissors -> "translate-x-[calc(-100%-0.75rem)]"
            _ -> ""
          end

        true ->
          "translate-x-0 opacity-0"
      end

    ~H"""
    <button class={ "rounded-lg hover:bg-theme-3 dark-t:hover:bg-theme-2 transition " <> classes } phx-click="choose-symbol" phx-value-symbol={symbol}>
      <%= symbol(socket, symbol) %>
    </button>
    """
  end

  defp symbol(socket, symbol, classes \\ "") when is_atom(symbol) and is_binary(classes) do
    assigns = %{}

    {src, alt} =
      case symbol do
        :rock -> {"rock.svg", "rock"}
        :paper -> {"paper.svg", "paper"}
        :scissors -> {"scissors.svg", "scissors"}
        _ -> {"question-mark.svg", "question mark"}
      end

    ~H"""
    <img src={Routes.static_path(socket, "/images/rps/#{src}")} alt={alt} class={ "w-20 p-2 aspect-square grid place-items-center leading-none " <> classes }>
    """
  end

  defp both_players_chose_symbol?(players) do
    not Enum.any?(players, fn {_nth, player} -> is_nil(player.symbol) end)
  end

  defp other(nth) do
    case nth do
      :first -> :second
      :second -> :first
    end
  end

  defp scroll_chat(socket) do
    push_event(socket, "scroll-end", %{id: "chat"})
  end

  defp clear_message_box(socket) do
    push_event(socket, "clear-input", %{id: "message-box"})
  end
end
