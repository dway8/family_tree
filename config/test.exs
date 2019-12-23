use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :family_tree, FamilyTreeWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :family_tree, FamilyTree.Repo,
  username: "postgres",
  password: "postgres",
  database: "family_tree_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
