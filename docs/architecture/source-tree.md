# Source Tree Documentation - Spreadsheet Data Tools

## Introduction

This document captures the planned source tree structure for the Spreadsheet Data Tools platform. The project is a privacy-focused, client-side only web application built with Elm that provides specialized tools for comparing, extracting, and merging data between spreadsheets without storing any user data.

### Document Scope
Focused on the complete implementation architecture for:
- Data Extractor tool (Epic 2)
- Data Merger tool (Epic 4) 
- Shared component framework (Epic 3)
- Platform infrastructure (Epic 1)

### Architecture Context
- **100% Client-Side Processing**: No backend, all computation in browser
- **Elm Architecture (MVU)**: Model-View-Update pattern throughout
- **Modular Tool Design**: Extensible architecture for adding new tools
- **Privacy-First**: No data persistence, no server communication

## Quick Reference - Key Files and Entry Points

### Critical Files for Understanding the System

- **Main Entry**: `src/Main.elm` - Application bootstrap and routing
- **Tool Definitions**: 
  - `src/Tools/DataExtractor/Model.elm` - Data Extractor state
  - `src/Tools/DataMerger/Model.elm` - Data Merger state
- **Shared Framework**:
  - `src/Shared/Wizard/Wizard.elm` - 5-step wizard framework
  - `src/Shared/Processing/Matching/Engine.elm` - Core matching logic
- **JavaScript Interop**: `src/Ports.elm` - File handling bridges
- **Configuration**: `elm.json`, `package.json`, `webpack.config.js`

## High Level Architecture

### Technical Summary

Pure Elm application with minimal JavaScript interop for file operations. All data processing occurs in-browser through functional transformations. No server dependencies, APIs, or data persistence.

### Actual Tech Stack

| Category | Technology | Version | Purpose |
|----------|------------|---------|---------|
| Frontend Language | Elm | 0.19.1 | Primary application language |
| Architecture | Elm MVU | Built-in | Application structure |
| JavaScript Interop | SheetJS | 0.18.5 | Excel file parsing only |
| Build Tool | Webpack | 5.74.0 | Bundle and compilation |
| Testing | elm-test | 0.19.1 | Unit/integration tests |
| E2E Testing | Cypress | 10.8.0 | Browser automation |
| Deployment | GitHub Pages | N/A | Static hosting |
| CSS Methodology | BEM | N/A | No inline styles |

## Source Tree and Module Organization

### Project Structure (Planned)

```text
SpreadsheetDataTools/
├── src/                       # Elm application source
│   ├── Main.elm              # ENTRY POINT - Routing and app initialization
│   ├── Types/                # Shared type definitions
│   │   ├── Common.elm        # FileData, MatchConfig, ProcessingState
│   │   ├── DataExtractor.elm # ExtractorModel, ExtractorMsg
│   │   ├── DataMerger.elm    # MergerModel, MergerMsg  
│   │   └── Ports.elm         # Port message types
│   ├── Shared/               # CRITICAL - Reusable modules (Epic 3)
│   │   ├── Wizard/           # Generic 5-step wizard framework
│   │   │   ├── Wizard.elm    # Core wizard state machine
│   │   │   ├── Types.elm     # WizardStep, WizardState types
│   │   │   └── View.elm      # Progress bar, navigation UI
│   │   ├── Components/       # UI building blocks
│   │   │   ├── Button.elm    # Primary/secondary button styles
│   │   │   ├── Card.elm      # Tool card component
│   │   │   ├── FileUpload.elm # Drag-drop file handling
│   │   │   ├── FieldSelector.elm # Multi-column selection UI
│   │   │   └── Preview.elm   # Data preview tables
│   │   ├── Processing/       # CORE LOGIC - Pure functions only
│   │   │   ├── Matching/     
│   │   │   │   ├── Engine.elm # Multi-column matching algorithm
│   │   │   │   └── Fuzzy.elm  # "includes" fuzzy matching
│   │   │   ├── CSV.elm       # CSV generation (pure)
│   │   │   └── Validation.elm # File size/format validation
│   │   └── Utils/
│   │       └── Constants.elm # 50MB limit, file formats
│   ├── Tools/                # Individual tool implementations
│   │   ├── DataExtractor/    # Epic 2 implementation
│   │   │   ├── Model.elm     # ExtractorModel state
│   │   │   ├── Update.elm    # Message handlers
│   │   │   ├── View.elm      # Tool rendering
│   │   │   └── Steps/        # Wizard step modules
│   │   │       ├── Upload.elm      # Step 1: Dual file upload
│   │   │       ├── Configure.elm   # Step 2: Match config
│   │   │       ├── Preview.elm     # Step 3: Sample matches
│   │   │       ├── SelectFields.elm # Step 4: Output fields
│   │   │       └── Download.elm    # Step 5: CSV generation
│   │   └── DataMerger/       # Epic 4 implementation
│   │       ├── Model.elm     # MergerModel state
│   │       ├── Update.elm    # Message handlers
│   │       ├── View.elm      # Tool rendering
│   │       └── Steps/        # Similar 5-step structure
│   ├── Pages/
│   │   └── Home.elm          # Landing page with tool cards
│   └── Ports.elm             # JavaScript interop definitions
├── assets/
│   └── styles/               # CSS files (NO inline styles)
│       ├── base/             # Reset, typography, variables
│       ├── components/       # BEM component styles
│       │   ├── wizard.css    # .wizard__progress-bar
│       │   ├── cards.css     # .tool-card__title
│       │   └── buttons.css   # .btn--primary
│       └── main.css          # Import aggregator
├── public/
│   └── index.html            # HTML shell with CSP headers
├── tests/                    # Elm test files
│   ├── unit/
│   │   ├── MatchingTests.elm # Fuzzy matching tests
│   │   └── CSVTests.elm      # CSV generation tests
│   └── integration/
│       └── WizardTests.elm   # Wizard state machine tests
├── cypress/                  # E2E test suite
│   └── e2e/
│       ├── data-extractor.cy.js
│       └── data-merger.cy.js
├── .github/
│   └── workflows/
│       ├── ci.yml            # Test on PR
│       └── deploy.yml        # Deploy to GitHub Pages
├── elm.json                  # Elm dependencies
├── package.json              # Node scripts and JS libs
└── webpack.config.js         # Build configuration
```

### Key Modules and Their Purpose

#### Core Entry Points
- **Main.elm**: Application initialization, URL routing between Home/DataExtractor/DataMerger
- **Ports.elm**: Defines port functions for file operations (readExcelFile, downloadCSV)

#### Shared Framework (Epic 3 - Critical for Reusability)
- **Wizard.elm**: Generic 5-step wizard state machine, handles step validation and navigation
- **Matching/Engine.elm**: Multi-column positional matching, core algorithm used by both tools
- **Matching/Fuzzy.elm**: Implements "includes" logic (e.g., "Mark" matches "Mr. Mark")
- **CSV.elm**: Pure CSV generation with proper escaping and quoting

#### Tool Implementations
- **DataExtractor/Model.elm**: Manages master/data spreadsheets, matching config, field selection
- **DataMerger/Model.elm**: Handles A/B spreadsheets, merge logic, tilde prefix marking
- **Steps/*.elm**: Each step module handles specific wizard page logic and validation

## Data Flow and Architecture Patterns

### File Processing Pipeline

```elm
-- Simplified data flow through the system
User Upload → Port.readExcelFile → JavaScript (SheetJS) → Port.fileDataReceived
→ Elm Model Update → Pure Processing Functions → CSV Generation → Port.downloadCSV
```

### Wizard State Management

```elm
type WizardStep
    = Upload
    | Configure  
    | Preview
    | SelectFields
    | Download

type alias WizardState =
    { currentStep : WizardStep
    , canProceed : Bool
    , canGoBack : Bool
    , stepData : StepData  -- Tool-specific data
    }
```

### Matching Algorithm Structure

```elm
-- Core matching function signature
matchRecords : List MatchConfig -> List Record -> List Record -> List MatchResult

-- Multi-column matching with positional ordering
type alias MatchConfig =
    { masterColumns : List Int  -- Column indices in order
    , dataColumns : List Int    -- Matching column indices
    , useFuzzy : Bool           -- Enable "includes" matching
    }
```

## Technical Constraints and Patterns

### Critical Implementation Rules

1. **Pure Functions Only**: All data processing in `Shared/Processing/` must be pure
2. **No Inline Styles**: All CSS in separate files using BEM methodology
3. **Port Isolation**: JavaScript interop only through defined ports
4. **Memory Management**: Clear file data after processing completes
5. **Error Handling**: All fallible operations return `Result` types
6. **File Limits**: Enforce 50MB/10,000 row limits in validation

### JavaScript Interop Boundaries

```elm
-- Ports for file operations (only JS interaction points)
port readExcelFile : FileData -> Cmd msg
port fileDataReceived : (Json.Value -> msg) -> Sub msg
port downloadCSV : { filename : String, content : String } -> Cmd msg
port clearMemory : () -> Cmd msg
```

### Wizard Framework Contract

Each tool must implement:
- 5 distinct steps with validation
- Progress indicator updates
- Previous/Next navigation
- Step-specific data persistence
- "Start Over" functionality

## Development Patterns

### Module Organization Rules

1. **Shared modules** contain no tool-specific logic
2. **Tool modules** import from Shared, never cross-import
3. **Types module** defines all custom types for domain modeling
4. **Pure functions** separated from UI and effects
5. **Step modules** encapsulate wizard page logic

### Testing Strategy Layers

- **Unit Tests**: Pure functions in Processing modules
- **Integration Tests**: Wizard state transitions
- **E2E Tests**: Complete tool workflows with file operations
- **Property Tests**: Fuzzy matching edge cases

### CSS Architecture (BEM)

```css
/* Component */
.wizard { }

/* Element */  
.wizard__progress-bar { }

/* Modifier */
.wizard__step--active { }

/* Tool-specific */
.data-extractor__preview { }
```

## Future Extension Points

### Adding New Tools

1. Create new directory under `src/Tools/NewTool/`
2. Implement Model, Update, View modules
3. Define 5 wizard steps in Steps/ subdirectory
4. Register route in Main.elm
5. Add tool card to Home.elm
6. Reuse Shared components (no duplication)

### Shared Component Expansion

- Additional matching algorithms in `Shared/Processing/Matching/`
- New file formats in validation
- Enhanced preview components
- Additional wizard configurations

## Implementation Priorities

### Phase 1: Foundation (Epic 1)
- Main.elm with routing
- Home page with tool cards  
- Basic CSS structure
- Webpack configuration

### Phase 2: Data Extractor (Epic 2)
- Complete tool implementation
- All 5 wizard steps
- CSV download functionality

### Phase 3: Refactoring (Epic 3)
- Extract shared components
- Generalize wizard framework
- Create reusable matching engine

### Phase 4: Data Merger (Epic 4)
- Implement using shared components
- Add tilde prefix logic
- Complete merge functionality

## Notes

- This document reflects the **planned architecture** based on PRD requirements
- No backend code exists as this is a client-side only application
- All data processing happens in the browser for privacy
- The architecture supports adding new tools with <1 week effort
- Elm's type system prevents runtime errors in production