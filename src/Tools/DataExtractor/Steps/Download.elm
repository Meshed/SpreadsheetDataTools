module Tools.DataExtractor.Steps.Download exposing (view, processAllData, generateCSVFromData, formatFileSize, formatTimestamp)

{-| Download step for the Data Extractor tool.

Processes all matching records, generates CSV file, and manages download completion.

@docs view, processAllData, generateCSVFromData, formatFileSize, formatTimestamp

-}

import Html exposing (Html, button, div, h2, h3, h4, i, p, progress, span, text)
import Html.Attributes exposing (class, disabled, value)
import Html.Events exposing (onClick)
import Set exposing (Set)
import Shared.Processing.CSV as CSV
import Shared.Processing.Matching.Engine as Engine
import Tools.DataExtractor.Model exposing (DownloadMsg(..), ExtractionStats, FileData, MatchConfig, MatchedRecord, Model, Msg(..), ProcessedData, ProcessingStatus(..))


{-| View function for the Download step
-}
view : Model -> Html Msg
view model =
    div [ class "download-step" ]
        [ viewHeader
        , viewContent model
        , viewNavigationActions model
        ]


{-| Header section for Download step
-}
viewHeader : Html msg
viewHeader =
    div [ class "step-header" ]
        [ h2 [ class "step-title" ] [ text "Download Results" ]
        , p [ class "step-description" ]
            [ text "Your extraction is being processed. The CSV file will download automatically when complete." ]
        ]


{-| Main content area showing processing or completion status
-}
viewContent : Model -> Html Msg
viewContent model =
    div [ class "download-content" ]
        [ case model.processingStatus of
            NotStarted ->
                viewNotStarted model

            Processing progress ->
                viewProcessing progress model

            Completed ->
                viewCompleted model

            Failed error ->
                viewFailed error model
        ]


{-| View for initial state before processing starts
-}
viewNotStarted : Model -> Html Msg
viewNotStarted model =
    div [ class "download-content__not-started" ]
        [ div [ class "summary-card" ]
            [ h3 [ class "summary-card__title" ] [ text "Ready to Extract Data" ]
            , viewExtractionSummary model
            , button
                [ class "btn btn--primary btn--large"
                , onClick (DownloadMsg StartProcessing)
                ]
                [ text "Start Processing" ]
            ]
        ]


{-| View extraction summary before processing
-}
viewExtractionSummary : Model -> Html msg
viewExtractionSummary model =
    let
        selectedCount =
            Set.size model.selectedFields

        masterRows =
            model.masterFile
                |> Maybe.map .rowCount
                |> Maybe.withDefault 0

        dataRows =
            model.dataFile
                |> Maybe.map .rowCount
                |> Maybe.withDefault 0
    in
    div [ class "extraction-summary" ]
        [ p [ class "extraction-summary__item" ]
            [ span [ class "extraction-summary__label" ] [ text "Master records: " ]
            , span [ class "extraction-summary__value" ] [ text (String.fromInt masterRows) ]
            ]
        , p [ class "extraction-summary__item" ]
            [ span [ class "extraction-summary__label" ] [ text "Data records: " ]
            , span [ class "extraction-summary__value" ] [ text (String.fromInt dataRows) ]
            ]
        , p [ class "extraction-summary__item" ]
            [ span [ class "extraction-summary__label" ] [ text "Selected fields: " ]
            , span [ class "extraction-summary__value" ] [ text (String.fromInt selectedCount) ]
            ]
        ]


{-| View for processing state with progress bar
-}
viewProcessing : Float -> Model -> Html Msg
viewProcessing progressValue model =
    let
        percentComplete =
            String.fromInt (round (progressValue * 100))

        currentRow =
            case model.masterFile of
                Just master ->
                    round (toFloat master.rowCount * progressValue)

                Nothing ->
                    0

        totalRows =
            model.masterFile
                |> Maybe.map .rowCount
                |> Maybe.withDefault 0
    in
    div [ class "download-content__processing" ]
        [ div [ class "progress-card" ]
            [ h3 [ class "progress-card__title" ] [ text "Processing Data" ]
            , div [ class "progress-container" ]
                [ progress
                    [ class "progress-bar"
                    , value (String.fromFloat progressValue)
                    , Html.Attributes.max "1"
                    ]
                    []
                , span [ class "progress-text" ]
                    [ text (percentComplete ++ "% complete") ]
                ]
            , p [ class "progress-details" ]
                [ text ("Processing " ++ String.fromInt currentRow ++ " of " ++ String.fromInt totalRows ++ " records...") ]
            ]
        ]


{-| View for completed state with download success
-}
viewCompleted : Model -> Html Msg
viewCompleted model =
    div [ class "download-content__completed" ]
        [ div [ class "success-card" ]
            [ div [ class "success-icon" ]
                [ i [ class "icon icon--checkmark" ] [] ]
            , h3 [ class "success-card__title" ] [ text "Download Complete!" ]
            , viewCompletionStats model
            , viewPostDownloadGuidance
            , div [ class "action-buttons" ]
                [ button
                    [ class "btn btn--secondary"
                    , onClick (DownloadMsg ClearData)
                    ]
                    [ text "Clear All Data" ]
                , button
                    [ class "btn btn--primary"
                    , onClick (DownloadMsg StartOverFromDownload)
                    ]
                    [ text "Start Over" ]
                ]
            ]
        ]


{-| View completion statistics
-}
viewCompletionStats : Model -> Html msg
viewCompletionStats model =
    case model.extractionStats of
        Just stats ->
            div [ class "completion-stats" ]
                [ p [ class "completion-stats__item" ]
                    [ span [ class "completion-stats__label" ] [ text "Records extracted: " ]
                    , span [ class "completion-stats__value" ] [ text (String.fromInt stats.recordsExtracted) ]
                    ]
                , p [ class "completion-stats__item" ]
                    [ span [ class "completion-stats__label" ] [ text "File size: " ]
                    , span [ class "completion-stats__value" ] [ text (formatFileSize stats.fileSizeBytes) ]
                    ]
                , p [ class "completion-stats__item" ]
                    [ span [ class "completion-stats__label" ] [ text "Completed at: " ]
                    , span [ class "completion-stats__value" ] [ text (formatTimestamp stats.timestamp) ]
                    ]
                ]

        Nothing ->
            text ""


{-| View post-download guidance
-}
viewPostDownloadGuidance : Html msg
viewPostDownloadGuidance =
    div [ class "guidance-section" ]
        [ h4 [ class "guidance-section__title" ] [ text "Next Steps" ]
        , div [ class "guidance-section__content" ]
            [ p []
                [ text "Your extracted data has been downloaded as a CSV file. You can:" ]
            , ul [ class "guidance-list" ]
                [ li [] [ text "Open the file in Microsoft Excel, Google Sheets, or any spreadsheet application" ]
                , li [] [ text "Import the data into your database or analysis tools" ]
                , li [] [ text "Use the CSV format for further data processing" ]
                ]
            , p [ class "guidance-note" ]
                [ text "Note: The CSV file uses UTF-8 encoding and follows RFC 4180 standards for maximum compatibility." ]
            ]
        ]


{-| View for failed state with error message
-}
viewFailed : String -> Model -> Html Msg
viewFailed error model =
    div [ class "download-content__failed" ]
        [ div [ class "error-card" ]
            [ div [ class "error-icon" ]
                [ i [ class "icon icon--error" ] [] ]
            , h3 [ class "error-card__title" ] [ text "Processing Failed" ]
            , p [ class "error-message" ] [ text error ]
            , div [ class "action-buttons" ]
                [ button
                    [ class "btn btn--primary"
                    , onClick (DownloadMsg StartProcessing)
                    ]
                    [ text "Try Again" ]
                , button
                    [ class "btn btn--secondary"
                    , onClick PreviousStep
                    ]
                    [ text "Go Back" ]
                ]
            ]
        ]


{-| Navigation actions for download step
-}
viewNavigationActions : Model -> Html Msg
viewNavigationActions model =
    let
        isProcessing =
            case model.processingStatus of
                Processing _ ->
                    True

                _ ->
                    False
    in
    div [ class "step-actions" ]
        [ button
            [ class "btn btn--secondary"
            , onClick PreviousStep
            , disabled isProcessing
            ]
            [ text "Previous" ]
        ]


{-| Process all data using the matching configuration
Returns ProcessedData with all matches
-}
processAllData : MatchConfig -> FileData -> FileData -> Set String -> ProcessedData
processAllData config masterFile dataFile selectedFields =
    let
        -- Use the matching engine to process all rows
        processedData =
            Engine.matchRows config masterFile.rows dataFile.rows
    in
    { processedData
        | selectedFields = selectedFields
    }


{-| Generate CSV string from processed data using only selected fields
-}
generateCSVFromData : ProcessedData -> List String -> String
generateCSVFromData processedData fieldOrder =
    let
        -- Use all fields as provided (including empty strings if they exist)
        headers =
            fieldOrder

        -- Extract data rows from matched records, filtering by selected fields
        dataRows =
            if List.isEmpty fieldOrder then
                []

            else
                processedData.matchedRecords
                    |> List.map
                        (\record ->
                            -- Combine master and data rows, then extract selected fields
                            let
                                allColumns =
                                    record.masterRow ++ record.dataRow

                                -- Extract columns matching field order length, padding with empty strings if needed
                                extractedColumns =
                                    List.take (List.length fieldOrder) allColumns
                                        |> (\cols -> cols ++ List.repeat (List.length fieldOrder - List.length cols) "")
                            in
                            extractedColumns
                        )
                    |> List.filter
                        (\row ->
                            -- Filter out completely empty rows (all fields empty or whitespace-only)
                            not (List.all (\field -> String.trim field == "") row)
                        )
    in
    if List.isEmpty fieldOrder then
        ""

    else
        CSV.generateCSV headers dataRows


{-| Format file size in human-readable format
-}
formatFileSize : Int -> String
formatFileSize bytes =
    if bytes < 1024 then
        String.fromInt bytes ++ " B"

    else if bytes < 1048576 then
        let
            kbValue =
                toFloat bytes / 1024 |> round2
        in
        formatDecimal kbValue ++ " KB"

    else if bytes < 1073741824 then
        let
            mbValue =
                toFloat bytes / 1048576 |> round2
        in
        formatDecimal mbValue ++ " MB"

    else
        let
            gbValue =
                toFloat bytes / 1073741824 |> round2
        in
        formatDecimal gbValue ++ " GB"


{-| Round float to 2 decimal places
-}
round2 : Float -> Float
round2 n =
    toFloat (round (n * 100)) / 100


{-| Format decimal with consistent precision (always show .0 for whole numbers)
-}
formatDecimal : Float -> String
formatDecimal value =
    let
        rounded =
            round2 value

        asString =
            String.fromFloat rounded
    in
    if String.contains "." asString then
        asString

    else
        asString ++ ".0"


{-| Format timestamp as human-readable string
-}
formatTimestamp : Float -> String
formatTimestamp timestamp =
    -- Convert Unix timestamp (milliseconds) to a simple time format
    -- For now, show a basic time format with colons
    let
        -- Get current time components (simplified approach)
        hours =
            modBy 24 (floor (timestamp / (1000 * 60 * 60)))

        minutes =
            modBy 60 (floor (timestamp / (1000 * 60)))

        seconds =
            modBy 60 (floor (timestamp / 1000))

        -- Format with leading zeros
        formatWithZero n =
            if n < 10 then
                "0" ++ String.fromInt n

            else
                String.fromInt n
    in
    formatWithZero hours ++ ":" ++ formatWithZero minutes ++ ":" ++ formatWithZero seconds


{-| HTML element helpers
-}
ul : List (Html.Attribute msg) -> List (Html msg) -> Html msg
ul attrs children =
    Html.node "ul" attrs children


li : List (Html.Attribute msg) -> List (Html msg) -> Html msg
li attrs children =
    Html.node "li" attrs children
