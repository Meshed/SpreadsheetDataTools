module DataExtractorTests exposing (..)

import Expect exposing (Expectation)
import Json.Encode as Encode
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
        ]



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
