# Spreadsheet Data Tools

## Plan:

- Create a website that will be a hub for different data tools used for working with spreadsheets.  
- While there are only two tools initially, I want the flexibility to add more.  
- I want each tool to be presented in a card or tile that displays the name of the tool, an icon representing the tool, and a brief explanation of the behavior of each respective tool.  
- The landing page for the tool should display the website name, a brief description of what the website is and a list of tools as described above.  
- **TODO**: Find and reference websites for cards or tiles as reference when designing the UI

## Features/Notes:

- **This is important and must be followed:** I do not want to keep, store, record, or in any way keep track of the contents or names of the spreadsheets uploaded. **This is important and must be followed.**  
- Since there is a possibility for functionality to be shared between tools, such as uploading, field matching comparison, record display, file creation, file downloads, etc, we should look for refactoring opportunities after completing each story.

## Future Features and Ideas (future phase, not part of MVP):

- Comprehensive access and feature usage logging and reporting 

## Tools:

- Data Extractor  
- Data Merger

### Data Extractor

Problem: I often get spreadsheets with data for students for the entire county. I have a list of students for just my school. I want to somehow use the list of students for my school, hereby refered to as the **master spreadsheet**, to get information from the list of students for the entire county, hereby referred to as the **data spreadsheet**, for just the students in the master spreadsheet. Sometimes the files will match on student ID, but often the match is by name matching. Some names include extra punctuation or titles, so I need to perform searches that will perform an “include” search on names (example: “Mark” matches with “Mr. Mark” and “Mark S.”).

Plan:

- Make a section in the Spreadsheet Data Tools website called Data Extractor  
- This tool will allow me to upload two spreadsheets, a master spreadsheet and a data spreadsheet.  
- Once uploaded, show me a separate list of all columns and data from both spreadsheets so I can select fields to match on  
- I then want to see up to combined records for up to 3 matching records  
- Then I want to select the fields that I want included in the new spreadsheet the tool will generate.  
- Finally, I want to then press a button to have a new spreadsheet ready to download with just the fields I have selected and the records for the students matching the master spreadsheet.

Features/Notes:

- **This is important and must be followed:** I do not want to keep, store, record, or in any way keep track of the contents or names of the spreadsheets uploaded. **This is important and must be followed.**  
- I want the field selection for matching and selecting for import to be a clean and intuitive visual selection.   
- **TODO:** Find and mimic other drag and drop UIs from popular image handling websites.  
- Create new spreadsheets as .csv files

### Data Merger

Problem: Each sheet is an example of the spreadsheets... Sheet A represents what I get from the program and Sheet B represents how I've modified it for my purposes... So as you can see Sheet A (being the update) shows different students than Sheet B. The ones that are in Both sheets need to STAY on B, but the ones on B that are NO LONGER on A need a strikethrough or something to show that they aren't active anymore. Then new ones on A that are not on B yet need to be added.

Plan:

- Make a section in the Spreadsheet Data Tools website called Data Merger  
- This tool will allow me to upload two spreadsheets, spreadsheet A and spreadsheet B  
- Once uploaded, show me a separate list of all columns and data from both spreadsheets so I can select fields to match on  
- I then want to see up to combined records for up to 3 matching records  
- Then I want to select the fields that I want included in the new spreadsheet the tool will generate.  
- Finally, I want to press a button to have a new spreadsheet ready to download with just the fields I have selected, with all records from B, the cells for records in B that are not in A are stricken through, and the records in A that are not in B are added to added to the new spreadsheet.

Features/Notes:

- **This is important and must be followed:** I do not want to keep, store, record, or in any way keep track of the contents or names of the spreadsheets uploaded. **This is important and must be followed.**  
- I want the field selection for matching and selecting for import to be a clean and intuitive visual selection. Find and mimic other drag and drop UIs from popular image handling websites.  
- Create new spreadsheets as .csv files
- Use "Example Sheet A.xlsx" and "ExampleSheet B.xlsx" as reference