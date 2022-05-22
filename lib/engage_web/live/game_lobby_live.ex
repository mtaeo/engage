defmodule EngageWeb.GameLobbyLive do
  use Phoenix.LiveView, layout: {EngageWeb.LayoutView, "live.html"}
  import EngageWeb.LiveHelpers
  alias Engage.Games
  alias Engage.Games.{Chat, TicTacToe, Memory}
  alias EngageWeb.Router.Helpers, as: Routes

  def mount(_params, session, socket) do
    socket =
      live_auth_check(socket, session, fn socket, user ->
        socket
        |> live_template_assigns(user)
        |> assign(
          player_id: user.id,
          player_name: user.username,
          players: %{},
          messages: [],
          is_lobby_owner: false
        )
      end)

    {:ok, socket}
  end

  def handle_params(%{"game" => game_name, "code" => game_code}, _url, socket) do
    socket =
      case Games.get_game_by_name(game_name) do
        nil ->
          push_redirect(socket, to: Routes.game_list_path(socket, :index))

        game ->
          setup(socket, game, game_code)
      end

    {:noreply, socket}
  end

  def handle_info(players, socket) when is_map(players) do
    {:noreply, assign(socket, players: players)}
  end

  def handle_info(:game_started, socket) do
    path = "/games/#{socket.assigns.game.name}/#{socket.assigns.game_code}"

    {:noreply, push_redirect(socket, to: path)}
  end

  def handle_event("kick-player", %{"kicked-player-id" => kicked_player_id}, socket) do
    kicked_player_id = String.to_integer(kicked_player_id)

    game_genserver(socket.assigns.game.name).kick_player(
      socket.assigns.game_genserver_name,
      socket.assigns.nth,
      kicked_player_id
    )

    {:noreply, socket}
  end

  def handle_event("start-game", _, socket) do
    nth = socket.assigns.nth

    game_started? =
      game_genserver(socket.assigns.game.name).start_game(
        socket.assigns.game_genserver_name,
        socket.assigns.players[nth]
      )

    socket =
      if game_started?,
        do: socket,
        else: put_flash(socket, :error, "Not enough players have joined.")

    {:noreply, socket}
  end

  defp setup(socket, game, game_code) do
    game_genserver_name = String.to_atom(game_code)
    chat_genserver_name = String.to_atom("chat_" <> game_code)

    game_genserver(game.name).start(game_genserver_name)
    Chat.GenServer.start(chat_genserver_name)
    Phoenix.PubSub.subscribe(Engage.PubSub, game_code)
    Phoenix.PubSub.subscribe(Engage.PubSub, "chat_" <> game_code)

    players =
      TicTacToe.GenServer.add_player(
        game_genserver_name,
        socket.assigns.player_id,
        socket.assigns.player_name
      )

    nth =
      TicTacToe.GenServer.get_player_nth_by_name(game_genserver_name, socket.assigns.player_name)

    messages = Chat.GenServer.view(chat_genserver_name)

    assign(socket,
      nth: nth,
      game: game,
      game_code: game_code,
      players: players,
      messages: messages,
      game_genserver_name: game_genserver_name,
      chat_genserver_name: chat_genserver_name,
      is_lobby_owner: socket.assigns.player_id === players.first.id
    )
  end

  defp game_genserver(game_name) do
    case game_name do
      "tic-tac-toe" ->
        TicTacToe.GenServer

      "memory" ->
        Memory.GenServer
    end
  end
end
