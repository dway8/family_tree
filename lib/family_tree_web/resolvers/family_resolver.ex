defmodule FamilyTreeWeb.FamilyResolver do
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

  def create_spouse(args, _info) do
    Logger.info("Creating spouse with args #{inspect(args)}")

    case People.create_person(args.spouse) do
      {:error, _} ->
        {:error, "Error when creating spouse"}

      {:ok, spouse} ->
        Logger.info("Created spouse with id #{spouse.id}")

        rel_attrs =
          if spouse.sex == "Male" do
            %{father_id: spouse.id, mother_id: args.person_id}
          else
            %{mother_id: spouse.id, father_id: args.person_id}
          end
          |> Map.put(:children, [])

        case Relationships.create_relationship(rel_attrs) do
          {:error, _} ->
            {:error, "Error when creating relationship"}

          {:ok, relationship} ->
            Logger.info("Created relationship with id #{relationship.id}")
            get_all({}, {}, {})
        end
    end
  end

  def create_child(args, _info) do
    Logger.info("Creating child with args #{inspect(args)}")

    relationship = Relationships.get_relationship(args.relationship_id)

    case People.create_child(relationship, args.child) do
      {:error, _} ->
        {:error, "Error when creating child"}

      {:ok, child} ->
        Logger.info("Created child with id #{child.id}")

        rel_attrs = %{children: Enum.concat(relationship.children, [child.id])}

        case Relationships.update_relationship(relationship, rel_attrs) do
          {:error, _} ->
            {:error, "Error when updating relationship #{relationship.id}"}

          {:ok, relationship} ->
            get_all({}, {}, {})
        end
    end
  end
end
