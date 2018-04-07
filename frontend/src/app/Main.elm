module Main exposing (main)

import Html exposing (Html, program, h1, text)
import Json.Decode as Decode exposing (Decoder, field, at, string, decodeString)
import Http


-- MODEL --


type alias Model =
    { message : String
    }


atEndpoint : String -> String
atEndpoint endpoint =
    "http://127.0.0.1:8080/wp-json" ++ endpoint


welcomeDecoder : Decoder String
welcomeDecoder =
    at [ "title", "rendered" ] string


initCmd : Cmd Msg
initCmd =
    Http.send FetchData (Http.get (atEndpoint "/elm-press/v1/page?slug=welcome") welcomeDecoder)


init : ( Model, Cmd Msg )
init =
    ( Model "waiting...", initCmd )



-- VIEW --


view : Model -> Html Msg
view model =
    h1 [] [ text model.message ]



-- UPDATE --


type Msg
    = FetchData (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchData (Ok response) ->
            ( { model | message = response }, Cmd.none )

        FetchData (Err httpError) ->
            case httpError of
                Http.BadUrl _ ->
                    ( { model | message = "badurl" }, Cmd.none )

                Http.Timeout ->
                    ( { model | message = "timeout" }, Cmd.none )

                Http.NetworkError ->
                    ( { model | message = "networkerr" }, Cmd.none )

                Http.BadStatus response ->
                    ( { model | message = "badstatus" }, Cmd.none )

                Http.BadPayload _ _ ->
                    ( { model | message = "badpayload" }, Cmd.none )



-- SUBSCRIPTIONS
-- MAIN


main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = \model -> Sub.none
        }
