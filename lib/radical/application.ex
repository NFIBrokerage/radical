defmodule Radical.Application do
  @moduledoc false

  use Application

  import Supervisor.Spec

  def start(_type, _args) do
    children = [
      worker(Extreme, [Application.fetch_env!(:radical, EventStore), [name: EventStore]]),
      {Radical.MyBroadway, []}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
