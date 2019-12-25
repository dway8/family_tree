# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     FamilyTree.Repo.insert!(%FamilyTree.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias FamilyTree.Repo
alias FamilyTree.Models.{Person, Relationship}

%Person{
  last_name: "Manière",
  first_name: "Olivier",
  sex: "Male"
}
|> Repo.insert!()
