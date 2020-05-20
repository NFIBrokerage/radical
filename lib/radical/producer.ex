defmodule Radical.Producer do
  @moduledoc """
  A Broadway producer
  """

  use GenStage

  require Logger

  alias Broadway.Message

  def start_link(opts) do
    GenStage.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    GenStage.cast(self(), :subscribe)

    {:producer, Map.new(opts)}
  end

  def handle_cast(:subscribe, state) do
    {:ok, subscription} =
      EventStore.connect_to_persistent_subscription(
        self(),
        state.stream,
        state.group,
        state.allowed_in_flight_messages
      )

    {:noreply, [], Map.put(state, :subscription, subscription)}
  end

  def handle_cast({:on_event, event, correlation_id}, %{subscription: subscription} = state) do
    Logger.debug("#{inspect(__MODULE__)} got event #{inspect(event)}")

    message = %Message{
      data: event,
      acknowledger:
        {Radical.Ack, subscription, %{correlation_id: correlation_id}}
    }

    {:noreply, [message], state}
  end

  def handle_info({:extreme, event}, state) do
    Logger.debug("Received extreme update: #{inspect(event)}")

    {:noreply, [], state}
  end

  def handle_demand(_demand, state), do: {:noreply, [], state}
end
