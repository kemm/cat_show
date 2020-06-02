module Session.Request exposing (Error(..), login, logout, register)

import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Task

import Helpers.Request exposing (apiUrl, authHeader)
import Session.AuthToken as AuthToken
import Session.Model exposing (Session)
import User.Model as User

type Error
    = BadUrl String
    | Timeout
    | NetworkError
    | BackendErrors (List String)
    | BadStatus Int
    | ParseError String


type alias MapMsg msg = Result Error Session -> msg


login : { r | email : String, password : String } -> Decoder (List String) -> MapMsg msg -> Cmd msg
login { email, password } errorsDecoder mapMsg =
    let
        user =
            Encode.object
                [ ( "email", Encode.string email )
                , ( "password", Encode.string password )
                ]

        body = Http.jsonBody user
    in
    { body = body
    , url = apiUrl "/sessions"
    , expect = expectJson mapMsg decodeSessionResponse errorsDecoder
    } |> Http.post


register : { r | email : String, name : String, password : String, password2 : String } -> Decoder (List String) -> MapMsg msg -> Cmd msg
register { email, name, password, password2 } errorsDecoder mapMsg =
    let
        user =
            Encode.object
                [ ( "email", Encode.string email )
                , ( "name", Encode.string name )
                , ( "password", Encode.string password )
                , ( "password2", Encode.string password2 )
                , ( "roles", Encode.list Encode.string [ "user" ] )
                ]

        body = Http.jsonBody user
    in
    { body = body
    , url = apiUrl "/users"
    , expect = expectJson mapMsg decodeSessionResponse errorsDecoder
    } |> Http.post


getOk : Cmd (Result Http.Error ())
getOk =
    Task.perform Ok (Task.succeed ())


logout : Maybe Session -> (Result Http.Error () -> msg) -> Cmd msg
logout session mapMsg =
    case session of
        Nothing ->
            Cmd.map mapMsg getOk

        Just sess ->
            { method = "DELETE"
            , body = Http.emptyBody
            , headers = [ authHeader sess ]
            , url = apiUrl "/sessions"
            , expect = Http.expectWhatever mapMsg
            , timeout = Nothing
            , tracker = Nothing
            } |> Http.request


decodeSessionResponse : Decoder Session
decodeSessionResponse =
    Decode.map2 Session
        (Decode.field "data" User.decoder)
        (Decode.at [ "meta", "token" ] AuthToken.decoder)


expectJson : (Result Error a -> msg) -> Decoder a -> Decoder (List String) -> Http.Expect msg
expectJson toMsg decoder errorsDecoder =
    let
        handler response =
            case response of
                Http.BadUrl_ url ->
                    Err <| BadUrl url

                Http.Timeout_ ->
                    Err Timeout

                Http.NetworkError_ ->
                    Err NetworkError

                Http.BadStatus_ meta body ->
                    case meta.statusCode // 100 of
                        4 ->
                            case decodeErrors errorsDecoder body of
                                Ok errList ->
                                    Err <| BackendErrors errList

                                Err what ->
                                    Err <| ParseError <| Decode.errorToString what
                        _ ->
                            Err <| BadStatus meta.statusCode

                Http.GoodStatus_ _ body ->
                    case Decode.decodeString decoder body of
                        Ok value ->
                            Ok value

                        Err err ->
                            Err <| ParseError <| Decode.errorToString err

    in
    Http.expectStringResponse toMsg handler


decodeErrors : Decoder (List String) -> String -> Result Decode.Error (List String)
decodeErrors errorsDecoder body =
    Decode.decodeString (Decode.field "errors" errorsDecoder) body
