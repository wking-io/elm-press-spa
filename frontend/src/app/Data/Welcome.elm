module Data.Welcome exposing (Welcome, decoder)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (requiredAt, decode)


type alias Welcome =
    { title : String
    , content : String
    }


decoder : Decoder Welcome
decoder =
    decode Welcome
        |> requiredAt [ "title", "rendered" ] Decode.string
        |> requiredAt [ "content", "rendered" ] Decode.string
