module Tools.DataExtractor.View exposing (view)

{-| Data Extractor tool placeholder view.

@docs view

-}

import Html exposing (Html, div, h1, p, text)
import Html.Attributes exposing (attribute, class)


{-| Data Extractor placeholder view
-}
view : Html msg
view =
    div [ class "data-extractor", attribute "data-testid" "data-extractor-page" ]
        [ div [ class "data-extractor__content" ]
            [ h1 [ class "data-extractor__title" ]
                [ text "Data Extractor Tool" ]
            , p [ class "data-extractor__description" ]
                [ text "Extract matching records from one spreadsheet based on criteria from another." ]
            , p [ class "data-extractor__placeholder" ]
                [ text "This tool will be implemented in a future story." ]
            ]
        ]
