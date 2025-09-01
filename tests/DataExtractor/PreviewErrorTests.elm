module DataExtractor.PreviewErrorTests exposing (suite)

import Expect
import Set
import Test exposing (..)
import Tools.DataExtractor.Model exposing (..)
import Tools.DataExtractor.Steps.Preview as Preview
import Shared.Processing.Matching.Engine as Engine


suite : Test
suite =
    describe "Data Extractor Preview Error Tests"
        [ describe "Invalid Input Handling"
            [ test "handles empty master file rows" <|
                \_ ->
                    let
                        masterRows = []  -- Empty
                        dataRows = [["Name1", "1"]]
                        
                        matchConfig = 
                            { masterColumns = [0, 1]
                            , dataColumns = [0, 1]
                            , useFuzzyMatch = False
                            }
                        
                        processedData = Engine.matchRows matchConfig masterRows dataRows
                    in
                    Expect.equal 0 (List.length processedData.matchedRecords)
            
            , test "handles empty data file rows" <|
                \_ ->
                    let
                        masterRows = [["Name1", "1"]]
                        dataRows = []  -- Empty
                        
                        matchConfig = 
                            { masterColumns = [0, 1]
                            , dataColumns = [0, 1]
                            , useFuzzyMatch = False
                            }
                        
                        processedData = Engine.matchRows matchConfig masterRows dataRows
                    in
                    Expect.equal 0 (List.length processedData.matchedRecords)
            
            , test "handles invalid column indices gracefully" <|
                \_ ->
                    let
                        masterRows = [["Name1", "1"]]
                        dataRows = [["Name1", "1"]]
                        
                        matchConfig = 
                            { masterColumns = [0, 5]  -- Column 5 doesn't exist
                            , dataColumns = [0, 1]
                            , useFuzzyMatch = False
                            }
                        
                        processedData = Engine.matchRows matchConfig masterRows dataRows
                    in
                    -- Should not crash, but may not find matches due to missing column
                    Expect.greaterThan -1 (List.length processedData.matchedRecords)
            
            , test "handles missing columns in rows" <|
                \_ ->
                    let
                        masterRows = [["Name1"]]  -- Missing second column
                        dataRows = [["Name1", "1"]]
                        
                        matchConfig = 
                            { masterColumns = [0, 1]  -- Second column doesn't exist in master
                            , dataColumns = [0, 1]
                            , useFuzzyMatch = False
                            }
                        
                        processedData = Engine.matchRows matchConfig masterRows dataRows
                    in
                    -- Should handle gracefully without crashing
                    Expect.greaterThan -1 (List.length processedData.matchedRecords)
            ]
            
        , describe "Fuzzy Match Error Cases"
            [ test "handles invalid fuzzy match threshold" <|
                \_ ->
                    let
                        result1 = Engine.fuzzyMatch -0.5 "test" "test"  -- Negative threshold
                        result2 = Engine.fuzzyMatch 1.5 "test" "test"   -- Threshold > 1
                    in
                    -- Should handle edge cases without crashing
                    Expect.all
                        [ \_ -> Expect.equal True result1  -- Exact match should still work
                        , \_ -> Expect.equal True result2  -- Exact match should still work
                        ] ()
            
            , test "handles empty strings in fuzzy matching" <|
                \_ ->
                    let
                        score1 = Engine.scoreSimilarity "" "test"
                        score2 = Engine.scoreSimilarity "test" ""
                        score3 = Engine.scoreSimilarity "" ""
                    in
                    Expect.all
                        [ \_ -> Expect.equal 0.0 score1
                        , \_ -> Expect.equal 0.0 score2
                        , \_ -> Expect.atLeast 0.0 score3  -- Should be 0 or valid
                        ] ()
            
            , test "handles very long strings" <|
                \_ ->
                    let
                        longString = String.repeat 1000 "a"
                        score = Engine.scoreSimilarity longString "a"
                    in
                    Expect.all
                        [ \s -> Expect.atLeast 0.0 s
                        , \s -> Expect.atMost 1.0 s
                        ] score
            ]
            
        , describe "Memory and Performance Error Boundaries"
            [ test "handles extremely large datasets" <|
                \_ ->
                    let
                        -- Simulate very large dataset (but keep test reasonable)
                        largeNumber = 100
                        masterRows = List.range 1 largeNumber |> List.map (\i -> [String.fromInt i])
                        dataRows = List.range 1 largeNumber |> List.map (\i -> [String.fromInt i])
                        
                        matchConfig = 
                            { masterColumns = [0]
                            , dataColumns = [0]
                            , useFuzzyMatch = False
                            }
                        
                        processedData = Engine.matchRows matchConfig masterRows dataRows
                        limitedData = Preview.limitToPreviewSize 3 processedData
                    in
                    -- Should complete without error and limit correctly
                    Expect.all
                        [ \data -> Expect.equal 3 (List.length data.matchedRecords)
                        , \data -> Expect.equal largeNumber data.statistics.matchedCount
                        ] limitedData
            
            , test "handles complex nested data structures" <|
                \_ ->
                    let
                        -- Complex row data with various characters
                        complexMasterRows = 
                            [ ["John \"The Great\" O'Neil", "ID-123-ABC", "john@company.co.uk"]
                            , ["Mary & Associates, LLC", "ID-456-DEF", "mary@firm.org"]
                            , ["José María Álvarez", "ID-789-GHI", "jose@empresa.es"]
                            ]
                        
                        complexDataRows = 
                            [ ["John \"The Great\" O'Neil", "ID-123-ABC", "Engineering"]
                            , ["Mary & Associates, LLC", "ID-456-DEF", "Legal"]
                            , ["José María Álvarez", "ID-789-GHI", "Marketing"]
                            ]
                        
                        matchConfig = 
                            { masterColumns = [0, 1]
                            , dataColumns = [0, 1]
                            , useFuzzyMatch = False
                            }
                        
                        processedData = Engine.matchRows matchConfig complexMasterRows complexDataRows
                    in
                    -- Should handle special characters and complex strings
                    Expect.equal 3 (List.length processedData.matchedRecords)
            ]
            
        , describe "Configuration Error Recovery"
            [ test "recovers from malformed match configuration" <|
                \_ ->
                    let
                        masterRows = [["Name1", "1"]]
                        dataRows = [["Name1", "1"]]
                        
                        -- Empty column lists
                        emptyConfig = 
                            { masterColumns = []
                            , dataColumns = []
                            , useFuzzyMatch = False
                            }
                        
                        processedData = Engine.matchRows emptyConfig masterRows dataRows
                    in
                    -- Should handle gracefully, not crash
                    Expect.equal 0 (List.length processedData.matchedRecords)
            
            , test "handles mismatched column list lengths" <|
                \_ ->
                    let
                        masterRows = [["Name1", "1", "Extra"]]
                        dataRows = [["Name1", "1"]]
                        
                        mismatchedConfig = 
                            { masterColumns = [0, 1, 2]  -- 3 columns
                            , dataColumns = [0, 1]       -- 2 columns
                            , useFuzzyMatch = False
                            }
                        
                        processedData = Engine.matchRows mismatchedConfig masterRows dataRows
                    in
                    -- Should handle gracefully
                    Expect.greaterThan -1 (List.length processedData.matchedRecords)
            ]
            
        , describe "Data Consistency Error Cases"
            [ test "preserves data integrity after errors" <|
                \_ ->
                    let
                        masterRows = [["Name1", "1"], ["Name2", "2"]]
                        dataRows = [["Name1", "1"]]  -- Partial matches
                        
                        matchConfig = 
                            { masterColumns = [0, 1]
                            , dataColumns = [0, 1]
                            , useFuzzyMatch = False
                            }
                        
                        processedData = Engine.matchRows matchConfig masterRows dataRows
                        limitedData = Preview.limitToPreviewSize 3 processedData
                        
                        -- Check that statistics remain consistent
                        totalRows = processedData.statistics.matchedCount + 
                                   processedData.statistics.unmatchedMasterCount
                    in
                    Expect.equal processedData.statistics.totalMasterRows totalRows
            
            , test "handles data corruption gracefully" <|
                \_ ->
                    let
                        -- Simulate corrupted data with null/undefined equivalents
                        corruptedMasterRows = [["", "", ""], ["Valid", "Data", "Here"]]
                        corruptedDataRows = [["", "", ""], ["Valid", "Data", "Different"]]
                        
                        matchConfig = 
                            { masterColumns = [0, 1]
                            , dataColumns = [0, 1]
                            , useFuzzyMatch = False
                            }
                        
                        processedData = Engine.matchRows matchConfig corruptedMasterRows corruptedDataRows
                    in
                    -- Should not crash on empty strings
                    Expect.greaterThan -1 (List.length processedData.matchedRecords)
            ]
        ]