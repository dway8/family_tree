defmodule FamilyTree.Repo.Migrations.CreatePeople do
  use Ecto.Migration

  def change do
    create table(:people) do
      add :last_name, :string
      add :first_name, :string
      add :sex, :string

      timestamps()
    end

  end
end
