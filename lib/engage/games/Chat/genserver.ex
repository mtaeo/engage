defmodule Engage.Games.Chat.GenServer do
  use GenServer
  alias Engage.Games.Chat.Message

  def start(
        genserver_name,
        state \\ %{messages: []}
      )
      when is_atom(genserver_name) do
    GenServer.start(
      __MODULE__,
      Map.merge(state, %{
        genserver_name: genserver_name
      }),
      name: genserver_name
    )
  end

  def send_message(genserver_name, %Message{} = message) do
    GenServer.call(genserver_name, {:send_message, message})
  end

  def view(genserver_name) do
    GenServer.call(genserver_name, :view)
  end

  # Server API

  def handle_call({:send_message, message}, _from, state) do
    state = put_in(state.messages, [message | state.messages])

    Phoenix.PubSub.broadcast(
      Engage.PubSub,
      Atom.to_string(state.genserver_name),
      state.messages
    )

    {:reply, state.messages, state}
  end

  def handle_call(:view, _from, state) do
    {:reply, state.messages, state}
  end

  def init(state) do
    {:ok, state}
  end

end
