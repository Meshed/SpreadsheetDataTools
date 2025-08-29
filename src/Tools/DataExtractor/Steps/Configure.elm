module Tools.DataExtractor.Steps.Configure exposing (view)

{-| Configure step for Data Extractor tool.

@docs view

-}

import Html exposing (Html, button, div, h2, h3, h4, input, label, li, p, span, text, ul)
import Html.Attributes exposing (attribute, checked, class, disabled, type_)
import Html.Events exposing (onCheck, onClick)
import Tools.DataExtractor.Model exposing (ConfigureMsg(..), FileData, Model, Msg(..))


{-| Render configure step
-}
view : Model -> Html Msg
view model =
    div [ class "configure-step" ]
        [ h2 [ class "configure-step__title" ] [ text "Configure Matching Criteria" ]
        , div [ class "configure-step__progress" ]
            [ text "Step 2 of 5" ]
        , div [ class "configure-step__explanation" ]
            [ p [] [ text "Columns match by selection order - 1st selected master column matches 1st selected data column, etc." ] ]
        , div [ class "configure-step__content" ]
            [ div [ class "configure-step__columns" ]
                [ Html.map ConfigureMsg (renderMasterColumns model.masterFile model.selectedMasterColumns)
                , Html.map ConfigureMsg (renderDataColumns model.dataFile model.selectedDataColumns)
                ]
            , Html.map ConfigureMsg (renderMatchingPairs model.selectedMasterColumns model.selectedDataColumns)
            , Html.map ConfigureMsg (renderFuzzyOption (getFuzzyMatchingEnabled model.matchConfig))
            , Html.map ConfigureMsg (renderSamplePreview model.masterFile model.dataFile model.selectedMasterColumns model.selectedDataColumns)
            , Html.map ConfigureMsg (renderValidationError (validateCurrentSelections model.selectedMasterColumns model.selectedDataColumns))
            ]
        , renderNavigationButtons model.selectedMasterColumns model.selectedDataColumns
        ]


{-| Render master spreadsheet column selection
-}
renderMasterColumns : Maybe FileData -> List String -> Html ConfigureMsg
renderMasterColumns maybeFileData selectedColumns =
    div [ class "column-selector" ]
        [ h3 [ class "column-selector__title" ] [ text "Master Spreadsheet Columns" ]
        , case maybeFileData of
            Nothing ->
                p [ class "column-selector__empty" ] [ text "No master file loaded" ]

            Just fileData ->
                div [ class "column-selector__list" ]
                    (List.map (renderColumnOption SelectMasterColumn DeselectMasterColumn selectedColumns) fileData.headers)
        ]


{-| Render data spreadsheet column selection
-}
renderDataColumns : Maybe FileData -> List String -> Html ConfigureMsg
renderDataColumns maybeFileData selectedColumns =
    div [ class "column-selector" ]
        [ h3 [ class "column-selector__title" ] [ text "Data Spreadsheet Columns" ]
        , case maybeFileData of
            Nothing ->
                p [ class "column-selector__empty" ] [ text "No data file loaded" ]

            Just fileData ->
                div [ class "column-selector__list" ]
                    (List.map (renderColumnOption SelectDataColumn DeselectDataColumn selectedColumns) fileData.headers)
        ]


{-| Render individual column option
-}
renderColumnOption : (String -> ConfigureMsg) -> (String -> ConfigureMsg) -> List String -> String -> Html ConfigureMsg
renderColumnOption selectMsg deselectMsg selectedColumns column =
    let
        isSelected =
            List.member column selectedColumns

        selectionIndex =
            getSelectionIndex column selectedColumns

        buttonClass =
            if isSelected then
                "column-option column-option--selected"

            else
                "column-option"

        clickAction =
            if isSelected then
                deselectMsg column

            else
                selectMsg column

        index =
            Maybe.withDefault 0 selectionIndex
    in
    button
        [ class buttonClass
        , onClick clickAction
        ]
        [ text column
        , case selectionIndex of
            Just idx ->
                span [ class "column-option__badge" ] [ text (String.fromInt idx) ]

            Nothing ->
                text ""
        , if isSelected then
            div [ class "column-option__controls" ]
                [ button [ class "btn btn--small", onClick (ReorderSelection (index - 1) (index - 2)) ] [ text "↑" ]
                , button [ class "btn btn--small", onClick (ReorderSelection (index - 1) index) ] [ text "↓" ]
                ]

          else
            text ""
        ]


{-| Get selection index for a column (1-based)
-}
getSelectionIndex : String -> List String -> Maybe Int
getSelectionIndex column selectedColumns =
    List.indexedMap Tuple.pair selectedColumns
        |> List.filter (\( _, col ) -> col == column)
        |> List.head
        |> Maybe.map (\( index, _ ) -> index + 1)


{-| Render matching pairs display
-}
renderMatchingPairs : List String -> List String -> Html ConfigureMsg
renderMatchingPairs masterColumns dataColumns =
    div [ class "matching-pairs" ]
        [ h3 [ class "matching-pairs__title" ] [ text "Column Matching Pairs" ]
        , div [ class "matching-pairs__list" ]
            (List.map2 renderMatchingPair
                (List.indexedMap (\i col -> ( i + 1, col )) masterColumns)
                (List.indexedMap (\i col -> ( i + 1, col )) dataColumns)
            )
        ]


{-| Render individual matching pair
-}
renderMatchingPair : ( Int, String ) -> ( Int, String ) -> Html ConfigureMsg
renderMatchingPair ( masterIndex, masterColumn ) ( dataIndex, dataColumn ) =
    div [ class "matching-pairs__pair" ]
        [ span [ class "matching-pairs__master" ]
            [ text (masterColumn ++ " (" ++ String.fromInt masterIndex ++ "st)") ]
        , span [ class "matching-pairs__arrow" ] [ text " ↔ " ]
        , span [ class "matching-pairs__data" ]
            [ text (dataColumn ++ " (" ++ String.fromInt dataIndex ++ "st)") ]
        ]


{-| Render fuzzy matching option
-}
renderFuzzyOption : Bool -> Html ConfigureMsg
renderFuzzyOption enabled =
    div [ class "fuzzy-option" ]
        [ label [ class "fuzzy-option__label" ]
            [ input
                [ type_ "checkbox"
                , class "fuzzy-option__checkbox"
                , checked enabled
                , onCheck ToggleFuzzyMatching
                ]
                []
            , text "Enable fuzzy matching"
            ]
        , p [ class "fuzzy-option__help" ]
            [ text "Matches similar text (e.g., 'John' matches 'John Smith')" ]
        ]


{-| Render sample data preview
-}
renderSamplePreview : Maybe FileData -> Maybe FileData -> List String -> List String -> Html ConfigureMsg
renderSamplePreview masterFile dataFile masterColumns dataColumns =
    div [ class "sample-preview" ]
        [ h3 [ class "sample-preview__title" ] [ text "Sample Data Preview" ]
        , div [ class "sample-preview__content" ]
            [ renderPreviewTable "Master Data" masterFile masterColumns
            , renderPreviewTable "Data File" dataFile dataColumns
            ]
        ]


{-| Render preview table for selected columns
-}
renderPreviewTable : String -> Maybe FileData -> List String -> Html ConfigureMsg
renderPreviewTable title maybeFileData selectedColumns =
    div [ class "preview-table" ]
        [ h4 [ class "preview-table__title" ] [ text title ]
        , case maybeFileData of
            Nothing ->
                p [ class "preview-table__empty" ] [ text "No file loaded" ]

            Just fileData ->
                if List.isEmpty selectedColumns then
                    p [ class "preview-table__empty" ] [ text "No columns selected" ]

                else
                    Html.table [ class "preview-table__table" ]
                        [ Html.thead []
                            [ Html.tr [] (List.map (\col -> Html.th [] [ text col ]) selectedColumns) ]
                        , Html.tbody []
                            (List.take 3 fileData.rows
                                |> List.map (renderPreviewRow fileData.headers selectedColumns)
                            )
                        ]
        ]


{-| Render individual preview row
-}
renderPreviewRow : List String -> List String -> List String -> Html ConfigureMsg
renderPreviewRow headers selectedColumns rowData =
    let
        selectedData =
            getSelectedColumnData headers selectedColumns rowData
    in
    Html.tr [] (List.map (\data -> Html.td [] [ text data ]) selectedData)


{-| Get data for selected columns from a row
-}
getSelectedColumnData : List String -> List String -> List String -> List String
getSelectedColumnData headers selectedColumns rowData =
    let
        headerIndexMap =
            List.indexedMap (\i header -> ( header, i )) headers

        getColumnIndex column =
            List.filter (\( h, _ ) -> h == column) headerIndexMap
                |> List.head
                |> Maybe.map Tuple.second
    in
    List.map
        (\column ->
            case getColumnIndex column of
                Just index ->
                    List.drop index rowData |> List.head |> Maybe.withDefault ""

                Nothing ->
                    ""
        )
        selectedColumns


{-| Render validation error
-}
renderValidationError : Maybe String -> Html ConfigureMsg
renderValidationError maybeError =
    case maybeError of
        Nothing ->
            text ""

        Just error ->
            div [ class "validation-error" ]
                [ text error ]


{-| Get fuzzy matching enabled status from MatchConfig
-}
getFuzzyMatchingEnabled : Maybe { a | useFuzzyMatch : Bool } -> Bool
getFuzzyMatchingEnabled maybeConfig =
    case maybeConfig of
        Just config ->
            config.useFuzzyMatch

        Nothing ->
            False


{-| Validate current selections and return error if invalid
-}
validateCurrentSelections : List String -> List String -> Maybe String
validateCurrentSelections masterColumns dataColumns =
    let
        masterEmpty =
            List.isEmpty masterColumns

        dataEmpty =
            List.isEmpty dataColumns
    in
    if masterEmpty && dataEmpty then
        Just "Select at least one column from each spreadsheet"

    else if masterEmpty then
        Just "Select at least one column from master spreadsheet"

    else if dataEmpty then
        Just "Select at least one column from data spreadsheet"

    else
        Nothing


{-| Navigation buttons for wizard
-}
renderNavigationButtons : List String -> List String -> Html Msg
renderNavigationButtons masterColumns dataColumns =
    let
        canProceed =
            not (List.isEmpty masterColumns) && not (List.isEmpty dataColumns)
        
        helpText =
            if not canProceed then
                "Select at least one column from each spreadsheet to continue"
            else
                "Ready to preview results"
    in
    div [ class "configure-step__navigation wizard-navigation" ]
        [ if not canProceed then
            div [ class "wizard-navigation__help" ]
                [ text helpText ]
          else
            text ""
        , div [ class "wizard-navigation__buttons" ]
            [ button
                [ class "wizard-navigation__button wizard-navigation__button--secondary"
                , onClick PreviousStep
                , attribute "data-testid" "previous-step-button"
                ]
                [ text "Previous: Upload Files" ]
            , button
                [ class
                    ("wizard-navigation__button wizard-navigation__button--primary"
                        ++ (if canProceed then
                                ""

                            else
                                " wizard-navigation__button--disabled"
                           )
                    )
                , onClick NextStep
                , disabled (not canProceed)
                , attribute "data-testid" "next-step-button"
                ]
                [ text "Next: Preview Results" ]
            ]
        ]
