module DataExtractor.PreviewPerformanceTests exposing (suite)

import Expect
import Test exposing (..)
import Tools.DataExtractor.Model exposing (..)
import Tools.DataExtractor.Steps.Preview as Preview
import Shared.Processing.Matching.Engine as Engine


suite : Test
suite =
    describe "Data Extractor Preview Performance Tests"
        [ describe "Preview Sample Limiting"
            [ test "limits preview to exactly 3 samples" <|
                \_ ->
                    let
                        -- Generate 10 matching records
                        masterRows = List.range 1 10 |> List.map (\i -> ["Name" ++ String.fromInt i, String.fromInt i])
                        dataRows = List.range 1 10 |> List.map (\i -> ["Name" ++ String.fromInt i, String.fromInt i])
                        
                        matchConfig = 
                            { masterColumns = [0, 1]
                            , dataColumns = [0, 1]
                            , useFuzzyMatch = False
                            }
                        
                        fullProcessedData = Engine.matchRows matchConfig masterRows dataRows
                        limitedData = Preview.limitToPreviewSize 3 fullProcessedData
                    in
                    Expect.all
                        [ \data -> Expect.equal 3 (List.length data.matchedRecords)
                        , \data -> Expect.equal fullProcessedData.statistics data.statistics  -- Stats unchanged
                        , \data -> Expect.equal fullProcessedData.selectedFields data.selectedFields  -- Fields unchanged
                        ] limitedData
            
            , test "handles fewer than 3 matches correctly" <|
                \_ ->
                    let
                        masterRows = [["Name1", "1"], ["Name2", "2"]]
                        dataRows = [["Name1", "1"]]  -- Only one match possible
                        
                        matchConfig = 
                            { masterColumns = [0, 1]
                            , dataColumns = [0, 1]
                            , useFuzzyMatch = False
                            }
                        
                        processedData = Engine.matchRows matchConfig masterRows dataRows
                        limitedData = Preview.limitToPreviewSize 3 processedData
                    in
                    Expect.equal 1 (List.length limitedData.matchedRecords)
            
            , test "handles empty results correctly" <|
                \_ ->
                    let
                        masterRows = [["Name1", "1"]]
                        dataRows = [["Name2", "2"]]  -- No matches
                        
                        matchConfig = 
                            { masterColumns = [0, 1]
                            , dataColumns = [0, 1]
                            , useFuzzyMatch = False
                            }
                        
                        processedData = Engine.matchRows matchConfig masterRows dataRows
                        limitedData = Preview.limitToPreviewSize 3 processedData
                    in
                    Expect.equal 0 (List.length limitedData.matchedRecords)
            ]
            
        , describe "Large Dataset Handling"
            [ test "processes large dataset efficiently" <|
                \_ ->
                    let
                        -- Simulate 1000 records
                        masterRows = List.range 1 1000 |> List.map (\i -> ["Name" ++ String.fromInt i, String.fromInt i])
                        dataRows = List.range 1 1000 |> List.map (\i -> ["Name" ++ String.fromInt i, String.fromInt i])
                        
                        matchConfig = 
                            { masterColumns = [0, 1]
                            , dataColumns = [0, 1]
                            , useFuzzyMatch = False
                            }
                        
                        processedData = Engine.matchRows matchConfig masterRows dataRows
                        limitedData = Preview.limitToPreviewSize 3 processedData
                    in
                    Expect.all
                        [ \data -> Expect.equal 3 (List.length data.matchedRecords)
                        , \data -> Expect.equal 1000 data.statistics.totalMasterRows
                        , \data -> Expect.equal 1000 data.statistics.totalDataRows
                        , \data -> Expect.equal 1000 data.statistics.matchedCount
                        ] limitedData
            
            , test "handles varying row lengths" <|
                \_ ->
                    let
                        -- Rows with different column counts
                        masterRows = 
                            [ ["Name1", "1", "Extra1"]
                            , ["Name2", "2"]  -- Missing column
                            , ["Name3", "3", "Extra3", "More"]  -- Extra columns
                            ]
                        
                        dataRows = 
                            [ ["Name1", "1"]
                            , ["Name2", "2", "Dept"]
                            , ["Name3", "3"]
                            ]
                        
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
            
        , describe "Memory Efficiency"
            [ test "preserves original data structure integrity" <|
                \_ ->
                    let
                        masterRows = [["Name1", "1"], ["Name2", "2"], ["Name3", "3"]]
                        dataRows = [["Name1", "1"], ["Name2", "2"], ["Name3", "3"]]
                        
                        matchConfig = 
                            { masterColumns = [0, 1]
                            , dataColumns = [0, 1]
                            , useFuzzyMatch = False
                            }
                        
                        originalData = Engine.matchRows matchConfig masterRows dataRows
                        limitedData = Preview.limitToPreviewSize 3 originalData
                        
                        -- First record should be preserved exactly
                        firstOriginal = List.head originalData.matchedRecords
                        firstLimited = List.head limitedData.matchedRecords
                    in
                    case (firstOriginal, firstLimited) of
                        (Just orig, Just limited) ->
                            Expect.all
                                [ \_ -> Expect.equal orig.masterRow limited.masterRow
                                , \_ -> Expect.equal orig.dataRow limited.dataRow
                                , \_ -> Expect.equal orig.matchScore limited.matchScore
                                , \_ -> Expect.equal orig.matchedOn limited.matchedOn
                                ] ()
                        
                        _ ->
                            Expect.fail "Expected both original and limited data to have records"
            
            , test "does not modify statistics when limiting" <|
                \_ ->
                    let
                        masterRows = List.range 1 100 |> List.map (\i -> ["Name" ++ String.fromInt i, String.fromInt i])
                        dataRows = List.range 1 50 |> List.map (\i -> ["Name" ++ String.fromInt i, String.fromInt i])  -- Only 50 matches
                        
                        matchConfig = 
                            { masterColumns = [0, 1]
                            , dataColumns = [0, 1]
                            , useFuzzyMatch = False
                            }
                        
                        originalData = Engine.matchRows matchConfig masterRows dataRows
                        limitedData = Preview.limitToPreviewSize 3 originalData
                    in
                    Expect.all
                        [ \_ -> Expect.equal originalData.statistics.totalMasterRows limitedData.statistics.totalMasterRows
                        , \_ -> Expect.equal originalData.statistics.totalDataRows limitedData.statistics.totalDataRows
                        , \_ -> Expect.equal originalData.statistics.matchedCount limitedData.statistics.matchedCount
                        , \_ -> Expect.equal originalData.statistics.unmatchedMasterCount limitedData.statistics.unmatchedMasterCount
                        , \_ -> Expect.equal originalData.statistics.unmatchedDataCount limitedData.statistics.unmatchedDataCount
                        ] ()
            ]
            
        , describe "Edge Cases"
            [ test "handles zero limit correctly" <|
                \_ ->
                    let
                        masterRows = [["Name1", "1"], ["Name2", "2"]]
                        dataRows = [["Name1", "1"], ["Name2", "2"]]
                        
                        matchConfig = 
                            { masterColumns = [0, 1]
                            , dataColumns = [0, 1]
                            , useFuzzyMatch = False
                            }
                        
                        processedData = Engine.matchRows matchConfig masterRows dataRows
                        limitedData = Preview.limitToPreviewSize 0 processedData
                    in
                    Expect.equal 0 (List.length limitedData.matchedRecords)
            
            , test "handles negative limit correctly" <|
                \_ ->
                    let
                        masterRows = [["Name1", "1"]]
                        dataRows = [["Name1", "1"]]
                        
                        matchConfig = 
                            { masterColumns = [0, 1]
                            , dataColumns = [0, 1]
                            , useFuzzyMatch = False
                            }
                        
                        processedData = Engine.matchRows matchConfig masterRows dataRows
                        limitedData = Preview.limitToPreviewSize -1 processedData
                    in
                    Expect.equal 0 (List.length limitedData.matchedRecords)
            
            , test "handles very large limit correctly" <|
                \_ ->
                    let
                        masterRows = [["Name1", "1"], ["Name2", "2"]]
                        dataRows = [["Name1", "1"], ["Name2", "2"]]
                        
                        matchConfig = 
                            { masterColumns = [0, 1]
                            , dataColumns = [0, 1]
                            , useFuzzyMatch = False
                            }
                        
                        processedData = Engine.matchRows matchConfig masterRows dataRows
                        limitedData = Preview.limitToPreviewSize 1000 processedData
                    in
                    -- Should return all available matches (2), not fail or crash
                    Expect.equal 2 (List.length limitedData.matchedRecords)
            ]
        ]