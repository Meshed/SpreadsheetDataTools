# Frontend Architecture

## Component Architecture

### Component Organization
```text
src/
├── Main.elm                    # Application entry and routing
├── Types/
│   ├── Common.elm             # Shared types across application
│   ├── FileData.elm           # File-related types
│   ├── Matching.elm           # Matching algorithm types
│   └── Ports.elm              # Port communication types
├── Shared/
│   ├── Wizard/
│   │   ├── Wizard.elm         # Generic wizard framework
│   │   ├── Types.elm          # Wizard-specific types
│   │   └── View.elm           # Wizard view components
│   ├── Components/
│   │   ├── Button.elm         # Button component
│   │   ├── Card.elm           # Card component
│   │   ├── Form.elm           # Form elements
│   │   └── Progress.elm       # Progress indicators
│   ├── Matching/
│   │   ├── Engine.elm         # Pure matching functions
│   │   ├── Fuzzy.elm          # Fuzzy matching algorithms
│   │   └── Exact.elm          # Exact matching logic
│   └── Utils/
│       ├── CSV.elm            # CSV generation (pure)
│       ├── Validation.elm     # Data validation (pure)
│       └── Format.elm         # Formatting utilities (pure)
├── Tools/
│   ├── DataExtractor/
│   │   ├── Model.elm          # Tool state
│   │   ├── Update.elm         # State transitions
│   │   ├── View.elm           # Tool UI
│   │   └── Steps/             # Step-specific modules
│   │       ├── Upload.elm
│   │       ├── Configure.elm
│   │       ├── Preview.elm
│   │       ├── SelectFields.elm
│   │       └── Download.elm
│   └── DataMerger/            # Similar structure
└── Ports.elm                  # All port definitions
```

### Component Template
```elm
module Shared.Components.Button exposing (button, ButtonConfig, ButtonVariant(..))

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events

type ButtonVariant
    = Primary
    | Secondary
    | Danger

type alias ButtonConfig msg =
    { variant : ButtonVariant
    , disabled : Bool
    , onClick : Maybe msg
    , testId : Maybe String
    }

button : ButtonConfig msg -> String -> Html msg
button config label =
    Html.button
        (List.filterMap identity
            [ Just (Attr.class (buttonClass config))
            , Just (Attr.disabled config.disabled)
            , Maybe.map Events.onClick config.onClick
            , Maybe.map (Attr.attribute "data-testid") config.testId
            ]
        )
        [ Html.text label ]

-- Pure function for class generation
buttonClass : ButtonConfig msg -> String
buttonClass config =
    let
        base = "btn"
        variant = 
            case config.variant of
                Primary -> "btn--primary"
                Secondary -> "btn--secondary"
                Danger -> "btn--danger"
        disabled = 
            if config.disabled then " btn--disabled" else ""
    in
    base ++ " " ++ variant ++ disabled
```

## State Management Architecture

### State Structure
```elm
-- Main application state
type alias Model =
    { route : Route
    , extractorState : Maybe DataExtractor.Model
    , mergerState : Maybe DataMerger.Model
    , globalError : Maybe AppError
    , screenSize : ScreenSize
    }

-- Tool-specific state
type alias ExtractorModel =
    { wizard : Wizard.Model ExtractorStep
    , masterFile : Maybe FileData
    , dataFile : Maybe FileData
    , matchConfig : Maybe MatchConfig
    , processedData : Maybe ProcessedData
    , selectedFields : Set String
    }

-- State update pattern (pure functions)
updateExtractor : ExtractorMsg -> ExtractorModel -> ( ExtractorModel, Cmd ExtractorMsg )
updateExtractor msg model =
    case msg of
        FileUploaded fileType fileData ->
            ( updateFileData fileType fileData model
            , Cmd.none
            )
        
        ConfigureMatching config ->
            ( { model | matchConfig = Just config }
            , generatePreview config model
            )
        
        ProcessData ->
            ( model
            , processWithPureFunctions model
            )
```

### State Management Patterns
- All state updates through pure functions
- Immutable data structures throughout
- Time-travel debugging enabled in development
- No hidden state or side effects
- Command pattern for async operations

## Routing Architecture

### Route Organization
```text
Routes:
/                      # Landing page with tool cards
/data-extractor        # Data Extractor tool
  /data-extractor/upload
  /data-extractor/configure
  /data-extractor/preview
  /data-extractor/select-fields
  /data-extractor/download
/data-merger          # Data Merger tool (similar sub-routes)
/not-found           # 404 page
```

### Protected Route Pattern
```elm
-- No authentication needed, but we validate wizard state
type Route
    = Home
    | DataExtractor ExtractorRoute
    | DataMerger MergerRoute
    | NotFound

type ExtractorRoute
    = ExtractorStep ExtractorStep

-- Route validation
validateRoute : Route -> Model -> Route
validateRoute requestedRoute model =
    case requestedRoute of
        DataExtractor (ExtractorStep step) ->
            if canNavigateToStep step model.extractorState then
                requestedRoute
            else
                DataExtractor (ExtractorStep ExtractorUpload)
        
        _ ->
            requestedRoute

-- Pure function to check step validity
canNavigateToStep : ExtractorStep -> Maybe ExtractorModel -> Bool
canNavigateToStep step maybeModel =
    case maybeModel of
        Nothing ->
            step == ExtractorUpload
        
        Just model ->
            stepIsAccessible step model.wizard.completedSteps
```

## Frontend Services Layer

### API Client Setup
```elm
-- No traditional API, but we have port communication
port module Ports exposing (..)

-- Outgoing ports (commands)
port parseFile : FileUploadRequest -> Cmd msg
port generateDownload : DownloadRequest -> Cmd msg
port clearMemory : () -> Cmd msg

-- Incoming ports (subscriptions)
port fileParsed : (FileParseResult -> msg) -> Sub msg
port downloadReady : (String -> msg) -> Sub msg
port memoryCleared : (() -> msg) -> Sub msg

-- Type-safe port communication
type alias FileUploadRequest =
    { id : String
    , content : String
    , fileType : String
    }

type alias FileParseResult =
    { id : String
    , success : Bool
    , data : Maybe ParsedData
    , error : Maybe String
    }
```

### Service Example
```elm
module Services.FileProcessor exposing (processFile, parseExcel)

import Ports
import Types.FileData exposing (FileData)

-- Service function that returns a command
processFile : String -> String -> String -> Cmd Msg
processFile fileId fileType content =
    Ports.parseFile
        { id = fileId
        , content = content
        , fileType = fileType
        }

-- Pure function for processing parsed data
validateParsedData : ParsedData -> Result ValidationError FileData
validateParsedData parsed =
    parsed
        |> checkHeaders
        |> Result.andThen checkRowConsistency
        |> Result.andThen checkDataTypes
        |> Result.map toFileData

-- Pure helper functions
checkHeaders : ParsedData -> Result ValidationError ParsedData
checkHeaders data =
    if List.isEmpty data.headers then
        Err NoHeaders
    else
        Ok data

checkRowConsistency : ParsedData -> Result ValidationError ParsedData
checkRowConsistency data =
    let
        headerCount = List.length data.headers
        invalidRows = 
            List.filter (\row -> List.length row /= headerCount) data.rows
    in
    if List.isEmpty invalidRows then
        Ok data
    else
        Err (InconsistentColumns (List.length invalidRows))
```
