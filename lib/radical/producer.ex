defmodule Radical.Producer do
  @moduledoc """
  A Broadway producer
  """

  use GenStage

  alias Extreme.Messages.PersistentSubscriptionStreamEventAppeared

  require Logger

  alias Broadway.Message

  def start_link(opts) do
    GenStage.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    send(self(), :subscribe)

    {:producer, Map.new(opts)}
  end

  def handle_info(:subscribe, state) do
    {:ok, subscription} =
      EventStore.connect_to_persistent_subscription(
        state.stream,
        state.group,
        self(),
        state.allowed_in_flight_messages
      )

    {:noreply, [], Map.put(state, :subscription, subscription)}
  end

  def handle_info({:on_event, event, correlation_id}, state) do
    Logger.debug("#{inspect(__MODULE__)} got event #{inspect(event)}")

    {:noreply, Enum.map([event], &transform(&1, correlation_id)), state}
  end

  def handle_info({:ack, _successful, _failed} = msg, %{subscription: subscription_proc} = state) do
    send(subscription_proc, msg)

    {:noreply, [], state}
  end

  def handle_demand(_demand, state), do: {:noreply, [], state}

  def transform(%PersistentSubscriptionStreamEventAppeared{event: event}, correlation_id) do
    %Message{
      data: event,
      metadata: %{correlation_id: correlation_id},
      acknowledger: {Radical.Ack, self(), []}
    }
  end
end
