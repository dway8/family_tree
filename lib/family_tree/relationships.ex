defmodule FamilyTree.Relationships do
  require Logger

  alias FamilyTree.Models.Relationship
  alias FamilyTree.Repo

  def get_relationships() do
    Repo.all(Relationship)
  end

  def create_relationship(attrs) do
    Logger.info("Creating relationship with attrs #{inspect(attrs)}")

    %Relationship{}
    |> Relationship.changeset(attrs)
    |> Repo.insert()
  end
end
