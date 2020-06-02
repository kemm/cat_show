module Route exposing (Route(..), fromLocation, href, modifyUrl)

import Browser.Navigation as Nav
import Html exposing (Attribute)
import Html.Attributes as Attr
import Url exposing (Url)
import Url.Parser as UrlP exposing (Parser, oneOf, fragment, s)


type Route
    = Home
    | Root
    | Login
    | Logout
    | Register


routeParser : Parser (Route -> a) a
routeParser =
    oneOf
        [ UrlP.map Home (s "")
        , UrlP.map Login (s "login")
        , UrlP.map Logout (s "logout")
        , UrlP.map Register (s "register")
        ]


routeToString : Route -> String
routeToString page =
    let
        pieces =
            case page of
                Home ->
                    []

                Root ->
                    []

                Login ->
                    [ "login" ]

                Logout ->
                    [ "logout" ]

                Register ->
                    [ "register" ]
    in
        "/" ++ String.join "/" pieces


href : Route -> Attribute msg
href route =
    Attr.href (routeToString route)


modifyUrl : Nav.Key -> Route -> Cmd msg
modifyUrl key route =
    Nav.replaceUrl key <| routeToString route


fromLocation : Url -> Maybe Route
fromLocation location =
    case location.path of
        "/" -> Just Home
        _   -> UrlP.parse routeParser location
