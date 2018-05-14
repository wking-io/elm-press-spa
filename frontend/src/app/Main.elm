module Main exposing (main)

import Data.Link exposing (Link)
import Data.Menu exposing (Menu, MenuItem)
import Data.Page exposing (Page, Slug)
import Request.Menu as Menu
import Request.Page as Page
import Html exposing (Html, program, h1, h2, ul, li, a, div, main_, nav, text)
import Html.Attributes exposing (href, class)
import Html.Attributes.Extra exposing (innerHtml)
import Json.Decode as Decode exposing (Decoder)
import Http
import Task


-- MODEL --


type alias Model =
    { menu : Menu
    , welcome : Page
    , pages : List Link
    , posts : List Link
    , error : Maybe String
    }


atEndpoint : String -> String
atEndpoint endpoint =
    "http://127.0.0.1:8080/wp-json" ++ endpoint


initCmd : Cmd Msg
initCmd =
    Task.attempt FetchData <|
        Task.map5 Model
            (Menu.get |> Http.toTask)
            (Page.get (Data.Page.Slug "welcome") |> Http.toTask)
            (Http.get (atEndpoint "/wp/v2/pages?_embed") (Decode.list Data.Link.decoder) |> Http.toTask)
            (Http.get (atEndpoint "/wp/v2/posts?_embed") (Decode.list Data.Link.decoder) |> Http.toTask)
            (Task.succeed Nothing)


init : ( Model, Cmd Msg )
init =
    ( (Model (Data.Menu.Menu []) (Page "" "") [] [] Nothing), initCmd )



-- VIEW --


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ nav []
            [ ul [ class "menu" ] ((viewMenuItem { route = "http://localhost:3000/", title = "Home" }) :: (List.map viewMenuItem (Data.Menu.toList model.menu))) ]
        , main_ []
            [ h1 [] [ text model.welcome.title ]
            , div [ innerHtml model.welcome.content ] []
            , h2 [] [ text "Posts" ]
            , ul [] (List.map (viewLink "post/") model.posts)
            , h2 [] [ text "Pages" ]
            , ul [] (List.map (viewLink "page/") model.pages)
            ]
        ]


viewLink : String -> Link -> Html Msg
viewLink ext { title, link } =
    li [] [ a [ href ("http://localhost:3000/" ++ ext ++ link) ] [ text title ] ]


viewMenuItem : MenuItem -> Html Msg
viewMenuItem { route, title } =
    li [ class "menu__item" ] [ a [ href route ] [ text title ] ]



-- UPDATE --


type Msg
    = FetchData (Result Http.Error Model)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchData (Ok response) ->
            ( response, Cmd.none )

        FetchData (Err httpError) ->
            case httpError of
                Http.BadUrl _ ->
                    ( { model | error = Just "badurl" }, Cmd.none )

                Http.Timeout ->
                    ( { model | error = Just "timeout" }, Cmd.none )

                Http.NetworkError ->
                    ( { model | error = Just "networkerr" }, Cmd.none )

                Http.BadStatus response ->
                    ( { model | error = Just response.url }, Cmd.none )

                Http.BadPayload _ _ ->
                    ( { model | error = Just "badpayload" }, Cmd.none )



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
