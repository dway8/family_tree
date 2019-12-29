defmodule FamilyTree.Repo.Migrations.AddDatesToPerson do
  use Ecto.Migration

  def change do
    alter table(:people) do
      add :birth_day, :integer
      add :birth_month, :integer
      add :birth_year, :integer
      add :death_day, :integer
      add :death_month, :integer
      add :death_year, :integer
    end
  end
end
