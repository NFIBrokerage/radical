defmodule Radical.Producer do
  @moduledoc """
  A Broadway producer
  """

  use GenStage

  import Logger, only: [debug: 1]

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
      Extreme.connect_to_persistent_subscription(EventStore, self(), "v2", "$ce-IdentityService.Profile.dev", 15)

    {:noreply, [], Map.put(state, :subscription, subscription)}
  end

  def handle_info({:on_event, event, correlation_id}, state) do
    debug("#{inspect(__MODULE__)} got event #{inspect(event)}")

    {:noreply, Enum.map([event], &transform(&1, correlation_id)), state}
  end

  def handle_cast({:ack, successful, failed} = msg, %{subscription: subscription_proc} = state) do
    successful
    |> Enum.each(fn %{correlation_id: correlation_id, event_id: event_id} ->
      :ok = Extreme.PersistentSubscription.ack(subscription_proc, event_id, correlation_id)
    end)

    failed
    |> Enum.each(fn %{correlation_id: correlation_id, event_id: event_id} ->
      :ok = Extreme.PersistentSubscription.nack(subscription_proc, event_id, correlation_id, :Retry)
    end)

    {:noreply, [], state}
  end

  def handle_demand(_demand, state), do: {:noreply, [], state}

  def transform(event, correlation_id) do
    %Message{
      data: event,
      metadata: %{correlation_id: correlation_id},
      acknowledger: {Radical.Ack, :ack_id, %{producer: self()}}
    }
  end
end
