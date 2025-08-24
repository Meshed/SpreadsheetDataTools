# Epic 3: Shared Components Refactoring

**Epic Goal:** Extract and generalize reusable components from the Data Extractor implementation, creating a robust shared framework for wizard workflows, file handling, matching algorithms, and UI components while maintaining all existing functionality and test coverage, enabling efficient implementation of Data Merger and future tools.

## Story 3.1: Extract Wizard Framework Components
As a developer,  
I want to refactor the wizard workflow into reusable components,  
so that Data Merger and future tools can use the same wizard structure.

### Acceptance Criteria
1. Generic wizard component extracted with configurable number of steps
2. Progress indicator component accepts step count, current step, and step labels
3. Navigation component handles Previous/Next/Start Over with customizable validation
4. Step container component provides consistent layout and transitions
5. All Data Extractor wizard functionality remains unchanged
6. Existing Data Extractor tests pass without modification
7. New unit tests cover generic wizard components independently
8. Documentation explains wizard component API and usage patterns

## Story 3.2: Generalize File Upload Components
As a developer,  
I want reusable file upload components with configurable options,  
so that different tools can customize upload behavior while sharing core functionality.

### Acceptance Criteria
1. File upload component extracted with configurable labels and validation rules
2. Drag-and-drop functionality abstracted into reusable module
3. File format validation configurable per tool instance
4. Progress indicators and error handling standardized across uploads
5. Dual upload interface supports variable number of upload areas
6. JavaScript interop for file parsing centralized with error boundaries
7. All existing file upload tests pass without modification
8. New tests verify component flexibility with different configurations

## Story 3.3: Create Shared Matching Logic Module
As a developer,  
I want to extract matching algorithms into a shared module,  
so that both tools can use the same fuzzy matching capabilities.

### Acceptance Criteria
1. Matching logic extracted into pure Elm functions with clear interfaces
2. Multi-column matching with positional ordering fully abstracted
3. Fuzzy "includes" matching algorithm in separate testable function
4. Matching configuration type defined for different matching strategies
5. Performance optimizations applied for large dataset matching
6. Data Extractor continues using matching logic without changes
7. Property-based tests verify matching logic edge cases
8. Matching module documented with examples and performance notes

## Story 3.4: Standardize Data Preview Components
As a developer,  
I want reusable preview components for displaying sample data,  
so that consistent preview functionality can be used across tools.

### Acceptance Criteria
1. Preview table component extracted with configurable columns and rows
2. Sample data selection logic abstracted (first N, random N, etc.)
3. Match highlighting component for showing matched fields
4. "No matches found" component with customizable help text
5. Preview loading states standardized across all preview displays
6. Data Extractor preview functionality unchanged after refactoring
7. Preview components tested with various data shapes and sizes
8. Component flexibility verified with different configurations

## Story 3.5: Centralize CSV Generation and Download
As a developer,  
I want shared CSV generation utilities,  
so that all tools can consistently create and download CSV files.

### Acceptance Criteria
1. CSV generation module handles various data structures and encodings
2. Special character escaping and quoting rules properly implemented
3. Download triggering abstracted with configurable file names
4. Large file generation optimized for memory efficiency
5. Progress tracking for CSV generation standardized
6. Data Extractor CSV functionality continues working identically
7. Unit tests verify CSV format compliance and edge cases
8. Performance tests ensure large file handling within browser limits

## Story 3.6: Create Shared UI Components Library
As a developer,  
I want a library of common UI components following our design system,  
so that all tools maintain consistent visual appearance.

### Acceptance Criteria
1. Card component extracted with consistent styling and hover effects
2. Button components standardized (primary, secondary, disabled states)
3. Checkbox and radio button components with consistent styling
4. Field selection components (multi-select, drag-to-reorder) abstracted
5. Loading spinners and progress bars standardized
6. Error message components with consistent styling and icons
7. All components follow no-inline-styles requirement with CSS classes
8. Component showcase page demonstrates all shared components

## Story 3.7: Refactoring Validation and Migration
As a developer,  
I want to ensure the refactoring maintains quality and functionality,  
so that users experience no regression in Data Extractor features.

### Acceptance Criteria
1. All existing Data Extractor tests pass after refactoring
2. Test coverage remains at or above pre-refactoring levels
3. Performance benchmarks show no degradation in operation speed
4. Manual testing checklist completed for all user workflows
5. Code review confirms proper separation of concerns
6. Documentation updated to reflect new component architecture
7. Migration guide created for implementing new tools with shared components
8. Technical debt log updated with any remaining refactoring opportunities
