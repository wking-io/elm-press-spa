module Data.Menu exposing (Menu(..), MenuItem, decoder, toList)

import Json.Decode as Decode exposing (Decoder, field)
import Json.Decode.Pipeline exposing (required, decode)
import Route exposing (Route, fromLocation)


type Menu
    = Menu (List MenuItem)


type alias MenuItem =
    { route : Route
    , title : String
    }



-- SERIALIZATION --


decoder : Decoder Menu
decoder =
    decode Menu
        |> required "items" (Decode.list decodeMenuItem)


decodeRoute : Decoder Route
decodeRoute =
    decode fromLocafield "url" Decode.string
        |> Decode.andThen fromLocation


decodeMenuItem : Decoder MenuItem
decodeMenuItem =
    decode MenuItem
        |> required "url" decodeRoute
        |> required "title" Decode.string


toList : Menu -> List MenuItem
toList (Menu menuItems) =
    menuItems
