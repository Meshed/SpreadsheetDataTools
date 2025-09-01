module DataExtractor.SelectFieldsTests exposing (suite)

import Expect
import Fuzz exposing (int, list, string)
import Set
import Test exposing (..)
import Tools.DataExtractor.Model exposing (..)
import Tools.DataExtractor.Steps.SelectFields as SelectFields
import Tools.DataExtractor.Update as Update


suite : Test
suite =
    describe "Data Extractor SelectFields Tests"
        [ describe "Field Extraction"
            [ test "extracts fields from preview data when available" <|
                \_ ->
                    let
                        previewData =
                            sampleProcessedData

                        masterFile =
                            Just sampleMasterFile

                        dataFile =
                            Just sampleDataFile

                        availableFields =
                            SelectFields.extractAvailableFields (Just previewData) masterFile dataFile
                    in
                    Expect.greaterThan 0 (List.length availableFields)
            , test "extracts fields from FileData headers as fallback" <|
                \_ ->
                    let
                        masterFile =
                            Just sampleMasterFile

                        dataFile =
                            Just sampleDataFile

                        availableFields =
                            SelectFields.extractAvailableFields Nothing masterFile dataFile

                        expectedFields =
                            List.sort (sampleMasterFile.headers ++ sampleDataFile.headers |> removeDuplicates)
                    in
                    Expect.equal expectedFields (List.sort availableFields)
            , test "returns empty list when no data available" <|
                \_ ->
                    let
                        availableFields =
                            SelectFields.extractAvailableFields Nothing Nothing Nothing
                    in
                    Expect.equal [] availableFields
            , test "handles master file only" <|
                \_ ->
                    let
                        masterFile =
                            Just sampleMasterFile

                        availableFields =
                            SelectFields.extractAvailableFields Nothing masterFile Nothing
                    in
                    Expect.equal sampleMasterFile.headers availableFields
            , test "handles data file only" <|
                \_ ->
                    let
                        dataFile =
                            Just sampleDataFile

                        availableFields =
                            SelectFields.extractAvailableFields Nothing Nothing dataFile
                    in
                    Expect.equal sampleDataFile.headers availableFields
            ]
        , describe "Default Field Selection"
            [ test "selects all data file headers by default" <|
                \_ ->
                    let
                        dataFile =
                            Just sampleDataFile

                        defaultSelection =
                            SelectFields.initializeSelectedFields dataFile

                        expectedFields =
                            Set.fromList sampleDataFile.headers
                    in
                    Expect.equal expectedFields defaultSelection
            , test "returns empty set when no data file" <|
                \_ ->
                    let
                        defaultSelection =
                            SelectFields.initializeSelectedFields Nothing
                    in
                    Expect.equal Set.empty defaultSelection
            ]
        , describe "Field Sample Values"
            [ test "extracts sample values from preview data" <|
                \_ ->
                    let
                        previewData =
                            sampleProcessedData

                        samples =
                            SelectFields.getFieldSamples "TestField" previewData
                    in
                    Expect.atMost 3 (List.length samples)
            , test "filters out empty values" <|
                \_ ->
                    let
                        previewData =
                            { sampleProcessedData
                                | matchedRecords =
                                    [ { masterRow = [ "Value1", "" ]
                                      , dataRow = [ "Value2", "Value3" ]
                                      , matchScore = 1.0
                                      , matchedOn = [ "0" ]
                                      }
                                    ]
                            }

                        samples =
                            SelectFields.getFieldSamples "TestField" previewData

                        hasEmptyValues =
                            List.any String.isEmpty samples
                    in
                    Expect.equal False hasEmptyValues
            , test "removes duplicate sample values" <|
                \_ ->
                    let
                        previewData =
                            { sampleProcessedData
                                | matchedRecords =
                                    [ { masterRow = [ "SameValue" ]
                                      , dataRow = [ "SameValue" ]
                                      , matchScore = 1.0
                                      , matchedOn = [ "0" ]
                                      }
                                    ]
                            }

                        samples =
                            SelectFields.getFieldSamples "TestField" previewData

                        uniqueValues =
                            removeDuplicates samples
                    in
                    Expect.equal (List.length uniqueValues) (List.length samples)
            ]
        , describe "SelectFieldsMsg Update Logic"
            [ test "ToggleField adds field when not selected" <|
                \_ ->
                    let
                        model =
                            { initWithFields | selectedFields = Set.empty }

                        ( updatedModel, _ ) =
                            Update.update (SelectFieldsMsg (ToggleField "TestField")) model
                    in
                    Expect.equal True (Set.member "TestField" updatedModel.selectedFields)
            , test "ToggleField removes field when already selected" <|
                \_ ->
                    let
                        model =
                            { initWithFields | selectedFields = Set.fromList [ "TestField" ] }

                        ( updatedModel, _ ) =
                            Update.update (SelectFieldsMsg (ToggleField "TestField")) model
                    in
                    Expect.equal False (Set.member "TestField" updatedModel.selectedFields)
            , test "SelectAllFields selects all available fields" <|
                \_ ->
                    let
                        availableFields =
                            [ "Field1", "Field2", "Field3" ]

                        model =
                            { initWithFields | availableFields = availableFields, selectedFields = Set.empty }

                        ( updatedModel, _ ) =
                            Update.update (SelectFieldsMsg SelectAllFields) model
                    in
                    Expect.equal (Set.fromList availableFields) updatedModel.selectedFields
            , test "ClearAllFields removes all selected fields" <|
                \_ ->
                    let
                        model =
                            { initWithFields | selectedFields = Set.fromList [ "Field1", "Field2" ] }

                        ( updatedModel, _ ) =
                            Update.update (SelectFieldsMsg ClearAllFields) model
                    in
                    Expect.equal Set.empty updatedModel.selectedFields
            , test "ValidateFieldSelection does not change state" <|
                \_ ->
                    let
                        originalFields =
                            Set.fromList [ "Field1" ]

                        model =
                            { initWithFields | selectedFields = originalFields }

                        ( updatedModel, _ ) =
                            Update.update (SelectFieldsMsg ValidateFieldSelection) model
                    in
                    Expect.equal originalFields updatedModel.selectedFields
            ]
        , describe "Field Source Categorization"
            [ test "identifies master-only fields" <|
                \_ ->
                    let
                        masterFile =
                            { sampleMasterFile | headers = [ "MasterOnly" ] }

                        dataFile =
                            { sampleDataFile | headers = [ "DataOnly" ] }

                        source =
                            SelectFields.categorizeField masterFile dataFile "MasterOnly"
                    in
                    Expect.equal SelectFields.Master source
            , test "identifies data-only fields" <|
                \_ ->
                    let
                        masterFile =
                            { sampleMasterFile | headers = [ "MasterOnly" ] }

                        dataFile =
                            { sampleDataFile | headers = [ "DataOnly" ] }

                        source =
                            SelectFields.categorizeField masterFile dataFile "DataOnly"
                    in
                    Expect.equal SelectFields.Data source
            , test "identifies fields in both files" <|
                \_ ->
                    let
                        masterFile =
                            { sampleMasterFile | headers = [ "SharedField" ] }

                        dataFile =
                            { sampleDataFile | headers = [ "SharedField" ] }

                        source =
                            SelectFields.categorizeField masterFile dataFile "SharedField"
                    in
                    Expect.equal SelectFields.Both source
            , test "defaults to master for non-existent fields" <|
                \_ ->
                    let
                        masterFile =
                            { sampleMasterFile | headers = [ "Master" ] }

                        dataFile =
                            { sampleDataFile | headers = [ "Data" ] }

                        source =
                            SelectFields.categorizeField masterFile dataFile "NonExistent"
                    in
                    Expect.equal SelectFields.Master source
            ]
        , describe "Navigation Logic"
            [ test "can proceed to SelectFields when preview data exists" <|
                \_ ->
                    let
                        model =
                            { init
                                | masterFile = Just sampleMasterFile
                                , dataFile = Just sampleDataFile
                                , previewData = Just sampleProcessedData
                                , selectedMasterColumns = [ "Name", "ID" ] -- Required for Preview step validation
                                , selectedDataColumns = [ "Full Name", "Employee ID" ] -- Required for Preview step validation
                            }

                        canProceed =
                            canProceedToStep SelectFields model
                    in
                    Expect.equal True canProceed
            , test "cannot proceed to SelectFields without preview data" <|
                \_ ->
                    let
                        model =
                            { init
                                | masterFile = Just sampleMasterFile
                                , dataFile = Just sampleDataFile
                                , previewData = Nothing
                            }

                        canProceed =
                            canProceedToStep SelectFields model
                    in
                    Expect.equal False canProceed
            , test "can proceed to Download when fields are selected" <|
                \_ ->
                    let
                        model =
                            { init
                                | masterFile = Just sampleMasterFile
                                , dataFile = Just sampleDataFile
                                , previewData = Just sampleProcessedData
                                , selectedFields = Set.fromList [ "Field1" ]
                                , selectedMasterColumns = [ "Name", "ID" ] -- Required for Preview step validation
                                , selectedDataColumns = [ "Full Name", "Employee ID" ] -- Required for Preview step validation
                            }

                        canProceed =
                            canProceedToStep Download model
                    in
                    Expect.equal True canProceed
            , test "cannot proceed to Download without selected fields" <|
                \_ ->
                    let
                        model =
                            { init
                                | masterFile = Just sampleMasterFile
                                , dataFile = Just sampleDataFile
                                , previewData = Just sampleProcessedData
                                , selectedFields = Set.empty
                            }

                        canProceed =
                            canProceedToStep Download model
                    in
                    Expect.equal False canProceed
            ]
        , describe "NextStep Field Initialization"
            [ test "initializes available fields when entering SelectFields" <|
                \_ ->
                    let
                        model =
                            { init
                                | currentStep = Preview
                                , masterFile = Just sampleMasterFile
                                , dataFile = Just sampleDataFile
                                , previewData = Just sampleProcessedData
                                , availableFields = [] -- Initially empty
                                , selectedMasterColumns = [ "Name", "ID" ] -- Required for NextStep to work
                                , selectedDataColumns = [ "Full Name", "Employee ID" ] -- Required for NextStep to work
                            }

                        ( updatedModel, _ ) =
                            Update.update NextStep model
                    in
                    Expect.greaterThan 0 (List.length updatedModel.availableFields)
            , test "initializes default selected fields when entering SelectFields" <|
                \_ ->
                    let
                        model =
                            { init
                                | currentStep = Preview
                                , masterFile = Just sampleMasterFile
                                , dataFile = Just sampleDataFile
                                , previewData = Just sampleProcessedData
                                , selectedFields = Set.empty -- Initially empty
                                , selectedMasterColumns = [ "Name", "ID" ] -- Required for NextStep to work
                                , selectedDataColumns = [ "Full Name", "Employee ID" ] -- Required for NextStep to work
                            }

                        ( updatedModel, _ ) =
                            Update.update NextStep model

                        expectedDefaults =
                            Set.fromList sampleDataFile.headers
                    in
                    Expect.equal expectedDefaults updatedModel.selectedFields
            , test "preserves existing field selection when re-entering SelectFields" <|
                \_ ->
                    let
                        existingSelection =
                            Set.fromList [ "CustomField1", "CustomField2" ]

                        model =
                            { init
                                | currentStep = Preview
                                , masterFile = Just sampleMasterFile
                                , dataFile = Just sampleDataFile
                                , previewData = Just sampleProcessedData
                                , selectedFields = existingSelection
                                , selectedMasterColumns = [ "Name", "ID" ] -- Required for NextStep to work
                                , selectedDataColumns = [ "Full Name", "Employee ID" ] -- Required for NextStep to work
                            }

                        ( updatedModel, _ ) =
                            Update.update NextStep model
                    in
                    Expect.equal existingSelection updatedModel.selectedFields
            ]
        , describe "Memory Management and Performance"
            [ test "field extraction is efficient with large datasets" <|
                \_ ->
                    let
                        largePreviewData =
                            { sampleProcessedData
                                | matchedRecords = List.repeat 1000 sampleMatchedRecord
                            }

                        samples =
                            SelectFields.getFieldSamples "TestField" largePreviewData
                    in
                    -- Should still limit to 3 samples for performance
                    Expect.atMost 3 (List.length samples)
            , test "available fields list handles duplicates efficiently" <|
                \_ ->
                    let
                        masterFile =
                            Just { sampleMasterFile | headers = List.repeat 10 "DuplicateHeader" }

                        dataFile =
                            Just { sampleDataFile | headers = List.repeat 10 "DuplicateHeader" }

                        availableFields =
                            SelectFields.extractAvailableFields Nothing masterFile dataFile

                        uniqueFields =
                            removeDuplicates availableFields
                    in
                    Expect.equal (List.length uniqueFields) (List.length availableFields)
            ]
        ]



-- HELPER FUNCTIONS AND SAMPLE DATA


{-| Sample master file for testing
-}
sampleMasterFile : FileData
sampleMasterFile =
    { fileName = "master.xlsx"
    , fileSize = 1000
    , headers = [ "Name", "ID", "Email" ]
    , rows = [ [ "John Doe", "123", "john@example.com" ], [ "Jane Smith", "456", "jane@example.com" ] ]
    , rowCount = 2
    , columnCount = 3
    }


{-| Sample data file for testing
-}
sampleDataFile : FileData
sampleDataFile =
    { fileName = "data.xlsx"
    , fileSize = 1200
    , headers = [ "Full Name", "Employee ID", "Department" ]
    , rows = [ [ "John Doe", "123", "Engineering" ], [ "Jane Smith", "456", "Marketing" ] ]
    , rowCount = 2
    , columnCount = 3
    }


{-| Sample matched record for testing
-}
sampleMatchedRecord : MatchedRecord
sampleMatchedRecord =
    { masterRow = [ "John Doe", "123", "john@example.com" ]
    , dataRow = [ "John Doe", "123", "Engineering" ]
    , matchScore = 1.0
    , matchedOn = [ "0", "1" ]
    }


{-| Sample processed data for testing
-}
sampleProcessedData : ProcessedData
sampleProcessedData =
    { matchedRecords = [ sampleMatchedRecord ]
    , unmatchedMaster = []
    , unmatchedData = []
    , statistics =
        { totalMasterRows = 1
        , totalDataRows = 1
        , matchedCount = 1
        , unmatchedMasterCount = 0
        , unmatchedDataCount = 0
        , processingTime = 50.0
        }
    , selectedFields = Set.empty
    }


{-| Initialized model with field-related data for testing
-}
initWithFields : Model
initWithFields =
    { init
        | masterFile = Just sampleMasterFile
        , dataFile = Just sampleDataFile
        , previewData = Just sampleProcessedData
        , availableFields = sampleMasterFile.headers ++ sampleDataFile.headers
        , selectedFields = Set.empty
    }


{-| Remove duplicate strings from list while preserving order
-}
removeDuplicates : List String -> List String
removeDuplicates list =
    removeDuplicatesHelper list []


{-| Helper function for removing duplicates
-}
removeDuplicatesHelper : List String -> List String -> List String
removeDuplicatesHelper remaining acc =
    case remaining of
        [] ->
            List.reverse acc

        head :: tail ->
            if List.member head acc then
                removeDuplicatesHelper tail acc

            else
                removeDuplicatesHelper tail (head :: acc)
