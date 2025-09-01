module Tools.DataExtractor.Steps.Preview exposing (view, generatePreview, limitToPreviewSize)

{-| Preview step for the Data Extractor tool.

Shows sample matched records before field selection to verify matching logic.

@docs view, generatePreview, limitToPreviewSize

-}

import Html exposing (Html, div, h2, h3, h4, h5, p, text, button, span, strong)
import Html.Attributes exposing (class, disabled)
import Html.Events exposing (onClick)
import Task exposing (Task)
import Shared.Processing.Matching.Engine as Engine
import Tools.DataExtractor.Model exposing (Model, PreviewMsg(..), MatchedRecord, ProcessingStats, ProcessedData, MatchConfig, FileData)


{-| View function for the Preview step
-}
view : Model -> Html PreviewMsg
view model =
    div [ class "preview-step" ]
        [ viewHeader
        , viewProgressIndicator
        , viewPreviewContent model
        , viewNavigationActions model
        ]


{-| Header section for Preview step
-}
viewHeader : Html msg
viewHeader =
    div [ class "step-header" ]
        [ h2 [ class "step-title" ] [ text "Preview Extraction Results" ]
        , p [ class "step-description" ]
            [ text "Review sample matches to verify your matching configuration before selecting output fields." ]
        ]


{-| Progress indicator showing step 3 of 5
-}
viewProgressIndicator : Html msg
viewProgressIndicator =
    div [ class "wizard__progress" ]
        [ div [ class "wizard__progress-bar" ]
            [ div [ class "wizard__step wizard__step--completed" ] [ text "1" ]
            , div [ class "wizard__step wizard__step--completed" ] [ text "2" ]
            , div [ class "wizard__step wizard__step--active" ] [ text "3" ]
            , div [ class "wizard__step wizard__step--inactive" ] [ text "4" ]
            , div [ class "wizard__step wizard__step--inactive" ] [ text "5" ]
            ]
        , p [ class "wizard__step-label" ] [ text "Step 3 of 5: Preview Results" ]
        ]


{-| Main preview content based on model state
-}
viewPreviewContent : Model -> Html PreviewMsg
viewPreviewContent model =
    if model.isGeneratingPreview then
        viewLoadingState
    else
        case model.previewError of
            Just error ->
                viewErrorState error

            Nothing ->
                case model.previewData of
                    Just processedData ->
                        if List.isEmpty processedData.matchedRecords then
                            viewNoMatchesState
                        else
                            viewPreviewSamples processedData

                    Nothing ->
                        viewInitialState


{-| Loading state while generating preview
-}
viewLoadingState : Html msg
viewLoadingState =
    div [ class "preview-loading" ]
        [ div [ class "loading-spinner" ] []
        , p [] [ text "Generating preview..." ]
        ]


{-| Initial state - trigger preview generation
-}
viewInitialState : Html PreviewMsg
viewInitialState =
    div [ class "preview-initial" ]
        [ button [ class "btn btn--primary", onClick GeneratePreview ]
            [ text "Generate Preview" ]
        ]


{-| Error state display
-}
viewErrorState : String -> Html PreviewMsg
viewErrorState error =
    div [ class "preview-error" ]
        [ h3 [] [ text "Preview Generation Failed" ]
        , p [] [ text error ]
        , button [ class "btn btn--secondary", onClick GeneratePreview ]
            [ text "Try Again" ]
        ]


{-| No matches found state with helpful suggestions
-}
viewNoMatchesState : Html PreviewMsg
viewNoMatchesState =
    div [ class "no-matches" ]
        [ h3 [] [ text "No matches found" ]
        , p [] [ text "Your current matching criteria didn't find any matching records." ]
        , div [ class "no-matches__suggestions" ]
            [ h4 [] [ text "Try the following to improve matches:" ]
            , div [ class "suggestion-list" ]
                [ p [] [ text "• Check that selected columns contain similar data types" ]
                , p [] [ text "• Enable fuzzy matching for text fields with slight variations" ]
                , p [] [ text "• Review your column selections in the previous step" ]
                , p [] [ text "• Consider reviewing your source files to ensure matching data is available" ]
                ]
            ]
        ]


{-| Display preview samples (up to 3 matched records)
-}
viewPreviewSamples : { a | matchedRecords : List MatchedRecord, statistics : ProcessingStats } -> Html msg
viewPreviewSamples processedData =
    let
        previewRecords = List.take 3 processedData.matchedRecords
    in
    div [ class "preview-samples" ]
        [ div [ class "preview-summary" ]
            [ p []
                [ text "Showing "
                , strong [] [ text (String.fromInt (List.length previewRecords)) ]
                , text " sample matches out of "
                , strong [] [ text (String.fromInt processedData.statistics.matchedCount) ]
                , text " total matches found."
                ]
            ]
        , div [ class "samples-container" ]
            (List.indexedMap viewMatchedRecord previewRecords)
        ]


{-| Display individual matched record with field highlighting
-}
viewMatchedRecord : Int -> MatchedRecord -> Html msg
viewMatchedRecord index record =
    div [ class "preview-sample" ]
        [ h4 [ class "sample-title" ] 
            [ text ("Match " ++ String.fromInt (index + 1)) ]
        , div [ class "matched-record" ]
            [ div [ class "master-record" ]
                [ h5 [] [ text "Master Record" ]
                , viewRecordFields record.masterRow record.matchedOn
                ]
            , div [ class "match-arrow" ] [ text "↔" ]
            , div [ class "data-record" ]
                [ h5 [] [ text "Data Record" ]
                , viewRecordFields record.dataRow record.matchedOn
                ]
            ]
        , viewMatchConfidence record.matchScore
        ]


{-| Display record fields with highlighting for matched fields
-}
viewRecordFields : List String -> List String -> Html msg
viewRecordFields values matchedFields =
    let
        fieldPairs = List.indexedMap (\index value -> (index, value)) values
    in
    div [ class "record-fields" ]
        (List.map (viewField matchedFields) fieldPairs)


{-| Display individual field with highlighting if matched
-}
viewField : List String -> (Int, String) -> Html msg
viewField matchedFields (index, value) =
    let
        fieldIndex = String.fromInt index
        isMatched = List.member fieldIndex matchedFields
        fieldClass = if isMatched then "field field--matched" else "field"
    in
    div [ class fieldClass ]
        [ span [ class "field-value" ] [ text value ] ]


{-| Display match confidence score
-}
viewMatchConfidence : Float -> Html msg
viewMatchConfidence score =
    let
        percentage = round (score * 100)
        confidenceClass = 
            if score >= 1.0 then "match-confidence match-confidence--exact"
            else if score >= 0.9 then "match-confidence match-confidence--high"
            else if score >= 0.7 then "match-confidence match-confidence--medium"
            else "match-confidence match-confidence--low"
    in
    div [ class confidenceClass ]
        [ span [] 
            [ text "Match Confidence: "
            , strong [] [ text (String.fromInt percentage ++ "%") ]
            ]
        ]


{-| Navigation actions for Preview step
-}
viewNavigationActions : Model -> Html PreviewMsg
viewNavigationActions model =
    div [ class "preview-actions wizard__actions" ]
        [ button 
            [ class "btn btn--secondary"
            , onClick ReturnToConfigure
            ] 
            [ text "Re-configure" ]
        , button 
            [ class "btn btn--primary"
            , disabled (model.previewData == Nothing)
            , onClick NextToSelectFields
            ] 
            [ text "Next: Select Fields" ]
        ]


{-| Generate preview data using the Matching Engine with performance monitoring
-}
generatePreview : Model -> Cmd PreviewMsg
generatePreview model =
    case (model.masterFile, model.dataFile, model.matchConfig) of
        (Just masterFile, Just dataFile, Just config) ->
            let
                -- Performance check: limit input size for preview
                masterRowsLimited = List.take 1000 masterFile.rows  -- Limit to 1000 rows for preview
                dataRowsLimited = List.take 1000 dataFile.rows      -- Limit to 1000 rows for preview
                
                -- Memory check: validate file sizes (simulated - actual memory would be handled by JS)
                totalSize = masterFile.fileSize + dataFile.fileSize
                maxPreviewSize = 10 * 1024 * 1024  -- 10MB limit for preview
                
                result =
                    if totalSize > maxPreviewSize then
                        PreviewFailed ("Files too large for preview (" ++ String.fromInt (totalSize // (1024 * 1024)) ++ "MB). Maximum 10MB supported for preview.")
                    else
                        let
                            processedData = 
                                Engine.matchRows config masterRowsLimited dataRowsLimited
                                    |> limitToPreviewSize 3  -- Always limit to 3 for performance
                        in
                        PreviewGenerated processedData
            in
            Task.succeed result
                |> Task.perform identity

        _ ->
            Task.succeed (PreviewFailed "Missing required data for preview generation")
                |> Task.perform identity


{-| Limit processed data to preview size for performance
-}
limitToPreviewSize : Int -> ProcessedData -> ProcessedData
limitToPreviewSize maxSamples processedData =
    { processedData 
        | matchedRecords = List.take maxSamples processedData.matchedRecords
    }