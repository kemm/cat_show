module Session.Register exposing (ExternalMsg(..), Model, Msg, initialModel, update, view)

import Browser.Navigation as Nav
import Html exposing (Html, a, button, div, h1, p, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onInput, onSubmit)
import Json.Decode as Decode exposing (Decoder)
import Validate exposing (Validator, ifBlank, ifInvalidEmail, validate)

import Helpers.Decode exposing (optionalError, optionalFieldError)
import Helpers.Form as Form
import Route
import Session.Model exposing (Session, storeSession)
import Session.Request exposing (Error, register)

type Msg
    = SubmitForm
    | SetName String
    | SetEmail String
    | SetPassword String
    | SetPassword2 String
    | RegisterCompleted (Result Session.Request.Error Session)


type ExternalMsg
    = NoOp
    | SetSession Session


type alias Model =
    { errors : List Error
    , name : String
    , email : String
    , password : String
    , password2 : String
    , navKey : Nav.Key
    }

initialModel : Nav.Key -> Model
initialModel navKey =
    { errors = []
    , name = ""
    , email = ""
    , password = ""
    , password2 = ""
    , navKey = navKey
    }


view : Model -> Html Msg
view model =
    div [ class "mt4 mt6-l pa4" ]
        [ h1 [] [ text "Sign up" ]
        , p [ class "f7" ]
            [ a [ Route.href Route.Login ]
                [ text "Have an account?" ]
            ]
        , div [ class "measure center" ]
            [ Form.viewErrors model.errors
            , viewForm
            ]
        ]


viewForm : Html Msg
viewForm =
    Html.form [ onSubmit SubmitForm ]
        [ Form.input "Name" [ onInput SetName ] []
        , Form.input "Email" [ onInput SetEmail ] []
        , Form.password "Password" [ onInput SetPassword ] []
        , Form.password "Repeat" [ onInput SetPassword2 ] []
        , button [ class "b ph3 pv2 input-reset ba b--black bg-transparent grow pointer f6" ] [ text "Sign up" ]
        ]


update : Msg -> Model -> ( ( Model, Cmd Msg ), ExternalMsg )
update msg model =
    case msg of
        SubmitForm ->
            case validate modelValidator model of
                Ok _ ->
                    ( ( { model | errors = [] }
                      , register model errorsDecoder RegisterCompleted
                      )
                    , NoOp
                    )

                Err errors ->
                    ( ( { model | errors = errors }
                      , Cmd.none
                      )
                    , NoOp
                    )

        SetName name ->
            ( ( { model | name = name }
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

        SetPassword2 password ->
            ( ( { model | password2 = password }
              , Cmd.none
              )
            , NoOp
            )

        RegisterCompleted (Err error) ->
            let
                errorMessages =
                    case error of
                        Session.Request.BackendErrors err ->
                            err

                        _ ->
                            [ "Unable to process registration" ]
            in
                ( ( { model | errors = List.map (\errorMessage -> ( Form, errorMessage ) ) errorMessages }
                  , Cmd.none
                  )
                , NoOp
                )

        RegisterCompleted (Ok session) ->
            ( ( model
              , Cmd.batch [ storeSession session, Route.modifyUrl model.navKey Route.Home ]
              )
            , SetSession session
            )



-- VALIDATION --


type Field
    = Form
    | Name
    | Email
    | Password


type alias Error =
    ( Field, String )

modelValidator : Validator Error Model
modelValidator =
    Validate.all
        [ ifBlank .name (Name, "name can't be blank.")
        , ifBlank .email (Email, "email can't be blank.")
        , ifBlank .password (Password, "password can't be blank.")
        ]


errorsDecoder : Decoder (List String)
errorsDecoder =
    Decode.succeed (\name email password password2 error -> error :: List.concat [ name, email, password, password2 ])
        |> optionalFieldError "name"
        |> optionalFieldError "email"
        |> optionalFieldError "password"
        |> optionalFieldError "password2"
        |> optionalError "error"
