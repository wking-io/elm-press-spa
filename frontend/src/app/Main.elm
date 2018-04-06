module Main exposing (main)

import Html exposing (Html, program, h1, text)


-- MODEL --


type alias Model =
    { name : String
    }


init : ( Model, Cmd Msg )
init =
    ( Model "friend", Cmd.none )



-- VIEW --


view : Model -> Html Msg
view model =
    h1 [] [ text ("Hello, " ++ model.name) ]



-- UPDATE --


type Msg
    = Default


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Default ->
            ( model, Cmd.none )



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
