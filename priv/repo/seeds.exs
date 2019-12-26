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

olivier =
  %Person{
    last_name: "Manière",
    first_name: "Olivier",
    sex: "Male"
  }
  |> Repo.insert!()

blandine =
  %Person{
    last_name: "Jantet",
    first_name: "Blandine",
    sex: "Female"
  }
  |> Repo.insert!()

vianney =
  %Person{
    last_name: "Manière",
    first_name: "Vianney",
    sex: "Male"
  }
  |> Repo.insert!()

diane =
  %Person{
    last_name: "Manière",
    first_name: "Diane",
    sex: "Female"
  }
  |> Repo.insert!()

mederic =
  %Person{
    last_name: "Manière",
    first_name: "Médéric",
    sex: "Male"
  }
  |> Repo.insert!()

melchior =
  %Person{
    last_name: "Manière",
    first_name: "Melchior",
    sex: "Male"
  }
  |> Repo.insert!()

%Relationship{
  father_id: olivier.id,
  mother_id: blandine.id,
  children: [vianney.id, diane.id, mederic.id, melchior.id]
}
|> Repo.insert!()

orlane =
  %Person{
    last_name: "Felix",
    first_name: "Orlane",
    sex: "Female"
  }
  |> Repo.insert!()

felix =
  %Person{
    last_name: "Manière",
    first_name: "Felix",
    sex: "Male"
  }
  |> Repo.insert!()

timothee =
  %Person{
    last_name: "Manière",
    first_name: "Timothée",
    sex: "Male"
  }
  |> Repo.insert!()

%Relationship{
  father_id: vianney.id,
  mother_id: orlane.id,
  children: [felix.id, timothee.id]
}
|> Repo.insert!()
