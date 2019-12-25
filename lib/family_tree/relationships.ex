defmodule FamilyTree.Relationships do
  alias FamilyTree.Models.Relationship
  alias FamilyTree.Repo

  def get_relationships() do
    Repo.all(Relationship)
  end
end
