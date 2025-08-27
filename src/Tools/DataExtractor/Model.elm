module Tools.DataExtractor.Model exposing
    ( Model, Msg(..), Step(..), FileData, ValidationError(..)
    , init, stepToString, canProceedToStep, getStepIndex
    )

{-| Data Extractor tool model and types.

@docs Model, Msg, Step, FileData, ValidationError
@docs init, stepToString, canProceedToStep, getStepIndex

-}

import Dict exposing (Dict)
import Json.Encode as Encode
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
    , matchConfig : Maybe MatchConfig
    , processedData : Maybe ProcessedData
    , selectedFields : List String
    , privacyNoticeShown : Bool
    }


{-| Match configuration for extraction
-}
type alias MatchConfig =
    { masterColumns : List Int
    , dataColumns : List Int
    , useFuzzyMatch : Bool
    }


{-| Processed data after matching
-}
type alias ProcessedData =
    { matchedRecords : List (List String)
    , matchCount : Int
    , totalRecords : Int
    }


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
    , matchConfig = Nothing
    , processedData = Nothing
    , selectedFields = []
    , privacyNoticeShown = True
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
            canProceedToStep Configure model && model.matchConfig /= Nothing

        SelectFields ->
            canProceedToStep Preview model && model.processedData /= Nothing

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