module Tools.DataMerger.View exposing (view)

{-| Data Merger tool placeholder view.

@docs view

-}

import Html exposing (Html, div, h1, p, text)
import Html.Attributes exposing (attribute, class)


{-| Data Merger placeholder view
-}
view : Html msg
view =
    div [ class "data-merger", attribute "data-testid" "data-merger-page" ]
        [ div [ class "data-merger__content" ]
            [ h1 [ class "data-merger__title" ]
                [ text "Data Merger Tool" ]
            , p [ class "data-merger__description" ]
                [ text "Merge data from two spreadsheets with intelligent conflict resolution." ]
            , p [ class "data-merger__placeholder" ]
                [ text "This tool will be implemented in a future story." ]
            ]
        ]
