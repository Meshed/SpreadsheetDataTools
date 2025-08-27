module Tools.DataExtractor.Steps.Upload exposing (view)

{-| Upload step for Data Extractor wizard - handles dual file upload interface.

@docs view

-}

import Html exposing (Html, button, div, h2, input, label, p, span, text)
import Html.Attributes exposing (accept, attribute, class, disabled, id, multiple, type_)
import Html.Events exposing (on, onClick, preventDefaultOn)
import Json.Decode as Decode
import Json.Encode as Encode
import Shared.Components.ErrorDisplay as ErrorDisplay
import Shared.Components.Loading as Loading
import Tools.DataExtractor.Model exposing (Model, Msg(..), ValidationError(..), Step(..))
import Char


{-| Helper function to convert string to title case
-}
toTitleCase : String -> String
toTitleCase str =
    str
        |> String.words
        |> List.map (\word ->
            case String.uncons word of
                Just (first, rest) ->
                    String.fromChar (Char.toUpper first) ++ String.toLower rest
                Nothing ->
                    word
           )
        |> String.join " "


{-| Upload step view with dual file upload areas
-}
view : Model -> Html Msg
view model =
    div [ class "data-extractor__upload-step" ]
        [ viewStepHeader
        , viewUploadAreas model
        , viewPrivacyNotice
        , viewNavigationButtons model
        ]


{-| Step header with instructions
-}
viewStepHeader : Html Msg
viewStepHeader =
    div [ class "upload-step__header" ]
        [ h2 [ class "upload-step__title" ]
            [ text "Upload Your Spreadsheets" ]
        , p [ class "upload-step__instructions" ]
            [ text "Select your master spreadsheet and data spreadsheet to begin the extraction process. Both files must be uploaded to proceed." ]
        ]


{-| Dual file upload areas
-}
viewUploadAreas : Model -> Html Msg
viewUploadAreas model =
    div [ class "upload-step__areas" ]
        [ viewMasterUploadArea model
        , viewDataUploadArea model
        ]


{-| Master spreadsheet upload area
-}
viewMasterUploadArea : Model -> Html Msg
viewMasterUploadArea model =
    let
        fileInfoElements =
            case model.masterFile of
                Just fileData ->
                    [ div [ class "upload-area__file-info" ]
                        [ text ("Master Spreadsheet: " ++ fileData.fileName ++ " (" ++ String.fromInt fileData.rowCount ++ " rows)") ]
                    ]
                Nothing ->
                    []

        errorElements =
            case model.masterFileError of
                Just error ->
                    [ div [ class "upload-area__error" ]
                        [ viewValidationError error ]
                    ]
                Nothing ->
                    []
    in
    div [ class "upload-area upload-area--master" ]
        ([ viewUploadZone "master" model.masterFile model.masterFileError model.isProcessing ]
            ++ fileInfoElements
            ++ errorElements
        )


{-| Data spreadsheet upload area
-}
viewDataUploadArea : Model -> Html Msg
viewDataUploadArea model =
    let
        fileInfoElements =
            case model.dataFile of
                Just fileData ->
                    [ div [ class "upload-area__file-info" ]
                        [ text ("Data Spreadsheet: " ++ fileData.fileName ++ " (" ++ String.fromInt fileData.rowCount ++ " rows)") ]
                    ]
                Nothing ->
                    []

        errorElements =
            case model.dataFileError of
                Just error ->
                    [ div [ class "upload-area__error" ]
                        [ viewValidationError error ]
                    ]
                Nothing ->
                    []
    in
    div [ class "upload-area upload-area--data" ]
        ([ viewUploadZone "data" model.dataFile model.dataFileError model.isProcessing ]
            ++ fileInfoElements
            ++ errorElements
        )


{-| Upload zone with drag-and-drop functionality
-}
viewUploadZone : String -> Maybe fileData -> Maybe ValidationError -> Bool -> Html Msg
viewUploadZone fileType maybeFile maybeError isProcessing =
    let
        hasFile =
            maybeFile /= Nothing

        hasError =
            maybeError /= Nothing

        zoneClass =
            "upload-zone"
                ++ (if hasFile then
                        " upload-zone--has-file"
                    else
                        ""
                   )
                ++ (if hasError then
                        " upload-zone--error"
                    else
                        ""
                   )
                ++ (if isProcessing then
                        " upload-zone--processing"
                    else
                        ""
                   )

        fileSelectMsg =
            if fileType == "master" then
                MasterFileSelected
            else
                DataFileSelected
    in
    div
        [ class zoneClass
        , attribute "data-testid" ("upload-zone-" ++ fileType)
        , Html.Events.custom "dragover"
            (Decode.succeed
                { message = StepChanged Upload
                , stopPropagation = True
                , preventDefault = True
                }
            )
        , Html.Events.custom "dragenter"
            (Decode.succeed
                { message = StepChanged Upload
                , stopPropagation = True
                , preventDefault = True
                }
            )
        , Html.Events.custom "drop" (dropDecoderCustom fileSelectMsg)
        ]
        [ input
            [ type_ "file"
            , id (fileType ++ "-file-input")
            , class "upload-zone__input"
            , accept ".xlsx,.xls,.csv"
            , multiple False
            , on "change" (fileInputDecoder fileSelectMsg)
            ]
            []
        , label
            [ class "upload-zone__label"
            , Html.Attributes.for (fileType ++ "-file-input")
            ]
            [ if isProcessing then
                viewProcessingState
              else if hasFile then
                viewSuccessState fileType
              else
                viewEmptyState fileType
            ]
        ]


{-| Empty state for upload zone
-}
viewEmptyState : String -> Html Msg
viewEmptyState fileType =
    div [ class "upload-zone__content" ]
        [ div [ class "upload-zone__text" ]
            [ p [ class "upload-zone__primary-text" ]
                [ text ("Drop " ++ String.replace "-" " " fileType ++ " spreadsheet here") ]
            , p [ class "upload-zone__secondary-text" ]
                [ text "or click to browse files" ]
            , p [ class "upload-zone__format-text" ]
                [ text "Supports .xlsx, .xls, and .csv files" ]
            ]
        ]


{-| Success state when file is uploaded
-}
viewSuccessState : String -> Html Msg
viewSuccessState fileType =
    div [ class "upload-zone__content upload-zone__content--success" ]
        [ div [ class "upload-zone__text" ]
            [ p [ class "upload-zone__primary-text" ]
                [ text (toTitleCase (String.replace "-" " " fileType) ++ " spreadsheet uploaded successfully") ]
            , button
                [ class "upload-zone__clear-button"
                , onClick (if fileType == "master" then ClearMasterFile else ClearDataFile)
                , attribute "data-testid" ("clear-" ++ fileType ++ "-file")
                ]
                [ text "Remove file" ]
            ]
        ]


{-| Processing state during file upload
-}
viewProcessingState : Html Msg
viewProcessingState =
    div [ class "upload-zone__content upload-zone__content--processing" ]
        [ Loading.view
            { loadingType = Loading.Spinner
            , message = "Processing file..."
            , isVisible = True
            }
        ]


{-| Simple validation error display
-}
viewValidationError : ValidationError -> Html Msg
viewValidationError error =
    let
        errorConfig =
            validationErrorToErrorConfig error
    in
    ErrorDisplay.view errorConfig


{-| Convert validation error to ErrorDisplay config
-}
validationErrorToErrorConfig : ValidationError -> ErrorDisplay.ErrorConfig Msg
validationErrorToErrorConfig error =
    case error of
        InvalidFileType fileName supportedTypes ->
            { severity = ErrorDisplay.Warning
            , title = "Invalid File Type"
            , message = "The file '" ++ fileName ++ "' is not supported. Please upload " ++ String.join ", " supportedTypes ++ " files only."
            , actions = []
            }

        FileSizeExceeded actualSize maxSize ->
            let
                actualMB =
                    String.fromInt (actualSize // 1024 // 1024)

                maxMB =
                    String.fromInt (maxSize // 1024 // 1024)
            in
            { severity = ErrorDisplay.Warning
            , title = "File Too Large"
            , message = "File size is " ++ actualMB ++ "MB, but maximum allowed is " ++ maxMB ++ "MB. Please try a smaller file."
            , actions = []
            }

        FileParsingFailed message ->
            { severity = ErrorDisplay.Error
            , title = "File Processing Error"
            , message = message
            , actions = []
            }

        NoFileSelected fileType ->
            { severity = ErrorDisplay.Warning
            , title = "No File Selected"
            , message = "Please select a " ++ fileType ++ " spreadsheet file to continue."
            , actions = []
            }


{-| Privacy notice display
-}
viewPrivacyNotice : Html Msg
viewPrivacyNotice =
    div [ class "upload-step__privacy-notice privacy-notice" ]
        [ div [ class "privacy-notice__icon" ]
            [ text "🔒" ]
        , div [ class "privacy-notice__content" ]
            [ p [ class "privacy-notice__text" ]
                [ text "Files processed locally - never uploaded to servers" ]
            , p [ class "privacy-notice__subtext" ]
                [ text "Your data stays on your device for complete privacy" ]
            ]
        ]


{-| Navigation buttons for wizard
-}
viewNavigationButtons : Model -> Html Msg
viewNavigationButtons model =
    let
        canProceed =
            model.masterFile /= Nothing && model.dataFile /= Nothing && not model.isProcessing
    in
    div [ class "upload-step__navigation wizard-navigation" ]
        [ button
            [ class "wizard-navigation__button wizard-navigation__button--secondary"
            , onClick StartOver
            , attribute "data-testid" "start-over-button"
            ]
            [ text "Start Over" ]
        , button
            [ class ("wizard-navigation__button wizard-navigation__button--primary" ++ 
                    if canProceed then "" else " wizard-navigation__button--disabled")
            , onClick NextStep
            , disabled (not canProceed)
            , attribute "data-testid" "next-step-button"
            ]
            [ text "Next: Configure Matching" ]
        ]


{-| File drop event decoder for custom events
-}
dropDecoderCustom : (Encode.Value -> Msg) -> Decode.Decoder { message : Msg, stopPropagation : Bool, preventDefault : Bool }
dropDecoderCustom toMsg =
    Decode.at [ "dataTransfer", "files" ] (Decode.index 0 fileDecoder)
        |> Decode.map (\file -> 
            { message = toMsg file
            , stopPropagation = True
            , preventDefault = True
            })


{-| File drop event decoder
-}
dropDecoder : (Encode.Value -> Msg) -> Decode.Decoder Msg
dropDecoder toMsg =
    Decode.at [ "dataTransfer", "files" ] (Decode.index 0 fileDecoder)
        |> Decode.map toMsg


{-| File input change event decoder
-}
fileInputDecoder : (Encode.Value -> Msg) -> Decode.Decoder Msg
fileInputDecoder toMsg =
    Decode.at [ "target", "files" ] (Decode.index 0 fileDecoder)
        |> Decode.map toMsg


{-| File object decoder for JavaScript File API
-}
fileDecoder : Decode.Decoder Encode.Value
fileDecoder =
    Decode.value