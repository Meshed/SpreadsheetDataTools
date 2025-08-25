/**
 * CSS Architecture Tests for Story 1.4
 * 
 * Node.js-based tests that validate CSS file structure, naming conventions,
 * and build process integration using file system operations.
 */

const fs = require('fs');
const path = require('path');
const glob = require('glob');

describe('CSS Architecture Validation', () => {
  
  describe('1.4-UNIT-001: CSS Directory Structure Validation', () => {
    test('should have all required CSS directories', () => {
      const requiredDirs = ['base', 'components', 'layout', 'utilities', 'pages'];
      
      requiredDirs.forEach(dir => {
        const dirPath = path.join('assets', 'styles', dir);
        expect(fs.existsSync(dirPath)).toBe(true);
      });
    });
  });

  describe('1.4-UNIT-002: All Required CSS Files Exist', () => {
    test('should have all required CSS files present', () => {
      const requiredFiles = [
        'base/reset.css',
        'base/variables.css', 
        'base/typography.css',
        'components/buttons.css',
        'components/cards.css',
        'components/forms.css',
        'components/progress.css',
        'components/wizard.css',
        'layout/containers.css',
        'layout/grid.css',
        'layout/header.css',
        'layout/footer.css',
        'utilities/spacing.css',
        'utilities/colors.css',
        'utilities/helpers.css',
        'pages/landing.css',
        'pages/data-extractor.css',
        'pages/data-merger.css'
      ];
      
      requiredFiles.forEach(file => {
        const filePath = path.join('assets', 'styles', file);
        expect(fs.existsSync(filePath)).toBe(true);
      });
    });
  });

  describe('1.4-UNIT-003: Static Analysis - No Style Attributes', () => {
    test('should find no style attributes in Elm files', () => {
      const elmFiles = glob.sync('src/**/*.elm');
      
      elmFiles.forEach(file => {
        const content = fs.readFileSync(file, 'utf8');
        
        // Check for Html.Attributes.style usage
        expect(content).not.toMatch(/Html\.Attributes\.style/);
        
        // Check for inline style attributes
        expect(content).not.toMatch(/style\s*=/);
      });
    });

    test('should find no style attributes in HTML files', () => {
      const htmlFiles = glob.sync('public/**/*.html');
      
      htmlFiles.forEach(file => {
        const content = fs.readFileSync(file, 'utf8');
        
        // Check for inline style attributes
        expect(content).not.toMatch(/style\s*=/);
      });
    });
  });

  describe('1.4-UNIT-004: BEM Class Name Validation', () => {
    test('should follow BEM methodology in CSS files', () => {
      const cssFiles = glob.sync('assets/styles/**/*.css');
      
      cssFiles.forEach(file => {
        const content = fs.readFileSync(file, 'utf8');
        const classNames = extractClassNames(content);
        
        classNames.forEach(className => {
          // Skip utility classes (prefixed with u-)
          if (className.startsWith('u-')) return;
          
          // Skip CSS variables and keyframes
          if (className.startsWith('--') || className.includes('@')) return;
          
          // Validate BEM structure: block__element--modifier
          const bemPattern = /^[a-z][a-z0-9]*(-[a-z0-9]+)*(__[a-z][a-z0-9]*(-[a-z0-9]+)*)?(--[a-z][a-z0-9]*(-[a-z0-9]+)*)?$/;
          
          expect(className).toMatch(bemPattern);
        });
      });
    });
  });

  describe('1.4-UNIT-007: CSS Custom Properties Defined', () => {
    test('should define all required design system variables', () => {
      const variablesPath = path.join('assets', 'styles', 'base', 'variables.css');
      const variablesContent = fs.readFileSync(variablesPath, 'utf8');
      
      const requiredVariables = [
        '--color-primary',
        '--color-secondary', 
        '--color-background',
        '--color-surface',
        '--color-text',
        '--spacing-xs',
        '--spacing-sm', 
        '--spacing-md',
        '--spacing-lg',
        '--border-radius',
        '--box-shadow'
      ];
      
      requiredVariables.forEach(variable => {
        const variablePattern = new RegExp(`${escapeRegExp(variable)}:\\s*[^;]+;`);
        expect(variablesContent).toMatch(variablePattern);
      });
    });
  });

  describe('1.4-UNIT-008: Design Token Usage Validation', () => {
    test('should use CSS variables instead of hardcoded values', () => {
      const cssFiles = glob.sync('assets/styles/{components,layout,pages}/*.css');
      
      cssFiles.forEach(file => {
        const content = fs.readFileSync(file, 'utf8');
        
        // Check for hardcoded colors (should use var(--color-*))
        const hardcodedColors = content.match(/#[0-9a-fA-F]{3,6}/g) || [];
        
        // Allow minimal hardcoded colors for special cases
        expect(hardcodedColors.length).toBeLessThan(3);
        
        // Check for excessive hardcoded spacing values
        const hardcodedSpacing = content.match(/(?:margin|padding|gap):\s*(?:\d+(?:\.\d+)?(?:px|rem|em))/g) || [];
        
        // Allow some hardcoded values but flag excessive use
        expect(hardcodedSpacing.length).toBeLessThan(5);
      });
    });
  });

  describe('1.4-UNIT-010: No External CSS Framework Conflicts', () => {
    test('should not import external CSS frameworks', () => {
      const mainCssPath = path.join('assets', 'styles', 'main.css');
      const mainCssContent = fs.readFileSync(mainCssPath, 'utf8');
      const packageJsonPath = path.join('package.json');
      const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
      
      // Check no external CSS imports
      expect(mainCssContent).not.toMatch(/@import.*https?:/);
      expect(mainCssContent).not.toMatch(/@import.*node_modules/);
      
      // Check no CSS framework dependencies
      const frameworkNames = ['bootstrap', 'tailwindcss', 'bulma', 'foundation'];
      frameworkNames.forEach(framework => {
        expect(packageJson.dependencies || {}).not.toHaveProperty(framework);
        expect(packageJson.devDependencies || {}).not.toHaveProperty(framework);
      });
    });
  });

});

describe('CSS Build Process Integration', () => {
  
  describe('1.4-INT-001: CSS Import Resolution in main.css', () => {
    test('should resolve all CSS imports in main.css', () => {
      const mainCssPath = path.join('assets', 'styles', 'main.css');
      const mainCssContent = fs.readFileSync(mainCssPath, 'utf8');
      const importPaths = extractImportPaths(mainCssContent);
      
      importPaths.forEach(importPath => {
        const fullPath = path.resolve('assets', 'styles', importPath);
        expect(fs.existsSync(fullPath)).toBe(true);
        
        // Test that imported files are valid CSS (basic syntax check)
        const importedContent = fs.readFileSync(fullPath, 'utf8');
        expect(importedContent).toBeTruthy();
        expect(importedContent.length).toBeGreaterThan(0);
      });
    });
  });

  describe('1.4-INT-002: CSS Loading Order is Correct', () => {
    test('should load CSS in correct cascade order', () => {
      const mainCssPath = path.join('assets', 'styles', 'main.css');
      const mainCssContent = fs.readFileSync(mainCssPath, 'utf8');
      const importOrder = extractImportOrder(mainCssContent);
      
      // Verify order: base → layout → components → utilities → pages
      const expectedOrder = ['base/', 'layout/', 'components/', 'utilities/', 'pages/'];
      let currentIndex = 0;
      
      importOrder.forEach(importPath => {
        const category = expectedOrder.find(cat => importPath.startsWith(cat));
        if (category) {
          const categoryIndex = expectedOrder.indexOf(category);
          expect(categoryIndex).toBeGreaterThanOrEqual(currentIndex);
          currentIndex = categoryIndex;
        }
      });
    });
  });

  describe('1.4-INT-004: Cross-component Variable Inheritance', () => {
    test('should inherit design system variables across components', () => {
      const componentFiles = glob.sync('assets/styles/components/*.css');
      const variablesPath = path.join('assets', 'styles', 'base', 'variables.css');
      const variablesContent = fs.readFileSync(variablesPath, 'utf8');
      const definedVariables = extractVariableNames(variablesContent);
      
      componentFiles.forEach(file => {
        const content = fs.readFileSync(file, 'utf8');
        const usedVariables = extractUsedVariables(content);
        
        usedVariables.forEach(variable => {
          expect(definedVariables).toContain(variable);
        });
      });
    });
  });

});

// Utility Functions
function extractClassNames(cssContent) {
  const classRegex = /\.([a-zA-Z][a-zA-Z0-9_-]*)/g;
  const matches = [...cssContent.matchAll(classRegex)];
  return matches.map(match => match[1]);
}

function extractImportPaths(cssContent) {
  const importRegex = /@import\s+['"]([^'"]+)['"]/g;
  const matches = [...cssContent.matchAll(importRegex)];
  return matches.map(match => match[1]);
}

function extractImportOrder(cssContent) {
  return extractImportPaths(cssContent);
}

function extractVariableNames(cssContent) {
  const variableRegex = /--([\w-]+):/g;
  const matches = [...cssContent.matchAll(variableRegex)];
  return matches.map(match => `--${match[1]}`);
}

function extractUsedVariables(cssContent) {
  const usageRegex = /var\((--[\w-]+)\)/g;
  const matches = [...cssContent.matchAll(usageRegex)];
  return matches.map(match => match[1]);
}

function escapeRegExp(string) {
  return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}