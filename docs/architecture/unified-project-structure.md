# Unified Project Structure

```plaintext
SpreadsheetDataTools/
├── .github/                    # CI/CD workflows
│   └── workflows/
│       ├── ci.yml             # Test and build workflow
│       └── deploy.yml         # Deploy to GitHub Pages
├── src/                       # Elm application source
│   ├── Main.elm              # Application entry point and routing
│   ├── Types/                # Shared type definitions
│   │   ├── Common.elm        # Common types (FileData, MatchConfig, etc.)
│   │   ├── DataExtractor.elm # Data Extractor specific types
│   │   ├── DataMerger.elm    # Data Merger specific types
│   │   └── Ports.elm         # JavaScript interop types
│   ├── Shared/               # Shared modules across tools
│   │   ├── Wizard/           # Generic wizard framework
│   │   │   ├── Wizard.elm    # Core wizard logic
│   │   │   ├── Types.elm     # Wizard types and states
│   │   │   └── View.elm      # Wizard UI components
│   │   ├── Components/       # Reusable UI components
│   │   │   ├── Button.elm    # Button component
│   │   │   ├── Card.elm      # Card component
│   │   │   ├── Form.elm      # Form elements
│   │   │   ├── Progress.elm  # Progress indicators
│   │   │   ├── FileUpload.elm # File upload component
│   │   │   └── ErrorDisplay.elm # Error handling UI
│   │   ├── Processing/       # Pure data processing functions
│   │   │   ├── Matching/     # Data matching algorithms
│   │   │   │   ├── Engine.elm    # Core matching engine
│   │   │   │   ├── Fuzzy.elm     # Fuzzy matching algorithms
│   │   │   │   └── Exact.elm     # Exact matching logic
│   │   │   ├── CSV.elm       # CSV generation (pure)
│   │   │   ├── Validation.elm # Data validation (pure)
│   │   │   └── Format.elm    # Formatting utilities (pure)
│   │   └── Utils/            # General utilities
│   │       ├── Constants.elm # Application constants
│   │       ├── Http.elm      # HTTP utilities (unused but placeholder)
│   │       └── Time.elm      # Time utilities
│   ├── Tools/                # Individual tool implementations
│   │   ├── DataExtractor/    # Data Extractor tool
│   │   │   ├── Model.elm     # Tool state and types
│   │   │   ├── Update.elm    # State transitions
│   │   │   ├── View.elm      # Tool UI rendering
│   │   │   ├── Subscriptions.elm # Tool subscriptions
│   │   │   └── Steps/        # Step-specific modules
│   │   │       ├── Upload.elm      # File upload step
│   │   │       ├── Configure.elm   # Matching configuration
│   │   │       ├── Preview.elm     # Results preview
│   │   │       ├── SelectFields.elm # Field selection
│   │   │       └── Download.elm    # CSV download
│   │   └── DataMerger/       # Data Merger tool (similar structure)
│   │       ├── Model.elm
│   │       ├── Update.elm
│   │       ├── View.elm
│   │       ├── Subscriptions.elm
│   │       └── Steps/
│   ├── Pages/                # Page-level components
│   │   ├── Home.elm          # Landing page
│   │   ├── NotFound.elm      # 404 page
│   │   └── DesktopWarning.elm # Desktop-only warning
│   └── Ports.elm             # JavaScript interop definitions
├── assets/                   # Static assets
│   ├── styles/               # CSS files
│   │   ├── base/
│   │   │   ├── reset.css     # CSS reset and normalize
│   │   │   ├── typography.css # Font definitions
│   │   │   └── variables.css # CSS custom properties
│   │   ├── components/       # Component-specific styles
│   │   │   ├── buttons.css   # Button styles
│   │   │   ├── cards.css     # Card styles
│   │   │   ├── forms.css     # Form element styles
│   │   │   ├── progress.css  # Progress indicator styles
│   │   │   └── wizard.css    # Wizard framework styles
│   │   ├── layout/           # Layout styles
│   │   │   ├── header.css    # Header layout
│   │   │   ├── footer.css    # Footer layout
│   │   │   ├── grid.css      # Grid system
│   │   │   └── containers.css # Container layouts
│   │   ├── pages/            # Page-specific styles
│   │   │   ├── landing.css   # Landing page styles
│   │   │   ├── data-extractor.css # Tool-specific styles
│   │   │   └── data-merger.css
│   │   ├── utilities/        # Utility classes
│   │   │   ├── spacing.css   # Margin/padding utilities
│   │   │   ├── colors.css    # Color utilities
│   │   │   └── helpers.css   # Helper utilities
│   │   └── main.css          # Main import file
│   ├── images/               # Image assets
│   │   ├── icons/            # Tool icons
│   │   └── logos/            # Logo assets
│   └── fonts/                # Web fonts (if any)
├── public/                   # Public directory for serving
│   ├── index.html            # HTML template
│   ├── manifest.json         # Web app manifest
│   └── favicon.ico           # Favicon
├── tests/                    # Test files
│   ├── unit/                 # Unit tests
│   │   ├── MatchingTests.elm # Matching algorithm tests
│   │   ├── CSVTests.elm      # CSV generation tests
│   │   ├── ValidationTests.elm # Validation tests
│   │   └── WizardTests.elm   # Wizard framework tests
│   ├── integration/          # Integration tests
│   │   ├── ExtractorTests.elm # Data Extractor integration
│   │   └── MergerTests.elm   # Data Merger integration
│   └── TestData.elm          # Shared test data
├── cypress/                  # E2E test files
│   ├── e2e/                  # Test specs
│   │   ├── data-extractor.cy.js # Extractor E2E tests
│   │   ├── data-merger.cy.js    # Merger E2E tests
│   │   └── desktop-only.cy.js   # Desktop-only tests
│   ├── fixtures/             # Test data files
│   │   ├── sample-data.xlsx
│   │   ├── large-file.xlsx
│   │   └── invalid-file.txt
│   ├── support/              # Support files
│   │   ├── commands.js       # Custom commands
│   │   └── e2e.js           # E2E configuration
│   └── cypress.config.js     # Cypress configuration
├── scripts/                  # Build and development scripts
│   ├── build.js              # Production build script
│   ├── dev.js                # Development server script
│   └── test.js               # Test runner script
├── dist/                     # Built files (generated)
├── elm-stuff/                # Elm dependencies (generated)
├── node_modules/             # Node dependencies (generated)
├── docs/                     # Documentation
│   ├── prd.md               # Product Requirements Document
│   ├── front-end-specification.md # Frontend specification
│   ├── architecture.md      # This architecture document
│   └── README.md            # Project documentation
├── .bmad-core/              # BMad framework files
│   ├── core-config.yaml     # Project configuration
│   ├── tasks/               # AI agent tasks
│   ├── templates/           # Document templates
│   └── checklists/          # Quality checklists
├── .gitignore               # Git ignore rules
├── .env.example             # Environment variables template
├── elm.json                 # Elm package configuration
├── package.json             # Node.js package configuration
├── webpack.config.js        # Webpack build configuration
├── cypress.config.js        # Cypress testing configuration
└── README.md                # Main project documentation
```
