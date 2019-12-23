defmodule FamilyTree.Repo do
  use Ecto.Repo,
    otp_app: :family_tree,
    adapter: Ecto.Adapters.Postgres
end
