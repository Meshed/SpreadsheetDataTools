# User Interface Design Goals

## Overall UX Vision
**Wizard-driven interface** with clear progress tracking for both Data Extractor and Data Merger tools. Each tool presents a **multi-step guided workflow** with visual progress bar showing current step, completed steps, and remaining steps. Clean, professional design that builds user confidence through transparent progress indication and step-by-step guidance. Desktop-first design optimized for data manipulation tasks.

## Key Interaction Paradigms
- **Step-by-step wizard workflow** with progress bar showing: Upload → Configure → Preview → Download
- **Progress indicator design** similar to your reference images - circular step indicators with connecting lines, showing completed (filled), current (highlighted), and upcoming (outlined) steps
- **Navigation controls** with Previous/Next buttons, allowing users to move back to modify earlier choices
- **Visual field mapping** within wizard steps for column selection and matching criteria
- **Live preview integration** as dedicated wizard step before final processing
- **Clear privacy indicators** integrated into wizard header or footer
- **Modern card-based interface** for tool selection with hover effects and clear visual feedback
- **Consistent button styling** across cards and wizard navigation (primary actions, secondary actions)
- **Card-to-wizard transition** with smooth navigation from tool selection to guided workflow

## Core Screens and Views
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


## Branding
Clean, modern aesthetic emphasizing trust and professionalism. Minimal color palette focusing on data readability. Typography optimized for data display. Privacy-focused messaging integrated throughout interface. No corporate branding requirements - focus on usability and trustworthiness.

## Target Device and Platforms: Desktop Only
Desktop-exclusive design supporting Windows, macOS, and Linux browsers (minimum 1024px width). Optimized specifically for desktop screens where data manipulation workflows are most effective. No mobile support provided.
