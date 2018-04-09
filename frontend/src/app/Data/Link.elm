module Data.Link exposing (Link, decoder, decoderForMenuItem)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required, requiredAt, decode)


type alias Link =
    { title : String
    , link : String
    }


decoder : Decoder Link
decoder =
    decode Link
        |> requiredAt [ "title", "rendered" ] Decode.string
        |> required "slug" Decode.string


decoderForMenuItem : Decoder Link
decoderForMenuItem =
    decode Link
        |> required "title" Decode.string
        |> required "url" Decode.string
