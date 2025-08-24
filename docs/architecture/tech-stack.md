# Tech Stack

## Technology Stack Table

| Category | Technology | Version | Purpose | Rationale |
|----------|------------|---------|---------|-----------|
| Frontend Language | Elm | 0.19.1 | Primary application language | Type-safe, functional, enforces pure functions, zero runtime exceptions |
| Frontend Framework | Elm Architecture (MVU) | Built-in | Application structure | Native to Elm, predictable state management, time-travel debugging |
| UI Component Library | Custom Elm Components | N/A | Reusable UI elements | Full control, type-safe, follows Front-End Spec requirements |
| State Management | Elm Model | Built-in | Application state | Immutable, centralized, works with pure functions |
| Backend Language | N/A | N/A | No backend required | Client-side only processing for privacy |
| Backend Framework | N/A | N/A | No backend required | All processing in browser |
| API Style | N/A | N/A | No APIs needed | Zero server communication by design |
| Database | N/A | N/A | No persistence required | Privacy-first, no data storage |
| Cache | Browser Memory | N/A | Session-only data | No localStorage/cookies for privacy |
| File Storage | N/A | N/A | No file storage | Files processed and discarded |
| Authentication | N/A | N/A | No auth required | No user accounts, fully anonymous |
| Frontend Testing | elm-test | 0.19.1 | Unit/integration testing | Comprehensive testing, property-based testing |
| Backend Testing | N/A | N/A | No backend | N/A |
| E2E Testing | Cypress | 10.8.0 | End-to-end testing | Desktop browser automation, file upload testing |
| Build Tool | Webpack | 5.74.0 | Bundle and build | Asset optimization, code splitting |
| Bundler | Webpack | 5.74.0 | Module bundling | Elm compilation, CSS processing |
| IaC Tool | N/A | N/A | No infrastructure | Static files only |
| CI/CD | GitHub Actions | N/A | Automated deployment | Native GitHub integration, free for public repos |
| Monitoring | N/A | N/A | Privacy-first approach | No tracking per requirements |
| Logging | Browser Console | N/A | Development only | No production logging for privacy |
| CSS Framework | Custom CSS with BEM | N/A | Styling methodology | No inline styles, maintainable structure per Front-End Spec |

## Additional Technology Details

### JavaScript Libraries (via Interop)
| Library | Version | Purpose | Integration Method |
|---------|---------|---------|-------------------|
| SheetJS (xlsx) | 0.18.5 | Excel file parsing | Elm ports for controlled interop |
| FileSaver.js | 2.0.5 | File download trigger | Browser File API wrapper |
