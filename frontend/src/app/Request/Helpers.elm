module Request.Helpers exposing (atEndpoint)


atEndpoint : String -> String
atEndpoint endpoint =
    "http://127.0.0.1:8080/wp-json" ++ endpoint
