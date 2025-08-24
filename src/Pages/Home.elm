module Pages.Home exposing (view)

{-| Homepage component for the Spreadsheet Data Tools application.

@docs view
-}

import Html exposing (Html, div, h1, h2, p, a, text)
import Html.Attributes exposing (class, href, attribute)


{-| Home page view with tool cards for navigation
-}
view : Html msg
view =
    div [ class "homepage", attribute "data-testid" "homepage" ]
        [ div [ class "homepage__header" ]
            [ h1 [ class "homepage__title" ]
                [ text "Spreadsheet Data Tools" ]
            , p [ class "homepage__subtitle" ]
                [ text "Privacy-focused tools for comparing, extracting, and merging spreadsheet data" ]
            ]
        , div [ class "homepage__tools" ]
            [ toolCard
                { title = "Data Extractor"
                , description = "Extract matching records from one spreadsheet based on criteria from another"
                , route = "/data-extractor"
                , testId = "tool-card-data-extractor"
                }
            , toolCard
                { title = "Data Merger"
                , description = "Merge data from two spreadsheets with intelligent conflict resolution"
                , route = "/data-merger"
                , testId = "tool-card-data-merger"
                }
            ]
        ]


type alias ToolCardConfig =
    { title : String
    , description : String
    , route : String
    , testId : String
    }


toolCard : ToolCardConfig -> Html msg
toolCard config =
    a
        [ class "tool-card"
        , href config.route
        , attribute "data-testid" config.testId
        ]
        [ div [ class "tool-card__content" ]
            [ h2 [ class "tool-card__title" ]
                [ text config.title ]
            , p [ class "tool-card__description" ]
                [ text config.description ]
            ]
        ]