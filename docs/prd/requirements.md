# Requirements

## Functional Requirements

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

## Non-Functional Requirements

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
