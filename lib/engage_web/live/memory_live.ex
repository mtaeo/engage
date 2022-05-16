defmodule EngageWeb.MemoryLive do
  use Phoenix.LiveView, layout: {EngageWeb.LayoutView, "game.html"}
  alias EngageWeb.Router.Helpers, as: Routes
  alias Engage.Games.Memory
  alias Engage.Games.Memory.{GameBoard, EmojiCard}
  alias Engage.Games.Chat
  alias Engage.Games.Chat.Message
  import EngageWeb.LiveHelpers

  def mount(_params, session, socket) do
    socket =
      live_auth_check(socket, session, fn socket, _user ->
        setup(socket, session)
      end)
    {:ok, socket}
  end

  def handle_params(%{"id" => game_id}, _uri, socket) do
    game_genserver_name = String.to_atom(game_id)
    chat_genserver_name = String.to_atom("chat_" <> game_id)
    Memory.GenServer.start(game_genserver_name)
    Chat.GenServer.start(chat_genserver_name)
    Phoenix.PubSub.subscribe(Engage.PubSub, game_id)
    Phoenix.PubSub.subscribe(Engage.PubSub, "chat_" <> game_id)

    players =
      Memory.GenServer.add_player(
        game_genserver_name,
        socket.assigns.player_id,
        socket.assigns.player_name
      )

    nth = Memory.GenServer.get_player_nth_by_name(game_genserver_name, socket.assigns.player_name)
    game_board = Memory.GenServer.view(game_genserver_name)
    messages = Chat.GenServer.view(chat_genserver_name)

    {:noreply,
     assign(socket,
       nth: nth,
       players: players,
       game_board: game_board,
       messages: messages,
       game_genserver_name: game_genserver_name,
       chat_genserver_name: chat_genserver_name
     )}
  end

  def handle_event("make-move", %{"index" => index}, socket) do
    Memory.GenServer.make_move(
      socket.assigns.game_genserver_name,
      {socket.assigns.players[socket.assigns.nth], String.to_integer(index)}
    )

    {:noreply, socket}
  end

  def handle_event("send-message", %{"message-text" => text}, socket) do
    message = %Message{
      sender: socket.assigns.player_name,
      text: String.trim(text),
      sent_at: NaiveDateTime.local_now()
    }

    Chat.GenServer.send_message(
      socket.assigns.chat_genserver_name,
      message
    )

    {:noreply, socket}
  end

  def handle_info(%GameBoard{} = game_board, socket) do
    {:noreply, assign(socket, game_board: game_board)}
  end

  def handle_info(players, socket) when is_map(players) do
    {:noreply, assign(socket, players: players)}
  end

  def handle_info(messages, socket) when is_list(messages) do
    {:noreply, assign(socket, messages: messages)}
  end

  defp setup(socket, session) do
    assign(socket,
      player_id: session["current_user"].id,
      player_name: session["current_user"].username,
      game_board: %GameBoard{},
      players: %{first: nil, second: nil},
      messages: []
    )
  end

  defp cell_content(%EmojiCard{} = card) do
    assigns = %{face_up?: card.face_up?, symbol: card.symbol}

    ~H"""
      <div class={if (not @face_up?), do: "cursor-pointer"}>
        <h1>
          <%= if @face_up?, do: @symbol, else: "?" %>
        </h1>
      </div>
    """
  end
end
