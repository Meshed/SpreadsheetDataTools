# Spreadsheet Data Tools Product Requirements Document (PRD)

## Goals and Background Context

### Goals
- Launch MVP with 2 core tools (Data Extractor and Data Merger) within 3 months providing fully functional intuitive UI
- Achieve 95% client-side processing reliability for files up to 50MB/10,000 rows with zero server dependencies
- Establish absolute privacy guarantee with 100% browser-only processing, verifiable through network monitoring
- Enable non-technical user adoption with 80% of users completing first operation without documentation
- Build extensible modular architecture allowing new tools to be added with less than 1 week development effort
- Achieve 80% reduction in spreadsheet comparison task time and 75% reduction in data processing errors
- Reach 500 MAU within 3 months and 2,000 within 6 months with 60% return user rate

### Background Context
Professionals across industries regularly receive multiple spreadsheets requiring comparison, combination, or filtering operations. Current solutions force users to choose between privacy and functionality - either manually cross-referencing records (time-consuming and error-prone), using complex formulas requiring technical knowledge, or uploading sensitive data to cloud tools that store information. The matching process is particularly challenging with inconsistent data entry where names have different punctuation, titles, or formatting.

Spreadsheet Data Tools addresses this gap as a privacy-focused, extensible web platform providing specialized tools for comparing, extracting, and merging data between spreadsheets without storing any user data. All processing occurs client-side in the user's browser, ensuring complete data privacy while delivering powerful fuzzy matching capabilities through an intuitive visual interface built on an extensible architecture.

### Change Log
| Date | Version | Description | Author |
|------|---------|-------------|---------|
| 2025-08-20 | 1.0 | Initial PRD creation from approved Project Brief | John (PM) |

## Requirements

### Functional Requirements

**FR1:** The platform shall display a clean landing page with platform name, description, and tool cards showing tool name, icon, and brief description

**FR2:** The Data Extractor tool shall provide dual file upload interface accepting .xlsx, .xls, and .csv files up to 50MB/10,000 rows

**FR3:** The Data Extractor tool shall display visual column representations of both uploaded spreadsheets with all available fields

**FR4:** The Data Extractor tool shall provide field selection interface for choosing matching criteria between master and data spreadsheets

**FR5:** The Data Extractor tool shall implement fuzzy matching with "includes" logic handling name variations (e.g., "Mark" matches "Mr. Mark" and "Mark S.")

**FR6:** The Data Extractor tool shall display preview of up to 3 matched records for user validation before processing

**FR7:** The Data Extractor tool shall provide output field selection interface allowing users to choose which fields appear in results

**FR8:** The Data Extractor tool shall generate CSV download of extracted matching records

**FR9:** The Data Merger tool shall provide dual file upload interface for Spreadsheet A and Spreadsheet B with same file format support

**FR10:** The Data Merger tool shall display visual column representations for both spreadsheets with field matching selection interface

**FR11:** The Data Merger tool shall preview up to 3 combined records showing merge results before processing

**FR12:** The Data Merger tool shall mark records from B not found in A with tilde prefix ("~") at row beginning for easy Excel filtering

**FR13:** The Data Merger tool shall include clear UI messaging explaining tilde prefix meaning before download

**FR14:** The Data Merger tool shall add new records from A not found in B to the merged output

**FR15:** The platform shall provide post-download guidance explaining tilde prefix filtering in Excel (view deleted: "~*", hide deleted: "<>~*", remove markers: find/replace "~")

**FR16:** The platform shall include "Clear All Data" button immediately removing all loaded spreadsheet data from browser memory

**FR17:** All file processing shall occur entirely client-side with zero data transmission to servers

**FR18:** The platform shall handle Excel files with multiple sheets by using first sheet only with clear user notification

### Non-Functional Requirements

**NFR1:** The platform shall process files up to 50MB/10,000 rows within 30 seconds on modern browsers

**NFR2:** The platform shall provide smooth UI interactions with no perceptible lag during normal operations

**NFR3:** The platform shall support modern browsers (Chrome, Firefox, Safari, Edge - latest 2 versions) on desktop Windows, macOS, and Linux

**NFR4:** The platform shall achieve 95% operation completion rate without errors for target file sizes

**NFR5:** The platform shall implement Content Security Policy preventing data exfiltration

**NFR6:** The platform shall use no cookies or local storage for user data persistence

**NFR7:** The platform shall display visible messaging confirming no data leaves the browser during processing

**NFR8:** The platform architecture shall support adding new tools with less than 1 week development effort

**NFR9:** The platform shall handle browser memory limitations gracefully with appropriate user warnings for large files

**NFR10:** The platform shall implement robust JavaScript interop error handling preserving Elm type-safety

## User Interface Design Goals

### Overall UX Vision
**Wizard-driven interface** with clear progress tracking for both Data Extractor and Data Merger tools. Each tool presents a **multi-step guided workflow** with visual progress bar showing current step, completed steps, and remaining steps. Clean, professional design that builds user confidence through transparent progress indication and step-by-step guidance. Desktop-first design optimized for data manipulation tasks.

### Key Interaction Paradigms
- **Step-by-step wizard workflow** with progress bar showing: Upload → Configure → Preview → Download
- **Progress indicator design** similar to your reference images - circular step indicators with connecting lines, showing completed (filled), current (highlighted), and upcoming (outlined) steps
- **Navigation controls** with Previous/Next buttons, allowing users to move back to modify earlier choices
- **Visual field mapping** within wizard steps for column selection and matching criteria
- **Live preview integration** as dedicated wizard step before final processing
- **Clear privacy indicators** integrated into wizard header or footer
- **Modern card-based interface** for tool selection with hover effects and clear visual feedback
- **Consistent button styling** across cards and wizard navigation (primary actions, secondary actions)
- **Card-to-wizard transition** with smooth navigation from tool selection to guided workflow

### Core Screens and Views
- **Landing Page** - Clean card-based layout featuring:
  - **Tool Cards/Tiles** with modern card design (rounded corners, subtle shadows, hover states)
  - Each card includes: **Tool icon** (top), **Tool title** (prominent heading), **Brief description** (2-3 lines), and **Primary action button** ("Start Tool" or "Launch")
  - Cards arranged in responsive grid layout with consistent spacing
  - **Visual hierarchy** using card elevation and clean typography
  - **Professional styling** with subtle borders, proper whitespace, and modern button design

- **Data Extractor Wizard** - 5-step process:
  1. **Upload Files** (Master & Data spreadsheets)
  2. **Configure Matching** (Define matching criteria between spreadsheets)
  3. **Preview Results** (Sample matches for validation)
  4. **Select Fields** (Choose which columns to include in output)
  5. **Download** (CSV generation and file download)

- **Data Merger Wizard** - 5-step process:
  1. **Upload Files** (Spreadsheet A & B)
  2. **Configure Matching** (Define how records should be matched/merged)
  3. **Preview Results** (Sample merged records with tilde prefix examples)
  4. **Select Fields** (Choose output columns from both spreadsheets)
  5. **Download** (Final output with post-download guidance)

- **Wizard Progress Header** - 5-step progress indicator showing current position
- **Step Validation** - Each step validates inputs before allowing progression


### Branding
Clean, modern aesthetic emphasizing trust and professionalism. Minimal color palette focusing on data readability. Typography optimized for data display. Privacy-focused messaging integrated throughout interface. No corporate branding requirements - focus on usability and trustworthiness.

### Target Device and Platforms: Desktop Only
Desktop-exclusive design supporting Windows, macOS, and Linux browsers (minimum 1024px width). Optimized specifically for desktop screens where data manipulation workflows are most effective. No mobile support provided.

## Technical Assumptions

### Repository Structure: Monorepo
Single repository containing platform shell and individual tool modules with clear separation between platform core and tool implementations. Shared utilities for common operations (file parsing, matching algorithms, CSV generation). BMad Method integration for AI-assisted development with specialized agents.

### Service Architecture
**Client-side only architecture** with no server dependencies. Elm's Model-View-Update architecture for managing state and side effects. **Modular plugin architecture** for tools with defined interfaces allowing new tools to be added with less than 1 week development effort. JavaScript interop for file handling libraries where necessary, with comprehensive error handling and type validation at boundaries.

### Testing Requirements
Comprehensive testing strategy:
- **Unit tests for Elm functions**: Matching algorithms, data transformations, validation logic
- **Integration tests for JavaScript interop**: File parsing and CSV generation boundaries
- **Browser-based testing**: File upload/download workflows
- **Manual testing methods**: Wizard flow validation with predefined test cases
- **Elm Test framework**: Primary testing tool for pure Elm functions with high test coverage
- **Property-based testing**: Where applicable for data transformation functions to catch edge cases

### Additional Technical Assumptions and Requests

**Frontend Technology Stack:**
- **Elm Lang** for robust, type-safe client-side application development (non-negotiable from brief)
- **Modern CSS framework** evaluation needed (Tailwind CSS, Bootstrap, or Bulma) for professional UI components
- **Elm UI or elm-css** for component styling integration
- **JavaScript interop** via Elm ports for Excel file parsing (SheetJS/xlsx library)

**CSS and Styling Requirements:**
- **No inline styles**: All styling must be implemented in separate CSS files, no style attributes in HTML
- **CSS file organization**: Structured CSS architecture with logical file separation (components, layout, utilities)
- **Elm styling integration**: Use elm-css or CSS classes approach maintaining separation between HTML and styling
- **Maintainable CSS**: Clear class naming conventions and modular CSS structure

**File Processing Requirements:**
- **SheetJS/xlsx library** via JavaScript interop for Excel file parsing with robust error handling
- **CSV generation** using native Elm capabilities where possible
- **File API** for upload/download operations
- **Browser File API** constraints: 50MB/10,000 row limits for memory management

**Performance and Security:**
- **Content Security Policy** implementation preventing data exfiltration
- **No cookies or local storage** for user data - only session memory
- **GitHub Pages hosting** for static site deployment
- **HTTPS** provided by GitHub Pages infrastructure

**Development and Deployment:**
- **GitHub repository** for source code management and CI/CD
- **GitHub Pages deployment pipeline** (implemented in final epic)
- **Elm development environment** with hot reload for development efficiency
- **BMad Method agents** integration for AI-assisted development workflow
- **Context7 MCP server** for real-time documentation access during development

**Testing Infrastructure:**
- **Elm Test framework** for unit and integration testing
- **Test data sets**: Curated spreadsheet files covering edge cases (empty cells, special characters, large files)
- **Continuous testing**: Watch mode during development for immediate feedback
- **Coverage reporting**: Track test coverage to ensure comprehensive validation

## Epic List

**Epic 1: Foundation & Platform Infrastructure**  
Establish local development setup, Elm application shell, basic routing, and landing page with tool cards - delivering a functional platform that can be developed and tested locally.

**Epic 2: Data Extractor Tool**  
Complete end-to-end Data Extractor wizard workflow including file upload, field matching, preview, and CSV download - delivering the first functional data manipulation tool.

**Epic 3: Shared Components Refactoring**  
Extract reusable components and utilities from Data Extractor implementation, ensuring all existing tests pass while creating shared wizard framework, file handling, and UI components for use in Data Merger tool.

**Epic 4: Data Merger Tool**  
Implement Data Merger wizard workflow using refactored shared components, adding tilde prefix marking for deleted records - delivering the second core tool and completing MVP functionality.

**Epic 5: Quality Assurance & Polish**  
Comprehensive testing, performance optimization, error handling, and user experience refinements - delivering production-ready quality and reliability.

**Epic 6: Deployment and Hosting Setup**  
Implement GitHub Pages deployment pipeline, domain configuration, and production hosting setup - delivering the platform to users through a live, accessible URL.

## Epic 1: Foundation & Platform Infrastructure

**Epic Goal:** Establish complete local development foundation with Elm application, build tools, and landing page, delivering a functional platform that can be developed and tested locally while providing the base for all subsequent development.

### Story 1.1: Project Setup and Development Environment
As a developer,  
I want a complete Elm project setup with build tools and development workflow,  
so that I can efficiently develop and test the application.

#### Acceptance Criteria
1. Elm project initialized with elm.json configuration and folder structure
2. Package.json with build scripts for development and production
3. GitHub repository created with initial commit and branch protection
4. Development server with hot reload functionality working locally
5. Basic index.html template with required meta tags and CSP headers
6. Elm Test framework configured with example test

### Story 1.2: Basic Application Shell and Routing
As a user,  
I want to navigate between different sections of the platform,  
so that I can access tools and return to the homepage.

#### Acceptance Criteria
1. Elm application with Model-View-Update architecture established
2. URL-based routing implemented for homepage and tool pages
3. Navigation structure supports /home, /data-extractor, /data-merger routes
4. Browser back/forward buttons work correctly with routing
5. 404 handling for invalid routes returns user to homepage
6. Basic error boundary handling for application crashes

### Story 1.3: Landing Page with Tool Cards
As a user,  
I want to see available tools on the homepage,  
so that I can select and launch the tool I need.

#### Acceptance Criteria
1. Clean, professional landing page layout with platform branding
2. Two tool cards displayed: "Data Extractor" and "Data Merger"
3. Each card shows tool icon, title, brief description, and "Launch Tool" button
4. Cards use modern design (rounded corners, subtle shadows, hover effects)
5. Responsive grid layout adapts to different screen sizes
6. Privacy messaging prominently displayed explaining client-side processing
7. Cards navigate to respective tool pages when clicked

### Story 1.4: CSS Architecture and Base Styles
As a developer,  
I want organized CSS architecture with no inline styles,  
so that styling is maintainable and follows project requirements.

#### Acceptance Criteria
1. CSS files organized in logical structure (base, components, layout, utilities)
2. Zero inline styles in HTML - all styling in separate CSS files
3. CSS class naming convention established and documented
4. Base typography, colors, and spacing system defined
5. Card component styles implemented following modern design patterns
6. CSS framework integration (if selected) properly configured
7. CSS build process integrated with Elm compilation

### Story 1.5: Basic Error Handling and User Feedback
As a user,  
I want clear feedback when something goes wrong,  
so that I understand what happened and can take appropriate action.

#### Acceptance Criteria
1. Global error boundary catches and displays application errors gracefully
2. Loading states implemented for navigation and future async operations
3. User-friendly error messages replace technical error details
4. Network connectivity issues handled with appropriate messaging
5. Browser compatibility warnings for unsupported browsers
6. Error reporting structure established for development debugging

## Epic 2: Data Extractor Tool

**Epic Goal:** Deliver a complete, functional Data Extractor tool with 5-step wizard workflow that allows users to upload spreadsheets, configure matching criteria, preview results, select output fields, and download CSV extracts - providing the first valuable data manipulation capability for the platform.

### Story 2.1: File Upload Interface for Data Extractor
As a user,  
I want to upload master and data spreadsheets for extraction,  
so that I can provide the source data for matching operations.

#### Acceptance Criteria
1. Wizard step 1 displays dual file upload areas labeled "Master Spreadsheet" and "Data Spreadsheet"
2. Drag-and-drop functionality with visual feedback for file hover states
3. File format validation accepts .xlsx, .xls, and .csv files only
4. File size validation prevents uploads over 50MB with clear error message
5. Progress indicator shows wizard step 1 of 5 as active
6. "Next" button enabled only when both files successfully uploaded
7. Clear error messages for invalid file types or sizes
8. Privacy messaging visible: "Files processed locally - never uploaded to servers"

### Story 2.2: Configure Matching Criteria
As a user,  
I want to select multiple fields for matching between spreadsheets,  
so that I can create more precise matches using combinations of columns.

#### Acceptance Criteria
1. Wizard step 2 displays column headers from both uploaded spreadsheets
2. Multi-select interface allows selecting multiple fields from master spreadsheet for matching
3. Multi-select interface allows selecting multiple fields from data spreadsheet for matching
4. Selected fields display in order of selection with clear numbering (1st, 2nd, 3rd...)
5. Matching logic explanation: "Columns match by selection order - 1st selected master column matches 1st selected data column, etc."
6. Visual example shows matching pairs: "Master Col A (1st) ↔ Data Col C (1st), Master Col D (2nd) ↔ Data Col F (2nd)"
7. Reorder functionality allows changing selection order via drag-and-drop or up/down buttons
8. Remove individual selections without starting over
9. Must select at least one field from each spreadsheet to proceed
10. Fuzzy matching option applies to all selected text fields with explanation
11. Preview shows sample data from all selected fields for validation
12. Progress indicator shows step 2 of 5 as active

### Story 2.3: Preview Extraction Results
As a user,  
I want to see sample matches before selecting output fields,  
so that I can verify the matching logic and understand what data is available.

#### Acceptance Criteria
1. Wizard step 3 displays up to 3 sample matched records
2. Each sample shows master record with corresponding matched data record
3. Clear visual indication of which fields were used for matching
4. "No matches found" message if no records match with helpful suggestions
5. Match confidence or fuzzy match explanation displayed where applicable
6. "Re-configure" option to return to previous steps if matches look incorrect
7. All available fields from both spreadsheets visible in preview
8. Progress indicator shows step 3 of 5 as active

### Story 2.4: Select Output Fields
As a user,  
I want to choose which columns appear in my extracted results based on the preview,  
so that I get only the data I need in my output file.

#### Acceptance Criteria
1. Wizard step 4 shows all available columns from both spreadsheets
2. Checkbox interface allows selecting multiple fields for output
3. Selected fields visually distinguished (checked state, highlighting)
4. Default selection includes all fields from data spreadsheet
5. Field preview references sample data from previous step
6. "Select All" and "Clear All" buttons for convenient field management
7. At least one field must be selected to proceed
8. Progress indicator shows step 4 of 5 as active

### Story 2.5: CSV Download and Completion
As a user,  
I want to download my extracted results as a CSV file,  
so that I can use the matched data in other applications.

#### Acceptance Criteria
1. Wizard step 5 processes all matching records using configured criteria
2. Processing progress indicator shows real-time status for large files
3. CSV file generated with selected output fields only
4. Download initiated automatically when processing completes
5. Post-download guidance explaining CSV format and next steps
6. "Clear All Data" button removes uploaded files from browser memory
7. "Start Over" option returns to step 1 with clean state
8. Success message confirms number of records extracted and file size

### Story 2.6: Error Handling and Edge Cases
As a user,  
I want helpful guidance when problems occur,  
so that I can understand issues and complete my task successfully.

#### Acceptance Criteria
1. Corrupted or password-protected files display specific error messages
2. Empty spreadsheets handled gracefully with clear messaging
3. Large files show warning about potential browser memory limitations
4. Multi-sheet Excel files use first sheet with user notification
5. Special characters and encoding issues handled without crashes
6. No matches found scenario provides suggestions for different criteria
7. Browser memory errors caught and explained with file size guidance
8. All error states allow user to return to previous steps and retry

## Epic 3: Shared Components Refactoring

**Epic Goal:** Extract and generalize reusable components from the Data Extractor implementation, creating a robust shared framework for wizard workflows, file handling, matching algorithms, and UI components while maintaining all existing functionality and test coverage, enabling efficient implementation of Data Merger and future tools.

### Story 3.1: Extract Wizard Framework Components
As a developer,  
I want to refactor the wizard workflow into reusable components,  
so that Data Merger and future tools can use the same wizard structure.

#### Acceptance Criteria
1. Generic wizard component extracted with configurable number of steps
2. Progress indicator component accepts step count, current step, and step labels
3. Navigation component handles Previous/Next/Start Over with customizable validation
4. Step container component provides consistent layout and transitions
5. All Data Extractor wizard functionality remains unchanged
6. Existing Data Extractor tests pass without modification
7. New unit tests cover generic wizard components independently
8. Documentation explains wizard component API and usage patterns

### Story 3.2: Generalize File Upload Components
As a developer,  
I want reusable file upload components with configurable options,  
so that different tools can customize upload behavior while sharing core functionality.

#### Acceptance Criteria
1. File upload component extracted with configurable labels and validation rules
2. Drag-and-drop functionality abstracted into reusable module
3. File format validation configurable per tool instance
4. Progress indicators and error handling standardized across uploads
5. Dual upload interface supports variable number of upload areas
6. JavaScript interop for file parsing centralized with error boundaries
7. All existing file upload tests pass without modification
8. New tests verify component flexibility with different configurations

### Story 3.3: Create Shared Matching Logic Module
As a developer,  
I want to extract matching algorithms into a shared module,  
so that both tools can use the same fuzzy matching capabilities.

#### Acceptance Criteria
1. Matching logic extracted into pure Elm functions with clear interfaces
2. Multi-column matching with positional ordering fully abstracted
3. Fuzzy "includes" matching algorithm in separate testable function
4. Matching configuration type defined for different matching strategies
5. Performance optimizations applied for large dataset matching
6. Data Extractor continues using matching logic without changes
7. Property-based tests verify matching logic edge cases
8. Matching module documented with examples and performance notes

### Story 3.4: Standardize Data Preview Components
As a developer,  
I want reusable preview components for displaying sample data,  
so that consistent preview functionality can be used across tools.

#### Acceptance Criteria
1. Preview table component extracted with configurable columns and rows
2. Sample data selection logic abstracted (first N, random N, etc.)
3. Match highlighting component for showing matched fields
4. "No matches found" component with customizable help text
5. Preview loading states standardized across all preview displays
6. Data Extractor preview functionality unchanged after refactoring
7. Preview components tested with various data shapes and sizes
8. Component flexibility verified with different configurations

### Story 3.5: Centralize CSV Generation and Download
As a developer,  
I want shared CSV generation utilities,  
so that all tools can consistently create and download CSV files.

#### Acceptance Criteria
1. CSV generation module handles various data structures and encodings
2. Special character escaping and quoting rules properly implemented
3. Download triggering abstracted with configurable file names
4. Large file generation optimized for memory efficiency
5. Progress tracking for CSV generation standardized
6. Data Extractor CSV functionality continues working identically
7. Unit tests verify CSV format compliance and edge cases
8. Performance tests ensure large file handling within browser limits

### Story 3.6: Create Shared UI Components Library
As a developer,  
I want a library of common UI components following our design system,  
so that all tools maintain consistent visual appearance.

#### Acceptance Criteria
1. Card component extracted with consistent styling and hover effects
2. Button components standardized (primary, secondary, disabled states)
3. Checkbox and radio button components with consistent styling
4. Field selection components (multi-select, drag-to-reorder) abstracted
5. Loading spinners and progress bars standardized
6. Error message components with consistent styling and icons
7. All components follow no-inline-styles requirement with CSS classes
8. Component showcase page demonstrates all shared components

### Story 3.7: Refactoring Validation and Migration
As a developer,  
I want to ensure the refactoring maintains quality and functionality,  
so that users experience no regression in Data Extractor features.

#### Acceptance Criteria
1. All existing Data Extractor tests pass after refactoring
2. Test coverage remains at or above pre-refactoring levels
3. Performance benchmarks show no degradation in operation speed
4. Manual testing checklist completed for all user workflows
5. Code review confirms proper separation of concerns
6. Documentation updated to reflect new component architecture
7. Migration guide created for implementing new tools with shared components
8. Technical debt log updated with any remaining refactoring opportunities

## Epic 4: Data Merger Tool

**Epic Goal:** Implement the complete Data Merger tool leveraging refactored shared components from Epic 3, providing users with the ability to merge two spreadsheets with matching records updated, new records added, and deleted records marked with tilde prefix - completing the MVP's core functionality.

### Story 4.1: Data Merger Wizard Shell and Navigation
As a user,  
I want to launch the Data Merger tool from the homepage,  
so that I can access the merge functionality through a familiar wizard interface.

#### Acceptance Criteria
1. Data Merger card on homepage navigates to /data-merger route
2. Wizard framework from Epic 3 configured with 5 steps for merger workflow
3. Step labels: "Upload Files", "Configure Matching", "Preview Results", "Select Fields", "Download"
4. Navigation controls (Previous/Next/Start Over) connected to merger-specific logic
5. Progress indicator shows current position in 5-step workflow
6. Privacy messaging displayed: "All merging happens in your browser"
7. Wizard state management handles merger-specific data structures
8. URL updates to reflect current wizard step for browser back/forward support

### Story 4.2: File Upload for Merger (Spreadsheets A & B)
As a user,  
I want to upload two spreadsheets for merging,  
so that I can combine data from different sources.

#### Acceptance Criteria
1. Reused file upload component configured with labels "Spreadsheet A" and "Spreadsheet B"
2. Clear explanations: "Spreadsheet A: Primary data" and "Spreadsheet B: Updates/changes"
3. Same file format support (.xlsx, .xls, .csv) and size limits (50MB)
4. File parsing via shared JavaScript interop from Epic 3
5. Both files required before proceeding to next step
6. Upload state preserved when navigating back from later steps
7. Error handling for incompatible or corrupted files
8. Progress indicator shows step 1 of 5 as active

### Story 4.3: Configure Merge Matching Criteria
As a user,  
I want to specify how records should be matched between spreadsheets,  
so that the system correctly identifies which records to merge.

#### Acceptance Criteria
1. Reused matching configuration interface from shared components
2. Multi-column selection with positional ordering for both spreadsheets
3. Visual matching pairs display: "A Col 1 ↔ B Col 1" with clear relationships
4. Shared fuzzy matching logic applied with "includes" option
5. Explanation of merge behavior: "Matched records will be updated, unmatched from A added as new, unmatched from B marked with ~"
6. Sample data preview from selected matching columns
7. At least one matching column required from each spreadsheet
8. Progress indicator shows step 2 of 5 as active

### Story 4.4: Preview Merge Results
As a user,  
I want to see sample merged records before finalizing,  
so that I understand how the merge will affect my data.

#### Acceptance Criteria
1. Reused preview component showing up to 3 sample results
2. Three categories displayed: "Updated Records", "New Records", "Deleted Records"
3. Updated records show original and merged values side-by-side
4. New records (from A not in B) highlighted as additions
5. Deleted records (from B not in A) show with tilde prefix example
6. Clear explanation of tilde prefix: "Records marked with ~ were in Spreadsheet B but not found in A"
7. "Re-configure" option returns to matching configuration if needed
8. Progress indicator shows step 3 of 5 as active

### Story 4.5: Select Output Fields for Merged Data
As a user,  
I want to choose which columns to include in the merged output,  
so that I can control the structure of my final dataset.

#### Acceptance Criteria
1. Reused field selection component showing all available columns
2. Columns from both spreadsheets available for selection
3. Clear indication of column source (A or B) when names conflict
4. Default selection includes all columns from Spreadsheet A
5. For matched records, ability to choose whether to use A or B values
6. "Select All" and "Clear All" functionality from shared components
7. At least one field must be selected to proceed
8. Progress indicator shows step 4 of 5 as active

### Story 4.6: Process Merge and Generate CSV Output
As a user,  
I want to download the merged results with appropriate markings,  
so that I can use the combined data and identify changes.

#### Acceptance Criteria
1. Full merge processing using shared matching logic from Epic 3
2. Progress indicator for processing large files
3. Tilde prefix ("~") added to first cell of deleted records
4. CSV generation using shared utilities with proper escaping
5. Automatic download initiated when processing completes
6. Post-download instructions displayed: "Filter by ~* to see deleted records"
7. Success message shows counts: "X records updated, Y added, Z marked as deleted"
8. "Clear All Data" button removes files from browser memory
9. Progress indicator shows step 5 of 5 as complete

### Story 4.7: Data Merger Edge Cases and Validation
As a user,  
I want the merger to handle special cases gracefully,  
so that I can complete my task even with imperfect data.

#### Acceptance Criteria
1. Empty spreadsheets handled with appropriate messaging
2. Spreadsheets with no matches produce valid output (all new/deleted)
3. Duplicate matches handled consistently with clear user notification
4. Column name conflicts resolved with source indicators (A: or B:)
5. Special characters in data preserved without breaking CSV format
6. Large file processing maintains browser stability
7. Multi-sheet Excel files use first sheet with notification
8. All error states allow recovery without losing configuration

## Epic 5: Quality Assurance & Polish

**Epic Goal:** Ensure production-ready quality across the entire platform through comprehensive testing, performance optimization, security validation, and user experience refinements - delivering a polished, reliable product that users can trust with their sensitive data.

### Story 5.1: End-to-End Testing Suite
As a developer,  
I want comprehensive end-to-end tests for both tools,  
so that we can verify complete user workflows function correctly.

#### Acceptance Criteria
1. E2E test framework configured for browser-based testing (Cypress or similar)
2. Complete Data Extractor workflow tested from upload to download
3. Complete Data Merger workflow tested from upload to download
4. File upload tests include various formats (.xlsx, .xls, .csv) and sizes
5. Matching logic tests verify fuzzy matching and multi-column matching
6. CSV download tests verify file format and content correctness
7. Navigation tests verify wizard Previous/Next/Start Over functionality
8. Tests run automatically in CI/CD pipeline before deployment

### Story 5.2: Performance Optimization and Testing
As a developer,  
I want to optimize performance for large files,  
so that users can process maximum file sizes without browser crashes.

#### Acceptance Criteria
1. Performance benchmarks established for 10MB, 25MB, and 50MB files
2. Memory profiling identifies and fixes memory leaks
3. Matching algorithm optimized for O(n*m) or better complexity
4. CSV generation streams data to prevent memory spikes
5. Progress indicators accurately reflect processing time
6. Browser memory warnings displayed before critical thresholds
7. Performance regression tests prevent future degradation
8. Documentation includes performance characteristics and limits

### Story 5.3: Security and Privacy Validation
As a security-conscious user,  
I want assurance that my data never leaves my browser,  
so that I can trust the platform with sensitive information.

#### Acceptance Criteria
1. Content Security Policy headers prevent external data transmission
2. Network monitoring tests verify zero external API calls during processing
3. Browser developer tools documentation shows how users can verify privacy
4. No data persisted in localStorage, sessionStorage, or cookies
5. Memory clearing verified to remove all traces of user data
6. Security audit identifies and addresses any vulnerabilities
7. Privacy policy page clearly explains client-side only processing
8. Third-party security review or certification considered

### Story 5.4: Cross-Browser Compatibility Testing
As a user,  
I want the platform to work consistently across browsers,  
so that I can use my preferred browser without issues.

#### Acceptance Criteria
1. Full functionality tested on Chrome, Firefox, Safari, Edge (latest 2 versions)
2. File upload/download works consistently across all browsers
3. CSS renders correctly without browser-specific issues
4. JavaScript interop functions identically across browsers
5. Performance characteristics documented per browser
6. Browser-specific bugs fixed or documented with workarounds
7. Unsupported browser detection with helpful messaging
8. Mobile browser testing confirms basic functionality (view-only acceptable)

### Story 5.5: Error Recovery and User Guidance
As a user,  
I want helpful error messages and recovery options,  
so that I can complete my task even when problems occur.

#### Acceptance Criteria
1. All error messages rewritten in user-friendly language
2. Each error includes specific recovery steps or suggestions
3. File format errors explain supported formats and how to convert
4. Matching errors suggest alternative matching strategies
5. Memory errors provide file size reduction guidance
6. Network errors (for initial load) have retry mechanisms
7. FAQ or troubleshooting guide created for common issues
8. Contact or feedback mechanism established for unresolved issues

### Story 5.6: Documentation and User Help
As a user,  
I want clear documentation and examples,  
so that I can quickly learn how to use the platform effectively.

#### Acceptance Criteria
1. Quick start guide created with screenshots for each tool
2. Sample spreadsheet files provided for testing/learning
3. Video tutorials considered for complex workflows
4. Tooltip help added to complex interface elements
5. Glossary explains terms like "fuzzy matching" and "tilde prefix"
6. Use case examples show real-world applications
7. Technical documentation explains privacy architecture
8. Documentation accessible from platform header/footer

### Story 5.7: Final Polish and Launch Preparation
As a product owner,  
I want final refinements and launch readiness,  
so that we can confidently release the MVP to users.

#### Acceptance Criteria
1. UI/UX review identifies and fixes any usability issues
2. Loading time optimized to under 3 seconds on average connection
3. Analytics or feedback mechanism implemented (privacy-respecting)
4. Error tracking configured for production debugging
5. Production build configuration prepared for deployment
6. SEO meta tags and descriptions configured appropriately
7. Launch checklist completed covering all critical items
8. Rollback plan established in case of critical issues

## Epic 6: Deployment and Hosting Setup

**Epic Goal:** Implement complete deployment pipeline and hosting infrastructure to deliver the production-ready platform to users through GitHub Pages, establishing automated build processes, domain configuration, and production monitoring - making the platform publicly accessible and maintainable.

### Story 6.1: GitHub Pages Deployment Pipeline
As a product owner,  
I want automated deployment to GitHub Pages,  
so that the platform is accessible to users and stakeholders.

#### Acceptance Criteria
1. GitHub Actions workflow builds Elm application on commit to main
2. Built application automatically deploys to GitHub Pages
3. Custom domain configuration (if applicable) or github.io URL accessible
4. HTTPS enabled through GitHub Pages
5. Build failures prevent deployment and notify via GitHub
6. Deployment status visible in repository README
7. Production build optimization for performance and file size
8. Cache headers configured for static assets

### Story 6.2: Production Configuration and Optimization
As a user,
I want the platform to load quickly and perform well in production,
so that I can efficiently complete my spreadsheet tasks.

#### Acceptance Criteria
1. Production build minifies and optimizes Elm application
2. Static assets compressed and cached appropriately
3. Content Security Policy headers configured for production
4. GitHub Pages custom domain configuration (if applicable)
5. Error tracking and monitoring configured for production issues
6. Performance benchmarks established and monitored
7. SEO meta tags and Open Graph tags configured
8. Favicon and app icons configured

### Story 6.3: Production Monitoring and Maintenance
As a product owner,
I want visibility into platform usage and errors,
so that I can maintain quality and plan improvements.

#### Acceptance Criteria
1. Privacy-respecting analytics configured (no user data collection)
2. Error monitoring dashboard for tracking production issues
3. Performance monitoring for key user workflows
4. Uptime monitoring for GitHub Pages availability
5. Documentation for production troubleshooting and maintenance
6. Backup and recovery procedures documented
7. Rollback procedures tested and documented
8. Production health checks and status page consideration

## Checklist Results Report

### Executive Summary
- **Overall PRD Completeness:** 92%
- **MVP Scope Appropriateness:** Just Right
- **Readiness for Architecture Phase:** Ready
- **Critical Strengths:** Clear problem definition, well-structured epics with refactoring approach, comprehensive technical assumptions, excellent privacy-first requirements

### Category Analysis Table

| Category                         | Status  | Critical Issues |
| -------------------------------- | ------- | --------------- |
| 1. Problem Definition & Context  | PASS    | None |
| 2. MVP Scope Definition          | PASS    | None |
| 3. User Experience Requirements  | PASS    | None |
| 4. Functional Requirements       | PASS    | None |
| 5. Non-Functional Requirements   | PASS    | None |
| 6. Epic & Story Structure        | PASS    | None |
| 7. Technical Guidance            | PASS    | None |
| 8. Cross-Functional Requirements | PARTIAL | Data entity relationships not fully specified |
| 9. Clarity & Communication       | PASS    | None |

### Top Issues by Priority

**BLOCKERS:** None

**HIGH:** None

**MEDIUM:**
- Data entity relationships and schema structure not explicitly defined (will need architect attention)

**LOW:**
- Consider adding more specific performance benchmarks for matching algorithms
- Sample test data specifications could be more detailed

### MVP Scope Assessment
- **Scope is appropriate:** Two tools with shared refactoring epic demonstrates excellent planning
- **Strong architectural decision:** Epic 3 refactoring prevents technical debt
- **Timeline realistic:** 3-month timeline achievable with focused scope
- **Privacy-first approach:** Clear differentiator and well-executed throughout

### Technical Readiness
- **Clear technical constraints:** Elm-only, client-side processing, GitHub Pages
- **Testing requirements:** Comprehensive testing strategy ensures quality
- **Identified risks:** Browser memory limitations, Elm library ecosystem
- **Architecture needs:** Data structure design for spreadsheet processing

### Recommendations
1. **Immediate Actions:** None required - PRD is ready for architect
2. **For Architect Phase:** Focus on data entity modeling for spreadsheet structures
3. **Consider documenting:** Specific matching algorithm complexity targets
4. **Future enhancement:** Add performance profiling requirements for large datasets

### Final Decision
**READY FOR ARCHITECT**: The PRD and epics are comprehensive, properly structured, and ready for architectural design.

## Next Steps

### UX Expert Prompt
Review this PRD and create comprehensive UI/UX designs for the Spreadsheet Data Platform, focusing on the 5-step wizard workflows for both Data Extractor and Data Merger tools. Emphasize modern card-based landing page, clear progress indicators, and intuitive field selection interfaces.

### Architect Prompt
Using this PRD, create a detailed technical architecture for the Spreadsheet Data Platform with Elm-based client-side implementation, modular tool architecture, JavaScript interop for file handling, comprehensive testing strategy, and GitHub Pages deployment strategy.

## Current Implementation Status

### HTML Prototype Assessment

A basic HTML prototype exists in the `/prototype` directory demonstrating the landing page concept and visual design direction.

