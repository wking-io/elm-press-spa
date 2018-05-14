module Request.Menu exposing (get)

import Data.Menu as Menu exposing (Menu)
import Request.Helpers exposing (atEndpoint)
import HttpBuilder exposing (RequestBuilder)
import Http


-- GET --


get : Http.Request Menu
get =
    atEndpoint "/menus/v1/menus/header-menu"
        |> HttpBuilder.get
        |> HttpBuilder.withExpect (Http.expectJson Menu.decoder)
        |> HttpBuilder.toRequest
