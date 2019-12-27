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

  @doc """
  Gets a single person.
  """
  def get_person(id) do
    Logger.info("Getting person with id #{id}")

    Repo.get(Person, id)
  end

  def create_child(relationship, child_attrs) do
    father =
      relationship.father_id
      |> get_person()

    child_attrs
    |> Map.put(:last_name, father.last_name)
    |> create_person()
  end
end
