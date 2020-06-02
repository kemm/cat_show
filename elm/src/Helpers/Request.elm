module Helpers.Request exposing (apiUrl, authHeader)

import Http

import Session.Model exposing (Session, getToken)

apiUrl : String -> String
apiUrl str =
    "http://localhost:4001/api" ++ str


authHeader : Session -> Http.Header
authHeader session =
    Http.header "authorization" <| "Bearer " ++ getToken session
