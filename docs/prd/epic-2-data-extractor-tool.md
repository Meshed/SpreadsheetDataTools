# Epic 2: Data Extractor Tool

**Epic Goal:** Deliver a complete, functional Data Extractor tool with 5-step wizard workflow that allows users to upload spreadsheets, configure matching criteria, preview results, select output fields, and download CSV extracts - providing the first valuable data manipulation capability for the platform.

## Story 2.1: File Upload Interface for Data Extractor
As a user,  
I want to upload master and data spreadsheets for extraction,  
so that I can provide the source data for matching operations.

### Acceptance Criteria
1. Wizard step 1 displays dual file upload areas labeled "Master Spreadsheet" and "Data Spreadsheet"
2. Drag-and-drop functionality with visual feedback for file hover states
3. File format validation accepts .xlsx, .xls, and .csv files only
4. File size validation prevents uploads over 50MB with clear error message
5. Progress indicator shows wizard step 1 of 5 as active
6. "Next" button enabled only when both files successfully uploaded
7. Clear error messages for invalid file types or sizes
8. Privacy messaging visible: "Files processed locally - never uploaded to servers"

## Story 2.2: Configure Matching Criteria
As a user,  
I want to select multiple fields for matching between spreadsheets,  
so that I can create more precise matches using combinations of columns.

### Acceptance Criteria
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

## Story 2.3: Preview Extraction Results
As a user,  
I want to see sample matches before selecting output fields,  
so that I can verify the matching logic and understand what data is available.

### Acceptance Criteria
1. Wizard step 3 displays up to 3 sample matched records
2. Each sample shows master record with corresponding matched data record
3. Clear visual indication of which fields were used for matching
4. "No matches found" message if no records match with helpful suggestions
5. Match confidence or fuzzy match explanation displayed where applicable
6. "Re-configure" option to return to previous steps if matches look incorrect
7. All available fields from both spreadsheets visible in preview
8. Progress indicator shows step 3 of 5 as active

## Story 2.4: Select Output Fields
As a user,  
I want to choose which columns appear in my extracted results based on the preview,  
so that I get only the data I need in my output file.

### Acceptance Criteria
1. Wizard step 4 shows all available columns from both spreadsheets
2. Checkbox interface allows selecting multiple fields for output
3. Selected fields visually distinguished (checked state, highlighting)
4. Default selection includes all fields from data spreadsheet
5. Field preview references sample data from previous step
6. "Select All" and "Clear All" buttons for convenient field management
7. At least one field must be selected to proceed
8. Progress indicator shows step 4 of 5 as active

## Story 2.5: CSV Download and Completion
As a user,  
I want to download my extracted results as a CSV file,  
so that I can use the matched data in other applications.

### Acceptance Criteria
1. Wizard step 5 processes all matching records using configured criteria
2. Processing progress indicator shows real-time status for large files
3. CSV file generated with selected output fields only
4. Download initiated automatically when processing completes
5. Post-download guidance explaining CSV format and next steps
6. "Clear All Data" button removes uploaded files from browser memory
7. "Start Over" option returns to step 1 with clean state
8. Success message confirms number of records extracted and file size

## Story 2.6: Error Handling and Edge Cases
As a user,  
I want helpful guidance when problems occur,  
so that I can understand issues and complete my task successfully.

### Acceptance Criteria
1. Corrupted or password-protected files display specific error messages
2. Empty spreadsheets handled gracefully with clear messaging
3. Large files show warning about potential browser memory limitations
4. Multi-sheet Excel files use first sheet with user notification
5. Special characters and encoding issues handled without crashes
6. No matches found scenario provides suggestions for different criteria
7. Browser memory errors caught and explained with file size guidance
8. All error states allow user to return to previous steps and retry
