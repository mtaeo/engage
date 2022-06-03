defmodule Engage.Games.RockPaperScissors.GenServer do
  use GenServer
  alias Engage.Games.RockPaperScissors.Player

  @game_name "rock-paper-scissors"

  def start(
        genserver_name,
        state \\ %{
          players: %{first: nil, second: nil}
        }
      )
      when is_atom(genserver_name) do
    GenServer.start(
      __MODULE__,
      Map.merge(state, %{
        genserver_name: genserver_name,
        game_id: Engage.Games.get_game_by_name(@game_name).id,
        game_name: @game_name,
        game_started?: false
      }),
      name: genserver_name
    )
  end

  def add_player(genserver_name, player_id, player_name) do
    GenServer.call(genserver_name, {:add_player, player_id, player_name})
  end

  def get_player_nth_by_name(genserver_name, player_name) do
    GenServer.call(genserver_name, {:get_player_nth_by_name, player_name})
  end

  def make_move(genserver_name, %Player{} = player, symbol) when is_atom(symbol) do
    GenServer.call(genserver_name, {:make_move, player, symbol})
  end

  def start_game(genserver_name, %Player{} = player) do
    GenServer.call(genserver_name, {:start_game, player})
  end

  def kick_player(genserver_name, nth, kicked_player_id) do
    GenServer.call(genserver_name, {:kick_player, nth, kicked_player_id})
  end

  def game_started?(genserver_name) do
    GenServer.call(genserver_name, :game_started?)
  end

  # Server API

  def handle_call({:add_player, player_id, player_name}, _from, state) do
    state =
      cond do
        state.players.first === nil ->
          player = %Player{id: player_id, name: player_name}
          put_in(state.players.first, player)

        state.players.second === nil and state.players.first.id !== player_id ->
          player = %Player{id: player_id, name: player_name}
          state = put_in(state.players.second, player)

          Phoenix.PubSub.broadcast(
            Engage.PubSub,
            Atom.to_string(state.genserver_name),
            state.players
          )

          state

        true ->
          state
      end

    {:reply, state.players, state}
  end

  def handle_call({:make_move, player, symbol}, _from, state)
      when not is_nil(player) and
             not is_nil(symbol) do
    state =
      if is_nil(player.symbol) do
        player = put_in(player.symbol, symbol)
        nth = get_player_nth_by_id(state, player.id)
        state = put_in(state.players[nth], player)

        Phoenix.PubSub.broadcast(
          Engage.PubSub,
          Atom.to_string(state.genserver_name),
          state.players
        )

        if both_players_chose_symbol?(state) do
          decide_winner(state)
        else
          state
        end
      else
        state
      end

    {:reply, state.players, state}
  end

  def handle_call({:get_player_nth_by_name, player_name}, _from, state) do
    {nth, _player} = get_player_nth_by_name_helper(state, player_name)
    {:reply, nth, state}
  end

  def handle_call({:start_game, player}, _from, state) when not is_nil(player) do
    {state, game_started?} =
      if player === state.players.first and all_players_joined?(state) do
        state = put_in(state.game_started?, true)
        :timer.send_after(0, {:game_started, state})
        {state, true}
      else
        {state, false}
      end

    {:reply, game_started?, state}
  end

  def handle_call({:kick_player, owner_nth, kicked_player_id}, _from, state) do
    state =
      if owner_nth === :first and
           state.players[owner_nth].id !== kicked_player_id and
           not state.game_started? do
        kicked_nth = get_player_nth_by_id(state, kicked_player_id)
        state = put_in(state.players[kicked_nth], nil)
        :timer.send_after(0, {:send_players, state})
        state
      else
        state
      end

    {:reply, nil, state}
  end

  def handle_call(:game_started?, _from, state) do
    {:reply, state.game_started?, state}
  end

  def init(state) do
    {:ok, state}
  end

  def handle_info({:game_started, state}, _state) do
    Phoenix.PubSub.broadcast(
      Engage.PubSub,
      Atom.to_string(state.genserver_name),
      :game_started
    )

    {:noreply, state}
  end

  def handle_info(:replay, state) do
    state = put_in(state.players.first.symbol, nil)
    state = put_in(state.players.second.symbol, nil)

    Phoenix.PubSub.broadcast(
      Engage.PubSub,
      Atom.to_string(state.genserver_name),
      state.players
    )

    {:noreply, state}
  end

  defp decide_winner(state) do
    winner_nth =
      case {state.players[:first].symbol, state.players[:second].symbol} do
        {:rock, :paper} -> :second
        {:rock, :scissors} -> :first
        {:paper, :rock} -> :first
        {:paper, :scissors} -> :second
        {:scissors, :rock} -> :second
        {:scissors, :paper} -> :first
        _ -> nil
      end

    state =
      if is_nil(winner_nth) do
        state
      else
        update_in(state.players[winner_nth].score, &(&1 + 1))
      end

    :timer.send_after(2500, :replay)

    state
  end

  defp both_players_chose_symbol?(state) do
    not Enum.any?(state.players, fn {_nth, player} -> is_nil(player.symbol) end)
  end

  defp all_players_joined?(state) do
    state.players.first !== nil and state.players.second !== nil
  end

  defp get_player_nth_by_name_helper(state, player_name) do
    Enum.find(state.players, fn {_, v} -> v.name === player_name end)
  end

  defp get_player_nth_by_id(state, player_id) when is_integer(player_id) do
    {nth, _player} = Enum.find(state.players, fn {_nth, player} -> player.id === player_id end)
    nth
  end
end
