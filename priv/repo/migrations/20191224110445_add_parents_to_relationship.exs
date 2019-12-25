defmodule FamilyTree.Repo.Migrations.AddParentsToRelationship do
  use Ecto.Migration

  def change do
    alter table(:relationships) do
      add(:father_id, references(:people))
      add(:mother_id, references(:people))
    end
  end
end
