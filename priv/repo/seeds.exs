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
    sex: "Male",
    birth_year: 1954
  }
  |> Repo.insert!()

blandine =
  %Person{
    last_name: "Jantet",
    first_name: "Blandine",
    sex: "Female",
    birth_year: 1959
  }
  |> Repo.insert!()

vianney =
  %Person{
    last_name: "Manière",
    first_name: "Vianney",
    sex: "Male",
    birth_year: 1987
  }
  |> Repo.insert!()

diane =
  %Person{
    last_name: "Manière",
    first_name: "Diane",
    sex: "Female",
    birth_year: 1988
  }
  |> Repo.insert!()

mederic =
  %Person{
    last_name: "Manière",
    first_name: "Médéric",
    sex: "Male",
    birth_year: 1992
  }
  |> Repo.insert!()

melchior =
  %Person{
    last_name: "Manière",
    first_name: "Melchior",
    sex: "Male",
    birth_year: 1993
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
    sex: "Female",
    birth_year: 1987
  }
  |> Repo.insert!()

timothee =
  %Person{
    last_name: "Manière",
    first_name: "Timothée",
    sex: "Male",
    birth_year: 2019
  }
  |> Repo.insert!()

felix =
  %Person{
    last_name: "Manière",
    first_name: "Felix",
    sex: "Male",
    birth_year: 2017
  }
  |> Repo.insert!()

%Relationship{
  father_id: vianney.id,
  mother_id: orlane.id,
  children: [timothee.id, felix.id]
}
|> Repo.insert!()
