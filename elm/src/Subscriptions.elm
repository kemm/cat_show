module Subscriptions exposing (subscriptions)

import Model exposing (Model, Page(..), PageState(..), getPage)
import Messages exposing (Msg(..))
import Session.Model exposing (sessionChangeSubscription)


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ pageSubscriptions (getPage model.pageState)
        , Sub.map SetSession sessionChangeSubscription
        ]


pageSubscriptions : Page -> Sub Msg
pageSubscriptions page =
    case page of
        Blank ->
            Sub.none

        NotFound ->
            Sub.none

        Home ->
            Sub.none

        Login _ ->
            Sub.none

        Register _ ->
            Sub.none
