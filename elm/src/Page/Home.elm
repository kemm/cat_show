module Page.Home exposing (view)

import Html exposing (..)


view : Html msg
view =
    div []
        [ h1 [] [ text "CatShow" ]
        , p [] [ text "Welcome to CatShow!" ]
        ]
