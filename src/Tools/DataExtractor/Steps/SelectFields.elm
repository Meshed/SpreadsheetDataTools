module Tools.DataExtractor.Steps.SelectFields exposing
    ( view, extractAvailableFields, initializeSelectedFields, getFieldSamples
    , FieldSource(..), categorizeField
    )

{-| Select Fields step for the Data Extractor tool.

Shows all available columns from both spreadsheets with checkboxes for selection,
sample data preview, and bulk selection controls.

@docs view, extractAvailableFields, initializeSelectedFields, getFieldSamples

-}

import Html exposing (Html, button, div, h2, h3, h4, input, label, p, span, text)
import Html.Attributes exposing (checked, class, disabled, for, id, type_)
import Html.Events exposing (onCheck, onClick)
import Set exposing (Set)
import Tools.DataExtractor.Model exposing (FileData, MatchedRecord, Model, ProcessedData, SelectFieldsMsg(..))


{-| View function for the Select Fields step
-}
view : Model -> Html SelectFieldsMsg
view model =
    div [ class "select-fields-step" ]
        [ viewHeader
        , viewProgressIndicator
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


{-| Progress indicator showing step 4 of 5
-}
viewProgressIndicator : Html msg
viewProgressIndicator =
    div [ class "wizard__progress" ]
        [ div [ class "wizard__progress-bar" ]
            [ div [ class "wizard__step wizard__step--completed" ] [ text "1" ]
            , div [ class "wizard__step wizard__step--completed" ] [ text "2" ]
            , div [ class "wizard__step wizard__step--completed" ] [ text "3" ]
            , div [ class "wizard__step wizard__step--active" ] [ text "4" ]
            , div [ class "wizard__step wizard__step--inactive" ] [ text "5" ]
            ]
        , p [ class "wizard__step-label" ] [ text "Step 4 of 5: Select Output Fields" ]
        ]


{-| Main field selection content
-}
viewFieldSelectionContent : Model -> Html SelectFieldsMsg
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


{-| Main field selection interface
-}
viewFieldSelection : Model -> FileData -> FileData -> ProcessedData -> Html SelectFieldsMsg
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
        , viewFieldList model masterFile dataFile previewData
        , viewValidationMessage validationError
        , viewSelectionSummary fieldCount
        ]


{-| Bulk selection actions (Select All / Clear All)
-}
viewBulkActions : Int -> Int -> Html SelectFieldsMsg
viewBulkActions selectedCount totalCount =
    div [ class "bulk-actions" ]
        [ p [ class "selection-count" ]
            [ text (String.fromInt selectedCount ++ " of " ++ String.fromInt totalCount ++ " fields selected") ]
        , div [ class "bulk-buttons" ]
            [ button
                [ class "btn btn--outline btn--small"
                , onClick SelectAllFields
                , disabled (selectedCount == totalCount)
                ]
                [ text "Select All" ]
            , button
                [ class "btn btn--outline btn--small"
                , onClick ClearAllFields
                , disabled (selectedCount == 0)
                ]
                [ text "Clear All" ]
            ]
        ]


{-| List of all available fields with checkboxes and samples
-}
viewFieldList : Model -> FileData -> FileData -> ProcessedData -> Html SelectFieldsMsg
viewFieldList model masterFile dataFile previewData =
    div [ class "field-selection-list" ]
        (List.map (viewFieldOption model masterFile dataFile previewData) model.availableFields)


{-| Individual field option with checkbox, label, source indicator, and sample data
-}
viewFieldOption : Model -> FileData -> FileData -> ProcessedData -> String -> Html SelectFieldsMsg
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
                , onCheck (\_ -> ToggleField fieldName)
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


{-| Selection summary
-}
viewSelectionSummary : Int -> Html msg
viewSelectionSummary fieldCount =
    div [ class "selection-summary" ]
        [ p []
            [ text "Selected fields will be included in your CSV output in the order they appear above." ]
        ]


{-| Navigation actions for Select Fields step
-}
viewNavigationActions : Model -> Html SelectFieldsMsg
viewNavigationActions model =
    let
        canProceed =
            not (Set.isEmpty model.selectedFields)
    in
    div [ class "select-fields-actions wizard__actions" ]
        [ button
            [ class "btn btn--secondary"
            , onClick ValidateFieldSelection -- This will trigger navigation back
            ]
            [ text "Back to Preview" ]
        , button
            [ class "btn btn--primary"
            , disabled (not canProceed)
            , onClick ValidateFieldSelection -- This will trigger navigation forward
            ]
            [ text "Next: Download Results" ]
        ]



-- HELPER FUNCTIONS


{-| Extract all available fields from both spreadsheets
-}
extractAvailableFields : Maybe ProcessedData -> Maybe FileData -> Maybe FileData -> List String
extractAvailableFields maybePreviewData maybeMasterFile maybeDataFile =
    case maybePreviewData of
        Just previewData ->
            -- Use processed data if available (preferred)
            extractFieldsFromProcessedData previewData

        Nothing ->
            -- Fallback to raw FileData headers
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


{-| Extract fields from processed data (includes all fields from matched records)
-}
extractFieldsFromProcessedData : ProcessedData -> List String
extractFieldsFromProcessedData processedData =
    case List.head processedData.matchedRecords of
        Just firstRecord ->
            let
                masterFieldCount =
                    List.length firstRecord.masterRow

                dataFieldCount =
                    List.length firstRecord.dataRow

                -- Generate field names based on record structure
                masterFields =
                    List.range 0 (masterFieldCount - 1) |> List.map (\i -> "Master_" ++ String.fromInt i)

                dataFields =
                    List.range 0 (dataFieldCount - 1) |> List.map (\i -> "Data_" ++ String.fromInt i)
            in
            masterFields ++ dataFields

        Nothing ->
            []


{-| Initialize selected fields with default selection (data spreadsheet fields)
-}
initializeSelectedFields : Maybe FileData -> Set String
initializeSelectedFields maybeDataFile =
    case maybeDataFile of
        Just dataFile ->
            Set.fromList dataFile.headers

        Nothing ->
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
