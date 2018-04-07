module Main exposing (main)

import Html exposing (Html, program, h1, h2, ul, li, a, div, main_, nav, text)
import Html.Attributes exposing (href, class)
import Html.Attributes.Extra exposing (innerHtml)
import Json.Decode as Decode exposing (Decoder)
import Http
import Task


-- MODEL --


type alias Model =
    { menuItems : List Link
    , welcome : Welcome
    , pages : List Link
    , posts : List Link
    , error : Maybe String
    }


type alias Welcome =
    { title : String
    , content : String
    }


type alias Link =
    { title : String
    , link : String
    }


atEndpoint : String -> String
atEndpoint endpoint =
    "http://127.0.0.1:8080/wp-json" ++ endpoint


welcomeDecoder : Decoder Welcome
welcomeDecoder =
    Decode.map2 Welcome
        (Decode.at [ "title", "rendered" ] Decode.string)
        (Decode.at [ "content", "rendered" ] Decode.string)


linkDecoder : Decoder Link
linkDecoder =
    Decode.map2 Link
        (Decode.at [ "title", "rendered" ] Decode.string)
        (Decode.field "slug" Decode.string)


menuItemDecoder : Decoder Link
menuItemDecoder =
    Decode.map2 Link
        (Decode.field "title" Decode.string)
        (Decode.field "url" Decode.string)


menuDecoder : Decoder (List Link)
menuDecoder =
    Decode.field "items" (Decode.list menuItemDecoder)


initCmd : Cmd Msg
initCmd =
    Task.attempt FetchData <|
        Task.map5 Model
            (Http.get (atEndpoint "/menus/v1/menus/header-menu") menuDecoder |> Http.toTask)
            (Http.get (atEndpoint "/elm-press/v1/page?slug=welcome") welcomeDecoder |> Http.toTask)
            (Http.get (atEndpoint "/wp/v2/pages?_embed") (Decode.list linkDecoder) |> Http.toTask)
            (Http.get (atEndpoint "/wp/v2/posts?_embed") (Decode.list linkDecoder) |> Http.toTask)
            (Task.succeed Nothing)


init : ( Model, Cmd Msg )
init =
    ( (Model [] (Welcome "" "") [] [] Nothing), initCmd )



-- VIEW --


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ nav []
            [ ul [ class "menu" ] ((viewMenuItem { title = "Home", link = "http://localhost:3000/" }) :: (List.map viewMenuItem model.menuItems)) ]
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


viewMenuItem : Link -> Html Msg
viewMenuItem { title, link } =
    li [ class "menu__item" ] [ a [ href link ] [ text title ] ]



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
