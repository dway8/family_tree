defmodule FamilyTree.Models.Person do
  use Ecto.Schema
  import Ecto.Changeset

  schema "people" do
    field :first_name, :string
    field :last_name, :string
    field :sex, :string

    timestamps()
  end

  @doc false
  def changeset(person, attrs) do
    person
    |> cast(attrs, [:last_name, :first_name, :sex])
    |> validate_required([:last_name, :first_name, :sex])
  end
end
