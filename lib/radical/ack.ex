defmodule Radical.Ack do
  @moduledoc """
  Responsible for acking messages
  """

  alias Broadway.Message

  alias Extreme.PersistentSubscription

  alias Extreme.Messages.{
    ResolvedIndexedEvent,
    EventRecord
  }

  require Logger

  def ack(subscription, successful, failed) do
    Logger.debug(
      "#{inspect(__MODULE__)} acking successful #{inspect(successful)} and nacking failed #{
        inspect(failed)
      }"
    )

    :ok =
      successful
      |> batch_by_correlation_id()
      |> Enum.each(fn {correlation_id, event_ids} ->
        :ok =
          PersistentSubscription.ack(subscription, event_ids, correlation_id)
      end)

    :ok =
      failed
      |> batch_by_correlation_id()
      |> Enum.each(fn {correlation_id, event_ids} ->
        :ok =
          PersistentSubscription.nack(
            subscription,
            event_ids,
            correlation_id,
            :retry
          )
      end)

    :ok
  end

  defp batch_by_correlation_id(messages) do
    messages
    |> Enum.map(&take_ack_data/1)
    |> Enum.reduce(%{}, fn %{event_id: event_id, correlation_id: correlation_id},
                           acc ->
      Map.update(acc, correlation_id, [event_id], &[event_id | &1])
    end)
  end

  defp take_ack_data(%Message{
         acknowledger:
           {__MODULE__, _subscription, %{correlation_id: correlation_id}},
         data: %ResolvedIndexedEvent{link: %EventRecord{event_id: event_id}}
       }),
       do: %{event_id: event_id, correlation_id: correlation_id}

  defp take_ack_data(%Message{
         acknowledger:
           {__MODULE__, _subscription, %{correlation_id: correlation_id}},
         data: %ResolvedIndexedEvent{event: %EventRecord{event_id: event_id}}
       }),
       do: %{event_id: event_id, correlation_id: correlation_id}
end
