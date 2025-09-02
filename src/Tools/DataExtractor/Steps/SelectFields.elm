module Tools.DataExtractor.Steps.SelectFields exposing
    ( view, extractAvailableFields, initializeSelectedFields, getFieldSamples
    , FieldSource(..), categorizeField
    )

{-| Select Fields step for the Data Extractor tool.

Shows all available columns from both spreadsheets with checkboxes for selection,
sample data preview, and bulk selection controls.

@docs view, extractAvailableFields, initializeSelectedFields, getFieldSamples

-}

import Dict exposing (Dict)
import Html exposing (Html, button, div, h2, h3, h4, input, label, p, span, text)
import Html.Attributes exposing (checked, class, disabled, for, id, type_)
import Html.Events exposing (onCheck, onClick)
import Set exposing (Set)
import Tools.DataExtractor.Model exposing (FileData, MatchedRecord, Model, ProcessedData, SelectFieldsMsg(..), Msg(..))


{-| View function for the Select Fields step
-}
view : Model -> Html Msg
view model =
    div [ class "select-fields-step" ]
        [ viewHeader
        , viewFieldSelectionContent model
        , viewNavigationActions model
        ]


{-| Header section for Select Fields step
-}
viewHeader : Html msg
viewHeader =
    div [ class "step-header" ]
        [ h2 [ class "step-title" ] [ text "Select Output Fields" ]
        , p [ class "step-description" ]
            [ text "Choose which columns to include in your extracted data. Fields from your data spreadsheet are selected by default." ]
        ]




{-| Main field selection content
-}
viewFieldSelectionContent : Model -> Html Msg
viewFieldSelectionContent model =
    if model.isSelectingFields then
        viewLoadingState

    else
        case ( model.masterFile, model.dataFile, model.previewData ) of
            ( Just masterFile, Just dataFile, Just previewData ) ->
                viewFieldSelection model masterFile dataFile previewData

            _ ->
                viewErrorState "Required data not available for field selection"


{-| Loading state during field validation
-}
viewLoadingState : Html msg
viewLoadingState =
    div [ class "select-fields-loading" ]
        [ div [ class "loading-spinner" ] []
        , p [] [ text "Preparing field selection..." ]
        ]


{-| Error state when required data is missing
-}
viewErrorState : String -> Html msg
viewErrorState error =
    div [ class "select-fields-error" ]
        [ h3 [] [ text "Field Selection Not Available" ]
        , p [] [ text error ]
        ]


{-| Main field selection interface with two-panel layout
-}
viewFieldSelection : Model -> FileData -> FileData -> ProcessedData -> Html Msg
viewFieldSelection model masterFile dataFile previewData =
    let
        fieldCount =
            Set.size model.selectedFields

        validationError =
            if fieldCount == 0 then
                Just "At least one field must be selected to proceed"

            else
                Nothing
    in
    div [ class "field-selection" ]
        [ viewBulkActions fieldCount (List.length model.availableFields)
        , div [ class "field-selection-panels" ]
            [ div [ class "field-selection-panel" ]
                [ viewSelectedFieldsList model
                , viewAvailableFieldsList model masterFile dataFile previewData
                ]
            , div [ class "csv-preview-panel" ]
                [ viewCSVPreview model masterFile dataFile previewData ]
            ]
        , viewValidationMessage validationError
        ]


{-| Bulk selection actions (Select All / Clear All)
-}
viewBulkActions : Int -> Int -> Html Msg
viewBulkActions selectedCount totalCount =
    div [ class "bulk-actions" ]
        [ p [ class "selection-count" ]
            [ text (String.fromInt selectedCount ++ " of " ++ String.fromInt totalCount ++ " fields selected") ]
        , div [ class "bulk-buttons" ]
            [ button
                [ class "btn btn--outline btn--small"
                , onClick (SelectFieldsMsg SelectAllFields)
                , disabled (selectedCount == totalCount)
                ]
                [ text "Select All" ]
            , button
                [ class "btn btn--outline btn--small"
                , onClick (SelectFieldsMsg ClearAllFields)
                , disabled (selectedCount == 0)
                ]
                [ text "Clear All" ]
            ]
        ]


{-| Selected fields list with ordering controls (CSV column order)
-}
viewSelectedFieldsList : Model -> Html Msg
viewSelectedFieldsList model =
    div [ class "selected-fields-section" ]
        [ h3 [ class "section-title" ] [ text "Selected Fields (CSV Column Order)" ]
        , if List.isEmpty model.selectedFieldsOrder then
            div [ class "empty-selection" ]
                [ text "No fields selected. Choose fields from the Available Fields below." ]
          else
            div [ class "selected-fields-list" ]
                (List.indexedMap (viewSelectedField model) model.selectedFieldsOrder)
        ]


{-| Available fields list (unselected fields that can be added)
-}
viewAvailableFieldsList : Model -> FileData -> FileData -> ProcessedData -> Html Msg
viewAvailableFieldsList model masterFile dataFile previewData =
    let
        unselectedFields =
            List.filter (\field -> not (Set.member field model.selectedFields)) model.availableFields
    in
    div [ class "available-fields-section" ]
        [ h3 [ class "section-title" ] [ text "Available Fields" ]
        , if List.isEmpty unselectedFields then
            div [ class "empty-available" ]
                [ text "All fields have been selected." ]
          else
            div [ class "available-fields-list" ]
                (List.map (viewAvailableField model masterFile dataFile previewData) unselectedFields)
        ]


{-| Individual selected field with ordering controls
-}
viewSelectedField : Model -> Int -> String -> Html Msg
viewSelectedField model index fieldName =
    let
        canMoveUp = index > 0
        canMoveDown = index < (List.length model.selectedFieldsOrder - 1)
        fieldId = "selected-field-" ++ fieldName
    in
    div [ class "selected-field-item" ]
        [ div [ class "field-info" ]
            [ span [ class "field-name" ] [ text fieldName ]
            , span [ class "field-position" ] [ text ("Column " ++ String.fromInt (index + 1)) ]
            ]
        , div [ class "field-controls" ]
            [ button 
                [ class "btn btn--icon btn--small"
                , onClick (SelectFieldsMsg (MoveFieldUp fieldName))
                , disabled (not canMoveUp)
                ]
                [ text "↑" ]
            , button 
                [ class "btn btn--icon btn--small"
                , onClick (SelectFieldsMsg (MoveFieldDown fieldName))
                , disabled (not canMoveDown)
                ]
                [ text "↓" ]
            , button 
                [ class "btn btn--icon btn--small btn--remove"
                , onClick (SelectFieldsMsg (ToggleField fieldName))
                ]
                [ text "×" ]
            ]
        ]


{-| Individual available field that can be selected
-}
viewAvailableField : Model -> FileData -> FileData -> ProcessedData -> String -> Html Msg
viewAvailableField model masterFile dataFile previewData fieldName =
    let
        fieldSource =
            categorizeField masterFile dataFile fieldName

        sampleValues =
            getFieldSamples fieldName previewData

        fieldId =
            "available-field-" ++ fieldName
    in
    div [ class "available-field-item" ]
        [ div [ class "field-content" ]
            [ div [ class "field-header" ]
                [ span [ class "field-name" ] [ text fieldName ]
                , span [ class "field-source" ]
                    [ text (fieldSourceToString fieldSource) ]
                ]
            , viewFieldPreview sampleValues
            ]
        , button 
            [ class "btn btn--primary btn--small"
            , onClick (SelectFieldsMsg (ToggleField fieldName))
            ]
            [ text "Add" ]
        ]


{-| Individual field option with checkbox, label, source indicator, and sample data
-}
viewFieldOption : Model -> FileData -> FileData -> ProcessedData -> String -> Html Msg
viewFieldOption model masterFile dataFile previewData fieldName =
    let
        isSelected =
            Set.member fieldName model.selectedFields

        fieldSource =
            categorizeField masterFile dataFile fieldName

        sampleValues =
            getFieldSamples fieldName previewData

        fieldId =
            "field-" ++ fieldName
    in
    div [ class "field-option" ]
        [ div [ class "field-option__checkbox" ]
            [ input
                [ type_ "checkbox"
                , id fieldId
                , checked isSelected
                , onCheck (\_ -> SelectFieldsMsg (ToggleField fieldName))
                ]
                []
            ]
        , div [ class "field-option__content" ]
            [ label [ class "field-option__label", for fieldId ]
                [ text fieldName
                , span [ class "field-option__source" ]
                    [ text (fieldSourceToString fieldSource) ]
                ]
            , viewFieldPreview sampleValues
            ]
        ]


{-| Sample data preview for a field
-}
viewFieldPreview : List String -> Html msg
viewFieldPreview sampleValues =
    if List.isEmpty sampleValues then
        div [ class "field-preview" ]
            [ span [ class "field-preview__empty" ] [ text "No preview available" ] ]

    else
        let
            displayValues =
                List.take 3 sampleValues

            previewText =
                "Sample: " ++ String.join ", " displayValues
        in
        div [ class "field-preview" ]
            [ span [ class "field-preview__values" ] [ text previewText ] ]


{-| Validation message display
-}
viewValidationMessage : Maybe String -> Html msg
viewValidationMessage maybeError =
    case maybeError of
        Just error ->
            div [ class "field-validation" ]
                [ div [ class "field-validation__error" ]
                    [ span [ class "validation-icon" ] [ text "⚠" ]
                    , text error
                    ]
                ]

        Nothing ->
            text ""


{-| CSV Preview Grid showing what the output will look like
-}
viewCSVPreview : Model -> FileData -> FileData -> ProcessedData -> Html msg
viewCSVPreview model masterFile dataFile previewData =
    div [ class "csv-preview-section" ]
        [ div [ class "preview-header" ]
            [ h3 [ class "section-title" ] [ text "CSV Preview" ]
            , p [ class "preview-description" ] 
                [ text "This shows exactly what your CSV output will look like with the selected fields." ]
            ]
        , if List.isEmpty model.selectedFieldsOrder then
            div [ class "preview-empty" ]
                [ text "Select fields to see CSV preview" ]
          else
            viewCSVPreviewGrid model masterFile dataFile previewData
        ]


{-| CSV Preview Grid with actual data
-}
viewCSVPreviewGrid : Model -> FileData -> FileData -> ProcessedData -> Html msg
viewCSVPreviewGrid model masterFile dataFile previewData =
    let
        -- Get sample rows from preview data  
        sampleRows = List.take 5 previewData.matchedRecords
        
        -- Create combined field mapping
        fieldMapping = createFieldMapping masterFile dataFile
    in
    div [ class "csv-preview-grid" ]
        [ div [ class "csv-table" ]
            [ div [ class "csv-header" ]
                (List.map viewCSVHeaderCell model.selectedFieldsOrder)
            , div [ class "csv-body" ]
                (List.indexedMap (viewCSVDataRow model.selectedFieldsOrder fieldMapping) sampleRows)
            ]
        , viewCSVPreviewInfo (List.length sampleRows) (List.length model.selectedFieldsOrder)
        ]


{-| CSV Header Cell
-}
viewCSVHeaderCell : String -> Html msg
viewCSVHeaderCell fieldName =
    div [ class "csv-header-cell" ]
        [ text fieldName ]


{-| CSV Data Row
-}
viewCSVDataRow : List String -> Dict.Dict String Int -> Int -> MatchedRecord -> Html msg
viewCSVDataRow selectedFields fieldMapping rowIndex record =
    let
        -- Combine master and data rows for field lookup
        allFields = record.masterRow ++ record.dataRow
        
        rowValues = List.map (getFieldValue allFields fieldMapping) selectedFields
    in
    div [ class "csv-data-row" ]
        (List.map viewCSVDataCell rowValues)


{-| CSV Data Cell
-}
viewCSVDataCell : String -> Html msg
viewCSVDataCell value =
    div [ class "csv-data-cell" ]
        [ text (if String.isEmpty value then "(empty)" else value) ]


{-| CSV Preview Information
-}
viewCSVPreviewInfo : Int -> Int -> Html msg
viewCSVPreviewInfo rowCount columnCount =
    div [ class "csv-preview-info" ]
        [ p [ class "preview-stats" ]
            [ text ("Showing " ++ String.fromInt rowCount ++ " sample rows with " ++ String.fromInt columnCount ++ " columns") ]
        , p [ class "preview-note" ]
            [ text "The actual CSV will contain all matched records from your data processing." ]
        ]


{-| Navigation actions for Select Fields step
-}
viewNavigationActions : Model -> Html Msg
viewNavigationActions model =
    let
        canProceed =
            not (Set.isEmpty model.selectedFields)
    in
    div [ class "select-fields-actions wizard__actions" ]
        [ button
            [ class "btn btn--secondary"
            , onClick PreviousStep
            ]
            [ text "Back to Preview" ]
        , button
            [ class "btn btn--primary"
            , disabled (not canProceed)
            , onClick NextStep
            ]
            [ text "Next: Download Results" ]
        ]



-- HELPER FUNCTIONS


{-| Extract all available fields from both spreadsheets
-}
extractAvailableFields : Maybe ProcessedData -> Maybe FileData -> Maybe FileData -> List String
extractAvailableFields maybePreviewData maybeMasterFile maybeDataFile =
    -- Always use FileData headers as they contain the actual column names
    -- ProcessedData contains matched records but not the header information
    case ( maybeMasterFile, maybeDataFile ) of
        ( Just masterFile, Just dataFile ) ->
            List.concat [ masterFile.headers, dataFile.headers ]
                |> removeDuplicates
                |> List.sort

        ( Just masterFile, Nothing ) ->
            masterFile.headers

        ( Nothing, Just dataFile ) ->
            dataFile.headers

        ( Nothing, Nothing ) ->
            []


{-| Initialize selected fields with default selection (empty - let users choose)
-}
initializeSelectedFields : Maybe FileData -> Set String
initializeSelectedFields maybeDataFile =
    -- Start with empty selection - let users choose which fields they want
    Set.empty


{-| Get sample values for a field from preview data
-}
getFieldSamples : String -> ProcessedData -> List String
getFieldSamples fieldName previewData =
    previewData.matchedRecords
        |> List.take 3
        |> List.concatMap (\record -> record.masterRow ++ record.dataRow)
        |> removeDuplicates
        |> List.filter (not << String.isEmpty)
        |> List.take 3


{-| Categorize field source (Master, Data, or Both)
-}
categorizeField : FileData -> FileData -> String -> FieldSource
categorizeField masterFile dataFile fieldName =
    let
        inMaster =
            List.member fieldName masterFile.headers

        inData =
            List.member fieldName dataFile.headers
    in
    case ( inMaster, inData ) of
        ( True, True ) ->
            Both

        ( True, False ) ->
            Master

        ( False, True ) ->
            Data

        ( False, False ) ->
            Master



-- Fallback, shouldn't happen


{-| Field source type
-}
type FieldSource
    = Master
    | Data
    | Both


{-| Convert field source to display string
-}
fieldSourceToString : FieldSource -> String
fieldSourceToString source =
    case source of
        Master ->
            " (Master)"

        Data ->
            " (Data)"

        Both ->
            " (Both)"


{-| Remove duplicate strings from list while preserving order
-}
removeDuplicates : List String -> List String
removeDuplicates list =
    removeDuplicatesHelper list []


{-| Helper function for removing duplicates
-}
removeDuplicatesHelper : List String -> List String -> List String
removeDuplicatesHelper remaining acc =
    case remaining of
        [] ->
            List.reverse acc

        head :: tail ->
            if List.member head acc then
                removeDuplicatesHelper tail acc

            else
                removeDuplicatesHelper tail (head :: acc)


{-| Create field mapping for CSV preview (maps field names to indices)
-}
createFieldMapping : FileData -> FileData -> Dict String Int
createFieldMapping masterFile dataFile =
    let
        -- Create mapping for master file fields (indices 0 to n-1)
        masterMapping = 
            List.indexedMap (\index field -> (field, index)) masterFile.headers
            |> Dict.fromList
        
        -- Create mapping for data file fields (indices start after master fields)
        dataMapping = 
            List.indexedMap (\index field -> (field, index + List.length masterFile.headers)) dataFile.headers
            |> Dict.fromList
    in
    Dict.union masterMapping dataMapping


{-| Get field value from combined row data using field mapping
-}
getFieldValue : List String -> Dict String Int -> String -> String
getFieldValue allFields fieldMapping fieldName =
    case Dict.get fieldName fieldMapping of
        Just index ->
            case List.head (List.drop index allFields) of
                Just value ->
                    value
                Nothing ->
                    ""
        Nothing ->
            ""
