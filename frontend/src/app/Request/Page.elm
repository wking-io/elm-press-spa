module Request.Page exposing (get)

import Data.Page as Page exposing (Page, Slug, slugToString)
import Request.Helpers exposing (atEndpoint)
import HttpBuilder exposing (RequestBuilder)
import Http


-- GET --


get : Slug -> Http.Request Page
get slug =
    atEndpoint "/elm-press/v1/page"
        |> HttpBuilder.get
        |> HttpBuilder.withQueryParams [ ( "slug", (slugToString slug) ) ]
        |> HttpBuilder.withExpect (Http.expectJson Page.decoder)
        |> HttpBuilder.toRequest
