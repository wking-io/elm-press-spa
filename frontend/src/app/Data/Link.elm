module Data.Link exposing (Link, decoder)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required, requiredAt, decode)


type alias Link =
    { title : String
    , route : String
    }


type Slug
    = Slug LinkType Int String
    | Custom String


type LinkType
    = Page
    | Post
    | Category


decoder : Decoder Link
decoder =
    decode Link
        |> requiredAt [ "title", "rendered" ] Decode.string
        |> required "slug" Decode.string


toRoute : Slug -> Route
toRoute slug =
    case slug of
        Slug _ _ _ ->
            Route.Link slug

        Custom url ->
            Route.Custom url
