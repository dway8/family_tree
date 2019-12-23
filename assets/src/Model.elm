module Model exposing (..)


type alias Model =
    { tree : List Person
    , query : Maybe String
    , lastName : Maybe String
    , relationships : List Relationship
    , personDialog : Maybe PersonDialogConfig
    }


type alias Person =
    { id : Id
    , firstName : String
    , lastName : String
    , sex : Sex
    , relationship : Maybe Id
    }


type alias Relationship =
    { id : Id
    , children : List Id
    }


type Sex
    = Male
    | Female


type alias Id =
    Int


type alias Bounds =
    { x1 : Float, x2 : Float }


type alias PersonDialogConfig =
    { person : Person
    , addingSpouseLastName : Maybe String
    , addingSpouseFirstName : Maybe String
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
    , addingSpouseLastName = Nothing
    , addingSpouseFirstName = Nothing
    }
