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

  @doc """
  Gets a single relationship.
  """
  def get_relationship(id) do
    Logger.info("Getting relationship with id #{id}")

    Repo.get(Relationship, id)
  end

  @doc """
  Updates a relationship.
  """
  def update_relationship(%Relationship{} = relationship, attrs) do
    relationship
    |> Relationship.changeset(attrs)
    |> Repo.update()
  end
end
