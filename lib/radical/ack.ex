defmodule Radical.Ack do
  @moduledoc """
  Responsible for acking messages
  """

  alias Broadway.Message

  alias Extreme.Messages.{
    ResolvedIndexedEvent,
    EventRecord
  }

  require Logger

  def ack(producer, successful, failed) do
    Logger.debug("#{inspect(__MODULE__)} acking successful #{inspect(successful)} and nacking failed #{inspect(failed)}")

    send(producer, {:ack, take_ack_data(successful), take_ack_data(failed)})
  end

  defp take_ack_data(events) when is_list(events) do
    Enum.map(events, &take_ack_data/1)
  end

  defp take_ack_data(%Message{metadata: %{correlation_id: correlation_id}, data: %ResolvedIndexedEvent{link: %EventRecord{event_id: event_id}}}), do: %{event_id: event_id, correlation_id: correlation_id}
  defp take_ack_data(%Message{metadata: %{correlation_id: correlation_id}, data: %ResolvedIndexedEvent{event: %EventRecord{event_id: event_id}}}), do: %{event_id: event_id, correlation_id: correlation_id}
end
