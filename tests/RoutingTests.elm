module RoutingTests exposing (..)

{-| Unit tests for routing logic.
-}

import Expect
import Main exposing (parseUrl, routeToString)
import Test exposing (Test, describe, test)
import Types.Common exposing (Route(..))
import Url


suite : Test
suite =
    describe "Routing Tests"
        [ describe "parseUrl function"
            [ test "parses home route correctly from root path" <|
                \_ ->
                    let
                        url =
                            { protocol = Url.Http, host = "localhost", port_ = Just 8080, path = "/", query = Nothing, fragment = Nothing }
                    in
                    parseUrl url
                        |> Expect.equal Home
            , test "parses home route correctly from /home path" <|
                \_ ->
                    let
                        url =
                            { protocol = Url.Http, host = "localhost", port_ = Just 8080, path = "/home", query = Nothing, fragment = Nothing }
                    in
                    parseUrl url
                        |> Expect.equal Home
            , test "parses data extractor route correctly" <|
                \_ ->
                    let
                        url =
                            { protocol = Url.Http, host = "localhost", port_ = Just 8080, path = "/data-extractor", query = Nothing, fragment = Nothing }
                    in
                    parseUrl url
                        |> Expect.equal DataExtractor
            , test "parses data merger route correctly" <|
                \_ ->
                    let
                        url =
                            { protocol = Url.Http, host = "localhost", port_ = Just 8080, path = "/data-merger", query = Nothing, fragment = Nothing }
                    in
                    parseUrl url
                        |> Expect.equal DataMerger
            , test "handles invalid URL with NotFound fallback" <|
                \_ ->
                    let
                        url =
                            { protocol = Url.Http, host = "localhost", port_ = Just 8080, path = "/invalid-path", query = Nothing, fragment = Nothing }
                    in
                    parseUrl url
                        |> Expect.equal NotFound
            , test "handles deeply nested invalid URL with NotFound fallback" <|
                \_ ->
                    let
                        url =
                            { protocol = Url.Http, host = "localhost", port_ = Just 8080, path = "/invalid/nested/path", query = Nothing, fragment = Nothing }
                    in
                    parseUrl url
                        |> Expect.equal NotFound
            , test "handles URL with query parameters correctly" <|
                \_ ->
                    let
                        url =
                            { protocol = Url.Http, host = "localhost", port_ = Just 8080, path = "/data-extractor", query = Just "param=value", fragment = Nothing }
                    in
                    parseUrl url
                        |> Expect.equal DataExtractor
            , test "handles URL with fragment correctly" <|
                \_ ->
                    let
                        url =
                            { protocol = Url.Http, host = "localhost", port_ = Just 8080, path = "/data-merger", query = Nothing, fragment = Just "section" }
                    in
                    parseUrl url
                        |> Expect.equal DataMerger
            ]
        , describe "routeToString function"
            [ test "converts Home route to correct URL string" <|
                \_ ->
                    routeToString Home
                        |> Expect.equal "/"
            , test "converts DataExtractor route to correct URL string" <|
                \_ ->
                    routeToString DataExtractor
                        |> Expect.equal "/data-extractor"
            , test "converts DataMerger route to correct URL string" <|
                \_ ->
                    routeToString DataMerger
                        |> Expect.equal "/data-merger"
            , test "converts NotFound route to correct URL string" <|
                \_ ->
                    routeToString NotFound
                        |> Expect.equal "/not-found"
            ]
        , describe "Route roundtrip tests"
            [ test "Home route survives roundtrip conversion" <|
                \_ ->
                    let
                        originalRoute =
                            Home

                        url =
                            { protocol = Url.Http, host = "localhost", port_ = Just 8080, path = routeToString originalRoute, query = Nothing, fragment = Nothing }
                    in
                    parseUrl url
                        |> Expect.equal originalRoute
            , test "DataExtractor route survives roundtrip conversion" <|
                \_ ->
                    let
                        originalRoute =
                            DataExtractor

                        url =
                            { protocol = Url.Http, host = "localhost", port_ = Just 8080, path = routeToString originalRoute, query = Nothing, fragment = Nothing }
                    in
                    parseUrl url
                        |> Expect.equal originalRoute
            , test "DataMerger route survives roundtrip conversion" <|
                \_ ->
                    let
                        originalRoute =
                            DataMerger

                        url =
                            { protocol = Url.Http, host = "localhost", port_ = Just 8080, path = routeToString originalRoute, query = Nothing, fragment = Nothing }
                    in
                    parseUrl url
                        |> Expect.equal originalRoute
            ]
        ]
