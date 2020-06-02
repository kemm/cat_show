module Main exposing (main)

import Json.Decode as Decode exposing (Value)
import Browser
import Model exposing (Model)
import Messages exposing (Msg(..))
import Route exposing (Route)
import Subscriptions exposing (subscriptions)
import Update exposing (update, init)
import View exposing (view)


main : Program Value Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = ChangedUrl
        , onUrlRequest = ClickedLink
        }
