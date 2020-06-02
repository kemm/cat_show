module Update exposing (update, init)

import Json.Decode exposing (Value)
import Url exposing (Url)
import Browser
import Browser.Navigation as Nav

import Messages exposing (Msg(..))
import Model exposing (Model, initialModel, Page(..), PageState(..), getPage, navKey)
import Ports
import Route exposing (Route)
import Session.Login as Login
import Session.Register as Register
import Session.Request exposing (logout)


init : Value -> Url -> Nav.Key -> ( Model, Cmd Msg )
init val location key =
    updateRoute (Route.fromLocation location) (initialModel val key)


updateRoute : Maybe Route -> Model -> ( Model, Cmd Msg )
updateRoute maybeRoute model =
    case maybeRoute of
        Nothing ->
            ( { model | pageState = Loaded NotFound }, Cmd.none )

        Just Route.Home ->
            ( { model | pageState = Loaded Home }, Cmd.none )

        Just Route.Root ->
            ( model, Route.modifyUrl (navKey model) Route.Home )

        Just Route.Login ->
            ( { model | pageState = Loaded <| Login (Login.initialModel <| navKey model) }, Cmd.none )

        Just Route.Logout ->
            ( model, logout model.session LogoutCompleted )

        Just Route.Register ->
            ( { model | pageState = Loaded <| Register (Register.initialModel <| navKey model) }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    updatePage (getPage model.pageState) msg model


updatePage : Page -> Msg -> Model -> ( Model, Cmd Msg )
updatePage page msg model =
    case ( msg, page ) of
        ( ChangedUrl url, _ ) ->
            updateRoute (Route.fromLocation url) model

        ( ClickedLink (Browser.Internal url), _) ->
            ( model, Nav.pushUrl (navKey model) <| Url.toString url )

        ( ClickedLink (Browser.External url), _) ->
            ( model, Nav.load url )

        ( LoginMsg subMsg, Login subModel ) ->
            let
                ( ( pageModel, cmd ), msgFromPage ) =
                    Login.update subMsg subModel

                newModel =
                    case msgFromPage of
                        Login.NoOp ->
                            model

                        Login.SetSession session ->
                            { model | session = Just session }
            in
            ( { newModel | pageState = Loaded (Login pageModel) }
            , Cmd.map LoginMsg cmd
            )

        ( RegisterMsg subMsg, Register subModel ) ->
            let
                ( ( pageModel, cmd ), msgFromPage ) =
                    Register.update subMsg subModel

                newModel =
                    case msgFromPage of
                        Register.NoOp ->
                            model

                        Register.SetSession session ->
                            { model | session = Just session }
            in
            ( { newModel | pageState = Loaded (Register pageModel) }
            , Cmd.map RegisterMsg cmd
            )

        ( SetSession newSession, _ ) ->
            let
                cmd =
                    -- If we just signed out, then redirect to Home.
                    if model.session /= Nothing && newSession == Nothing then
                        Route.modifyUrl model.navKey Route.Home
                    else
                        Cmd.none
            in
                ( { model | session = newSession }, cmd )

        ( LogoutCompleted (Ok ()), _ ) ->
            ( { model | session = Nothing }
            , Cmd.batch
                [ Ports.storeSession Nothing
                , Route.modifyUrl model.navKey Route.Home
                ]
            )

        ( _, NotFound ) ->
            -- Disregard incoming messages when we're on the
            -- NotFound page.
            ( model, Cmd.none)

        ( _, _ ) ->
            -- Disregard incoming messages that arrived for the wrong page
            (model, Cmd.none)
