# Data Models

## FileData
**Purpose:** Represents parsed spreadsheet data from uploaded files

**Key Attributes:**
- headers: List String - Column headers from first row
- rows: List (List String) - Data rows as string lists
- metadata: FileMetadata - File information and statistics
- fileName: String - Original file name for reference
- fileSize: Int - Size in bytes for validation

**Elm Type Definition:**
```elm
type alias FileData =
    { headers : List String
    , rows : List (List String)
    , metadata : FileMetadata
    , fileName : String
    , fileSize : Int
    }

type alias FileMetadata =
    { rowCount : Int
    , columnCount : Int
    , sheetCount : Int
    , parseTime : Float -- milliseconds
    }
```

**Relationships:**
- Used by both DataExtractor and DataMerger tools
- Input to MatchingEngine (pure functions)
- Transformed to ProcessedData after matching

## MatchConfig
**Purpose:** Configuration for matching logic between spreadsheets

**Key Attributes:**
- masterColumns: List String - Selected columns from master/control file
- dataColumns: List String - Selected columns from data/source file
- fuzzyEnabled: Bool - Enable fuzzy matching
- threshold: Float - Similarity threshold (0.0 to 1.0)
- caseSensitive: Bool - Case sensitivity flag

**Elm Type Definition:**
```elm
type alias MatchConfig =
    { masterColumns : List String
    , dataColumns : List String
    , fuzzyEnabled : Bool
    , threshold : Float
    , caseSensitive : Bool
    }
```

**Relationships:**
- Created by user selections in wizard
- Consumed by MatchingEngine pure functions
- Stored in tool state during processing

## ProcessedData
**Purpose:** Results after matching and processing operations

**Key Attributes:**
- matchedRecords: List MatchedRecord - Successfully matched rows
- unmatchedMaster: List (List String) - Unmatched from master
- unmatchedData: List (List String) - Unmatched from data
- statistics: ProcessingStats - Summary statistics
- selectedFields: Set String - Fields chosen for output

**Elm Type Definition:**
```elm
type alias ProcessedData =
    { matchedRecords : List MatchedRecord
    , unmatchedMaster : List (List String)
    , unmatchedData : List (List String)
    , statistics : ProcessingStats
    , selectedFields : Set String
    }

type alias MatchedRecord =
    { masterRow : List String
    , dataRow : List String
    , matchScore : Float
    , matchedOn : List String -- which columns matched
    }

type alias ProcessingStats =
    { totalMasterRows : Int
    , totalDataRows : Int
    , matchedCount : Int
    , unmatchedMasterCount : Int
    , unmatchedDataCount : Int
    , processingTime : Float
    }
```

**Relationships:**
- Output from MatchingEngine pure functions
- Input to CSV generator pure functions
- Displayed in preview step

## WizardState
**Purpose:** Tracks progress through multi-step wizard workflow

**Key Attributes:**
- currentStep: step - Generic step type (polymorphic)
- completedSteps: Set String - Validated completed steps
- stepData: Dict String Json.Value - Step-specific data
- navigationState: NavigationState - Navigation permissions

**Elm Type Definition:**
```elm
type alias WizardState step =
    { currentStep : step
    , completedSteps : Set String
    , stepData : Dict String Json.Encode.Value
    , navigationState : NavigationState
    }

type NavigationState
    = CanNavigate { canGoBack : Bool, canGoForward : Bool }
    | Processing
    | Disabled String -- reason

-- Tool-specific step types
type ExtractorStep
    = ExtractorUpload
    | ExtractorConfigure
    | ExtractorPreview
    | ExtractorSelectFields
    | ExtractorDownload

type MergerStep
    = MergerUpload
    | MergerConfigure
    | MergerPreview
    | MergerSelectFields
    | MergerDownload
```

**Relationships:**
- Managed by Wizard framework
- Updated through pure state transition functions
- Controls view rendering

## MergeResult
**Purpose:** Specific result type for Data Merger tool operations

**Key Attributes:**
- updatedRecords: List MergedRecord - Records found in both files
- newRecords: List (List String) - Records only in spreadsheet A
- deletedRecords: List (List String) - Records only in spreadsheet B (marked with ~)
- mergeConfig: MergeConfig - Configuration used
- conflictResolutions: Dict String String - How conflicts were resolved

**Elm Type Definition:**
```elm
type alias MergeResult =
    { updatedRecords : List MergedRecord
    , newRecords : List (List String)
    , deletedRecords : List (List String) -- Will have ~ prefix added
    , mergeConfig : MergeConfig
    , conflictResolutions : Dict String String
    }

type alias MergedRecord =
    { originalA : List String
    , originalB : List String
    , merged : List String
    , changedFields : List String
    }

type alias MergeConfig =
    { matchColumns : List ColumnPair
    , conflictStrategy : ConflictStrategy
    , markDeleted : Bool
    , tildePrefix : String -- Default: "~"
    }

type alias ColumnPair =
    { columnA : String
    , columnB : String
    }

type ConflictStrategy
    = PreferA
    | PreferB
    | Newest
```

**Relationships:**
- Output from Data Merger pure processing functions
- Extends ProcessedData pattern
- Used for CSV generation with special formatting

## Port Data Types (JavaScript Boundary)
**Purpose:** Types for JavaScript interop - the only place where we need to consider JavaScript

**Elm Port Types:**
```elm
-- Data sent to JavaScript for file parsing
type alias FileUploadRequest =
    { fileId : String
    , fileType : String
    , content : String -- Base64 encoded
    }

-- Data received from JavaScript after parsing
type alias FileParseResult =
    { fileId : String
    , success : Bool
    , headers : List String
    , rows : List (List String)
    , error : Maybe String
    }

-- CSV generation request
type alias CSVGenerationRequest =
    { fileName : String
    , headers : List String
    , rows : List (List String)
    }
```
