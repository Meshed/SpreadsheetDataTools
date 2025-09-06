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
        , div [ class "configure-step__explanation" ]
            [ p [] [ text "Columns match by selection order - 1st selected master column matches 1st selected data column, etc." ] ]
        , Html.map ConfigureMsg (renderValidationError (validateCurrentSelections model.selectedMasterColumns model.selectedDataColumns))
        , div [ class "configure-step__content" ]
            [ Html.map ConfigureMsg (renderInteractiveGrid model.masterFile model.dataFile model.selectedMasterColumns model.selectedDataColumns)
            , Html.map ConfigureMsg (renderMatchingSummary model.selectedMasterColumns model.selectedDataColumns)
            , Html.map ConfigureMsg (renderFuzzyOption (getFuzzyMatchingEnabled model.matchConfig))
            ]
        , renderNavigationButtons model.selectedMasterColumns model.selectedDataColumns
        ]


{-| Render interactive grid layout for column matching
-}
renderInteractiveGrid : Maybe FileData -> Maybe FileData -> List String -> List String -> Html ConfigureMsg
renderInteractiveGrid masterFile dataFile selectedMasterColumns selectedDataColumns =
    div [ class "matching-grid" ]
        [ div [ class "matching-grid__container" ]
            [ div [ class "matching-grid__master" ]
                [ h3 [ class "matching-grid__title" ] [ text "Master Columns" ]
                , case masterFile of
                    Nothing ->
                        p [ class "matching-grid__empty" ] [ text "No master file loaded" ]
                    
                    Just fileData ->
                        div [ class "matching-grid__column-list" ]
                            (List.map (renderGridMasterColumn selectedMasterColumns selectedDataColumns) fileData.headers)
                ]
            , div [ class "matching-grid__data" ]
                [ h3 [ class "matching-grid__title" ] [ text "Data Columns" ]
                , case dataFile of
                    Nothing ->
                        p [ class "matching-grid__empty" ] [ text "No data file loaded" ]
                    
                    Just fileData ->
                        div [ class "matching-grid__column-list" ]
                            (List.map (renderGridDataColumn selectedMasterColumns selectedDataColumns) fileData.headers)
                ]
            , div [ class "matching-grid__preview" ]
                [ h3 [ class "matching-grid__title" ] [ text "Sample Preview" ]
                , renderCompactSamplePreview masterFile dataFile selectedMasterColumns selectedDataColumns
                ]
            ]
        ]


{-| Render compact sample preview for the grid
-}
renderCompactSamplePreview : Maybe FileData -> Maybe FileData -> List String -> List String -> Html ConfigureMsg
renderCompactSamplePreview masterFile dataFile selectedMasterColumns selectedDataColumns =
    if List.isEmpty selectedMasterColumns && List.isEmpty selectedDataColumns then
        div [ class "compact-preview__empty" ]
            [ p [] [ text "Select columns to see sample data" ] ]
    else
        div [ class "compact-preview__content" ]
            [ div [ class "compact-preview__side-by-side" ]
                [ renderCompactPreviewTable masterFile selectedMasterColumns "Master"
                , renderCompactPreviewTable dataFile selectedDataColumns "Data"
                ]
            ]


{-| Render compact preview table
-}
renderCompactPreviewTable : Maybe FileData -> List String -> String -> Html ConfigureMsg
renderCompactPreviewTable maybeFileData selectedColumns tableType =
    case maybeFileData of
        Nothing ->
            div [ class "compact-preview__table" ]
                [ p [ class "compact-preview__no-data" ] [ text ("No " ++ tableType ++ " file loaded") ] ]
        
        Just fileData ->
            if List.isEmpty selectedColumns then
                div [ class "compact-preview__table" ]
                    [ p [ class "compact-preview__no-columns" ] [ text ("No " ++ tableType ++ " columns selected") ] ]
            else
                let
                    sampleRows = List.take 3 fileData.rows
                    selectedData = List.map (getSelectedRowData fileData.headers selectedColumns) sampleRows
                in
                div [ class "compact-preview__table" ]
                    [ div [ class "compact-preview__header" ] [ text (tableType ++ " Sample") ]
                    , div [ class "compact-preview__rows" ]
                        (List.map (renderCompactRow selectedColumns) selectedData)
                    ]


{-| Render compact preview row
-}
renderCompactRow : List String -> List String -> Html ConfigureMsg
renderCompactRow columns values =
    div [ class "compact-preview__row" ]
        (List.map2 renderCompactCell columns values)


{-| Render compact preview cell
-}
renderCompactCell : String -> String -> Html ConfigureMsg
renderCompactCell column value =
    div [ class "compact-preview__cell" ]
        [ div [ class "compact-preview__cell-header" ] [ text column ]
        , div [ class "compact-preview__cell-value" ] [ text (String.left 20 value) ]
        ]


{-| Get selected row data for preview
-}
getSelectedRowData : List String -> List String -> List String -> List String
getSelectedRowData headers selectedColumns rowData =
    List.map (\col -> 
        case findColumnIndex col headers of
            Just index -> 
                List.drop index rowData |> List.head |> Maybe.withDefault ""
            Nothing -> 
                ""
    ) selectedColumns


{-| Find column index in headers
-}
findColumnIndex : String -> List String -> Maybe Int
findColumnIndex target headers =
    List.indexedMap Tuple.pair headers
        |> List.filter (\(_, header) -> header == target)
        |> List.head
        |> Maybe.map (\(index, _) -> index)


{-| Render master column in grid layout
-}
renderGridMasterColumn : List String -> List String -> String -> Html ConfigureMsg
renderGridMasterColumn selectedMasterColumns selectedDataColumns column =
    let
        isSelected = List.member column selectedMasterColumns
        maybeMatchIndex = getSelectionIndex column selectedMasterColumns
        hasMatch = case maybeMatchIndex of
            Just index -> index <= List.length selectedDataColumns
            Nothing -> False
        matchedDataColumn = 
            case maybeMatchIndex of
                Just index -> 
                    List.drop (index - 1) selectedDataColumns |> List.head |> Maybe.withDefault ""
                Nothing -> 
                    ""
        
        columnClass =
            if isSelected then
                "matching-grid__column matching-grid__column--selected"
            else
                "matching-grid__column"
    in
    div [ class columnClass, onClick (toggleMasterColumn selectedMasterColumns column) ]
        [ div [ class "matching-grid__column-header" ]
            [ input [ type_ "checkbox", checked isSelected ] []
            , span [ class "matching-grid__column-name" ] [ text column ]
            ]
        , if hasMatch then
            div [ class "matching-grid__match-info" ]
                [ span [ class "matching-grid__arrow" ] [ text "→" ]
                , span [ class "matching-grid__matched" ] [ text matchedDataColumn ]
                ]
          else
            div [ class "matching-grid__match-info" ] []
        ]


{-| Render data column in grid layout
-}
renderGridDataColumn : List String -> List String -> String -> Html ConfigureMsg
renderGridDataColumn selectedMasterColumns selectedDataColumns column =
    let
        isSelected = List.member column selectedDataColumns
        maybeMatchIndex = getSelectionIndex column selectedDataColumns
        hasMatch = case maybeMatchIndex of
            Just index -> index <= List.length selectedMasterColumns
            Nothing -> False
        matchedMasterColumn = 
            case maybeMatchIndex of
                Just index -> 
                    List.drop (index - 1) selectedMasterColumns |> List.head |> Maybe.withDefault ""
                Nothing -> 
                    ""
        
        columnClass =
            if isSelected then
                "matching-grid__column matching-grid__column--selected"
            else
                "matching-grid__column"
    in
    div [ class columnClass, onClick (toggleDataColumn selectedDataColumns column) ]
        [ div [ class "matching-grid__column-header" ]
            [ input [ type_ "checkbox", checked isSelected ] []
            , span [ class "matching-grid__column-name" ] [ text column ]
            ]
        , if hasMatch then
            div [ class "matching-grid__match-info" ]
                [ span [ class "matching-grid__matched" ] [ text matchedMasterColumn ]
                , span [ class "matching-grid__arrow" ] [ text "→" ]
                ]
          else
            div [ class "matching-grid__match-info" ] []
        ]


{-| Toggle master column selection
-}
toggleMasterColumn : List String -> String -> ConfigureMsg
toggleMasterColumn selectedColumns column =
    if List.member column selectedColumns then
        DeselectMasterColumn column
    else
        SelectMasterColumn column


{-| Toggle data column selection  
-}
toggleDataColumn : List String -> String -> ConfigureMsg
toggleDataColumn selectedColumns column =
    if List.member column selectedColumns then
        DeselectDataColumn column
    else
        SelectDataColumn column


{-| Render matching summary section
-}
renderMatchingSummary : List String -> List String -> Html ConfigureMsg
renderMatchingSummary selectedMasterColumns selectedDataColumns =
    let
        matches = List.map2 Tuple.pair selectedMasterColumns selectedDataColumns
        unmatchedMaster = List.drop (List.length selectedDataColumns) selectedMasterColumns
        unmatchedData = List.drop (List.length selectedMasterColumns) selectedDataColumns
    in
    div [ class "matching-summary" ]
        [ h4 [ class "matching-summary__title" ] [ text "Current Matches" ]
        , if List.isEmpty matches then
            p [ class "matching-summary__empty" ] [ text "No columns matched yet. Select columns from both sides to create matches." ]
          else
            div [ class "matching-summary__matches" ]
                (List.indexedMap renderMatch matches)
        , if not (List.isEmpty unmatchedMaster) then
            div [ class "matching-summary__unmatched" ]
                [ span [ class "matching-summary__label" ] [ text "Unmatched Master: " ]
                , span [ class "matching-summary__columns" ] [ text (String.join ", " unmatchedMaster) ]
                ]
          else
            text ""
        , if not (List.isEmpty unmatchedData) then
            div [ class "matching-summary__unmatched" ]
                [ span [ class "matching-summary__label" ] [ text "Unmatched Data: " ]
                , span [ class "matching-summary__columns" ] [ text (String.join ", " unmatchedData) ]
                ]
          else
            text ""
        ]


{-| Render individual match
-}
renderMatch : Int -> ( String, String ) -> Html ConfigureMsg
renderMatch index ( masterCol, dataCol ) =
    div [ class "matching-summary__match" ]
        [ span [ class "matching-summary__index" ] [ text (String.fromInt (index + 1) ++ ".") ]
        , span [ class "matching-summary__master" ] [ text masterCol ]
        , span [ class "matching-summary__arrow" ] [ text "↔" ]
        , span [ class "matching-summary__data" ] [ text dataCol ]
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
