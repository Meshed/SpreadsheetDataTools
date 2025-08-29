module Tools.DataExtractor.Update exposing (update)

{-| Data Extractor update logic and state transitions.

@docs update

-}

import Json.Decode as Decode
import Json.Encode as Encode
import Ports
import Tools.DataExtractor.Model exposing (ConfigureMsg(..), FileData, Model, Msg(..), Step(..), ValidationError(..))
import Types.Errors exposing (AppError(..))


{-| Update Data Extractor model based on messages
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        StepChanged step ->
            if Tools.DataExtractor.Model.canProceedToStep step model then
                ( { model | currentStep = step }, Cmd.none )

            else
                ( model, Cmd.none )

        MasterFileSelected fileValue ->
            let
                updatedModel =
                    { model
                        | masterFileError = Nothing
                        , isProcessing = True
                        , processingFileType = Just "master"
                    }
            in
            ( updatedModel, Ports.readExcelFile fileValue )

        DataFileSelected fileValue ->
            let
                updatedModel =
                    { model
                        | dataFileError = Nothing
                        , isProcessing = True
                        , processingFileType = Just "data"
                    }
            in
            ( updatedModel, Ports.readExcelFile fileValue )

        FileParseResult result ->
            handleFileParseResult result model

        ClearMasterFile ->
            ( { model
                | masterFile = Nothing
                , masterFileError = Nothing
              }
            , Cmd.none
            )

        ClearDataFile ->
            ( { model
                | dataFile = Nothing
                , dataFileError = Nothing
              }
            , Cmd.none
            )

        ClearError fileType ->
            case fileType of
                "master" ->
                    ( { model | masterFileError = Nothing }, Cmd.none )

                "data" ->
                    ( { model | dataFileError = Nothing }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        NextStep ->
            let
                nextStep =
                    getNextStep model.currentStep
            in
            if Tools.DataExtractor.Model.canProceedToStep nextStep model then
                ( { model | currentStep = nextStep }, Cmd.none )

            else
                ( model, Cmd.none )

        PreviousStep ->
            let
                previousStep =
                    getPreviousStep model.currentStep
            in
            ( { model | currentStep = previousStep }, Cmd.none )

        StartOver ->
            ( Tools.DataExtractor.Model.init, Ports.clearMemory () )

        ProcessFiles ->
            -- Future implementation for processing files in Configure step
            ( { model | isProcessing = True }, Cmd.none )

        ConfigureMatching matchConfig ->
            -- Future implementation for match configuration
            ( { model | matchConfig = Just matchConfig }, Cmd.none )

        ConfigureMsg configureMsg ->
            updateConfigureStep configureMsg model

        SelectField fieldName selected ->
            let
                updatedFields =
                    if selected then
                        fieldName :: model.selectedFields

                    else
                        List.filter ((/=) fieldName) model.selectedFields
            in
            ( { model | selectedFields = updatedFields }, Cmd.none )

        GenerateCSV ->
            -- Future implementation for CSV generation
            ( { model | isProcessing = True }, Cmd.none )

        DownloadComplete ->
            ( { model | isProcessing = False }, Cmd.none )


{-| Handle file parse results from JavaScript
-}
handleFileParseResult : Encode.Value -> Model -> ( Model, Cmd Msg )
handleFileParseResult result model =
    case decodeFileResult result of
        Ok fileData ->
            case validateFileData fileData of
                Ok validFile ->
                    let
                        updatedModel =
                            case model.processingFileType of
                                Just "master" ->
                                    { model
                                        | masterFile = Just validFile
                                        , masterFileError = Nothing
                                        , isProcessing = False
                                        , processingFileType = Nothing
                                    }

                                Just "data" ->
                                    { model
                                        | dataFile = Just validFile
                                        , dataFileError = Nothing
                                        , isProcessing = False
                                        , processingFileType = Nothing
                                    }

                                _ ->
                                    -- Fallback to filename-based detection if processingFileType is somehow lost
                                    if String.contains "master" (String.toLower validFile.fileName) then
                                        { model
                                            | masterFile = Just validFile
                                            , masterFileError = Nothing
                                            , isProcessing = False
                                            , processingFileType = Nothing
                                        }

                                    else
                                        { model
                                            | dataFile = Just validFile
                                            , dataFileError = Nothing
                                            , isProcessing = False
                                            , processingFileType = Nothing
                                        }
                    in
                    ( updatedModel, Cmd.none )

                Err validationError ->
                    let
                        updatedModel =
                            case model.processingFileType of
                                Just "master" ->
                                    { model
                                        | masterFileError = Just validationError
                                        , isProcessing = False
                                        , processingFileType = Nothing
                                    }

                                Just "data" ->
                                    { model
                                        | dataFileError = Just validationError
                                        , isProcessing = False
                                        , processingFileType = Nothing
                                    }

                                _ ->
                                    -- Fallback to filename-based detection if processingFileType is somehow lost
                                    if String.contains "master" (getFileNameFromResult result) then
                                        { model
                                            | masterFileError = Just validationError
                                            , isProcessing = False
                                            , processingFileType = Nothing
                                        }

                                    else
                                        { model
                                            | dataFileError = Just validationError
                                            , isProcessing = False
                                            , processingFileType = Nothing
                                        }
                    in
                    ( updatedModel, Cmd.none )

        Err _ ->
            let
                fileName =
                    getFileNameFromResult result

                validationError =
                    FileParsingFailed "Unable to parse file. Please ensure it's a valid Excel or CSV file."

                updatedModel =
                    case model.processingFileType of
                        Just "master" ->
                            { model
                                | masterFileError = Just validationError
                                , isProcessing = False
                                , processingFileType = Nothing
                            }

                        Just "data" ->
                            { model
                                | dataFileError = Just validationError
                                , isProcessing = False
                                , processingFileType = Nothing
                            }

                        _ ->
                            -- Fallback to filename-based detection if processingFileType is somehow lost
                            if String.contains "master" (String.toLower fileName) then
                                { model
                                    | masterFileError = Just validationError
                                    , isProcessing = False
                                    , processingFileType = Nothing
                                }

                            else
                                { model
                                    | dataFileError = Just validationError
                                    , isProcessing = False
                                    , processingFileType = Nothing
                                }
            in
            ( updatedModel, Cmd.none )


{-| Decode file parse result from JavaScript
-}
decodeFileResult : Encode.Value -> Result Decode.Error FileData
decodeFileResult value =
    Decode.decodeValue
        (Decode.map6 FileData
            (Decode.field "fileName" Decode.string)
            (Decode.field "fileSize" Decode.int)
            (Decode.field "headers" (Decode.list Decode.string))
            (Decode.field "rows" (Decode.list (Decode.list Decode.string)))
            (Decode.field "rowCount" Decode.int)
            (Decode.field "columnCount" Decode.int)
        )
        value


{-| Validate parsed file data
-}
validateFileData : FileData -> Result ValidationError FileData
validateFileData fileData =
    let
        maxFileSize =
            50 * 1024 * 1024

        -- 50MB in bytes
        supportedExtensions =
            [ ".xlsx", ".xls", ".csv" ]

        fileName =
            String.toLower fileData.fileName

        hasValidExtension =
            List.any (\ext -> String.endsWith ext fileName) supportedExtensions
    in
    if fileData.fileSize > maxFileSize then
        Err (FileSizeExceeded fileData.fileSize maxFileSize)

    else if not hasValidExtension then
        Err (InvalidFileType fileData.fileName supportedExtensions)

    else if fileData.rowCount == 0 then
        Err (FileParsingFailed "File appears to be empty or contains no readable data.")

    else
        Ok fileData


{-| Get file name from parse result for error handling
-}
getFileNameFromResult : Encode.Value -> String
getFileNameFromResult value =
    case Decode.decodeValue (Decode.field "fileName" Decode.string) value of
        Ok fileName ->
            fileName

        Err _ ->
            "Unknown file"


{-| Get next step in wizard flow
-}
getNextStep : Step -> Step
getNextStep currentStep =
    case currentStep of
        Upload ->
            Configure

        Configure ->
            Preview

        Preview ->
            SelectFields

        SelectFields ->
            Download

        Download ->
            Download


{-| Get previous step in wizard flow
-}
getPreviousStep : Step -> Step
getPreviousStep currentStep =
    case currentStep of
        Upload ->
            Upload

        Configure ->
            Upload

        Preview ->
            Configure

        SelectFields ->
            Preview

        Download ->
            SelectFields


{-| Update configure step state
-}
updateConfigureStep : ConfigureMsg -> Model -> ( Model, Cmd Msg )
updateConfigureStep configureMsg model =
    case configureMsg of
        SelectMasterColumn column ->
            if List.member column model.selectedMasterColumns then
                ( model, Cmd.none )

            else
                ( { model | selectedMasterColumns = model.selectedMasterColumns ++ [ column ] }, Cmd.none )

        DeselectMasterColumn column ->
            ( { model | selectedMasterColumns = List.filter ((/=) column) model.selectedMasterColumns }, Cmd.none )

        SelectDataColumn column ->
            if List.member column model.selectedDataColumns then
                ( model, Cmd.none )

            else
                ( { model | selectedDataColumns = model.selectedDataColumns ++ [ column ] }, Cmd.none )

        DeselectDataColumn column ->
            ( { model | selectedDataColumns = List.filter ((/=) column) model.selectedDataColumns }, Cmd.none )

        ReorderSelection fromIndex toIndex ->
            let
                reorderedMaster =
                    reorderList fromIndex toIndex model.selectedMasterColumns

                reorderedData =
                    reorderList fromIndex toIndex model.selectedDataColumns
            in
            ( { model
                | selectedMasterColumns = reorderedMaster
                , selectedDataColumns = reorderedData
              }
            , Cmd.none
            )

        ToggleFuzzyMatching enabled ->
            let
                updatedMatchConfig =
                    case model.matchConfig of
                        Just config ->
                            Just { config | useFuzzyMatch = enabled }

                        Nothing ->
                            Just { masterColumns = [], dataColumns = [], useFuzzyMatch = enabled }
            in
            ( { model | matchConfig = updatedMatchConfig }, Cmd.none )

        ValidateSelections ->
            -- Validation is handled in the view
            ( model, Cmd.none )


{-| Reorder list by moving item from fromIndex to toIndex
-}
reorderList : Int -> Int -> List a -> List a
reorderList fromIndex toIndex list =
    let
        listLength =
            List.length list

        validFromIndex =
            max 0 (min fromIndex (listLength - 1))

        validToIndex =
            max 0 (min toIndex (listLength - 1))
    in
    if validFromIndex == validToIndex then
        list

    else
        case List.drop validFromIndex list |> List.head of
            Nothing ->
                list

            Just item ->
                let
                    listWithoutItem =
                        List.take validFromIndex list ++ List.drop (validFromIndex + 1) list

                    beforeTarget =
                        List.take validToIndex listWithoutItem

                    afterTarget =
                        List.drop validToIndex listWithoutItem
                in
                beforeTarget ++ [ item ] ++ afterTarget
