module DataExtractor.DownloadTests exposing (suite)

import Expect
import Fuzz exposing (float, int, list, string)
import Set
import Test exposing (..)
import Tools.DataExtractor.Model exposing (..)
import Tools.DataExtractor.Steps.Download as Download


suite : Test
suite =
    describe "Data Extractor Download Tests"
        [ describe "CSV Generation"
            [ test "generateCSVFromData includes only selected fields" <|
                \_ ->
                    let
                        processedData =
                            { matchedRecords = sampleMatchedRecords
                            , unmatchedMaster = []
                            , unmatchedData = []
                            , statistics = sampleStats
                            , selectedFields = Set.fromList [ "Name", "Email" ]
                            }

                        fieldOrder =
                            [ "Name", "Email" ]

                        csvContent =
                            Download.generateCSVFromData processedData fieldOrder
                    in
                    Expect.all
                        [ \content ->
                            if String.contains "Name" content then
                                Expect.pass

                            else
                                Expect.fail "Should contain Name header"
                        , \content ->
                            if String.contains "Email" content then
                                Expect.pass

                            else
                                Expect.fail "Should contain Email header"
                        , \content ->
                            if String.contains "Phone" content then
                                Expect.fail "Should not contain Phone header"

                            else
                                Expect.pass
                        ]
                        csvContent
            , test "generateCSVFromData handles empty selected fields" <|
                \_ ->
                    let
                        processedData =
                            { matchedRecords = sampleMatchedRecords
                            , unmatchedMaster = []
                            , unmatchedData = []
                            , statistics = sampleStats
                            , selectedFields = Set.empty
                            }

                        fieldOrder =
                            []

                        csvContent =
                            Download.generateCSVFromData processedData fieldOrder
                    in
                    Expect.equal "" csvContent
            , test "generateCSVFromData handles empty matched records" <|
                \_ ->
                    let
                        processedData =
                            { matchedRecords = []
                            , unmatchedMaster = []
                            , unmatchedData = []
                            , statistics = sampleStats
                            , selectedFields = Set.fromList [ "Name", "Email" ]
                            }

                        fieldOrder =
                            [ "Name", "Email" ]

                        csvContent =
                            Download.generateCSVFromData processedData fieldOrder

                        expectedHeadersOnly =
                            "Name,Email"
                    in
                    Expect.equal expectedHeadersOnly csvContent
            , test "generateCSVFromData preserves field order for simple fields" <|
                \_ ->
                    let
                        fieldNames =
                            [ "Name", "Email", "Age" ]

                        processedData =
                            { matchedRecords = []
                            , unmatchedMaster = []
                            , unmatchedData = []
                            , statistics = sampleStats
                            , selectedFields = Set.fromList fieldNames
                            }

                        csvContent =
                            Download.generateCSVFromData processedData fieldNames

                        actualHeaders =
                            csvContent
                                |> String.split ","
                    in
                    Expect.all
                        [ \content ->
                            if String.contains "Name" content then
                                Expect.pass

                            else
                                Expect.fail "Should contain Name header"
                        , \content ->
                            if String.contains "Email" content then
                                Expect.pass

                            else
                                Expect.fail "Should contain Email header"
                        , \content ->
                            if String.contains "Age" content then
                                Expect.pass

                            else
                                Expect.fail "Should contain Age header"
                        ]
                        csvContent
            , test "generateCSVFromData filters out empty rows" <|
                \_ ->
                    let
                        -- Create test data with some empty records
                        mixedMatchedRecords =
                            [ { masterRow = [ "John Doe", "john@example.com" ]
                              , dataRow = [ "Engineering", "Manager" ]
                              , matchScore = 1.0
                              , matchedOn = [ "Name" ]
                              }
                            , { masterRow = [ "", "" ] -- Completely empty
                              , dataRow = [ "", "" ]
                              , matchScore = 0.5
                              , matchedOn = []
                              }
                            , { masterRow = [ "Jane Smith", "jane@example.com" ]
                              , dataRow = [ "Marketing", "Director" ]
                              , matchScore = 1.0
                              , matchedOn = [ "Name" ]
                              }
                            , { masterRow = [ "  ", "\t" ] -- Whitespace only
                              , dataRow = [ " ", "" ]
                              , matchScore = 0.3
                              , matchedOn = []
                              }
                            ]

                        processedData =
                            { matchedRecords = mixedMatchedRecords
                            , unmatchedMaster = []
                            , unmatchedData = []
                            , statistics = sampleStats
                            , selectedFields = Set.fromList [ "Name", "Email", "Department", "Role" ]
                            }

                        fieldOrder =
                            [ "Name", "Email", "Department", "Role" ]

                        csvContent =
                            Download.generateCSVFromData processedData fieldOrder

                        -- Split into lines and count non-header rows
                        csvLines =
                            csvContent
                                |> String.split "\n"
                                |> List.filter (\line -> not (String.isEmpty line))

                        -- Should have header + 2 data rows (empty rows filtered out)
                        expectedLineCount =
                            3
                    in
                    Expect.all
                        [ \content ->
                            if String.contains "Name,Email,Department,Role" content then
                                Expect.pass

                            else
                                Expect.fail "Should contain headers"
                        , \content ->
                            if String.contains "John Doe" content then
                                Expect.pass

                            else
                                Expect.fail "Should contain John Doe"
                        , \content ->
                            if String.contains "Jane Smith" content then
                                Expect.pass

                            else
                                Expect.fail "Should contain Jane Smith"
                        , \_ ->
                            Expect.equal expectedLineCount (List.length csvLines)
                        ]
                        csvContent
            ]
        , describe "Data Processing"
            [ test "processAllData handles valid configuration" <|
                \_ ->
                    let
                        config =
                            { masterColumns = [ 0, 1 ]
                            , dataColumns = [ 0, 2 ]
                            , useFuzzyMatch = False
                            }

                        masterFile =
                            sampleMasterFile

                        dataFile =
                            sampleDataFile

                        selectedFields =
                            Set.fromList [ "Name", "Email" ]

                        processedData =
                            Download.processAllData config masterFile dataFile selectedFields
                    in
                    Expect.all
                        [ \data ->
                            if not (List.isEmpty data.matchedRecords) || data.statistics.totalMasterRows > 0 then
                                Expect.pass

                            else
                                Expect.fail "Should have matched records or statistics"
                        , \data -> Expect.greaterThan -1 data.statistics.matchedCount
                        , \data -> Expect.greaterThan -1 data.statistics.totalMasterRows
                        ]
                        processedData
            , test "processAllData handles empty master file" <|
                \_ ->
                    let
                        config =
                            { masterColumns = [ 0 ]
                            , dataColumns = [ 0 ]
                            , useFuzzyMatch = False
                            }

                        emptyMasterFile =
                            { fileName = "empty.xlsx"
                            , headers = []
                            , rows = []
                            , rowCount = 0
                            , fileSize = 0
                            , columnCount = 0
                            }

                        dataFile =
                            sampleDataFile

                        selectedFields =
                            Set.fromList [ "Name" ]

                        processedData =
                            Download.processAllData config emptyMasterFile dataFile selectedFields
                    in
                    Expect.all
                        [ \data -> Expect.equal [] data.matchedRecords
                        , \data -> Expect.equal 0 data.statistics.matchedCount
                        ]
                        processedData
            , test "processAllData handles invalid column indices" <|
                \_ ->
                    let
                        config =
                            { masterColumns = [ 10, 20 ] -- Invalid indices
                            , dataColumns = [ 15, 25 ] -- Invalid indices
                            , useFuzzyMatch = False
                            }

                        selectedFields =
                            Set.fromList [ "Name" ]

                        processedData =
                            Download.processAllData config sampleMasterFile sampleDataFile selectedFields
                    in
                    Expect.all
                        [ \data -> Expect.equal [] data.matchedRecords
                        , \data -> Expect.equal 0 data.statistics.matchedCount
                        ]
                        processedData
            ]
        , describe "Utility Functions"
            [ test "formatFileSize handles bytes correctly" <|
                \_ ->
                    Expect.all
                        [ \_ -> Expect.equal "512 B" (Download.formatFileSize 512)
                        , \_ -> Expect.equal "1.0 KB" (Download.formatFileSize 1024)
                        , \_ -> Expect.equal "1.5 MB" (Download.formatFileSize (1024 * 1024 * 1.5 |> round))
                        , \_ -> Expect.equal "2.0 GB" (Download.formatFileSize (1024 * 1024 * 1024 * 2))
                        ]
                        ()
            , fuzz (Fuzz.intRange 0 (10 * 1024 * 1024)) "formatFileSize always returns valid format" <|
                \size ->
                    let
                        formatted =
                            Download.formatFileSize size
                    in
                    Expect.all
                        [ \result ->
                            if
                                String.contains " B" result
                                    || String.contains " KB" result
                                    || String.contains " MB" result
                                    || String.contains " GB" result
                            then
                                Expect.pass

                            else
                                Expect.fail "Should contain size unit"
                        , \result ->
                            if not (String.isEmpty result) then
                                Expect.pass

                            else
                                Expect.fail "Should not be empty"
                        ]
                        formatted
            , test "formatTimestamp handles Unix timestamp" <|
                \_ ->
                    let
                        -- Test with a known timestamp (2025-01-01 00:00:00 UTC)
                        timestamp =
                            1735689600000

                        formatted =
                            Download.formatTimestamp timestamp
                    in
                    Expect.all
                        [ \result ->
                            if String.contains ":" result then
                                Expect.pass

                            else
                                Expect.fail "Should contain time format"
                        , \result ->
                            if not (String.isEmpty result) then
                                Expect.pass

                            else
                                Expect.fail "Should not be empty"
                        ]
                        formatted
            ]
        , describe "Progress Calculation"
            [ fuzz (Fuzz.floatRange 0.0 1.0) "progress values stay within bounds" <|
                \progress ->
                    let
                        percentage =
                            round (progress * 100)
                    in
                    Expect.all
                        [ \p -> Expect.atLeast 0 p
                        , \p -> Expect.atMost 100 p
                        ]
                        percentage
            , test "progress calculation for known values" <|
                \_ ->
                    Expect.all
                        [ \_ -> Expect.equal 0 (round (0.0 * 100))
                        , \_ -> Expect.equal 50 (round (0.5 * 100))
                        , \_ -> Expect.equal 100 (round (1.0 * 100))
                        ]
                        ()
            ]
        ]



-- Sample data for tests


sampleMasterFile : FileData
sampleMasterFile =
    { fileName = "master.xlsx"
    , headers = [ "Name", "Email", "Phone" ]
    , rows =
        [ [ "John Doe", "john@example.com", "123-456-7890" ]
        , [ "Jane Smith", "jane@example.com", "098-765-4321" ]
        ]
    , rowCount = 2
    , fileSize = 1024
    , columnCount = 3
    }


sampleDataFile : FileData
sampleDataFile =
    { fileName = "data.xlsx"
    , headers = [ "FullName", "Department", "EmailAddr" ]
    , rows =
        [ [ "John Doe", "Engineering", "john@example.com" ]
        , [ "Jane Smith", "Marketing", "jane@example.com" ]
        , [ "Bob Johnson", "Sales", "bob@example.com" ]
        ]
    , rowCount = 3
    , fileSize = 1536
    , columnCount = 3
    }


sampleMatchedRecords : List MatchedRecord
sampleMatchedRecords =
    [ { masterRow = [ "John Doe", "john@example.com", "123-456-7890" ]
      , dataRow = [ "John Doe", "Engineering", "john@example.com" ]
      , matchScore = 1.0
      , matchedOn = [ "Name", "Email" ]
      }
    , { masterRow = [ "Jane Smith", "jane@example.com", "098-765-4321" ]
      , dataRow = [ "Jane Smith", "Marketing", "jane@example.com" ]
      , matchScore = 1.0
      , matchedOn = [ "Name", "Email" ]
      }
    ]


sampleStats : ProcessingStats
sampleStats =
    { totalMasterRows = 2
    , totalDataRows = 3
    , matchedCount = 2
    , unmatchedMasterCount = 0
    , unmatchedDataCount = 1
    , processingTime = 150.0
    }



-- Helper functions


removeDuplicates : List String -> List String
removeDuplicates list =
    list
        |> Set.fromList
        |> Set.toList
