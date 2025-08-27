module DataExtractorTests exposing (..)

import Expect exposing (Expectation)
import Test exposing (..)
import Tools.DataExtractor.Model as DataExtractor


suite : Test
suite =
    describe "Data Extractor Tests"
        [ describe "Model initialization"
            [ test "initializes with Upload step" <|
                \_ ->
                    let
                        model = DataExtractor.init
                    in
                    Expect.equal DataExtractor.Upload model.currentStep
            
            , test "initializes with no files" <|
                \_ ->
                    let
                        model = DataExtractor.init
                    in
                    Expect.all
                        [ \m -> Expect.equal Nothing m.masterFile
                        , \m -> Expect.equal Nothing m.dataFile
                        ] model
            
            , test "initializes with privacy notice shown" <|
                \_ ->
                    let
                        model = DataExtractor.init
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
                        ] ()

            , test "stepToString returns correct step names" <|
                \_ ->
                    Expect.all
                        [ \_ -> Expect.equal "Upload Files" (DataExtractor.stepToString DataExtractor.Upload)
                        , \_ -> Expect.equal "Configure Matching" (DataExtractor.stepToString DataExtractor.Configure)
                        , \_ -> Expect.equal "Preview Results" (DataExtractor.stepToString DataExtractor.Preview)
                        , \_ -> Expect.equal "Select Output Fields" (DataExtractor.stepToString DataExtractor.SelectFields)
                        , \_ -> Expect.equal "Download Results" (DataExtractor.stepToString DataExtractor.Download)
                        ] ()
            ]

        , describe "Step validation"
            [ test "Upload step is always accessible" <|
                \_ ->
                    let
                        model = DataExtractor.init
                    in
                    Expect.equal True (DataExtractor.canProceedToStep DataExtractor.Upload model)

            , test "Configure step requires both files" <|
                \_ ->
                    let
                        model = DataExtractor.init
                    in
                    Expect.equal False (DataExtractor.canProceedToStep DataExtractor.Configure model)
            ]
        ]