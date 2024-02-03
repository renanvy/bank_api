import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :bank_api, BankApi.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "bank_api_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :bank_api, BankApiWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "xFRRaIdycXaxh1/GcPONv7a88a/3g2Q7gR6ovzkj+tiLwLJs7NPOpv00ZQaWZ5ZS",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :bank_api, BankApiWeb.Auth.Guardian,
  issuer: "bank_api",
  secret_key: "VK7x3+aCAHtwVlTBXHtb2J9yYJ9+kHjpNF3B6MDBbjFZWFoG06PVZ9PYiiTxk+gm"
