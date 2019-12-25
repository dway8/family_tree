defmodule FamilyTree.People do
  alias FamilyTree.Models.Person
  alias FamilyTree.Repo

  def get_people() do
    Repo.all(Person)
  end
end
