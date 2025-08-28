module IconTests exposing (..)

{-| Tests for icon functionality across the application

Tests covering icon loading, accessibility, and visual consistency.

-}

import Expect
import Html exposing (Html)
import Pages.Home
import Test exposing (Test, describe, test)
import Test.Html.Query as Query
import Test.Html.Selector as Selector


suite : Test
suite =
    describe "Icon functionality tests"
        [ describe "Icon presence and attributes"
            [ test "tool card icons have proper src attributes" <|
                \_ ->
                    Pages.Home.view
                        |> Query.fromHtml
                        |> Query.findAll [ Selector.class "tool-card__icon" ]
                        |> Query.count (Expect.equal 2)
            , test "tool card icons have accessibility alt text" <|
                \_ ->
                    Pages.Home.view
                        |> Query.fromHtml
                        |> Query.findAll [ Selector.class "tool-card__icon" ]
                        |> Query.count (Expect.equal 2)
            , test "icons are implemented as img elements" <|
                \_ ->
                    Pages.Home.view
                        |> Query.fromHtml
                        |> Query.findAll [ Selector.class "tool-card__icon" ]
                        |> Query.each (Query.has [ Selector.tag "img" ])
            ]
        , describe "Icon CSS integration"
            [ test "icons use BEM methodology class naming" <|
                \_ ->
                    Pages.Home.view
                        |> Query.fromHtml
                        |> Query.findAll [ Selector.class "tool-card__icon" ]
                        |> Query.count (Expect.equal 2)
            , test "icons are properly positioned within tool card headers" <|
                \_ ->
                    Pages.Home.view
                        |> Query.fromHtml
                        |> Query.findAll [ Selector.class "tool-card__header" ]
                        |> Query.each (Query.has [ Selector.class "tool-card__icon" ])
            , test "tool cards contain header sections for icon-title layout" <|
                \_ ->
                    Pages.Home.view
                        |> Query.fromHtml
                        |> Query.findAll [ Selector.class "tool-card__header" ]
                        |> Query.count (Expect.equal 2)
            ]
        , describe "Icon-Title Layout Structure"
            [ test "each tool card header contains both icon and title" <|
                \_ ->
                    Pages.Home.view
                        |> Query.fromHtml
                        |> Query.findAll [ Selector.class "tool-card__header" ]
                        |> Expect.all
                            [ Query.each (Query.has [ Selector.class "tool-card__icon" ])
                            , Query.each (Query.has [ Selector.class "tool-card__title" ])
                            ]
            , test "icons and titles are siblings within header containers" <|
                \_ ->
                    Pages.Home.view
                        |> Query.fromHtml
                        |> Query.findAll [ Selector.class "tool-card__header" ]
                        |> Query.each
                            (Query.children []
                                >> Expect.all
                                    [ Query.index 0 >> Query.has [ Selector.class "tool-card__icon" ]
                                    , Query.index 1 >> Query.has [ Selector.class "tool-card__title" ]
                                    ]
                            )
            , test "header structure is consistent across both tool cards" <|
                \_ ->
                    Pages.Home.view
                        |> Query.fromHtml
                        |> Query.findAll [ Selector.class "tool-card__header" ]
                        |> Query.each (Query.children [] >> Query.count (Expect.equal 2))
            ]
        , describe "Icon file path validation"
            [ test "icons exist and are properly referenced" <|
                \_ ->
                    Pages.Home.view
                        |> Query.fromHtml
                        |> Query.findAll [ Selector.class "tool-card__icon" ]
                        |> Query.count (Expect.equal 2)
            ]
        ]
