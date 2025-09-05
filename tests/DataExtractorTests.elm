module DataExtractorTests exposing (..)

import Expect exposing (Expectation)
import Json.Encode as Encode
import Set
import Test exposing (..)
import Tools.DataExtractor.Model as DataExtractor
import Tools.DataExtractor.Update as DataExtractorUpdate


suite : Test
suite =
    describe "Data Extractor Tests"
        [ describe "Model initialization"
            [ test "initializes with Upload step" <|
                \_ ->
                    let
                        model =
                            DataExtractor.init
                    in
                    Expect.equal DataExtractor.Upload model.currentStep
            , test "initializes with no files" <|
                \_ ->
                    let
                        model =
                            DataExtractor.init
                    in
                    Expect.all
                        [ \m -> Expect.equal Nothing m.masterFile
                        , \m -> Expect.equal Nothing m.dataFile
                        ]
                        model
            , test "initializes with privacy notice shown" <|
                \_ ->
                    let
                        model =
                            DataExtractor.init
                    in
                    Expect.equal True model.privacyNoticeShown
            ]
        , describe "Step navigation"
            [ test "getStepIndex returns correct indices" <|
                \_ ->
                    Expect.all
                        [ \_ -> Expect.equal 1 (DataExtractor.getStepIndex DataExtractor.Upload)
                        , \_ -> Expect.equal 2 (DataExtractor.getStepIndex DataExtractor.Configure)
                        , \_ -> Expect.equal 3 (DataExtractor.getStepIndex DataExtractor.Preview)
                        , \_ -> Expect.equal 4 (DataExtractor.getStepIndex DataExtractor.SelectFields)
                        , \_ -> Expect.equal 5 (DataExtractor.getStepIndex DataExtractor.Download)
                        ]
                        ()
            , test "stepToString returns correct step names" <|
                \_ ->
                    Expect.all
                        [ \_ -> Expect.equal "Upload Files" (DataExtractor.stepToString DataExtractor.Upload)
                        , \_ -> Expect.equal "Configure Matching" (DataExtractor.stepToString DataExtractor.Configure)
                        , \_ -> Expect.equal "Preview Results" (DataExtractor.stepToString DataExtractor.Preview)
                        , \_ -> Expect.equal "Select Output Fields" (DataExtractor.stepToString DataExtractor.SelectFields)
                        , \_ -> Expect.equal "Download Results" (DataExtractor.stepToString DataExtractor.Download)
                        ]
                        ()
            ]
        , describe "Step validation"
            [ test "Upload step is always accessible" <|
                \_ ->
                    let
                        model =
                            DataExtractor.init
                    in
                    Expect.equal True (DataExtractor.canProceedToStep DataExtractor.Upload model)
            , test "Configure step requires both files" <|
                \_ ->
                    let
                        model =
                            DataExtractor.init
                    in
                    Expect.equal False (DataExtractor.canProceedToStep DataExtractor.Configure model)
            ]
        , describe "File assignment logic"
            [ test "MasterFileSelected sets processingFileType to master" <|
                \_ ->
                    let
                        model =
                            DataExtractor.init

                        fileValue =
                            Encode.object []

                        ( updatedModel, _ ) =
                            DataExtractorUpdate.update (DataExtractor.MasterFileSelected fileValue) model
                    in
                    Expect.equal (Just "master") updatedModel.processingFileType
            , test "DataFileSelected sets processingFileType to data" <|
                \_ ->
                    let
                        model =
                            DataExtractor.init

                        fileValue =
                            Encode.object []

                        ( updatedModel, _ ) =
                            DataExtractorUpdate.update (DataExtractor.DataFileSelected fileValue) model
                    in
                    Expect.equal (Just "data") updatedModel.processingFileType
            , test "successful master file processing assigns to masterFile" <|
                \_ ->
                    let
                        model =
                            modelWithProcessingFileType "master"

                        fileData =
                            { fileName = "test.xlsx"
                            , fileSize = 1000
                            , headers = [ "col1", "col2" ]
                            , rows = [ [ "row1col1", "row1col2" ] ]
                            , rowCount = 1
                            , columnCount = 2
                            }

                        result =
                            encodeFileData fileData

                        ( updatedModel, _ ) =
                            DataExtractorUpdate.update (DataExtractor.FileParseResult result) model
                    in
                    Expect.all
                        [ \m -> Expect.notEqual Nothing m.masterFile
                        , \m -> Expect.equal Nothing m.dataFile
                        , \m -> Expect.equal Nothing m.processingFileType
                        , \m -> Expect.equal False m.isProcessing
                        ]
                        updatedModel
            , test "successful data file processing assigns to dataFile" <|
                \_ ->
                    let
                        model =
                            modelWithProcessingFileType "data"

                        fileData =
                            { fileName = "test.csv"
                            , fileSize = 500
                            , headers = [ "name", "value" ]
                            , rows = [ [ "test", "123" ] ]
                            , rowCount = 1
                            , columnCount = 2
                            }

                        result =
                            encodeFileData fileData

                        ( updatedModel, _ ) =
                            DataExtractorUpdate.update (DataExtractor.FileParseResult result) model
                    in
                    Expect.all
                        [ \m -> Expect.equal Nothing m.masterFile
                        , \m -> Expect.notEqual Nothing m.dataFile
                        , \m -> Expect.equal Nothing m.processingFileType
                        , \m -> Expect.equal False m.isProcessing
                        ]
                        updatedModel
            , test "file assignment ignores filename when processingFileType is set" <|
                \_ ->
                    let
                        model =
                            modelWithProcessingFileType "data"

                        fileData =
                            { fileName = "master-file.xlsx" -- filename suggests master but processingFileType is data
                            , fileSize = 1000
                            , headers = [ "col1", "col2" ]
                            , rows = [ [ "row1col1", "row1col2" ] ]
                            , rowCount = 1
                            , columnCount = 2
                            }

                        result =
                            encodeFileData fileData

                        ( updatedModel, _ ) =
                            DataExtractorUpdate.update (DataExtractor.FileParseResult result) model
                    in
                    Expect.all
                        [ \m -> Expect.equal Nothing m.masterFile -- Should be Nothing, not assigned
                        , \m -> Expect.notEqual Nothing m.dataFile -- Should be assigned here
                        ]
                        updatedModel
            , test "fallback to filename detection when processingFileType is None" <|
                \_ ->
                    let
                        model =
                            modelWithNoProcessingFileType

                        fileData =
                            { fileName = "master-spreadsheet.xlsx"
                            , fileSize = 1000
                            , headers = [ "col1", "col2" ]
                            , rows = [ [ "row1col1", "row1col2" ] ]
                            , rowCount = 1
                            , columnCount = 2
                            }

                        result =
                            encodeFileData fileData

                        ( updatedModel, _ ) =
                            DataExtractorUpdate.update (DataExtractor.FileParseResult result) model
                    in
                    Expect.notEqual Nothing updatedModel.masterFile
            , test "error handling respects processingFileType for master" <|
                \_ ->
                    let
                        model =
                            modelWithProcessingFileType "master"

                        errorResult =
                            Encode.object
                                [ ( "fileName", Encode.string "test.xlsx" )
                                , ( "success", Encode.bool False )
                                , ( "error", Encode.string "Invalid file" )
                                ]

                        ( updatedModel, _ ) =
                            DataExtractorUpdate.update (DataExtractor.FileParseResult errorResult) model
                    in
                    Expect.all
                        [ \m -> Expect.notEqual Nothing m.masterFileError
                        , \m -> Expect.equal Nothing m.dataFileError
                        , \m -> Expect.equal Nothing m.processingFileType
                        ]
                        updatedModel
            , test "error handling respects processingFileType for data" <|
                \_ ->
                    let
                        model =
                            modelWithProcessingFileType "data"

                        errorResult =
                            Encode.object
                                [ ( "fileName", Encode.string "test.csv" )
                                , ( "success", Encode.bool False )
                                , ( "error", Encode.string "Invalid file" )
                                ]

                        ( updatedModel, _ ) =
                            DataExtractorUpdate.update (DataExtractor.FileParseResult errorResult) model
                    in
                    Expect.all
                        [ \m -> Expect.equal Nothing m.masterFileError
                        , \m -> Expect.notEqual Nothing m.dataFileError
                        , \m -> Expect.equal Nothing m.processingFileType
                        ]
                        updatedModel
            ]
        , describe "CSV Download Workflow Integration"
            [ test "complete workflow from upload to download processing" <|
                \_ ->
                    let
                        -- Start with initial model
                        initialModel =
                            DataExtractor.init

                        -- Add master file
                        masterFileData =
                            { fileName = "master.xlsx"
                            , fileSize = 1000
                            , headers = [ "Name", "Email", "Phone" ]
                            , rows = [ [ "John Doe", "john@example.com", "123-456-7890" ] ]
                            , rowCount = 1
                            , columnCount = 3
                            }

                        masterFileResult =
                            encodeFileData masterFileData

                        ( modelAfterMaster, _ ) =
                            DataExtractorUpdate.update (DataExtractor.MasterFileSelected (Encode.object [])) initialModel
                                |> (\(model, cmd) -> DataExtractorUpdate.update (DataExtractor.FileParseResult masterFileResult) model)

                        -- Add data file
                        dataFileData =
                            { fileName = "data.csv"
                            , fileSize = 800
                            , headers = [ "FullName", "Department", "EmailAddr" ]
                            , rows = [ [ "John Doe", "Engineering", "john@example.com" ] ]
                            , rowCount = 1
                            , columnCount = 3
                            }

                        dataFileResult =
                            encodeFileData dataFileData

                        ( modelAfterData, _ ) =
                            DataExtractorUpdate.update (DataExtractor.DataFileSelected (Encode.object [])) modelAfterMaster
                                |> (\(model, cmd) -> DataExtractorUpdate.update (DataExtractor.FileParseResult dataFileResult) model)

                        -- Configure matching
                        matchConfig =
                            { masterColumns = [ 0, 1 ]
                            , dataColumns = [ 0, 2 ]
                            , useFuzzyMatch = False
                            }

                        ( modelAfterConfig, _ ) =
                            DataExtractorUpdate.update (DataExtractor.ConfigureMatching matchConfig) modelAfterData

                        -- Add required fields for step validation
                        modelWithColumns =
                            { modelAfterConfig 
                                | selectedMasterColumns = [ "Name", "Email" ]
                                , selectedDataColumns = [ "FullName", "EmailAddr" ]
                            }

                        -- Add preview data (required for Download step)
                        samplePreviewData =
                            { matchedRecords = 
                                [ { masterRow = [ "John Doe", "john@example.com" ]
                                  , dataRow = [ "John Doe", "john@example.com" ]
                                  , matchScore = 1.0
                                  , matchedOn = [ "Name", "Email" ]
                                  }
                                ]
                            , unmatchedMaster = []
                            , unmatchedData = []
                            , statistics = 
                                { totalMasterRows = 1
                                , totalDataRows = 1
                                , matchedCount = 1
                                , unmatchedMasterCount = 0
                                , unmatchedDataCount = 0
                                , processingTime = 100.0
                                }
                            , selectedFields = Set.fromList [ "Name", "Email" ]
                            }

                        modelWithPreview =
                            { modelWithColumns 
                                | previewData = Just samplePreviewData
                                , selectedFields = Set.fromList [ "Name", "Email" ]
                            }

                        -- Navigate to Download step (should now pass validation)
                        ( modelAtDownload, _ ) =
                            DataExtractorUpdate.update (DataExtractor.StepChanged DataExtractor.Download) modelWithPreview

                        -- Start processing
                        ( finalModel, _ ) =
                            DataExtractorUpdate.update (DataExtractor.DownloadMsg DataExtractor.StartProcessing) modelAtDownload
                    in
                    Expect.all
                        [ \m -> Expect.notEqual Nothing m.masterFile
                        , \m -> Expect.notEqual Nothing m.dataFile
                        , \m -> Expect.notEqual Nothing m.matchConfig
                        , \m -> Expect.equal DataExtractor.Download m.currentStep
                        , \m -> Expect.notEqual DataExtractor.NotStarted m.processingStatus
                        ]
                        finalModel
            , test "processing status transitions correctly" <|
                \_ ->
                    let
                        -- Create a model ready for processing
                        readyModel =
                            createModelReadyForDownload

                        -- Start processing
                        ( processingModel, _ ) =
                            DataExtractorUpdate.update (DataExtractor.DownloadMsg DataExtractor.StartProcessing) readyModel

                        -- Simulate progress update
                        ( progressModel, _ ) =
                            DataExtractorUpdate.update (DataExtractor.DownloadMsg (DataExtractor.ProcessingProgress 0.5)) processingModel

                        -- Simulate completion
                        processedData =
                            { matchedRecords = []
                            , unmatchedMaster = []
                            , unmatchedData = []
                            , statistics = 
                                { totalMasterRows = 1
                                , totalDataRows = 1
                                , matchedCount = 0
                                , unmatchedMasterCount = 1
                                , unmatchedDataCount = 1
                                , processingTime = 100.0
                                }
                            , selectedFields = Set.empty
                            }

                        ( completedModel, _ ) =
                            DataExtractorUpdate.update (DataExtractor.DownloadMsg (DataExtractor.ProcessingComplete processedData)) progressModel
                    in
                    Expect.all
                        [ \_ -> case processingModel.processingStatus of
                            DataExtractor.Processing _ -> Expect.pass
                            _ -> Expect.fail "Expected Processing status after StartProcessing"
                        , \_ -> case progressModel.processingStatus of
                            DataExtractor.Processing progress -> Expect.within (Expect.Absolute 0.01) 0.5 progress
                            _ -> Expect.fail "Expected Processing status with correct progress"
                        , \_ -> Expect.equal DataExtractor.Completed completedModel.processingStatus
                        ]
                        ()
            , test "memory cleanup resets model state" <|
                \_ ->
                    let
                        -- Create a model with data
                        modelWithData =
                            createModelReadyForDownload

                        -- Clear all data
                        ( clearedModel, _ ) =
                            DataExtractorUpdate.update (DataExtractor.DownloadMsg DataExtractor.ClearData) modelWithData
                    in
                    Expect.all
                        [ \m -> Expect.equal Nothing m.masterFile
                        , \m -> Expect.equal Nothing m.dataFile
                        , \m -> Expect.equal Nothing m.previewData
                        , \m -> Expect.equal DataExtractor.NotStarted m.processingStatus
                        ]
                        clearedModel
            , test "start over resets wizard to upload step" <|
                \_ ->
                    let
                        -- Create a model at download step
                        downloadModel =
                            createModelReadyForDownload

                        -- Start over
                        ( resetModel, _ ) =
                            DataExtractorUpdate.update (DataExtractor.DownloadMsg DataExtractor.StartOverFromDownload) downloadModel
                    in
                    Expect.all
                        [ \m -> Expect.equal DataExtractor.Upload m.currentStep
                        , \m -> Expect.equal Nothing m.masterFile
                        , \m -> Expect.equal Nothing m.dataFile
                        , \m -> Expect.equal Nothing m.previewData
                        , \m -> Expect.equal DataExtractor.NotStarted m.processingStatus
                        ]
                        resetModel
            , test "download workflow handles empty result set" <|
                \_ ->
                    let
                        readyModel =
                            createModelReadyForDownload

                        -- Simulate processing with no matches
                        emptyProcessedData =
                            { matchedRecords = []
                            , unmatchedMaster = [ [ "John Doe", "john@example.com" ] ]
                            , unmatchedData = [ [ "Jane Smith", "jane@example.com" ] ]
                            , statistics = 
                                { totalMasterRows = 1
                                , totalDataRows = 1
                                , matchedCount = 0
                                , unmatchedMasterCount = 1
                                , unmatchedDataCount = 1
                                , processingTime = 50.0
                                }
                            , selectedFields = Set.empty
                            }

                        ( completedModel, _ ) =
                            DataExtractorUpdate.update (DataExtractor.DownloadMsg DataExtractor.StartProcessing) readyModel
                                |> (\(model, cmd) -> DataExtractorUpdate.update (DataExtractor.DownloadMsg (DataExtractor.ProcessingComplete emptyProcessedData)) model)
                    in
                    Expect.all
                        [ \m -> Expect.equal DataExtractor.Completed m.processingStatus
                        , \m -> case m.processedData of
                            Just data -> Expect.equal 0 data.statistics.matchedCount
                            Nothing -> Expect.fail "Expected processed data to be present"
                        ]
                        completedModel
            ]
        ]



-- Helper function to create a model ready for download processing
createModelReadyForDownload : DataExtractor.Model
createModelReadyForDownload =
    let
        baseModel =
            DataExtractor.init

        masterFile =
            { fileName = "master.xlsx"
            , headers = [ "Name", "Email" ]
            , rows = [ [ "John Doe", "john@example.com" ] ]
            , rowCount = 1
            , fileSize = 1000
            , columnCount = 2
            }

        dataFile =
            { fileName = "data.csv"
            , headers = [ "FullName", "EmailAddr" ]
            , rows = [ [ "John Doe", "john@example.com" ] ]
            , rowCount = 1
            , fileSize = 800
            , columnCount = 2
            }

        matchConfig =
            { masterColumns = [ 0, 1 ]
            , dataColumns = [ 0, 1 ]
            , useFuzzyMatch = False
            }

        -- Create sample preview data to satisfy validation
        samplePreviewData =
            { matchedRecords = 
                [ { masterRow = [ "John Doe", "john@example.com" ]
                  , dataRow = [ "John Doe", "john@example.com" ]
                  , matchScore = 1.0
                  , matchedOn = [ "Name", "Email" ]
                  }
                ]
            , unmatchedMaster = []
            , unmatchedData = []
            , statistics = 
                { totalMasterRows = 1
                , totalDataRows = 1
                , matchedCount = 1
                , unmatchedMasterCount = 0
                , unmatchedDataCount = 0
                , processingTime = 100.0
                }
            , selectedFields = Set.fromList [ "Name", "Email" ]
            }
    in
    { baseModel
        | masterFile = Just masterFile
        , dataFile = Just dataFile
        , matchConfig = Just matchConfig
        , currentStep = DataExtractor.Download
        , selectedFields = Set.fromList [ "Name", "Email" ]
        , selectedMasterColumns = [ "Name", "Email" ]  -- Required for Preview step validation
        , selectedDataColumns = [ "FullName", "EmailAddr" ]  -- Required for Preview step validation
        , previewData = Just samplePreviewData  -- Required for Download step validation
    }


-- Helper function to create a model with processingFileType set


modelWithProcessingFileType : String -> DataExtractor.Model
modelWithProcessingFileType fileType =
    let
        baseModel =
            DataExtractor.init
    in
    { baseModel | processingFileType = Just fileType }



-- Helper function to create a model with no processingFileType


modelWithNoProcessingFileType : DataExtractor.Model
modelWithNoProcessingFileType =
    let
        baseModel =
            DataExtractor.init
    in
    { baseModel | processingFileType = Nothing }



-- Helper function to encode FileData for testing


encodeFileData : DataExtractor.FileData -> Encode.Value
encodeFileData fileData =
    Encode.object
        [ ( "fileName", Encode.string fileData.fileName )
        , ( "fileSize", Encode.int fileData.fileSize )
        , ( "headers", Encode.list Encode.string fileData.headers )
        , ( "rows", Encode.list (Encode.list Encode.string) fileData.rows )
        , ( "rowCount", Encode.int fileData.rowCount )
        , ( "columnCount", Encode.int fileData.columnCount )
        ]
