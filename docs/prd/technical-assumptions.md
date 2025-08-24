# Technical Assumptions

## Repository Structure: Monorepo
Single repository containing platform shell and individual tool modules with clear separation between platform core and tool implementations. Shared utilities for common operations (file parsing, matching algorithms, CSV generation). BMad Method integration for AI-assisted development with specialized agents.

## Service Architecture
**Client-side only architecture** with no server dependencies. Elm's Model-View-Update architecture for managing state and side effects. **Modular plugin architecture** for tools with defined interfaces allowing new tools to be added with less than 1 week development effort. JavaScript interop for file handling libraries where necessary, with comprehensive error handling and type validation at boundaries.

## Testing Requirements
Comprehensive testing strategy:
- **Unit tests for Elm functions**: Matching algorithms, data transformations, validation logic
- **Integration tests for JavaScript interop**: File parsing and CSV generation boundaries
- **Browser-based testing**: File upload/download workflows
- **Manual testing methods**: Wizard flow validation with predefined test cases
- **Elm Test framework**: Primary testing tool for pure Elm functions with high test coverage
- **Property-based testing**: Where applicable for data transformation functions to catch edge cases

## Additional Technical Assumptions and Requests

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
