# Project Brief: Spreadsheet Data Platform

## Executive Summary

**Product Concept:** Spreadsheet Data Platform (SDP) is a privacy-focused, extensible web platform providing specialized tools for comparing, extracting, and merging data between spreadsheets without storing any user data, designed to grow with evolving data manipulation needs.

**Primary Problem:** Users frequently need to perform complex operations between two spreadsheets - extracting matching records, merging updates while preserving modifications, or comparing datasets - but existing solutions either require technical expertise, store sensitive data, or lack flexible matching capabilities like fuzzy name matching.

**Target Market:** Any professional who regularly works with spreadsheet data comparisons and transformations - including administrators, data analysts, researchers, educators, and business professionals handling sensitive or confidential information.

**Key Value Proposition:** A zero-storage, privacy-first solution that enables sophisticated spreadsheet operations through an intuitive visual interface, supporting flexible matching criteria (including fuzzy matching) while ensuring complete data privacy with no server-side storage, built on an extensible architecture that allows for adding new tools as needs emerge.

## Problem Statement

**Current State and Pain Points:**
Professionals across various industries regularly receive multiple spreadsheets that need to be compared, combined, or filtered against each other. Currently, they must either manually cross-reference records (extremely time-consuming and error-prone), use complex formulas like VLOOKUP (requires technical knowledge and exact matching), or upload data to online tools that store their potentially sensitive information. The matching process is particularly challenging when dealing with inconsistent data entry - names with different punctuation, titles, or formatting that should match but don't with exact-match methods.

**Impact of the Problem:**
- Manual processing of even moderate-sized spreadsheets (100+ records) can take hours of tedious work
- Data privacy concerns prevent many organizations from using existing cloud-based solutions
- Inconsistent name formatting leads to missed matches, resulting in incomplete data extraction or incorrect merge operations
- Lack of visual feedback during the matching process leads to errors that aren't discovered until after processing

**Why Existing Solutions Fall Short:**
- Desktop spreadsheet applications require advanced formula knowledge and don't handle fuzzy matching well
- Cloud-based tools store user data, creating privacy and compliance risks
- Most solutions are either too technical for average users or too simplistic for complex matching needs
- Existing tools typically focus on single operations rather than providing a suite of related capabilities

**Urgency and Importance:**
As data-driven decision making becomes standard across all industries, the volume of spreadsheet-based data exchange continues to grow. Organizations need immediate solutions that respect data privacy while providing powerful, accessible tools for non-technical users. The modular approach also allows the platform to evolve with emerging needs without requiring complete rebuilds.

## Proposed Solution

**Core Concept and Approach:**
Spreadsheet Data Platform is a browser-based platform that processes all data client-side, ensuring zero server storage while providing powerful spreadsheet manipulation capabilities. The platform presents tools through an intuitive card/tile interface, where each tool guides users through a visual workflow: upload spreadsheets, visually select matching fields, preview results with up to 3 sample matches, choose output fields, and generate downloadable results. The architecture supports pluggable tool modules, allowing new spreadsheet operations to be added without disrupting existing functionality.

**Key Differentiators:**
- **Complete Privacy by Design:** All processing happens in the user's browser - files never leave their machine, addressing the critical trust barrier for sensitive data
- **Intelligent Fuzzy Matching:** Built-in "includes" matching logic handles real-world data inconsistencies (e.g., "Mark" matches "Mr. Mark" and "Mark S.")
- **Visual Workflow Interface:** Drag-and-drop field selection and live preview of matches removes the technical barrier, making complex operations accessible to all users
- **Modular Tool Architecture:** Each tool is self-contained, allowing the platform to grow organically as new use cases emerge

**Why This Solution Will Succeed:**
Unlike existing solutions that force users to choose between privacy and functionality, SDP delivers both through client-side processing. The visual interface eliminates the learning curve of spreadsheet formulas while the fuzzy matching capability solves the persistent problem of inconsistent data entry. The modular design ensures the platform can adapt to emerging needs without requiring users to learn entirely new systems.

**High-level Vision:**
Spreadsheet Data Platform becomes the trusted hub for privacy-conscious data manipulation, starting with extraction and merging but expanding to address the full spectrum of dual-spreadsheet operations. The platform establishes a new standard for how sensitive data tools should operate - powerful, accessible, and absolutely private.

## Target Users

### Primary User Segment: Data-Handling Professionals

**Demographic/Firmographic Profile:**
- Mid-level professionals in organizations of all sizes (SMB to Enterprise)
- Age 25-55, comfortable with basic spreadsheet operations but not necessarily technical
- Roles include: Administrative assistants, HR coordinators, education administrators, research assistants, business analysts, operations managers
- Industries: Education, Healthcare, Government, Non-profits, Professional Services, Research institutions

**Current Behaviors and Workflows:**
- Regularly receive spreadsheets from multiple sources (vendors, departments, external partners)
- Spend 2-10 hours weekly on spreadsheet comparison and consolidation tasks
- Currently use manual methods or basic Excel formulas for data matching
- Often work with sensitive data (personal information, financial data, proprietary information)
- Export results to CSV for compatibility across systems

**Specific Needs and Pain Points:**
- Need to match records between spreadsheets with inconsistent formatting
- Require absolute privacy for sensitive data that cannot be uploaded to cloud services
- Frustrated by exact-match limitations when names/entries have slight variations
- Need visual confirmation that matches are correct before processing
- Lack time or inclination to learn complex spreadsheet formulas

**Goals They're Trying to Achieve:**
- Quickly extract relevant records from large datasets
- Maintain data integrity while merging updates from multiple sources
- Ensure compliance with data privacy regulations
- Reduce manual effort and human error in data processing
- Create clean, consolidated reports for decision-making

### Secondary User Segment: Technical Data Professionals

**Demographic/Firmographic Profile:**
- Data analysts, IT professionals, and developers who need quick spreadsheet operations
- Appreciate privacy-first tools for client data or when working with sensitive information
- May build workflows that incorporate SDP as one step in larger processes

**Current Behaviors and Workflows:**
- Use various tools including SQL, Python/R, and advanced Excel
- Often asked to help non-technical colleagues with "simple" spreadsheet tasks
- Value tools they can recommend to less technical team members

**Specific Needs and Pain Points:**
- Need reliable tools to recommend to non-technical colleagues
- Want to avoid writing custom scripts for one-off data operations
- Require tools that respect data privacy for client work

**Goals They're Trying to Achieve:**
- Streamline repetitive data tasks without coding
- Enable self-service for non-technical team members
- Maintain data privacy standards across all tools used

## Goals & Success Metrics

### Business Objectives

- **Launch MVP with 2 core tools within 3 months:** Data Extractor and Data Merger fully functional with intuitive UI
- **Achieve 95% client-side processing reliability:** All data operations complete successfully without server dependencies for files up to 50MB/10,000 rows
- **Establish trust through privacy guarantee:** 100% of data processing occurs in-browser with zero server transmission, verifiable through network monitoring
- **Enable non-technical user adoption:** 80% of users can complete their first data operation without documentation or support
- **Build extensible architecture:** New tools can be added with less than 1 week of development effort per tool

### User Success Metrics

- **Time to first successful operation:** Users complete their first extraction or merge within 5 minutes of landing on the platform
- **Data matching accuracy:** Fuzzy matching correctly identifies 90% of intended matches with inconsistent formatting
- **Error reduction:** 75% reduction in data processing errors compared to manual methods
- **Task completion time:** 80% reduction in time spent on spreadsheet comparison tasks (from hours to minutes)
- **User confidence score:** 90% of users report feeling confident their data remained private throughout the process

### Key Performance Indicators (KPIs)

- **Monthly Active Users (MAU):** 500 users within 3 months, 2,000 within 6 months
- **Tool Usage Rate:** Average of 3+ operations per user per month
- **Completion Rate:** 85% of started operations are successfully completed
- **Return User Rate:** 60% of users return within 30 days of first use
- **Platform Growth:** 1 new tool added every quarter after MVP based on user feedback
- **File Processing Volume:** Successfully process 10,000+ spreadsheet operations per month by month 6
- **User Satisfaction (NPS):** Net Promoter Score of 40+ within first 6 months

## MVP Scope

### Core Features (Must Have)

- **Platform Landing Page:** Clean, professional homepage displaying platform name, brief description, and tool cards/tiles showing tool name, icon, and description
- **Data Extractor Tool:** Complete workflow for extracting matching records from a data spreadsheet based on a master spreadsheet
  - Dual file upload interface (master and data spreadsheets)
  - Visual column display showing all fields from both spreadsheets
  - Field selection UI for choosing matching criteria
  - Fuzzy matching support with "includes" logic for names/text fields
  - Preview display showing up to 3 matched records for validation
  - Output field selection interface
  - CSV file generation and download of extracted results
- **Data Merger Tool:** Complete workflow for merging and updating records between two spreadsheets
  - Dual file upload interface (Spreadsheet A and B)
  - Visual column display for both spreadsheets
  - Field matching selection interface
  - Preview of up to 3 combined records
  - Output field selection
  - Tilde prefix ("~") for records in B not found in A, allowing easy filtering and identification in Excel
  - Clear UI messaging explaining tilde prefix meaning before download: "Records not found in Spreadsheet A will be marked with '~' at the beginning of the row for easy identification and filtering in Excel"
  - Addition of new records from A not in B
  - CSV output file generation and download with post-download user guidance
- **Client-Side Processing:** All data operations performed entirely in browser with zero server transmission
- **File Format Support:** Accept .xlsx, .xls, and .csv input files; generate CSV output files
- **Visual Feedback:** Clear progress indicators and confirmation messages throughout workflows
- **Privacy Assurance:** Visible messaging confirming no data leaves the browser
- **User Guidance for Tilde Prefix:** Post-download instructions explaining how to work with tilde-prefixed records in Excel:
  - "To view only deleted records: Filter column by '~*'"
  - "To hide deleted records: Filter column by '<>~*'"
  - "To remove tilde markers: Find and replace '~' with nothing"
- **Manual Data Purge:** Explicit "Clear All Data" button that immediately removes all loaded spreadsheet data from browser memory, providing users with control and peace of mind

### Out of Scope for MVP

The following items are not included in the MVP and there are no current plans to implement them:
- User accounts or authentication
- Saving/loading of operation templates or preferences
- Batch processing of multiple file pairs
- Advanced matching algorithms beyond "includes" fuzzy matching
- Excel (.xlsx) output formats - CSV-only for MVP
- File size handling beyond 50MB/10,000 rows
- Undo/redo functionality
- Collaborative features or sharing
- API or programmatic access
- Mobile-optimized interface (desktop-first approach)
- Additional tools beyond Data Extractor and Data Merger (though the architecture will support adding new tools as needs arise)

### MVP Success Criteria

The MVP will be considered successful when:
- Both Data Extractor and Data Merger tools complete end-to-end workflows without errors for 95% of test cases
- Processing occurs entirely client-side with zero data transmitted to servers (verifiable via browser dev tools)
- Non-technical users can complete their first operation within 5 minutes without external help
- The platform correctly handles common data inconsistencies (extra spaces, punctuation, titles) in matching
- Generated CSV files open correctly in Excel, Google Sheets, and LibreOffice
- Users understand tilde prefix meaning and can successfully filter/manage marked records in Excel
- The architecture supports adding a third tool without modifying existing tool code

## Post-MVP Vision

### Phase 2 Features

Based on user feedback and usage patterns from the MVP, potential next features might include:
- **Additional Spreadsheet Tools:** New tools addressing other dual-spreadsheet operations as specific needs are identified through user requests
- **Enhanced Output Formats:** Excel (.xlsx) file generation with native formatting support (strikethrough, colors, etc.)
- **Enhanced Matching Algorithms:** More sophisticated fuzzy matching options if users encounter limitations with the "includes" approach
- **Performance Optimizations:** Handling larger files if user needs exceed the 50MB/10,000 row threshold
- **UI/UX Refinements:** Interface improvements based on observed user behavior and feedback
- **Example Data Templates:** Sample spreadsheets demonstrating common use cases to help new users understand the tools

### Long-term Vision

Over the next 1-2 years, Spreadsheet Data Platform could evolve to:
- **Become the Standard for Privacy-First Data Tools:** Establish SDP as the go-to solution when data privacy is paramount
- **Expand Tool Portfolio:** Grow from 2 to 5-10 specialized tools based on real user needs and requests
- **Industry-Specific Solutions:** Develop targeted workflows for high-usage industries (education, healthcare, government)
- **Enterprise Adoption:** Scale to support larger organizations with more complex data workflows
- **Community-Driven Development:** Let user needs and feedback drive which new tools get developed

### Expansion Opportunities

Potential areas for platform growth based on market demand:
- **Multi-Spreadsheet Operations:** Tools that work with 3+ spreadsheets simultaneously
- **Data Validation Tools:** Checking data consistency and quality across spreadsheets
- **Format Conversion Tools:** Beyond CSV to other specialized formats if needed
- **Reporting Tools:** Generate summary reports from spreadsheet comparisons
- **Workflow Automation:** Chaining multiple tools together for complex operations

*Note: All expansion decisions will be driven by actual user needs and feedback rather than speculative feature development.*

## Technical Considerations

### Platform Requirements

- **Target Platforms:** Modern web browsers (Chrome, Firefox, Safari, Edge - latest 2 versions)
- **Browser/OS Support:** Desktop browsers on Windows, macOS, and Linux
- **Performance Requirements:** 
  - Process files up to 50MB/10,000 rows within 30 seconds
  - Smooth UI interactions with no perceptible lag
  - Instant preview generation for matched records

### Technology Preferences

- **Frontend:** Elm Lang for robust, type-safe client-side application development
- **Backend:** None - purely client-side application
- **Database:** None required - all processing is client-side with no persistence
- **Hosting/Infrastructure:** GitHub Pages for static site hosting
- **UI Components:** Explore and evaluate Elm-compatible UI libraries and component systems (e.g., Elm UI, elm-css, Material Design components for Elm) as well as CSS frameworks, libraries, and components (e.g., Tailwind CSS, Bootstrap, Bulma) to achieve modern, high-quality visual design with professional controls and widgets

### Architecture Considerations

- **Repository Structure:** 
  - Monorepo containing platform shell and individual tool modules
  - Clear separation between platform core and tool implementations
  - Shared utilities for common operations (file parsing, matching algorithms, CSV generation)
  - BMad Method integration for AI-assisted development with specialized agents
  - Context7 MCP server for real-time documentation access during development
  
- **Service Architecture:**
  - Client-side only architecture with no server dependencies
  - Elm's architecture for managing state and side effects
  - Modular plugin architecture for tools with defined interfaces
  - JavaScript interop for file handling libraries where necessary, with comprehensive error handling and type validation at boundaries
  
- **Integration Requirements:**
  - File API for spreadsheet upload and processing
  - JavaScript libraries for Excel file parsing (e.g., SheetJS/xlsx) via Elm ports with robust error handling
  - CSV generation and download capabilities
  - No external API integrations required
  
- **Security/Compliance:**
  - Content Security Policy to prevent data exfiltration
  - No cookies or local storage of user data
  - Clear privacy policy stating zero data collection
  - HTTPS provided by GitHub Pages

## Constraints & Assumptions

### Constraints

- **Budget:** Development effort constrained to available time and resources - no external development budget
- **Timeline:** MVP target of 3 months with part-time development effort
- **Resources:** Solo developer or small team with Elm expertise required
- **Technical:** 
  - Limited to browser capabilities for file processing
  - GitHub Pages hosting limits (1GB repository size, 100GB monthly bandwidth)
  - Client-side processing constraints for very large files
  - Must work within Elm's pure functional paradigm

### Key Assumptions

- Users have modern browsers with JavaScript enabled
- Target file sizes (up to 50MB/10,000 rows) cover the majority of use cases
- Users trust client-side privacy claims when properly communicated
- CSV output format is acceptable for MVP users
- Fuzzy "includes" matching is sufficient for most name-matching scenarios
- Users have stable internet connection for initial page load (though processing works offline)
- The Elm ecosystem provides sufficient libraries for spreadsheet processing needs
- GitHub Pages provides adequate performance and reliability for hosting
- Users are comfortable with a desktop-first interface
- Data privacy concerns outweigh the convenience of cloud storage for target users

## Risks & Open Questions

### Key Risks

- **Browser Memory Limitations:** Large files (approaching 50MB) might cause browser memory issues on older devices or with multiple tabs open
- **Elm Library Ecosystem:** Limited availability of Elm-specific libraries for spreadsheet processing may require JavaScript interop; while minimizing interop is preferred, usability takes priority. Any JavaScript interop must include robust exception handling to preserve Elm's type-safety benefits and application integrity
- **User Trust in Privacy Claims:** Users may be skeptical that data truly stays client-side without technical proof or third-party validation
- **CSV Format Limitations:** Tilde prefix approach for deleted records requires stakeholder training but provides clear filtering capability
- **Performance with Complex Matching:** Fuzzy matching on large datasets could be slow without optimization
- **Browser Compatibility:** File API implementations may vary across browsers, potentially causing inconsistent behavior
- **GitHub Pages Downtime:** Dependency on GitHub's infrastructure for availability
- **Learning Curve:** Despite visual interface, users may still struggle with field matching concepts

### Open Questions

- ~~What is the maximum practical file size that can be processed reliably across all target browsers?~~ **Decision:** Add warning for users on older systems about potential file size limitations
- ~~How should the platform handle Excel files with multiple sheets?~~ **Decision:** Use first sheet only, with clear notification and user acknowledgment required
- What visual indicators best communicate that processing is happening entirely client-side?
- ~~Should the platform provide any form of operation history within a session?~~ **Decision:** No - this would violate the privacy principle
- ~~How to handle special characters and encoding issues in international datasets?~~ **Decision:** Prioritize security against injection attacks; ensure proper sanitization
- ~~What's the best approach for preserving formatting (like strikethrough) in CSV output?~~ **Decision:** Use tilde prefix ("~") for deleted records; Excel formatting moved to Phase 2
- How to optimize Elm/JavaScript interop for file processing performance?
- What level of fuzzy matching configuration should be exposed to users?

### Areas Needing Further Research

- Elm libraries and patterns for efficient large-scale data processing
- Best practices for Elm ports with large data transfers (spreadsheet contents)
- CSS framework compatibility with Elm UI for achieving desired visual quality
- Methods to verify and demonstrate client-side-only processing to users
- **Tilde prefix implementation:** Validate tilde ("~") prefix approach for deleted record marking and stakeholder workflow
- Browser-specific memory management strategies for large file processing
- User research on acceptable wait times for file processing operations

## Appendices

### A. Research Summary

*No formal research has been conducted yet. Future research activities may include:*
- User interviews with professionals who regularly work with spreadsheet comparisons
- Analysis of existing spreadsheet manipulation tools and their limitations
- Technical feasibility studies for Elm-based spreadsheet processing
- Performance benchmarking of client-side file processing

### B. Stakeholder Input

*Initial requirements gathered from primary stakeholder indicate:*
- Strong emphasis on data privacy (no server storage)
- Need for fuzzy matching capabilities for inconsistent data
- Requirement for visual, intuitive interface
- Platform must be extensible for future tools
- Examples provided show education use case but tools should be generic

**Stakeholder Review & Approval:**
- Project brief reviewed and accepted by primary stakeholder on 2025-08-20
- Stakeholder approved changes to Data Merger tool output format (CSV with tilde prefix instead of Excel strikethrough)
- Stakeholder confirmed Excel file creation can be moved to Phase 2
- Stakeholder validated tilde ("~") prefix approach for deleted record identification

### C. References

**Requirements Documentation:**
- `docs/Spreadsheet Data Tools Requirements.md` - Original requirements document with detailed tool specifications

**Example Files:**
- `Example Sheet A.xlsx` - Sample data for Data Merger tool testing
- `Example Sheet B.xlsx` - Sample data for Data Merger tool testing

**Technology Resources:**
- [Elm Language Documentation](https://elm-lang.org/)
- [GitHub Pages Documentation](https://pages.github.com/)
- [SheetJS Documentation](https://sheetjs.com/) - Potential library for Excel file parsing
- [Elm UI Package](https://package.elm-lang.org/packages/mdgriffith/elm-ui/latest/) - Potential UI framework
- [Elm CSS](https://package.elm-lang.org/packages/rtfeldman/elm-css/latest/) - CSS in Elm

**Development Methodology:**
- [BMad Method](https://github.com/bmad-code-org/BMAD-METHOD) - AI-driven development framework with specialized agents
- [Context7 MCP Server](https://context7.com/modelcontextprotocol/servers) - Real-time documentation integration for AI assistants
- Model Context Protocol (MCP) - Standardized context exchange for AI development tools

## Next Steps

### Immediate Actions

1. **Setup BMad Method & Context7** - Configure BMad agents (Analyst, PM, Architect, Dev) and integrate Context7 MCP server for real-time Elm and JavaScript library documentation access during development
2. **Tilde Prefix Validation** - Validate tilde ("~") prefix approach for marking deleted records and confirm stakeholder workflow compatibility
3. **Elm Library Assessment** - Evaluate available Elm packages for file processing and identify where JavaScript interop will be required
4. **UI Framework Selection** - Test and select Elm-compatible UI libraries and CSS frameworks that provide the desired modern, professional appearance
5. **Proof of Concept** - Build minimal prototype demonstrating:
   - File upload and client-side processing in Elm
   - JavaScript interop with error handling for Excel file parsing
   - Basic fuzzy matching implementation
   - CSV file generation and download with tilde prefix marking
6. **Architecture Design** - Create detailed technical architecture supporting modular tool development
7. **Development Environment Setup** - Configure Elm development environment, GitHub repository, GitHub Pages deployment pipeline, BMad Method agents, and Context7 MCP server for documentation access
8. **Create Example Test Files** - Develop comprehensive test spreadsheets covering various edge cases and formatting scenarios
9. **Begin MVP Development** - Start implementing the platform shell and first tool (Data Extractor)

### PM Handoff

This Project Brief provides the full context for Spreadsheet Data Platform. Please start in 'PRD Generation Mode', review the brief thoroughly to work with the user to create the PRD section by section as the template indicates, asking for any necessary clarification or suggesting improvements.

**Key Points for PM:**
- Privacy-first approach is non-negotiable - all processing must be client-side
- Elm implementation with JavaScript interop where needed for usability
- Two tools for MVP: Data Extractor and Data Merger
- Extensible architecture is critical for future growth
- No user accounts or data persistence planned
- GitHub Pages hosting with static site approach