defmodule Radical.Ack do
  @moduledoc """
  Responsible for acking messages
  """

  alias Broadway.Message

  alias Extreme.Msg.{
    PersistentSubscriptionStreamEventAppeared,
    ResolvedIndexedEvent,
    EventRecord
  }

  require Logger

  def ack(:ack_id, successful, failed) do
    Logger.debug("#{inspect(__MODULE__)} handling successful #{inspect(successful)} and failed #{inspect(failed)}")

    producer = producer_proc(successful, failed)

    :ok = GenServer.cast(producer, {:ack, take_ack_data(successful), take_ack_data(failed)})
  end

  defp take_ack_data(events) when is_list(events) do
    Enum.map(events, &take_ack_data/1)
  end

  defp take_ack_data(%Message{metadata: %{correlation_id: correlation_id}, data: %ResolvedIndexedEvent{link: %EventRecord{event_id: event_id}}}), do: %{event_id: event_id, correlation_id: correlation_id}
  defp take_ack_data(%Message{metadata: %{correlation_id: correlation_id}, data: %ResolvedIndexedEvent{event: %EventRecord{event_id: event_id}}}), do: %{event_id: event_id, correlation_id: correlation_id}

  defp producer_proc([%Message{acknowledger: {__MODULE__, _ack_ref, %{producer: producer_pid}}} | _], _failed), do: producer_pid
  defp producer_proc(_successful, [%Message{acknowledger: {__MODULE__, _ack_ref, %{producer: producer_pid}}} | _]), do: producer_pid
end
