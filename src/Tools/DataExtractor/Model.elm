module Tools.DataExtractor.Model exposing
    ( Model, Msg(..), ConfigureMsg(..), PreviewMsg(..), SelectFieldsMsg(..), Step(..), FileData, ValidationError(..)
    , MatchedRecord, ProcessingStats, ProcessedData, MatchConfig
    , init, stepToString, canProceedToStep, getStepIndex
    , clearLargeDataStructures, estimateFileDataMemory, isMemoryUsageCritical, isMemoryUsageHigh, shouldShowMemoryWarning
      -- Memory Management Functions
    )

{-| Data Extractor tool model and types.

@docs Model, Msg, ConfigureMsg, PreviewMsg, SelectFieldsMsg, Step, FileData, ValidationError
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
    , selectedFields : Set String
    , availableFields : List String
    , isSelectingFields : Bool
    , selectedMasterColumns : List String
    , selectedDataColumns : List String
    , privacyNoticeShown : Bool
    , previewData : Maybe ProcessedData
    , isGeneratingPreview : Bool
    , previewError : Maybe String

    -- Memory Management Fields
    , memoryUsage : Int -- In bytes
    , memoryWarningThreshold : Int -- 80MB threshold
    , memoryLimitThreshold : Int -- 100MB hard limit
    , showMemoryWarning : Bool
    , lastMemoryCheck : Float -- Timestamp of last memory check
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
      -- Memory Management Messages
    | CheckMemoryUsage
    | MemoryUsageUpdated Int
    | ClearPreviewData
    | TriggerMemoryCleanup


{-| Select Fields step messages
-}
type SelectFieldsMsg
    = ToggleField String
    | SelectAllFields
    | ClearAllFields
    | ValidateFieldSelection


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
    | SelectFieldsMsg SelectFieldsMsg
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
    , selectedFields = Set.empty
    , availableFields = []
    , isSelectingFields = False
    , selectedMasterColumns = []
    , selectedDataColumns = []
    , privacyNoticeShown = True
    , previewData = Nothing
    , isGeneratingPreview = False
    , previewError = Nothing

    -- Memory Management Initial Values
    , memoryUsage = 0
    , memoryWarningThreshold = 83886080 -- 80MB in bytes
    , memoryLimitThreshold = 104857600 -- 100MB in bytes
    , showMemoryWarning = False
    , lastMemoryCheck = 0.0
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
            canProceedToStep SelectFields model && not (Set.isEmpty model.selectedFields)


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



-- MEMORY MANAGEMENT FUNCTIONS


{-| Estimate memory usage of FileData in bytes
-}
estimateFileDataMemory : FileData -> Int
estimateFileDataMemory fileData =
    let
        -- Estimate string memory (roughly 2 bytes per character + overhead)
        stringMemory strings =
            strings
                |> List.map String.length
                |> List.sum
                |> (*) 3

        -- Account for UTF-8 and overhead
        headerMemory =
            stringMemory fileData.headers

        rowMemory =
            fileData.rows |> List.concat |> stringMemory

        -- Add overhead for data structures (lists, records, etc.)
        structureOverhead =
            (List.length fileData.rows + List.length fileData.headers) * 64
    in
    headerMemory + rowMemory + structureOverhead + fileData.fileSize


{-| Check if memory usage is at critical level (>100MB)
-}
isMemoryUsageCritical : Model -> Bool
isMemoryUsageCritical model =
    model.memoryUsage >= model.memoryLimitThreshold


{-| Check if memory usage is high (>80MB)
-}
isMemoryUsageHigh : Model -> Bool
isMemoryUsageHigh model =
    model.memoryUsage >= model.memoryWarningThreshold


{-| Determine if memory warning should be shown
-}
shouldShowMemoryWarning : Model -> Bool
shouldShowMemoryWarning model =
    isMemoryUsageHigh model && not model.showMemoryWarning


{-| Clear large data structures from model for memory cleanup
-}
clearLargeDataStructures : Model -> Model
clearLargeDataStructures model =
    { model
        | previewData = Nothing
        , processedData = Nothing

        -- Reset memory tracking
        , memoryUsage =
            case ( model.masterFile, model.dataFile ) of
                ( Just master, Just data ) ->
                    estimateFileDataMemory master + estimateFileDataMemory data

                ( Just master, Nothing ) ->
                    estimateFileDataMemory master

                ( Nothing, Just data ) ->
                    estimateFileDataMemory data

                ( Nothing, Nothing ) ->
                    0
        , showMemoryWarning = False
    }
