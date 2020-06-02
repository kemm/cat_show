module Messages exposing (Msg(..))

import Browser
import Http
import Url exposing (Url)

import Session.Model exposing (Session)
import Session.Login as Login
import Session.Register as Register

type Msg
    = ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | LoginMsg Login.Msg
    | RegisterMsg Register.Msg
    | LogoutCompleted (Result Http.Error ())
    | SetSession (Maybe Session)
