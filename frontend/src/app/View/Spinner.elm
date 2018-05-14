module View.Spinner exposing (spinner)

import Html exposing (Attribute, Html, div, li)
import Html.Attributes exposing (class, style)


spinner : Html msg
spinner =
    div [ class "spinner" ]
        [ div [ class "spinner__rect spinner__rect--1" ] []
        , div [ class "spinner__rect spinner__rect--2" ] []
        , div [ class "spinner__rect spinner__rect--3" ] []
        , div [ class "spinner__rect spinner__rect--4" ] []
        , div [ class "spinner__rect spinner__rect--5" ] []
        ]
