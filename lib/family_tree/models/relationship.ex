defmodule FamilyTree.Models.Relationship do
  use Ecto.Schema
  import Ecto.Changeset

  alias FamilyTree.Models.Person

  schema "relationships" do
    belongs_to(:father, Person)
    belongs_to(:mother, Person)
    field(:children, {:array, :integer})
    timestamps()
  end

  @doc false
  def changeset(relationship, attrs) do
    relationship
    |> cast(attrs, [:children])
    |> validate_required([])
  end
end
