module Tools.DataExtractor.Model exposing
    ( Model, Msg(..), ConfigureMsg(..), PreviewMsg(..), Step(..), FileData, ValidationError(..)
    , MatchedRecord, ProcessingStats, ProcessedData, MatchConfig
    , init, stepToString, canProceedToStep, getStepIndex
    )

{-| Data Extractor tool model and types.

@docs Model, Msg, ConfigureMsg, PreviewMsg, Step, FileData, ValidationError
@docs MatchedRecord, ProcessingStats, ProcessedData, MatchConfig
@docs init, stepToString, canProceedToStep, getStepIndex

-}

import Dict exposing (Dict)
import Json.Encode as Encode
import Set exposing (Set)
import Types.Errors exposing (AppError)


{-| Data Extractor wizard steps
-}
type Step
    = Upload
    | Configure
    | Preview
    | SelectFields
    | Download


{-| File data structure after parsing
-}
type alias FileData =
    { fileName : String
    , fileSize : Int
    , headers : List String
    , rows : List (List String)
    , rowCount : Int
    , columnCount : Int
    }


{-| File validation errors specific to Data Extractor
-}
type ValidationError
    = InvalidFileType String (List String)
    | FileSizeExceeded Int Int
    | FileParsingFailed String
    | NoFileSelected String


{-| Data Extractor tool model
-}
type alias Model =
    { currentStep : Step
    , masterFile : Maybe FileData
    , dataFile : Maybe FileData
    , masterFileError : Maybe ValidationError
    , dataFileError : Maybe ValidationError
    , isProcessing : Bool
    , processingFileType : Maybe String
    , matchConfig : Maybe MatchConfig
    , processedData : Maybe ProcessedData
    , selectedFields : List String
    , selectedMasterColumns : List String
    , selectedDataColumns : List String
    , privacyNoticeShown : Bool
    , previewData : Maybe ProcessedData
    , isGeneratingPreview : Bool
    , previewError : Maybe String
    }


{-| Match configuration for extraction
-}
type alias MatchConfig =
    { masterColumns : List Int
    , dataColumns : List Int
    , useFuzzyMatch : Bool
    }


{-| Individual matched record with metadata
-}
type alias MatchedRecord =
    { masterRow : List String
    , dataRow : List String
    , matchScore : Float
    , matchedOn : List String
    }


{-| Processing statistics
-}
type alias ProcessingStats =
    { totalMasterRows : Int
    , totalDataRows : Int
    , matchedCount : Int
    , unmatchedMasterCount : Int
    , unmatchedDataCount : Int
    , processingTime : Float
    }


{-| Processed data after matching
-}
type alias ProcessedData =
    { matchedRecords : List MatchedRecord
    , unmatchedMaster : List (List String)
    , unmatchedData : List (List String)
    , statistics : ProcessingStats
    , selectedFields : Set String
    }


{-| Preview step messages
-}
type PreviewMsg
    = GeneratePreview
    | PreviewGenerated ProcessedData
    | PreviewFailed String
    | ReturnToConfigure
    | NextToSelectFields


{-| Configure step messages
-}
type ConfigureMsg
    = SelectMasterColumn String
    | DeselectMasterColumn String
    | SelectDataColumn String
    | DeselectDataColumn String
    | ReorderSelection Int Int
    | ToggleFuzzyMatching Bool
    | ValidateSelections


{-| Data Extractor messages
-}
type Msg
    = StepChanged Step
    | MasterFileSelected Encode.Value
    | DataFileSelected Encode.Value
    | FileParseResult Encode.Value
    | ClearMasterFile
    | ClearDataFile
    | ClearError String
    | NextStep
    | PreviousStep
    | StartOver
    | ProcessFiles
    | ConfigureMatching MatchConfig
    | ConfigureMsg ConfigureMsg
    | PreviewMsg PreviewMsg
    | SelectField String Bool
    | GenerateCSV
    | DownloadComplete


{-| Initialize Data Extractor model
-}
init : Model
init =
    { currentStep = Upload
    , masterFile = Nothing
    , dataFile = Nothing
    , masterFileError = Nothing
    , dataFileError = Nothing
    , isProcessing = False
    , processingFileType = Nothing
    , matchConfig = Nothing
    , processedData = Nothing
    , selectedFields = []
    , selectedMasterColumns = []
    , selectedDataColumns = []
    , privacyNoticeShown = True
    , previewData = Nothing
    , isGeneratingPreview = False
    , previewError = Nothing
    }


{-| Convert step to string for display
-}
stepToString : Step -> String
stepToString step =
    case step of
        Upload ->
            "Upload Files"

        Configure ->
            "Configure Matching"

        Preview ->
            "Preview Results"

        SelectFields ->
            "Select Output Fields"

        Download ->
            "Download Results"


{-| Check if user can proceed to a specific step
-}
canProceedToStep : Step -> Model -> Bool
canProceedToStep step model =
    case step of
        Upload ->
            True

        Configure ->
            model.masterFile /= Nothing && model.dataFile /= Nothing

        Preview ->
            canProceedToStep Configure model
                && not (List.isEmpty model.selectedMasterColumns)
                && not (List.isEmpty model.selectedDataColumns)

        SelectFields ->
            canProceedToStep Preview model && model.previewData /= Nothing

        Download ->
            canProceedToStep SelectFields model && not (List.isEmpty model.selectedFields)


{-| Get step index for progress indicator
-}
getStepIndex : Step -> Int
getStepIndex step =
    case step of
        Upload ->
            1

        Configure ->
            2

        Preview ->
            3

        SelectFields ->
            4

        Download ->
            5
