module Tools.DataExtractor.Update exposing (update)

{-| Data Extractor update logic and state transitions.

@docs update

-}

import Json.Decode as Decode
import Json.Encode as Encode
import Ports
import Set
import Tools.DataExtractor.Model exposing (ConfigureMsg(..), DownloadMsg(..), ExtractionStats, FileData, Model, Msg(..), PreviewMsg(..), ProcessingStatus(..), SelectFieldsMsg(..), Step(..), ValidationError(..))
import Tools.DataExtractor.Steps.Download as Download
import Tools.DataExtractor.Steps.Preview as Preview
import Tools.DataExtractor.Steps.SelectFields as SelectFields
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
                let
                    updatedModel =
                        if nextStep == Preview then
                            -- Create MatchConfig when transitioning to Preview step
                            let
                                masterIndices =
                                    columnNamesToIndices model.selectedMasterColumns model.masterFile

                                dataIndices =
                                    columnNamesToIndices model.selectedDataColumns model.dataFile

                                matchConfig =
                                    { masterColumns = masterIndices
                                    , dataColumns = dataIndices
                                    , useFuzzyMatch = model.matchConfig |> Maybe.map .useFuzzyMatch |> Maybe.withDefault False
                                    }
                            in
                            { model
                                | currentStep = nextStep
                                , matchConfig = Just matchConfig
                            }

                        else if nextStep == SelectFields then
                            -- Initialize field selection when entering SelectFields step
                            let
                                availableFields =
                                    SelectFields.extractAvailableFields model.previewData model.masterFile model.dataFile

                                defaultSelection =
                                    SelectFields.initializeSelectedFields model.dataFile

                                selectedFields =
                                    if Set.isEmpty model.selectedFields then
                                        defaultSelection

                                    else
                                        model.selectedFields

                                selectedFieldsOrder =
                                    if List.isEmpty model.selectedFieldsOrder then
                                        -- Initialize order from selected fields
                                        Set.toList selectedFields
                                    else
                                        -- Keep existing order, but filter out any fields that are no longer available
                                        List.filter (\field -> Set.member field selectedFields) model.selectedFieldsOrder
                                
                            in
                            { model
                                | currentStep = nextStep
                                , availableFields = availableFields
                                , selectedFields = selectedFields
                                , selectedFieldsOrder = selectedFieldsOrder
                            }

                        else
                            { model | currentStep = nextStep }

                    -- Automatically generate preview when entering Preview step
                    cmd =
                        if nextStep == Preview && model.previewData == Nothing then
                            Cmd.map PreviewMsg (Preview.generatePreview updatedModel)

                        else
                            Cmd.none
                in
                ( updatedModel, cmd )

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

        PreviewMsg previewMsg ->
            updatePreviewStep previewMsg model

        SelectFieldsMsg selectFieldsMsg ->
            updateSelectFieldsStep selectFieldsMsg model

        DownloadMsg downloadMsg ->
            updateDownloadStep downloadMsg model

        SelectField fieldName selected ->
            let
                updatedFields =
                    if selected then
                        Set.insert fieldName model.selectedFields

                    else
                        Set.remove fieldName model.selectedFields
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


{-| Update preview step state
-}
updatePreviewStep : PreviewMsg -> Model -> ( Model, Cmd Msg )
updatePreviewStep previewMsg model =
    case previewMsg of
        GeneratePreview ->
            ( { model | isGeneratingPreview = True, previewError = Nothing }
            , Cmd.map PreviewMsg (Preview.generatePreview model)
            )

        PreviewGenerated processedData ->
            ( { model
                | previewData = Just processedData
                , isGeneratingPreview = False
                , previewError = Nothing
              }
            , Cmd.none
            )

        PreviewFailed error ->
            ( { model
                | previewError = Just error
                , isGeneratingPreview = False
              }
            , Cmd.none
            )

        ReturnToConfigure ->
            ( { model
                | currentStep = Configure
                , previewData = Nothing
                , previewError = Nothing
              }
            , Cmd.none
            )

        NextToSelectFields ->
            -- Use the proper NextStep logic instead of just changing the step
            update NextStep model

        -- Memory Management Messages
        CheckMemoryUsage ->
            let
                currentMemory =
                    calculateCurrentMemoryUsage model

                updatedModel =
                    { model
                        | memoryUsage = currentMemory
                        , showMemoryWarning = Tools.DataExtractor.Model.shouldShowMemoryWarning { model | memoryUsage = currentMemory }
                        , lastMemoryCheck = 0.0 -- Would be Time.now in real implementation
                    }
            in
            ( updatedModel, Cmd.none )

        MemoryUsageUpdated newUsage ->
            ( { model
                | memoryUsage = newUsage
                , showMemoryWarning = newUsage >= model.memoryWarningThreshold
              }
            , Cmd.none
            )

        ClearPreviewData ->
            ( { model
                | previewData = Nothing
                , memoryUsage = max 0 (model.memoryUsage - estimatePreviewDataMemory model.previewData)
              }
            , Cmd.none
            )

        TriggerMemoryCleanup ->
            let
                cleanedModel =
                    Tools.DataExtractor.Model.clearLargeDataStructures model
            in
            ( cleanedModel, Cmd.none )


{-| Convert column names to column indices using file headers
-}
columnNamesToIndices : List String -> Maybe FileData -> List Int
columnNamesToIndices columnNames maybeFileData =
    case maybeFileData of
        Nothing ->
            []

        Just fileData ->
            columnNames
                |> List.filterMap
                    (\columnName ->
                        fileData.headers
                            |> List.indexedMap Tuple.pair
                            |> List.filter (\( _, header ) -> header == columnName)
                            |> List.head
                            |> Maybe.map Tuple.first
                    )



-- MEMORY MANAGEMENT HELPER FUNCTIONS


{-| Calculate current memory usage of the model
-}
calculateCurrentMemoryUsage : Model -> Int
calculateCurrentMemoryUsage model =
    let
        masterFileMemory =
            case model.masterFile of
                Just file ->
                    Tools.DataExtractor.Model.estimateFileDataMemory file

                Nothing ->
                    0

        dataFileMemory =
            case model.dataFile of
                Just file ->
                    Tools.DataExtractor.Model.estimateFileDataMemory file

                Nothing ->
                    0

        previewDataMemory =
            estimatePreviewDataMemory model.previewData

        processedDataMemory =
            estimateProcessedDataMemory model.processedData
    in
    masterFileMemory + dataFileMemory + previewDataMemory + processedDataMemory


{-| Estimate memory usage of preview data
-}
estimatePreviewDataMemory : Maybe Tools.DataExtractor.Model.ProcessedData -> Int
estimatePreviewDataMemory maybeData =
    case maybeData of
        Nothing ->
            0

        Just data ->
            let
                recordsMemory =
                    data.matchedRecords
                        |> List.map
                            (\record ->
                                let
                                    masterRowMemory =
                                        record.masterRow |> List.map String.length |> List.sum |> (*) 3

                                    dataRowMemory =
                                        record.dataRow |> List.map String.length |> List.sum |> (*) 3

                                    matchedOnMemory =
                                        record.matchedOn |> List.map String.length |> List.sum |> (*) 3
                                in
                                masterRowMemory + dataRowMemory + matchedOnMemory + 32
                             -- Record overhead
                            )
                        |> List.sum

                unmatchedMemory =
                    (data.unmatchedMaster ++ data.unmatchedData)
                        |> List.map (List.map String.length >> List.sum >> (*) 3)
                        |> List.sum
            in
            recordsMemory + unmatchedMemory + 1024



-- Structure overhead


{-| Estimate memory usage of processed data
-}
estimateProcessedDataMemory : Maybe Tools.DataExtractor.Model.ProcessedData -> Int
estimateProcessedDataMemory maybeData =
    -- For now, same estimation as preview data
    estimatePreviewDataMemory maybeData


{-| Update select fields step state
-}
updateSelectFieldsStep : SelectFieldsMsg -> Model -> ( Model, Cmd Msg )
updateSelectFieldsStep selectFieldsMsg model =
    case selectFieldsMsg of
        ToggleField fieldName ->
            let
                isCurrentlySelected = Set.member fieldName model.selectedFields
                
                (updatedFields, updatedOrder) =
                    if isCurrentlySelected then
                        -- Removing field
                        ( Set.remove fieldName model.selectedFields
                        , List.filter ((/=) fieldName) model.selectedFieldsOrder
                        )
                    else
                        -- Adding field
                        ( Set.insert fieldName model.selectedFields
                        , model.selectedFieldsOrder ++ [fieldName]
                        )
            in
            ( { model | selectedFields = updatedFields, selectedFieldsOrder = updatedOrder }, Cmd.none )

        SelectAllFields ->
            let
                allFieldsSet =
                    Set.fromList model.availableFields
                allFieldsOrder =
                    model.availableFields
            in
            ( { model | selectedFields = allFieldsSet, selectedFieldsOrder = allFieldsOrder }, Cmd.none )

        ClearAllFields ->
            ( { model | selectedFields = Set.empty, selectedFieldsOrder = [] }, Cmd.none )

        MoveFieldUp fieldName ->
            let
                updatedOrder = moveFieldUp fieldName model.selectedFieldsOrder
            in
            ( { model | selectedFieldsOrder = updatedOrder }, Cmd.none )

        MoveFieldDown fieldName ->
            let
                updatedOrder = moveFieldDown fieldName model.selectedFieldsOrder
            in
            ( { model | selectedFieldsOrder = updatedOrder }, Cmd.none )

        ReorderFields newOrder ->
            ( { model | selectedFieldsOrder = newOrder }, Cmd.none )

        ValidateFieldSelection ->
            -- Validation happens automatically in the view
            -- This message is just for future extensibility
            ( model, Cmd.none )


{-| Move a field up in the order list
-}
moveFieldUp : String -> List String -> List String
moveFieldUp fieldName fields =
    moveFieldUpHelper fieldName fields []


{-| Helper function to move field up - accumulates previous elements
-}
moveFieldUpHelper : String -> List String -> List String -> List String
moveFieldUpHelper fieldName remaining acc =
    case remaining of
        [] ->
            List.reverse acc

        first :: rest ->
            if first == fieldName then
                case acc of
                    [] ->
                        -- Already at the top
                        fieldName :: rest
                    
                    prevField :: accRest ->
                        -- Swap with previous field
                        List.reverse accRest ++ [ fieldName, prevField ] ++ rest
            else
                moveFieldUpHelper fieldName rest (first :: acc)


{-| Move a field down in the order list
-}
moveFieldDown : String -> List String -> List String
moveFieldDown fieldName fields =
    moveFieldDownHelper fieldName fields []


{-| Helper function to move field down
-}
moveFieldDownHelper : String -> List String -> List String -> List String
moveFieldDownHelper fieldName remaining acc =
    case remaining of
        [] ->
            List.reverse acc

        first :: second :: rest ->
            if first == fieldName then
                -- Swap with next
                List.reverse acc ++ [ second, first ] ++ rest

            else
                moveFieldDownHelper fieldName (second :: rest) (first :: acc)

        [ single ] ->
            List.reverse (single :: acc)


{-| Update download step based on messages
-}
updateDownloadStep : DownloadMsg -> Model -> ( Model, Cmd Msg )
updateDownloadStep msg model =
    case msg of
        StartProcessing ->
            -- Start the full data processing
            case ( model.masterFile, model.dataFile, model.matchConfig ) of
                ( Just masterFile, Just dataFile, Just config ) ->
                    let
                        -- Process the data immediately (in real app, this would be async)
                        processedData =
                            Download.processAllData config masterFile dataFile model.selectedFields
                        
                        -- Generate CSV content
                        csvContent =
                            Download.generateCSVFromData processedData model.selectedFieldsOrder
                        
                        -- Calculate file size
                        fileSizeBytes =
                            String.length csvContent
                        
                        -- Create extraction stats
                        stats =
                            { recordsExtracted = List.length processedData.matchedRecords
                            , fileSizeBytes = fileSizeBytes
                            , timestamp = 0.0  -- Will be set properly with Time subscription
                            }
                        
                        -- Generate filename with timestamp
                        filename =
                            "extracted_data.csv"  -- Will be enhanced with timestamp
                    in
                    -- Set to Completed state with all data
                    ( { model 
                        | processingStatus = Completed
                        , processedData = Just processedData
                        , extractionStats = Just stats
                        }
                    , Ports.downloadCSV { filename = filename, content = csvContent }
                    )

                _ ->
                    ( { model | processingStatus = Failed "Missing required data for processing" }, Cmd.none )

        ProcessingProgress progress ->
            ( { model 
                | processingProgress = progress
                , processingStatus = Processing progress
                }
            , Cmd.none
            )

        ProcessingComplete processedData ->
            ( { model 
                | processedData = Just processedData
                , processingStatus = Completed
                }
            , Cmd.none
            )

        DownloadInitiated url ->
            ( { model | downloadUrl = Just url }, Cmd.none )

        ClearData ->
            -- Clear all data and reset to initial state
            ( Tools.DataExtractor.Model.init
            , Ports.clearMemory ()
            )

        StartOverFromDownload ->
            -- Reset to Upload step but keep privacy notice shown
            ( { model 
                | currentStep = Upload
                , masterFile = Nothing
                , dataFile = Nothing
                , processedData = Nothing
                , previewData = Nothing
                , processingStatus = NotStarted
                , processingProgress = 0.0
                , selectedFields = Set.empty
                , selectedFieldsOrder = []
                , extractionStats = Nothing
                , downloadUrl = Nothing
                , selectedMasterColumns = []
                , selectedDataColumns = []
                , matchConfig = Nothing
                }
            , Cmd.none
            )

