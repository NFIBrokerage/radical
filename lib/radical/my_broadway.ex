defmodule Radical.MyBroadway do
  use Broadway

  alias Broadway.Message

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: {Radical.Producer, []}
      ],
      processors: [
        default: [concurrency: 1]
      ]
    )
  end

  @impl Broadway
  def handle_message(_processor, %Message{} = message, _context) do
    IO.inspect(message, label: "message")
  end
end
