# Epic 4: Data Merger Tool

**Epic Goal:** Implement the complete Data Merger tool leveraging refactored shared components from Epic 3, providing users with the ability to merge two spreadsheets with matching records updated, new records added, and deleted records marked with tilde prefix - completing the MVP's core functionality.

## Story 4.1: Data Merger Wizard Shell and Navigation
As a user,  
I want to launch the Data Merger tool from the homepage,  
so that I can access the merge functionality through a familiar wizard interface.

### Acceptance Criteria
1. Data Merger card on homepage navigates to /data-merger route
2. Wizard framework from Epic 3 configured with 5 steps for merger workflow
3. Step labels: "Upload Files", "Configure Matching", "Preview Results", "Select Fields", "Download"
4. Navigation controls (Previous/Next/Start Over) connected to merger-specific logic
5. Progress indicator shows current position in 5-step workflow
6. Privacy messaging displayed: "All merging happens in your browser"
7. Wizard state management handles merger-specific data structures
8. URL updates to reflect current wizard step for browser back/forward support

## Story 4.2: File Upload for Merger (Spreadsheets A & B)
As a user,  
I want to upload two spreadsheets for merging,  
so that I can combine data from different sources.

### Acceptance Criteria
1. Reused file upload component configured with labels "Spreadsheet A" and "Spreadsheet B"
2. Clear explanations: "Spreadsheet A: Primary data" and "Spreadsheet B: Updates/changes"
3. Same file format support (.xlsx, .xls, .csv) and size limits (50MB)
4. File parsing via shared JavaScript interop from Epic 3
5. Both files required before proceeding to next step
6. Upload state preserved when navigating back from later steps
7. Error handling for incompatible or corrupted files
8. Progress indicator shows step 1 of 5 as active

## Story 4.3: Configure Merge Matching Criteria
As a user,  
I want to specify how records should be matched between spreadsheets,  
so that the system correctly identifies which records to merge.

### Acceptance Criteria
1. Reused matching configuration interface from shared components
2. Multi-column selection with positional ordering for both spreadsheets
3. Visual matching pairs display: "A Col 1 ↔ B Col 1" with clear relationships
4. Shared fuzzy matching logic applied with "includes" option
5. Explanation of merge behavior: "Matched records will be updated, unmatched from A added as new, unmatched from B marked with ~"
6. Sample data preview from selected matching columns
7. At least one matching column required from each spreadsheet
8. Progress indicator shows step 2 of 5 as active

## Story 4.4: Preview Merge Results
As a user,  
I want to see sample merged records before finalizing,  
so that I understand how the merge will affect my data.

### Acceptance Criteria
1. Reused preview component showing up to 3 sample results
2. Three categories displayed: "Updated Records", "New Records", "Deleted Records"
3. Updated records show original and merged values side-by-side
4. New records (from A not in B) highlighted as additions
5. Deleted records (from B not in A) show with tilde prefix example
6. Clear explanation of tilde prefix: "Records marked with ~ were in Spreadsheet B but not found in A"
7. "Re-configure" option returns to matching configuration if needed
8. Progress indicator shows step 3 of 5 as active

## Story 4.5: Select Output Fields for Merged Data
As a user,  
I want to choose which columns to include in the merged output,  
so that I can control the structure of my final dataset.

### Acceptance Criteria
1. Reused field selection component showing all available columns
2. Columns from both spreadsheets available for selection
3. Clear indication of column source (A or B) when names conflict
4. Default selection includes all columns from Spreadsheet A
5. For matched records, ability to choose whether to use A or B values
6. "Select All" and "Clear All" functionality from shared components
7. At least one field must be selected to proceed
8. Progress indicator shows step 4 of 5 as active

## Story 4.6: Process Merge and Generate CSV Output
As a user,  
I want to download the merged results with appropriate markings,  
so that I can use the combined data and identify changes.

### Acceptance Criteria
1. Full merge processing using shared matching logic from Epic 3
2. Progress indicator for processing large files
3. Tilde prefix ("~") added to first cell of deleted records
4. CSV generation using shared utilities with proper escaping
5. Automatic download initiated when processing completes
6. Post-download instructions displayed: "Filter by ~* to see deleted records"
7. Success message shows counts: "X records updated, Y added, Z marked as deleted"
8. "Clear All Data" button removes files from browser memory
9. Progress indicator shows step 5 of 5 as complete

## Story 4.7: Data Merger Edge Cases and Validation
As a user,  
I want the merger to handle special cases gracefully,  
so that I can complete my task even with imperfect data.

### Acceptance Criteria
1. Empty spreadsheets handled with appropriate messaging
2. Spreadsheets with no matches produce valid output (all new/deleted)
3. Duplicate matches handled consistently with clear user notification
4. Column name conflicts resolved with source indicators (A: or B:)
5. Special characters in data preserved without breaking CSV format
6. Large file processing maintains browser stability
7. Multi-sheet Excel files use first sheet with notification
8. All error states allow recovery without losing configuration
