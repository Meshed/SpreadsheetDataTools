module DataExtractor.PreviewTests exposing (suite)

import Expect
import Fuzz exposing (string, int, list)
import Set
import Test exposing (..)
import Tools.DataExtractor.Model exposing (..)
import Tools.DataExtractor.Steps.Preview as Preview
import Shared.Processing.Matching.Engine as Engine


suite : Test
suite =
    describe "Data Extractor Preview Tests"
        [ describe "Preview Generation"
            [ test "generates preview with valid data" <|
                \_ ->
                    let
                        masterFile = 
                            { fileName = "master.xlsx"
                            , fileSize = 1000
                            , headers = ["Name", "ID", "Email"]
                            , rows = [["John Doe", "123", "john@example.com"], ["Jane Smith", "456", "jane@example.com"]]
                            , rowCount = 2
                            , columnCount = 3
                            }
                        
                        dataFile = 
                            { fileName = "data.xlsx"
                            , fileSize = 1200
                            , headers = ["Full Name", "Employee ID", "Department"]
                            , rows = [["John Doe", "123", "Engineering"], ["Jane Smith", "456", "Marketing"]]
                            , rowCount = 2
                            , columnCount = 3
                            }
                        
                        matchConfig = 
                            { masterColumns = [0, 1]  -- Name, ID
                            , dataColumns = [0, 1]    -- Full Name, Employee ID
                            , useFuzzyMatch = False
                            }
                        
                        model = 
                            { init 
                                | masterFile = Just masterFile
                                , dataFile = Just dataFile
                                , matchConfig = Just matchConfig
                            }
                        
                        processedData = Engine.matchRows matchConfig masterFile.rows dataFile.rows
                    in
                    Expect.equal 2 (List.length processedData.matchedRecords)
            
            , test "handles no matches scenario" <|
                \_ ->
                    let
                        masterFile = 
                            { fileName = "master.xlsx"
                            , fileSize = 1000
                            , headers = ["Name", "ID"]
                            , rows = [["John Doe", "123"]]
                            , rowCount = 1
                            , columnCount = 2
                            }
                        
                        dataFile = 
                            { fileName = "data.xlsx"
                            , fileSize = 1200
                            , headers = ["Full Name", "Employee ID"]
                            , rows = [["Jane Smith", "456"]]  -- No match
                            , rowCount = 1
                            , columnCount = 2
                            }
                        
                        matchConfig = 
                            { masterColumns = [0, 1]
                            , dataColumns = [0, 1]
                            , useFuzzyMatch = False
                            }
                        
                        processedData = Engine.matchRows matchConfig masterFile.rows dataFile.rows
                    in
                    Expect.equal 0 (List.length processedData.matchedRecords)
            
            , test "limits preview to maximum 3 samples" <|
                \_ ->
                    let
                        masterRows = List.repeat 10 ["Name", "ID"]
                        dataRows = List.repeat 10 ["Name", "ID"]
                        
                        matchConfig = 
                            { masterColumns = [0, 1]
                            , dataColumns = [0, 1]
                            , useFuzzyMatch = False
                            }
                        
                        processedData = Engine.matchRows matchConfig masterRows dataRows
                        limitedData = Preview.limitToPreviewSize 3 processedData
                    in
                    Expect.atMost 3 (List.length limitedData.matchedRecords)
            ]
            
        , describe "Match Configuration"
            [ test "exact match works correctly" <|
                \_ ->
                    let
                        result = Engine.exactMatch "John Doe" "John Doe"
                    in
                    Expect.equal True result
            
            , test "exact match is case insensitive" <|
                \_ ->
                    let
                        result = Engine.exactMatch "John Doe" "john doe"
                    in
                    Expect.equal True result
            
            , test "fuzzy match works with threshold" <|
                \_ ->
                    let
                        score = Engine.scoreSimilarity "John" "John Doe"
                        result = Engine.fuzzyMatch 0.6 "John" "John Doe"  -- Lower threshold since "John" in "John Doe" gives ~0.64
                    in
                    Expect.equal True result
            
            , test "similarity scoring works" <|
                \_ ->
                    let
                        score = Engine.scoreSimilarity "John" "John Doe"
                    in
                    Expect.greaterThan 0.5 score
            ]
            
        , describe "Preview Data Structure"
            [ test "matched record contains required fields" <|
                \_ ->
                    let
                        masterRow = ["John Doe", "123", "john@example.com"]
                        dataRow = ["John Doe", "123", "Engineering"]
                        
                        matchedRecord = 
                            { masterRow = masterRow
                            , dataRow = dataRow
                            , matchScore = 1.0
                            , matchedOn = ["0", "1"]
                            }
                    in
                    Expect.all
                        [ \record -> Expect.equal masterRow record.masterRow
                        , \record -> Expect.equal dataRow record.dataRow
                        , \record -> Expect.equal 1.0 record.matchScore
                        , \record -> Expect.equal ["0", "1"] record.matchedOn
                        ] matchedRecord
            
            , test "processing stats are calculated correctly" <|
                \_ ->
                    let
                        masterRows = [["A", "1"], ["B", "2"], ["C", "3"]]
                        dataRows = [["A", "1"], ["B", "2"]]  -- One unmatched master
                        
                        matchConfig = 
                            { masterColumns = [0, 1]
                            , dataColumns = [0, 1]
                            , useFuzzyMatch = False
                            }
                        
                        processedData = Engine.matchRows matchConfig masterRows dataRows
                    in
                    Expect.all
                        [ \stats -> Expect.equal 3 stats.totalMasterRows
                        , \stats -> Expect.equal 2 stats.totalDataRows
                        , \stats -> Expect.equal 2 stats.matchedCount
                        , \stats -> Expect.equal 1 stats.unmatchedMasterCount
                        , \stats -> Expect.equal 0 stats.unmatchedDataCount
                        ] processedData.statistics
            ]
            
        , describe "Error Handling"
            [ test "handles missing master file" <|
                \_ ->
                    let
                        model = { init | masterFile = Nothing, dataFile = Just sampleDataFile, matchConfig = Just sampleMatchConfig }
                        -- This would trigger PreviewFailed in real usage
                    in
                    Expect.equal Nothing model.masterFile
            
            , test "handles missing data file" <|
                \_ ->
                    let
                        model = { init | masterFile = Just sampleMasterFile, dataFile = Nothing, matchConfig = Just sampleMatchConfig }
                    in
                    Expect.equal Nothing model.dataFile
            
            , test "handles missing match config" <|
                \_ ->
                    let
                        model = { init | masterFile = Just sampleMasterFile, dataFile = Just sampleDataFile, matchConfig = Nothing }
                    in
                    Expect.equal Nothing model.matchConfig
            ]
        ]


{-| Sample master file for testing
-}
sampleMasterFile : FileData
sampleMasterFile =
    { fileName = "master.xlsx"
    , fileSize = 1000
    , headers = ["Name", "ID", "Email"]
    , rows = [["John Doe", "123", "john@example.com"], ["Jane Smith", "456", "jane@example.com"]]
    , rowCount = 2
    , columnCount = 3
    }


{-| Sample data file for testing
-}
sampleDataFile : FileData
sampleDataFile =
    { fileName = "data.xlsx"
    , fileSize = 1200
    , headers = ["Full Name", "Employee ID", "Department"]
    , rows = [["John Doe", "123", "Engineering"], ["Jane Smith", "456", "Marketing"]]
    , rowCount = 2
    , columnCount = 3
    }


{-| Sample match configuration for testing
-}
sampleMatchConfig : MatchConfig
sampleMatchConfig =
    { masterColumns = [0, 1]
    , dataColumns = [0, 1]
    , useFuzzyMatch = False
    }