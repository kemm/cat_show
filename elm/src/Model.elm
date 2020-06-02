module Model exposing (Model, initialModel, Page(..), PageState(..), navKey, getPage)

import Json.Decode as Decode exposing (Value)
import Browser.Navigation as Nav

import Session.Login as Login
import Session.Model exposing (Session)
import Session.Register as Register


type Page
    = Blank
    | NotFound
    | Home
    | Login Login.Model
    | Register Register.Model


type PageState
    = Loaded Page
    | TransitioningFrom Page


type alias Model =
    { session : Maybe Session
    , pageState : PageState
    , navKey : Nav.Key
    }


initialModel : Value -> Nav.Key -> Model
initialModel val key =
    { session = decodeSessionFromJson val
    , pageState = Loaded Blank
    , navKey = key
    }


getPage : PageState -> Page
getPage pageState =
    case pageState of
        Loaded page ->
            page

        TransitioningFrom page ->
            page

navKey : Model -> Nav.Key
navKey model =
    model.navKey


decodeSessionFromJson : Value -> Maybe Session
decodeSessionFromJson json =
    json
    |> Decode.decodeValue Decode.string
    |> Result.toMaybe
    |> Maybe.andThen (Decode.decodeString Session.Model.decoder >> Result.toMaybe)
