module Api exposing (getFamily)

import FamilyTree.Object
import FamilyTree.Object.Family as Family
import FamilyTree.Object.Person as Person
import FamilyTree.Object.Relationship as Relationship
import FamilyTree.Query as Query
import Graphql.Http
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet, with)
import Model exposing (Family, Msg(..), Person, Relationship, Sex(..))
import RemoteData


endpoint : String
endpoint =
    "/elixir/graphql"


getFamily : String -> Cmd Msg
getFamily lastName =
    Query.family { lastName = lastName } familySelection
        |> Graphql.Http.queryRequest endpoint
        -- We have to use `withCredentials` to support a CORS endpoint that allows a wildcard origin
        |> Graphql.Http.withCredentials
        |> Graphql.Http.send (RemoteData.fromResult >> GotFamily)


familySelection : SelectionSet Family FamilyTree.Object.Family
familySelection =
    SelectionSet.succeed Family
        |> with (Family.people personSelection)
        |> with (Family.relationships relationshipSelection)


personSelection : SelectionSet Person FamilyTree.Object.Person
personSelection =
    SelectionSet.succeed Person
        |> with Person.id
        |> with Person.firstName
        |> with Person.lastName
        |> with (SelectionSet.map sexFromString Person.sex)
        |> with Person.relationshipId


relationshipSelection : SelectionSet Relationship FamilyTree.Object.Relationship
relationshipSelection =
    SelectionSet.succeed Relationship
        |> with Relationship.id
        |> with Relationship.children


sexFromString : String -> Sex
sexFromString str =
    case str of
        "Male" ->
            Male

        "Female" ->
            Female

        _ ->
            Male
