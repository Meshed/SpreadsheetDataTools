module IconLayoutTests exposing (..)

{-| Tests for icon layout behavior and horizontal positioning

Tests covering the flexbox layout implementation for icon-title horizontal alignment.
-}

import Expect
import Html exposing (Html)
import Test exposing (Test, describe, test)
import Test.Html.Query as Query
import Test.Html.Selector as Selector
import Pages.Home


suite : Test
suite =
    describe "Icon Layout and Positioning Tests"
        [ describe "HTML Structure for Horizontal Layout"
            [ test "tool card content contains header as first child" <|
                \_ ->
                    Pages.Home.view
                        |> Query.fromHtml
                        |> Query.findAll [ Selector.class "tool-card__content" ]
                        |> Query.each
                            (Query.children []
                                >> Query.index 0
                                >> Query.has [ Selector.class "tool-card__header" ]
                            )
            , test "header contains icon as first child and title as second child" <|
                \_ ->
                    Pages.Home.view
                        |> Query.fromHtml
                        |> Query.findAll [ Selector.class "tool-card__header" ]
                        |> Query.each
                            (\header ->
                                header
                                    |> Query.children []
                                    |> Expect.all
                                        [ Query.index 0 >> Query.has [ Selector.class "tool-card__icon" ]
                                        , Query.index 1 >> Query.has [ Selector.class "tool-card__title" ]
                                        , Query.count (Expect.equal 2)
                                        ]
                            )
            , test "description comes after header in card content structure" <|
                \_ ->
                    Pages.Home.view
                        |> Query.fromHtml
                        |> Query.findAll [ Selector.class "tool-card__content" ]
                        |> Query.each
                            (Query.children []
                                >> Query.index 1
                                >> Query.has [ Selector.class "tool-card__description" ]
                            )
            , test "launch button comes last in card content structure" <|
                \_ ->
                    Pages.Home.view
                        |> Query.fromHtml
                        |> Query.findAll [ Selector.class "tool-card__content" ]
                        |> Query.each
                            (Query.children []
                                >> Query.index 2
                                >> Query.has [ Selector.class "tool-card__button" ]
                            )
            ]
        , describe "BEM CSS Class Validation"
            [ test "all header elements use proper BEM naming convention" <|
                \_ ->
                    Pages.Home.view
                        |> Query.fromHtml
                        |> Query.findAll [ Selector.class "tool-card__header" ]
                        |> Query.count (Expect.equal 2)
            , test "icons maintain BEM naming within new structure" <|
                \_ ->
                    Pages.Home.view
                        |> Query.fromHtml
                        |> Query.findAll [ Selector.class "tool-card__icon" ]
                        |> Query.each (Query.has [ Selector.tag "img" ])
            , test "titles maintain BEM naming within new structure" <|
                \_ ->
                    Pages.Home.view
                        |> Query.fromHtml
                        |> Query.findAll [ Selector.class "tool-card__title" ]
                        |> Query.each (Query.has [ Selector.tag "h2" ])
            ]
        , describe "Layout Consistency Validation"
            [ test "both tool cards have identical header structure" <|
                \_ ->
                    let
                        headers =
                            Pages.Home.view
                                |> Query.fromHtml
                                |> Query.findAll [ Selector.class "tool-card__header" ]
                    in
                    Expect.all
                        [ \_ -> headers |> Query.count (Expect.equal 2)
                        , \_ ->
                            headers
                                |> Query.each
                                    (Query.children []
                                        >> Query.count (Expect.equal 2)
                                    )
                        ]
                        ()
            , test "each header contains exactly one icon and one title" <|
                \_ ->
                    Pages.Home.view
                        |> Query.fromHtml
                        |> Query.findAll [ Selector.class "tool-card__header" ]
                        |> Query.each
                            (\header ->
                                Expect.all
                                    [ \_ ->
                                        header
                                            |> Query.findAll [ Selector.class "tool-card__icon" ]
                                            |> Query.count (Expect.equal 1)
                                    , \_ ->
                                        header
                                            |> Query.findAll [ Selector.class "tool-card__title" ]
                                            |> Query.count (Expect.equal 1)
                                    ]
                                    ()
                            )
            ]
        , describe "Accessibility and Semantic Structure"
            [ test "icons maintain proper alt text in new structure" <|
                \_ ->
                    Pages.Home.view
                        |> Query.fromHtml
                        |> Query.findAll [ Selector.class "tool-card__header" ]
                        |> Query.each
                            (Query.find [ Selector.class "tool-card__icon" ]
                                >> Query.has [ Selector.tag "img" ]
                            )
            , test "titles remain as heading elements in header structure" <|
                \_ ->
                    Pages.Home.view
                        |> Query.fromHtml
                        |> Query.findAll [ Selector.class "tool-card__header" ]
                        |> Query.each
                            (Query.find [ Selector.class "tool-card__title" ]
                                >> Query.has [ Selector.tag "h2" ]
                            )
            , test "header maintains semantic relationship between icon and title" <|
                \_ ->
                    Pages.Home.view
                        |> Query.fromHtml
                        |> Query.findAll [ Selector.class "tool-card__header" ]
                        |> Query.each
                            (\header ->
                                let
                                    children = header |> Query.children []
                                in
                                Expect.all
                                    [ \_ -> children |> Query.index 0 |> Query.has [ Selector.tag "img" ]
                                    , \_ -> children |> Query.index 1 |> Query.has [ Selector.tag "h2" ]
                                    ]
                                    ()
                            )
            ]
        ]