module Model exposing (..)

import FamilyTree.Scalar exposing (Id(..))
import Graphql.Http
import RemoteData exposing (RemoteData(..), WebData)
import Time exposing (Month, Posix)


type alias Model =
    { family : RemoteData (Graphql.Http.Error Family) Family
    , query : Maybe String
    , lastName : Maybe String
    , personDialog : Maybe PersonDialogConfig
    , now : Posix
    }


type alias Flags =
    { now : Int }


type alias Family =
    { tree : List Person
    , relationships : List Relationship
    }


type alias Person =
    { id : Id
    , firstName : String
    , lastName : String
    , sex : Sex
    , relationship : Maybe Id
    , birthDate : FullDate
    , deathDate : FullDate
    }


type alias FullDate =
    { day : Maybe Int
    , month : Maybe Month
    , year : Maybe Int
    }


type alias Relationship =
    { id : Id
    , children : List Id
    }


type Sex
    = Male
    | Female


type alias Bounds =
    { x1 : Float, x2 : Float }


type alias PersonDialogConfig =
    { person : Person
    , addingSpouse : Maybe Person
    , addingChild : Maybe Person
    , saveRequest : WebData ()
    }


type PersonField
    = LastName
    | FirstName


type Msg
    = NoOp
    | PersonSelected Person
    | SearchQueryUpdated String
    | LastNameSelected String
    | PersonDialogClosed
    | AddSpouseButtonPressed
    | NewSpouseNameUpdated PersonField String
    | ConfirmRelationshipButtonPressed
    | GotFamily (RemoteData (Graphql.Http.Error Family) Family)
    | GotCreateSpouseResponse (RemoteData (Graphql.Http.Error Family) Family)
    | AddChildButtonPressed
    | NewChildFirstNameUpdated String
    | SelectedChildSex String
    | ConfirmChildButtonPressed
    | GotCreateChildResponse (RemoteData (Graphql.Http.Error Family) Family)


personWidth : Float
personWidth =
    150


personHeight : Float
personHeight =
    40


heightBetweenParentsAndChildren : Float
heightBetweenParentsAndChildren =
    80


widthBetweenSiblings : Float
widthBetweenSiblings =
    36


widthBetweenSpouses : Float
widthBetweenSpouses =
    24


parentsWidth : Float
parentsWidth =
    2 * personWidth + widthBetweenSpouses


initPersonDialogConfig : Person -> PersonDialogConfig
initPersonDialogConfig person =
    { person = person
    , addingSpouse = Nothing
    , addingChild = Nothing
    , saveRequest = NotAsked
    }


sexFromString : String -> Sex
sexFromString str =
    case str of
        "Male" ->
            Male

        "Female" ->
            Female

        _ ->
            Male


sexToString : Sex -> String
sexToString sex =
    case sex of
        Male ->
            "Male"

        Female ->
            "Female"


initPerson : Person
initPerson =
    { id = Id "NEW"
    , firstName = ""
    , lastName = ""
    , sex = Male
    , relationship = Nothing
    , birthDate = initFullDate
    , deathDate = initFullDate
    }


initFullDate : FullDate
initFullDate =
    { day = Nothing, month = Nothing, year = Nothing }
