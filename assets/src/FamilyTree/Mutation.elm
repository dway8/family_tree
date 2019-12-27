-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module FamilyTree.Mutation exposing (..)

import FamilyTree.InputObject
import FamilyTree.Interface
import FamilyTree.Object
import FamilyTree.Scalar
import FamilyTree.ScalarCodecs
import FamilyTree.Union
import Graphql.Internal.Builder.Argument as Argument exposing (Argument)
import Graphql.Internal.Builder.Object as Object
import Graphql.Internal.Encode as Encode exposing (Value)
import Graphql.Operation exposing (RootMutation, RootQuery, RootSubscription)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet exposing (SelectionSet)
import Json.Decode as Decode exposing (Decoder)


type alias CreateChildRequiredArguments =
    { child : FamilyTree.InputObject.ChildParams
    , relationshipId : FamilyTree.ScalarCodecs.Id
    }


createChild : CreateChildRequiredArguments -> SelectionSet decodesTo FamilyTree.Object.Family -> SelectionSet decodesTo RootMutation
createChild requiredArgs object_ =
    Object.selectionForCompositeField "createChild" [ Argument.required "child" requiredArgs.child FamilyTree.InputObject.encodeChildParams, Argument.required "relationshipId" requiredArgs.relationshipId (FamilyTree.ScalarCodecs.codecs |> FamilyTree.Scalar.unwrapEncoder .codecId) ] object_ identity


type alias CreateSpouseRequiredArguments =
    { personId : FamilyTree.ScalarCodecs.Id
    , spouse : FamilyTree.InputObject.SpouseParams
    }


createSpouse : CreateSpouseRequiredArguments -> SelectionSet decodesTo FamilyTree.Object.Family -> SelectionSet decodesTo RootMutation
createSpouse requiredArgs object_ =
    Object.selectionForCompositeField "createSpouse" [ Argument.required "personId" requiredArgs.personId (FamilyTree.ScalarCodecs.codecs |> FamilyTree.Scalar.unwrapEncoder .codecId), Argument.required "spouse" requiredArgs.spouse FamilyTree.InputObject.encodeSpouseParams ] object_ identity
