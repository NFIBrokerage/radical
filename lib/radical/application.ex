defmodule Radical.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {EventStore, Application.fetch_env!(:radical, EventStore)},
      {Radical.Handler, []}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
