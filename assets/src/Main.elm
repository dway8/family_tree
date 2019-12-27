module Main exposing (..)

import Api
import Browser
import Browser.Navigation as Nav
import Dict exposing (Dict)
import Html exposing (Html)
import Http
import Model exposing (Model, Msg(..), Person, PersonField(..), Sex(..))
import RemoteData as RD exposing (RemoteData(..))
import Url exposing (Url)
import View


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = View.view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = always NoOp
        , onUrlChange = always NoOp
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( { family = Loading
      , query = Nothing
      , lastName = Nothing
      , personDialog = Nothing
      }
    , Api.getFamily
    )



-- [ { id = 1, children = [ 5, 6 ] }
-- , { id = 2, children = [ 1, 9, 10, 18 ] }
-- , { id = 3, children = [ 16, 17, 2 ] }
-- , { id = 4, children = [ 20, 21, 22 ] }
-- , { id = 5, children = [ 11, 27, 3, 13, 28 ] }
-- , { id = 6, children = [ 24, 25, 26 ] }
-- ]
-- [ { id = 1
--   , firstName = "Vianney"
--   , lastName = "Manière"
--   , sex = Male
--   , relationship = Just 1
--   }
-- , { id = 2
--   , firstName = "Blandine"
--   , lastName = "Jantet"
--   , sex = Female
--   , relationship = Just 2
--   }
-- , { id = 3
--   , firstName = "Olivier"
--   , lastName = "Manière"
--   , sex = Male
--   , relationship = Just 2
--   }
-- , { id = 4
--   , firstName = "Orlane"
--   , lastName = "Félix"
--   , sex = Female
--   , relationship = Just 1
--   }
-- , { id = 5
--   , firstName = "Felix"
--   , lastName = "Manière"
--   , sex = Male
--   , relationship = Nothing
--   }
-- , { id = 6
--   , firstName = "Timothée"
--   , lastName = "Manière"
--   , sex = Male
--   , relationship = Nothing
--   }
-- , { id = 7
--   , firstName = "Alice"
--   , lastName = "Moulin"
--   , sex = Female
--   , relationship = Just 3
--   }
-- , { id = 8
--   , firstName = "Georges"
--   , lastName = "Jantet"
--   , sex = Male
--   , relationship = Just 3
--   }
-- , { id = 9
--   , firstName = "Diane"
--   , lastName = "Manière"
--   , sex = Female
--   , relationship = Nothing
--   }
-- , { id = 10
--   , firstName = "Médéric"
--   , lastName = "Manière"
--   , sex = Male
--   , relationship = Nothing
--   }
-- , { id = 11
--   , firstName = "Dominique"
--   , lastName = "Manière"
--   , sex = Male
--   , relationship = Just 4
--   }
-- , { id = 13
--   , firstName = "Sophie"
--   , lastName = "Manière"
--   , sex = Female
--   , relationship = Nothing
--   }
-- , { id = 14
--   , firstName = "Nicole"
--   , lastName = "de Kernafflen de Kergos"
--   , sex = Female
--   , relationship = Just 5
--   }
-- , { id = 15
--   , firstName = "Paul-Henry"
--   , lastName = "Manière"
--   , sex = Male
--   , relationship = Just 5
--   }
-- , { id = 16
--   , firstName = "Martine"
--   , lastName = "Jantet"
--   , sex = Female
--   , relationship = Nothing
--   }
-- , { id = 17
--   , firstName = "Bruno"
--   , lastName = "Jantet"
--   , sex = Male
--   , relationship = Just 6
--   }
-- , { id = 18
--   , firstName = "Melchior"
--   , lastName = "Manière"
--   , sex = Male
--   , relationship = Nothing
--   }
-- , { id = 19
--   , firstName = "Chantal"
--   , lastName = "de Saint-Mars"
--   , sex = Female
--   , relationship = Just 4
--   }
-- , { id = 20
--   , firstName = "Pierre"
--   , lastName = "Manière"
--   , sex = Male
--   , relationship = Nothing
--   }
-- , { id = 21
--   , firstName = "Paul-Marie"
--   , lastName = "Manière"
--   , sex = Male
--   , relationship = Nothing
--   }
-- , { id = 22
--   , firstName = "Edmée"
--   , lastName = "Manière"
--   , sex = Female
--   , relationship = Nothing
--   }
-- , { id = 23
--   , firstName = "Isabelle"
--   , lastName = "Giraud"
--   , sex = Female
--   , relationship = Just 6
--   }
-- , { id = 24
--   , firstName = "Benoît"
--   , lastName = "Jantet"
--   , sex = Male
--   , relationship = Nothing
--   }
-- , { id = 25
--   , firstName = "Henry"
--   , lastName = "Jantet"
--   , sex = Male
--   , relationship = Nothing
--   }
-- , { id = 26
--   , firstName = "Constant"
--   , lastName = "Jantet"
--   , sex = Male
--   , relationship = Nothing
--   }
-- , { id = 27
--   , firstName = "Roseline"
--   , lastName = "Manière"
--   , sex = Female
--   , relationship = Nothing
--   }
-- , { id = 28
--   , firstName = "Nicolas"
--   , lastName = "Manière"
--   , sex = Male
--   , relationship = Nothing
--   }
-- ]
--


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        PersonSelected person ->
            ( { model | personDialog = Just <| Model.initPersonDialogConfig person }, Cmd.none )

        SearchQueryUpdated query ->
            ( { model | query = Just query }, Cmd.none )

        LastNameSelected lastName ->
            ( { model | lastName = Just lastName, query = Nothing }, Cmd.none )

        PersonDialogClosed ->
            ( { model | personDialog = Nothing }, Cmd.none )

        AddSpouseButtonPressed ->
            let
                newPersonDialog =
                    model.personDialog
                        |> Maybe.map
                            (\pd ->
                                { pd
                                    | addingSpouseLastName = Just ""
                                    , addingSpouseFirstName = Just ""
                                }
                            )
            in
            ( { model | personDialog = newPersonDialog }, Cmd.none )

        NewSpouseNameUpdated field val ->
            let
                newPersonDialog =
                    model.personDialog
                        |> Maybe.map
                            (\pd ->
                                case field of
                                    LastName ->
                                        { pd | addingSpouseLastName = Just val }

                                    FirstName ->
                                        { pd | addingSpouseFirstName = Just val }
                            )
            in
            ( { model | personDialog = newPersonDialog }, Cmd.none )

        ConfirmRelationshipButtonPressed ->
            case model.personDialog of
                Nothing ->
                    ( model, Cmd.none )

                Just ({ person, addingSpouseLastName, addingSpouseFirstName } as personDialog) ->
                    case ( addingSpouseLastName, addingSpouseFirstName ) of
                        ( Just lastName, Just firstName ) ->
                            let
                                newPersonDialog =
                                    { personDialog | saveRequest = Loading }

                                spouseSex =
                                    case person.sex of
                                        Male ->
                                            Female

                                        Female ->
                                            Male
                            in
                            ( { model | personDialog = Just newPersonDialog }, Api.createSpouse person.id lastName firstName spouseSex )

                        _ ->
                            ( model, Cmd.none )

        GotFamily resp ->
            ( { model | family = resp }, Cmd.none )

        GotCreateSpouseResponse resp ->
            case model.personDialog of
                Just personDialog ->
                    case resp of
                        Success family ->
                            ( { model | family = resp, personDialog = Nothing }, Cmd.none )

                        _ ->
                            let
                                newPersonDialog =
                                    { personDialog | saveRequest = Failure (Http.BadBody "") }
                            in
                            ( { model | personDialog = Just newPersonDialog }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        AddChildButtonPressed ->
            let
                newPersonDialog =
                    model.personDialog
                        |> Maybe.map
                            (\pd ->
                                { pd
                                    | addingChildFirstName = Just ""
                                    , addingChildSex = Just Male
                                }
                            )
            in
            ( { model | personDialog = newPersonDialog }, Cmd.none )

        NewChildFirstNameUpdated val ->
            let
                newPersonDialog =
                    model.personDialog
                        |> Maybe.map
                            (\pd -> { pd | addingChildFirstName = Just val })
            in
            ( { model | personDialog = newPersonDialog }, Cmd.none )

        SelectedChildSex str ->
            let
                newPersonDialog =
                    model.personDialog
                        |> Maybe.map
                            (\pd -> { pd | addingChildSex = Just (Model.sexFromString str) })
            in
            ( { model | personDialog = newPersonDialog }, Cmd.none )
