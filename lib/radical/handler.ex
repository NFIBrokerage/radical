defmodule Radical.Handler do
  use Broadway

  alias Broadway.Message

  def start_link(_opts) do
    producer_opts = Application.fetch_env!(:radical, :persistent_subscription)

    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: {Radical.Producer, producer_opts}
      ],
      processors: [
        default: [concurrency: 1]
      ]
    )
  end

  @impl Broadway
  def handle_message(_processor, %Message{data: event} = message, _context) do
    payload = decode_subscription_event(event)

    Process.sleep(500)

    IO.inspect(payload.count_id, label: "received event")

    message
  end

  defp decode_subscription_event(%{event: %{data: json_data}}) do
    Jason.decode!(json_data, keys: :atoms)
  end
end
