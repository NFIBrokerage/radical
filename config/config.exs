use Mix.Config

config :radical, EventStore,
  db_type: :node,
  port: 1113,
  username: "admin",
  reconnect_delay: 2_000,
  max_attempts: :infinity,
  host: System.get_env("EVENTSTORE_HOST"),
  password: "changeit",
  connection_name: "radical"

config :extreme, :protocol_version, 4

# config :logger, level: :info
