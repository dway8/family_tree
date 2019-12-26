defmodule FamilyTree.People do
  require Logger

  alias FamilyTree.Models.Person
  alias FamilyTree.Repo

  def get_people() do
    Repo.all(Person)
  end

  def create_person(attrs) do
    Logger.info("Creating person with attrs #{inspect(attrs)}")

    %Person{}
    |> Person.changeset(attrs)
    |> Repo.insert()
  end
end
