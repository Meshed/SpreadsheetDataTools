# Testing Strategy

## Testing Pyramid

```text
      E2E Tests (10%)
     /              \
   Integration Tests (20%)
  /                    \
Unit Tests (70% - Pure Functions)
```

## Test Organization

### Frontend Tests
```text
tests/
├── unit/                    # Pure function tests (70%)
│   ├── Matching/
│   │   ├── EngineTests.elm     # Core matching algorithm tests
│   │   ├── FuzzyTests.elm      # Fuzzy matching tests
│   │   └── ExactTests.elm      # Exact matching tests
│   ├── Processing/
│   │   ├── CSVTests.elm        # CSV generation tests
│   │   ├── ValidationTests.elm # Data validation tests
│   │   └── FormatTests.elm     # Formatting utility tests
│   ├── Components/
│   │   ├── WizardTests.elm     # Wizard framework tests
│   │   ├── ButtonTests.elm     # Button component tests
│   │   └── FormTests.elm       # Form component tests
│   └── Utils/
│       ├── ConstantsTests.elm  # Constants validation
│       └── TimeTests.elm       # Time utility tests
├── integration/             # Component integration tests (20%)
│   ├── ExtractorWorkflowTests.elm # End-to-end extractor workflow
│   ├── MergerWorkflowTests.elm    # End-to-end merger workflow
│   ├── FileProcessingTests.elm    # File upload to processing
│   └── ErrorHandlingTests.elm     # Error scenarios
├── property/               # Property-based tests
│   ├── MatchingPropertyTests.elm  # Matching properties
│   └── CSVPropertyTests.elm       # CSV format properties
└── TestData.elm            # Shared test data and utilities
```

### Backend Tests
**N/A - No backend to test**

### E2E Tests
```text
cypress/
├── e2e/
│   ├── data-extractor-workflow.cy.js  # Complete extractor workflow
│   ├── data-merger-workflow.cy.js     # Complete merger workflow
│   ├── file-upload-validation.cy.js   # File validation scenarios
│   ├── error-handling.cy.js           # Error recovery flows
│   ├── desktop-only-validation.cy.js  # Desktop-only enforcement
│   └── performance-validation.cy.js   # Large file performance
├── fixtures/
│   ├── sample-control.xlsx      # Sample control file
│   ├── sample-data.xlsx         # Sample data file
│   ├── large-file-10mb.xlsx     # Performance testing
│   ├── large-file-50mb.xlsx     # Maximum size testing
│   ├── invalid-format.txt       # Error testing
│   └── corrupted-file.xlsx      # Error testing
└── support/
    ├── commands.js              # Custom Cypress commands
    └── file-helpers.js          # File manipulation utilities
```
