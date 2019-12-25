defmodule FamilyTreeWeb.PeopleResolver do
  require Logger

  alias FamilyTree.{People, Relationships}

  def get_all(_root, _args, _info) do
    case People.get_people() do
      nil ->
        {:error, "Error when fetching people"}

      people ->
        case Relationships.get_relationships() do
          nil ->
            {:error, "Error when fetching relationships"}

          relationships ->
            people =
              people
              |> Enum.map(fn person ->
                searchFn =
                  if person.sex == "Male" do
                    fn rel -> rel.father_id == person.id end
                  else
                    fn rel -> rel.mother_id == person.id end
                  end

                personRel =
                  relationships
                  |> Enum.find(searchFn)

                if personRel do
                  person
                  |> Map.put(:relationship_id, personRel.id)
                else
                  person
                end
              end)

            family = %{people: people, relationships: relationships}
            {:ok, family}
        end
    end
  end
end
