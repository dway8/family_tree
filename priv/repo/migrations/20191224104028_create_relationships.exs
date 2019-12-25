defmodule FamilyTree.Repo.Migrations.CreateRelationships do
  use Ecto.Migration

  def change do
    create table(:relationships) do
      add(:children, {:array, :integer})

      timestamps()
    end
  end
end
