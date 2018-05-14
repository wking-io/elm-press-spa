module View.Page exposing (frame)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Lazy exposing (lazy2)
import Route exposing (Route)
import Util exposing ((=>))
import View.Spinner exposing (spinner)


frame : Bool -> Html msg -> Html msg
frame isLoading content =
    div [ class "container" ]
        [ viewHeader isLoading
        , content
        , viewFooter
        ]


viewHeader : Bool -> Html msg
viewHeader isLoading =
    nav []
        [ a [ class "brand", Route.href Route.Home ]
            [ text "elm-press" ]
        , ul [ class "menu" ] <|
            lazy2 Util.viewIf isLoading spinner
                :: viewMenuItem Route.Home [ text "Home" ]
                :: List.map viewMenuItem
        ]


viewMenuItem : Route -> List (Html msg) -> Html msg
viewMenuItem route linkContent =
    li [ class "menu__item" ]
        [ a [ Route.href route ] linkContent ]
