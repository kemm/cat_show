module Session.Login exposing (ExternalMsg(..), Model, Msg, initialModel, update, view)

import Html exposing (Html, button, div, h1, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onInput, onSubmit)
import Json.Decode as Decode exposing (Decoder)

import Helpers.Decode exposing (optionalError, optionalFieldError)
import Helpers.Form as Form
import Route
import Session.Model exposing (Session, storeSession)
import Session.Request exposing (login)
import Validate exposing (Validator, ifBlank, validate, ifInvalidEmail)
import Browser.Navigation as Nav

type alias Model =
    { errors : List Error
    , email : String
    , password : String
    , navKey : Nav.Key
    }


initialModel : Nav.Key -> Model
initialModel key =
    { errors = []
    , email = ""
    , password = ""
    , navKey = key
    }

type Msg
    = SubmitForm
    | SetEmail String
    | SetPassword String
    | LoginCompleted (Result Session.Request.Error Session)


type ExternalMsg
    = NoOp
    | SetSession Session

view : Model -> Html Msg
view model =
    div [ class "mt4 mt6-l pa4" ]
        [ h1 [] [ text "Sign in" ]
        , div [ class "measure center" ]
            [ Form.viewErrors model.errors
            , viewForm
            ]
        ]


viewForm : Html Msg
viewForm =
    Html.form [ onSubmit SubmitForm ]
        [ Form.input "Email" [ onInput SetEmail ] []
        , Form.password "Password" [ onInput SetPassword ] []
        , button [ class "b ph3 pv2 input-reset ba b--black bg-transparent grow pointer f6" ] [ text "Sign in" ]
        ]

update : Msg -> Model -> ( ( Model, Cmd Msg ), ExternalMsg )
update msg model =
    case msg of
        SubmitForm ->
            case validate modelValidator model of
                Ok _ ->
                    ( ( { model | errors = [] }
                      , login model errorsDecoder LoginCompleted
                      )
                    , NoOp
                    )

                Err errors ->
                    ( ( { model | errors = errors }
                      , Cmd.none
                      )
                    , NoOp
                    )

        SetEmail email ->
            ( ( { model | email = email }
              , Cmd.none
              )
            , NoOp
            )

        SetPassword password ->
            ( ( { model | password = password }
              , Cmd.none
              )
            , NoOp
            )

        LoginCompleted (Err error) ->
            let
                errorMessages =
                    case error of
                        Session.Request.BackendErrors bodyErr ->
                            bodyErr

                        _ ->
                            [ "unable to perform login" ]
            in
                ( ( { model | errors = List.map (\errorMessage -> ( Form, errorMessage ) ) errorMessages }
                  , Cmd.none
                  )
                , NoOp
                )

        LoginCompleted (Ok session) ->
            ( ( model
              , Cmd.batch [ storeSession session, Route.modifyUrl model.navKey Route.Home ]
              )
            , SetSession session
            )

ifPwdTooShort : (subject -> String) -> error -> Validator error subject
ifPwdTooShort mapper error =
    Validate.ifTrue (\subject -> String.length (mapper subject) < 8) error

type Field
    = Form
    | Email
    | Password


type alias Error =
    ( Field, String )


modelValidator : Validator Error Model
modelValidator =
    Validate.all
        [ ifBlank .email (Email, "email can't be blank.")
        , ifBlank .password (Password, "password can't be blank.")
        , ifInvalidEmail .email <| \value -> (Email, "\"" ++ value ++ "\" is invalid email.")
        , ifPwdTooShort .password (Password, "password too short, it should be at least 8 chars.")
        ]


errorsDecoder : Decoder (List String)
errorsDecoder =
    Decode.succeed (\email password error -> error :: List.concat [ email, password ])
        |> optionalFieldError "email"
        |> optionalFieldError "password"
        |> optionalError "error"
