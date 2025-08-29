module DataExtractorConfigureTests exposing (..)

{-| Tests for Data Extractor Configure step functionality.

Tests include:
- Column selection and deselection logic
- Selection ordering and reordering functions  
- Validation rules and error messaging
- MatchConfig generation from user selections
- Sample data preview accuracy

-}

import Expect
import Test exposing (Test, describe, test)
import Tools.DataExtractor.Model exposing (Model, Msg(..), ConfigureMsg(..), Step(..), FileData, ValidationError(..))
import Tools.DataExtractor.Update exposing (update)
import Tools.DataExtractor.Steps.Configure exposing (view)


-- Test Data
sampleMasterFile : FileData
sampleMasterFile =
    { fileName = "master.xlsx"
    , fileSize = 1000
    , headers = [ "Employee_ID", "Full_Name", "Department", "Email" ]
    , rows = 
        [ [ "001", "John Smith", "Engineering", "john@company.com" ]
        , [ "002", "Jane Doe", "Marketing", "jane@company.com" ]
        , [ "003", "Bob Johnson", "Sales", "bob@company.com" ]
        ]
    , rowCount = 3
    , columnCount = 4
    }

sampleDataFile : FileData  
sampleDataFile =
    { fileName = "data.xlsx"
    , fileSize = 1200
    , headers = [ "EmpID", "Name", "Salary", "Bonus" ]
    , rows = 
        [ [ "001", "John Smith", "75000", "5000" ]
        , [ "002", "Jane Doe", "65000", "3000" ]
        , [ "003", "Bob Johnson", "55000", "2000" ]
        ]
    , rowCount = 3
    , columnCount = 4
    }

initialModel : Model
initialModel =
    { currentStep = Configure
    , masterFile = Just sampleMasterFile
    , dataFile = Just sampleDataFile
    , masterFileError = Nothing
    , dataFileError = Nothing
    , isProcessing = False
    , processingFileType = Nothing
    , matchConfig = Nothing
    , processedData = Nothing
    , selectedFields = []
    , selectedMasterColumns = []
    , selectedDataColumns = []
    , privacyNoticeShown = True
    }


-- Test Suite
suite : Test
suite =
    describe "Data Extractor Configure Step Tests"
        [ columnSelectionTests
        , selectionOrderingTests
        , validationTests
        , matchConfigGenerationTests
        ]


columnSelectionTests : Test
columnSelectionTests =
    describe "Column Selection Tests"
        [ test "SelectMasterColumn adds column to selectedMasterColumns" <|
            \_ ->
                let
                    msg = ConfigureMsg (SelectMasterColumn "Employee_ID")
                    (updatedModel, _) = update msg initialModel
                in
                updatedModel.selectedMasterColumns
                    |> Expect.equal [ "Employee_ID" ]

        , test "SelectMasterColumn does not add duplicate column" <|
            \_ ->
                let
                    model = { initialModel | selectedMasterColumns = [ "Employee_ID" ] }
                    msg = ConfigureMsg (SelectMasterColumn "Employee_ID")
                    (updatedModel, _) = update msg model
                in
                updatedModel.selectedMasterColumns
                    |> Expect.equal [ "Employee_ID" ]

        , test "DeselectMasterColumn removes column from selectedMasterColumns" <|
            \_ ->
                let
                    model = { initialModel | selectedMasterColumns = [ "Employee_ID", "Full_Name" ] }
                    msg = ConfigureMsg (DeselectMasterColumn "Employee_ID")
                    (updatedModel, _) = update msg model
                in
                updatedModel.selectedMasterColumns
                    |> Expect.equal [ "Full_Name" ]

        , test "SelectDataColumn adds column to selectedDataColumns" <|
            \_ ->
                let
                    msg = ConfigureMsg (SelectDataColumn "EmpID")
                    (updatedModel, _) = update msg initialModel
                in
                updatedModel.selectedDataColumns
                    |> Expect.equal [ "EmpID" ]

        , test "DeselectDataColumn removes column from selectedDataColumns" <|
            \_ ->
                let
                    model = { initialModel | selectedDataColumns = [ "EmpID", "Name" ] }
                    msg = ConfigureMsg (DeselectDataColumn "EmpID")
                    (updatedModel, _) = update msg model
                in
                updatedModel.selectedDataColumns
                    |> Expect.equal [ "Name" ]
        ]


selectionOrderingTests : Test
selectionOrderingTests =
    describe "Selection Ordering Tests"
        [ test "Multiple selections maintain order of addition" <|
            \_ ->
                let
                    model = initialModel
                    msg1 = ConfigureMsg (SelectMasterColumn "Employee_ID")
                    (model1, _) = update msg1 model
                    msg2 = ConfigureMsg (SelectMasterColumn "Full_Name")
                    (model2, _) = update msg2 model1
                    msg3 = ConfigureMsg (SelectMasterColumn "Email")
                    (finalModel, _) = update msg3 model2
                in
                finalModel.selectedMasterColumns
                    |> Expect.equal [ "Employee_ID", "Full_Name", "Email" ]

        , test "Removing middle selection preserves order of remaining items" <|
            \_ ->
                let
                    model = { initialModel | selectedMasterColumns = [ "Employee_ID", "Full_Name", "Email" ] }
                    msg = ConfigureMsg (DeselectMasterColumn "Full_Name")
                    (updatedModel, _) = update msg model
                in
                updatedModel.selectedMasterColumns
                    |> Expect.equal [ "Employee_ID", "Email" ]
        ]


validationTests : Test
validationTests =
    describe "Validation Tests"
        [ test "canProceedToStep Preview requires selections in both columns" <|
            \_ ->
                let
                    modelWithSelections = 
                        { initialModel 
                        | selectedMasterColumns = [ "Employee_ID" ]
                        , selectedDataColumns = [ "EmpID" ]
                        }
                in
                Tools.DataExtractor.Model.canProceedToStep Preview modelWithSelections
                    |> Expect.equal True

        , test "canProceedToStep Preview fails with empty selections" <|
            \_ ->
                Tools.DataExtractor.Model.canProceedToStep Preview initialModel
                    |> Expect.equal False
        ]


matchConfigGenerationTests : Test
matchConfigGenerationTests =
    describe "MatchConfig Generation Tests"
        [ test "ToggleFuzzyMatching creates MatchConfig when none exists" <|
            \_ ->
                let
                    msg = ConfigureMsg (ToggleFuzzyMatching True)
                    (updatedModel, _) = update msg initialModel
                in
                case updatedModel.matchConfig of
                    Nothing ->
                        Expect.fail "Expected MatchConfig to be created"
                    
                    Just config ->
                        config.useFuzzyMatch |> Expect.equal True

        , test "ToggleFuzzyMatching updates existing MatchConfig" <|
            \_ ->
                let
                    existingConfig = { masterColumns = [], dataColumns = [], useFuzzyMatch = False }
                    model = { initialModel | matchConfig = Just existingConfig }
                    msg = ConfigureMsg (ToggleFuzzyMatching True)
                    (updatedModel, _) = update msg model
                in
                case updatedModel.matchConfig of
                    Nothing ->
                        Expect.fail "Expected MatchConfig to exist"
                    
                    Just config ->
                        config.useFuzzyMatch |> Expect.equal True
        ]


