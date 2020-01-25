module Api exposing (createChild, createSpouse, getFamily)

import FamilyTree.InputObject
import FamilyTree.Mutation as Mutation
import FamilyTree.Object
import FamilyTree.Object.Family as Family
import FamilyTree.Object.Person as Person
import FamilyTree.Object.Relationship as Relationship
import FamilyTree.Query as Query
import FamilyTree.Scalar exposing (Id(..))
import Graphql.Http
import Graphql.OptionalArgument as GOA
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet, with)
import Model exposing (Family, FullDate, Msg(..), Person, Relationship, Sex(..))
import RemoteData
import Time exposing (Month(..))


endpoint : String
endpoint =
    "/elixir/graphql"


getFamily : Cmd Msg
getFamily =
    Query.family familySelection
        |> Graphql.Http.queryRequest endpoint
        -- We have to use `withCredentials` to support a CORS endpoint that allows a wildcard origin
        |> Graphql.Http.withCredentials
        |> Graphql.Http.send (RemoteData.fromResult >> GotFamily)


createSpouse : Id -> Person -> Cmd Msg
createSpouse personId spouse =
    Mutation.createSpouse
        { personId = personId
        , spouse =
            { firstName = spouse.firstName
            , lastName = spouse.lastName
            , sex = Model.sexToString spouse.sex
            , birthDate = fullDateToParams spouse.birthDate
            , deathDate = fullDateToParams spouse.deathDate
            }
        }
        familySelection
        |> Graphql.Http.mutationRequest endpoint
        |> Graphql.Http.withCredentials
        |> Graphql.Http.send (RemoteData.fromResult >> GotCreateSpouseResponse)


fullDateToParams : FullDate -> FamilyTree.InputObject.FullDateParams
fullDateToParams { day, month, year } =
    { day = day |> GOA.fromMaybe
    , month = month |> Maybe.map monthToInt |> GOA.fromMaybe
    , year = year |> GOA.fromMaybe
    }


createChild : Id -> Person -> Cmd Msg
createChild relationshipId child =
    Mutation.createChild
        { relationshipId = relationshipId
        , child =
            { firstName = child.firstName
            , sex = Model.sexToString child.sex
            , birthDate = fullDateToParams child.birthDate
            , deathDate = fullDateToParams child.deathDate
            }
        }
        familySelection
        |> Graphql.Http.mutationRequest endpoint
        |> Graphql.Http.withCredentials
        |> Graphql.Http.send (RemoteData.fromResult >> GotCreateChildResponse)


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
        |> with (SelectionSet.map Model.sexFromString Person.sex)
        |> with Person.relationshipId
        |> with birthDateFragment
        |> with deathDateFragment


birthDateFragment : SelectionSet FullDate FamilyTree.Object.Person
birthDateFragment =
    SelectionSet.succeed FullDate
        |> with Person.birthDay
        |> with (SelectionSet.map monthFromInt Person.birthMonth)
        |> with Person.birthYear


deathDateFragment : SelectionSet FullDate FamilyTree.Object.Person
deathDateFragment =
    SelectionSet.succeed FullDate
        |> with Person.deathDay
        |> with (SelectionSet.map monthFromInt Person.deathMonth)
        |> with Person.deathYear


monthFromInt : Maybe Int -> Maybe Month
monthFromInt =
    Maybe.andThen
        (\int ->
            case int of
                1 ->
                    Just Jan

                2 ->
                    Just Feb

                3 ->
                    Just Mar

                4 ->
                    Just Apr

                5 ->
                    Just May

                6 ->
                    Just Jun

                7 ->
                    Just Jul

                8 ->
                    Just Aug

                9 ->
                    Just Sep

                10 ->
                    Just Oct

                11 ->
                    Just Nov

                12 ->
                    Just Dec

                _ ->
                    Nothing
        )


monthToInt : Month -> Int
monthToInt month =
    case month of
        Jan ->
            1

        Feb ->
            2

        Mar ->
            3

        Apr ->
            4

        May ->
            5

        Jun ->
            6

        Jul ->
            7

        Aug ->
            8

        Sep ->
            9

        Oct ->
            10

        Nov ->
            11

        Dec ->
            12


relationshipSelection : SelectionSet Relationship FamilyTree.Object.Relationship
relationshipSelection =
    SelectionSet.succeed Relationship
        |> with Relationship.id
        |> with Relationship.children
