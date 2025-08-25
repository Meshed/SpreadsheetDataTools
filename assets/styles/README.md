# CSS Architecture and Naming Conventions

## Overview

This document outlines the CSS architecture, naming conventions, and best practices for the Spreadsheet Data Tools project. Our CSS follows the BEM (Block Element Modifier) methodology with a structured organization that promotes maintainability and scalability.

## CSS Architecture Structure

```
assets/styles/
├── base/
│   ├── reset.css          # CSS reset and normalize
│   ├── variables.css      # CSS custom properties (design system tokens)
│   └── typography.css     # Font definitions and text styles
├── components/            # Component-specific styles
│   ├── buttons.css        # Button component styles
│   ├── cards.css          # Card component styles
│   ├── forms.css          # Form element styles
│   ├── progress.css       # Progress indicator styles
│   ├── wizard.css         # Wizard framework styles
│   └── app.css           # Application-wide component styles
├── layout/                # Layout-specific styles
│   ├── containers.css     # Container and wrapper styles
│   ├── grid.css          # Grid system and layout utilities
│   ├── header.css        # Header layout styles
│   └── footer.css        # Footer layout styles
├── pages/                 # Page-specific styles
│   ├── landing.css       # Landing page styles
│   ├── data-extractor.css # Data Extractor tool styles
│   └── data-merger.css   # Data Merger tool styles
├── utilities/             # Utility classes
│   ├── spacing.css       # Margin and padding utilities
│   ├── colors.css        # Color utilities
│   └── helpers.css       # General helper utilities
└── main.css              # Main import file
```

## BEM Methodology

We use the BEM (Block Element Modifier) methodology for naming CSS classes, which provides clear structure and prevents specificity conflicts.

### BEM Syntax

```
.block__element--modifier
```

- **Block**: The main component (e.g., `.tool-card`, `.wizard`, `.btn`)
- **Element**: A child of the block (e.g., `.tool-card__title`, `.wizard__step`, `.btn__icon`)
- **Modifier**: A variant or state (e.g., `.tool-card--featured`, `.wizard--loading`, `.btn--primary`)

### BEM Examples

#### Block Examples
```css
.tool-card { /* Standalone component */ }
.wizard { /* Wizard component */ }
.btn { /* Button component */ }
.form { /* Form component */ }
```

#### Element Examples
```css
.tool-card__title { /* Title within tool card */ }
.tool-card__description { /* Description within tool card */ }
.tool-card__button { /* Button within tool card */ }

.wizard__header { /* Header within wizard */ }
.wizard__content { /* Content area within wizard */ }
.wizard__actions { /* Actions area within wizard */ }

.btn__icon { /* Icon within button */ }
.btn__text { /* Text within button */ }
```

#### Modifier Examples
```css
.tool-card--primary { /* Primary variant of tool card */ }
.tool-card--disabled { /* Disabled state of tool card */ }

.btn--primary { /* Primary button style */ }
.btn--secondary { /* Secondary button style */ }
.btn--large { /* Large button size */ }
.btn--loading { /* Loading state button */ }

.wizard--compact { /* Compact wizard variant */ }
.wizard--fullscreen { /* Fullscreen wizard variant */ }
```

## Naming Conventions by Category

### Component Classes
- Use descriptive names that indicate the component's purpose
- Start with the component name, followed by elements and modifiers
- Examples: `.tool-card`, `.data-extractor`, `.progress-bar`

### Layout Classes
- Describe the layout purpose or container type
- Examples: `.container`, `.section`, `.page-container`, `.sidebar-container`

### Utility Classes
- Prefix with `u-` to clearly identify as utilities
- Use descriptive names that indicate the utility's effect
- Examples: `.u-text-center`, `.u-margin-lg`, `.u-hidden`, `.u-flex`

### State Classes
- Use modifiers to indicate component states
- Examples: `.btn--disabled`, `.wizard--loading`, `.form__input--error`

### JavaScript Hook Classes
- Prefix with `js-` for classes used only by JavaScript
- Never style these classes with CSS
- Examples: `.js-toggle`, `.js-submit`, `.js-file-upload`

## CSS Custom Properties (Design System)

All design tokens are defined as CSS custom properties in `base/variables.css`:

### Color System
```css
--color-primary: #2563eb;
--color-primary-hover: #1d4ed8;
--color-secondary: #64748b;
--color-background: #ffffff;
--color-surface: #f8fafc;
--color-text: #1e293b;
--color-text-muted: #64748b;
```

### Spacing System
```css
--spacing-xs: 0.5rem;    /* 8px */
--spacing-sm: 1rem;      /* 16px */
--spacing-md: 1.5rem;    /* 24px */
--spacing-lg: 2rem;      /* 32px */
--spacing-xl: 3rem;      /* 48px */
--spacing-xxl: 4rem;     /* 64px */
```

### Typography Scale
```css
--font-size-xs: 0.75rem;   /* 12px */
--font-size-sm: 0.875rem;  /* 14px */
--font-size-base: 1rem;    /* 16px */
--font-size-lg: 1.125rem;  /* 18px */
--font-size-xl: 1.25rem;   /* 20px */
--font-size-2xl: 1.5rem;   /* 24px */
```

## Component Organization Patterns

### 1. Block Structure
Each component file should follow this structure:
```css
/* Main Block */
.component { }

/* Elements */
.component__element { }

/* Modifiers */
.component--modifier { }

/* Element Modifiers */
.component__element--modifier { }
```

### 2. Responsive Variants
Use consistent breakpoints and mobile-first approach:
```css
.component {
  /* Mobile styles first */
}

@media (min-width: 768px) {
  .component {
    /* Tablet styles */
  }
}

@media (min-width: 1024px) {
  .component {
    /* Desktop styles */
  }
}
```

### 3. State Management
Handle component states consistently:
```css
.component {
  /* Default state */
}

.component--loading {
  /* Loading state */
}

.component--error {
  /* Error state */
}

.component--disabled {
  /* Disabled state */
}
```

## Utility Classes

### Spacing Utilities
- `.u-margin-{size}` - Margin on all sides
- `.u-margin-{direction}-{size}` - Margin on specific side
- `.u-padding-{size}` - Padding on all sides
- `.u-padding-{direction}-{size}` - Padding on specific side

Sizes: `0`, `xs`, `sm`, `md`, `lg`, `xl`, `xxl`
Directions: `top`, `right`, `bottom`, `left`, `x` (horizontal), `y` (vertical)

### Color Utilities
- `.u-text-{color}` - Text colors
- `.u-bg-{color}` - Background colors
- `.u-border-{color}` - Border colors

Colors: `primary`, `secondary`, `success`, `warning`, `error`, `muted`

### Layout Utilities
- `.u-flex` - Display flex
- `.u-grid` - Display grid
- `.u-hidden` - Hide element
- `.u-text-center` - Center text
- `.u-w-full` - Full width
- `.u-h-full` - Full height

## Best Practices

### 1. No Inline Styles
- All styling must be in separate CSS files
- Never use `style` attributes in HTML
- Never use `Html.Attributes.style` in Elm code

### 2. Use CSS Custom Properties
- Always use design system variables instead of hardcoded values
- Example: Use `var(--color-primary)` instead of `#2563eb`

### 3. Follow BEM Strictly
- One block per component file
- Elements are children of blocks, never children of other elements
- Modifiers change appearance or behavior

### 4. Avoid Deep Nesting
- Maximum nesting depth of 3 levels in CSS
- Prefer flat BEM structure over nested selectors

### 5. Component Isolation
- Each component should be self-contained
- Avoid dependencies between component styles
- Use composition over inheritance

### 6. Performance Considerations
- Use efficient selectors (avoid complex descendant selectors)
- Group related properties together
- Minimize CSS file size through organization

## File Organization Rules

### Import Order in main.css
1. Base styles (reset, variables, typography)
2. Layout styles (containers, grid, header, footer)
3. Component styles (alphabetically ordered)
4. Utility classes
5. Page-specific styles

### Component File Structure
```css
/* Component Name - BEM Methodology */

/* Block */
.component {
  /* Properties */
}

/* Elements */
.component__element {
  /* Properties */
}

/* Modifiers */
.component--modifier {
  /* Properties */
}

/* Responsive styles at the end */
@media (max-width: 768px) {
  /* Mobile overrides */
}
```

## Testing and Validation

### CSS Validation Checklist
- [ ] All classes follow BEM naming convention
- [ ] No inline styles in HTML or Elm files
- [ ] All colors use CSS custom properties
- [ ] All spacing uses design system tokens
- [ ] Components are self-contained
- [ ] Utility classes are prefixed with `u-`
- [ ] CSS imports are in correct order
- [ ] Files compile without errors

### Browser Testing
- Test in modern browsers (Chrome, Firefox, Safari, Edge)
- Verify responsive design works across breakpoints
- Check accessibility and focus states
- Validate that CSS variables render correctly

## Migration Guidelines

When updating existing CSS:
1. Check if component follows BEM methodology
2. Replace hardcoded values with CSS custom properties
3. Remove any inline styles
4. Ensure proper file organization
5. Test across browsers and devices

## Tools and Build Process

- **Webpack**: Processes and bundles CSS files
- **CSS Import Resolution**: All @import statements resolved at build time
- **Minification**: CSS minified in production builds
- **Source Maps**: Available in development for debugging
- **Hot Reload**: CSS changes reload automatically in development

This architecture ensures maintainable, scalable, and consistent styling across the entire Spreadsheet Data Tools application.