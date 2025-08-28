module HomepageTests exposing (..)

{-| Unit tests for Pages.Home module

Tests covering basic structure and functionality of the homepage component.
This focuses on testing the view function's output structure.

-}

import Expect
import Html exposing (Html)
import Pages.Home
import Test exposing (Test, describe, test)
import Test.Html.Query as Query
import Test.Html.Selector as Selector


suite : Test
suite =
    describe "Homepage component"
        [ describe "Basic Structure Tests"
            [ test "homepage renders without crashing" <|
                \_ ->
                    Pages.Home.view
                        |> Query.fromHtml
                        |> Query.has [ Selector.class "homepage" ]
            , test "contains homepage header section" <|
                \_ ->
                    Pages.Home.view
                        |> Query.fromHtml
                        |> Query.has [ Selector.class "homepage__header" ]
            , test "contains homepage tools section" <|
                \_ ->
                    Pages.Home.view
                        |> Query.fromHtml
                        |> Query.has [ Selector.class "homepage__tools" ]
            , test "contains privacy banner section" <|
                \_ ->
                    Pages.Home.view
                        |> Query.fromHtml
                        |> Query.has [ Selector.class "privacy-banner" ]
            ]
        , describe "Header Content Tests"
            [ test "displays main title" <|
                \_ ->
                    Pages.Home.view
                        |> Query.fromHtml
                        |> Query.find [ Selector.class "homepage__title" ]
                        |> Query.has [ Selector.text "Spreadsheet Data Tools" ]
            , test "displays subtitle with platform description" <|
                \_ ->
                    Pages.Home.view
                        |> Query.fromHtml
                        |> Query.find [ Selector.class "homepage__subtitle" ]
                        |> Query.has [ Selector.text "Privacy-focused tools for comparing, extracting, and merging spreadsheet data" ]
            ]
        , describe "Tool Cards Tests"
            [ test "renders tool cards with proper CSS classes" <|
                \_ ->
                    Pages.Home.view
                        |> Query.fromHtml
                        |> Query.findAll [ Selector.class "tool-card" ]
                        |> Query.count (Expect.equal 2)
            , test "tool cards contain content sections" <|
                \_ ->
                    Pages.Home.view
                        |> Query.fromHtml
                        |> Query.findAll [ Selector.class "tool-card__content" ]
                        |> Query.count (Expect.equal 2)
            , test "tool cards contain icons" <|
                \_ ->
                    Pages.Home.view
                        |> Query.fromHtml
                        |> Query.findAll [ Selector.class "tool-card__icon" ]
                        |> Query.count (Expect.equal 2)
            , test "tool cards contain titles" <|
                \_ ->
                    Pages.Home.view
                        |> Query.fromHtml
                        |> Query.findAll [ Selector.class "tool-card__title" ]
                        |> Query.count (Expect.equal 2)
            , test "tool cards contain descriptions" <|
                \_ ->
                    Pages.Home.view
                        |> Query.fromHtml
                        |> Query.findAll [ Selector.class "tool-card__description" ]
                        |> Query.count (Expect.equal 2)
            , test "tool cards contain launch buttons" <|
                \_ ->
                    Pages.Home.view
                        |> Query.fromHtml
                        |> Query.findAll [ Selector.class "tool-card__button" ]
                        |> Query.count (Expect.equal 2)
            , test "tool cards contain header sections with icon-title layout" <|
                \_ ->
                    Pages.Home.view
                        |> Query.fromHtml
                        |> Query.findAll [ Selector.class "tool-card__header" ]
                        |> Query.count (Expect.equal 2)
            ]
        , describe "Card Content Tests"
            [ test "first tool card shows Data Extractor title" <|
                \_ ->
                    Pages.Home.view
                        |> Query.fromHtml
                        |> Query.has [ Selector.text "Data Extractor" ]
            , test "second tool card shows Data Merger title" <|
                \_ ->
                    Pages.Home.view
                        |> Query.fromHtml
                        |> Query.has [ Selector.text "Data Merger" ]
            , test "launch buttons display correct text" <|
                \_ ->
                    Pages.Home.view
                        |> Query.fromHtml
                        |> Query.findAll [ Selector.text "Launch Tool" ]
                        |> Query.count (Expect.equal 2)
            , test "cards contain descriptive text" <|
                \_ ->
                    Pages.Home.view
                        |> Query.fromHtml
                        |> Expect.all
                            [ Query.has [ Selector.text "Extract matching records" ]
                            , Query.has [ Selector.text "Merge data from two spreadsheets" ]
                            ]
            ]
        , describe "Privacy Message Tests"
            [ test "privacy banner displays privacy messaging" <|
                \_ ->
                    Pages.Home.view
                        |> Query.fromHtml
                        |> Query.find [ Selector.class "privacy-banner__text" ]
                        |> Expect.all
                            [ Query.has [ Selector.text "Your data stays private" ]
                            , Query.has [ Selector.text "locally" ]
                            , Query.has [ Selector.text "browser" ]
                            ]
            , test "privacy banner is positioned between header and tools in DOM structure" <|
                \_ ->
                    let
                        children =
                            Pages.Home.view
                                |> Query.fromHtml
                                |> Query.children []
                    in
                    Expect.all
                        [ \_ -> children |> Query.index 0 |> Query.has [ Selector.class "homepage__header" ]
                        , \_ -> children |> Query.index 1 |> Query.has [ Selector.class "privacy-banner" ]
                        , \_ -> children |> Query.index 2 |> Query.has [ Selector.class "homepage__tools" ]
                        ]
                        ()
            ]
        , describe "Navigation Structure Tests"
            [ test "tool cards are implemented as anchor links" <|
                \_ ->
                    Pages.Home.view
                        |> Query.fromHtml
                        |> Query.findAll [ Selector.tag "a" ]
                        |> Query.count (Expect.equal 2)
            , test "cards use proper CSS classes for styling" <|
                \_ ->
                    Pages.Home.view
                        |> Query.fromHtml
                        |> Query.findAll [ Selector.class "tool-card" ]
                        |> Query.each (Query.has [ Selector.tag "a" ])
            ]
        ]
