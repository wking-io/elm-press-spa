module Data.Page exposing (Page, Slug(..), decoder, slugParser, slugToString)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (requiredAt, decode)
import UrlParser


type alias Page =
    { title : String
    , content : String
    }



-- SERIALIZATION --


decoder : Decoder Page
decoder =
    decode Page
        |> requiredAt [ "title", "rendered" ] Decode.string
        |> requiredAt [ "content", "rendered" ] Decode.string



-- IDENTIFIERS --


type Slug
    = Slug String


slugParser : UrlParser.Parser (Slug -> a) a
slugParser =
    UrlParser.custom "SLUG" (Ok << Slug)


slugToString : Slug -> String
slugToString (Slug slug) =
    slug
