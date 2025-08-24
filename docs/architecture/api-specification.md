# API Specification

**N/A - No APIs Required**

This application has no REST APIs, GraphQL endpoints, or tRPC routers as all processing occurs entirely client-side in the browser. There is zero server communication by design to ensure absolute privacy.

The only external interfaces are:
1. **File Input:** Browser File API for uploading spreadsheets
2. **File Output:** Browser download API for CSV exports  
3. **JavaScript Interop:** Elm ports for controlled communication with JavaScript libraries (SheetJS)

All of these are local browser APIs, not network APIs.
