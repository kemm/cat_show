module User.Model exposing (User, decoder, encode)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode exposing (Value)


type alias User =
    { email : String
    , name : String
    }


decoder : Decoder User
decoder =
    Decode.succeed User
        |> required "email" Decode.string
        |> required "name" Decode.string


encode : User -> Value
encode user =
    Encode.object
        [ ( "email", Encode.string user.email )
        , ( "name", Encode.string user.name )
        ]
