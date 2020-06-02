module View exposing (..)

import Html exposing (Html)
import Browser
import Model exposing (Model, Page(..), PageState(..))
import Messages exposing (Msg(..))
import Page.Page as Page exposing (ActivePage)
import Page.Home as Home
import Page.NotFound as NotFound
import Session.Model exposing (Session)
import Session.Login as Login
import Session.Register as Register


view : Model -> Browser.Document Msg
view model =
    let
        makeDoc body =
            { title = "Cat Show"
            , body = [ body ]
            }
    in
    case model.pageState of
        Loaded page ->
            makeDoc <| viewPage True model.session page

        TransitioningFrom page ->
            makeDoc <| viewPage False model.session page


viewPage : Bool -> Maybe Session -> Page -> Html Msg
viewPage isLoading session page =
    let
        frame =
            Page.frame isLoading session
    in
        case page of
            NotFound ->
                NotFound.view
                    |> frame Page.Other

            Blank ->
                Html.text "Loading CatShow!"

            Home ->
                Home.view
                    |> frame Page.Home

            Login subModel ->
                Login.view subModel
                    |> frame Page.Login
                    |> Html.map LoginMsg

            Register subModel ->
                Register.view subModel
                    |> frame Page.Register
                    |> Html.map RegisterMsg
