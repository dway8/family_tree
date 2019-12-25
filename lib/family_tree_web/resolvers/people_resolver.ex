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
            family = %{people: people, relationships: relationships}
            {:ok, family}
        end
    end
  end
end
