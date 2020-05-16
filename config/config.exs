use Mix.Config

config :radical, EventStore,
  db_type: :node,
  port: 1113,
  reconnect_delay: 2_000,
  max_attempts: :infinity,
  host: System.get_env("EVENTSTORE_HOST"),
  username: "admin",
  password: "changeit",
  connection_name: "radical"

config :extreme, :protocol_version, 4

config :logger, level: :info

config :radical, :persistent_subscription,
  stream: "$ce-IdentityService.Profile.dev",
  group: "v2",
  allowed_in_flight_messages: 1
