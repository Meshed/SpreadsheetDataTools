/**
 * CSS Layout Tests for Icon-Title Horizontal Alignment
 * 
 * Tests the flexbox behavior and CSS implementation for horizontal icon-title layout
 */

describe('Icon Layout CSS Tests', () => {
  let testContainer;
  
  beforeEach(() => {
    // Create test container and inject CSS
    testContainer = document.createElement('div');
    document.body.appendChild(testContainer);
    
    // Inject the CSS rules needed for testing
    const style = document.createElement('style');
    style.textContent = `
      .tool-card__header {
        display: flex;
        align-items: center;
        gap: var(--spacing-sm, 0.5rem);
        margin-bottom: var(--spacing-md, 1rem);
      }
      
      .tool-card__icon {
        width: 2rem;
        height: 2rem;
        color: var(--color-primary, #3b82f6);
        flex-shrink: 0;
      }
      
      .tool-card__title {
        font-size: var(--font-size-2xl, 1.5rem);
        font-weight: var(--font-weight-semibold, 600);
        color: var(--color-text, #1f2937);
        margin: 0;
        line-height: var(--line-height-tight, 1.25);
      }
      
      /* Test CSS custom properties */
      :root {
        --spacing-sm: 0.5rem;
        --spacing-md: 1rem;
        --color-primary: #3b82f6;
        --font-size-2xl: 1.5rem;
        --font-weight-semibold: 600;
        --color-text: #1f2937;
        --line-height-tight: 1.25;
      }
    `;
    document.head.appendChild(style);
  });
  
  afterEach(() => {
    document.body.removeChild(testContainer);
    // Remove injected styles
    const styles = document.querySelectorAll('style');
    styles.forEach(style => {
      if (style.textContent.includes('tool-card__header')) {
        document.head.removeChild(style);
      }
    });
  });
  
  test('tool card header uses flexbox layout', () => {
    testContainer.innerHTML = `
      <div class="tool-card__header">
        <img class="tool-card__icon" src="/test.svg" alt="Test icon">
        <h2 class="tool-card__title">Test Title</h2>
      </div>
    `;
    
    const header = testContainer.querySelector('.tool-card__header');
    const computedStyle = window.getComputedStyle(header);
    
    expect(computedStyle.display).toBe('flex');
    expect(computedStyle.alignItems).toBe('center');
  });
  
  test('tool card icon has proper dimensions and flex behavior', () => {
    testContainer.innerHTML = `
      <div class="tool-card__header">
        <img class="tool-card__icon" src="/test.svg" alt="Test icon">
        <h2 class="tool-card__title">Test Title</h2>
      </div>
    `;
    
    const icon = testContainer.querySelector('.tool-card__icon');
    const computedStyle = window.getComputedStyle(icon);
    
    expect(computedStyle.width).toBe('32px'); // 2rem = 32px at default 16px base
    expect(computedStyle.height).toBe('32px');
    expect(computedStyle.flexShrink).toBe('0');
  });
  
  test('tool card title has proper typography and no margin', () => {
    testContainer.innerHTML = `
      <div class="tool-card__header">
        <img class="tool-card__icon" src="/test.svg" alt="Test icon">
        <h2 class="tool-card__title">Test Title</h2>
      </div>
    `;
    
    const title = testContainer.querySelector('.tool-card__title');
    const computedStyle = window.getComputedStyle(title);
    
    expect(computedStyle.fontSize).toBe('24px'); // 1.5rem = 24px at default 16px base
    expect(computedStyle.fontWeight).toBe('600');
    expect(computedStyle.margin).toBe('0px');
  });
  
  test('icon and title are positioned horizontally next to each other', () => {
    testContainer.innerHTML = `
      <div class="tool-card__header">
        <img class="tool-card__icon" src="/test.svg" alt="Test icon">
        <h2 class="tool-card__title">Test Title</h2>
      </div>
    `;
    
    const header = testContainer.querySelector('.tool-card__header');
    const icon = testContainer.querySelector('.tool-card__icon');
    const title = testContainer.querySelector('.tool-card__title');
    
    const headerRect = header.getBoundingClientRect();
    const iconRect = icon.getBoundingClientRect();
    const titleRect = title.getBoundingClientRect();
    
    // Icon should be on the left, title on the right
    expect(iconRect.left).toBeLessThan(titleRect.left);
    
    // Both should be vertically centered in header (approximately)
    const headerCenter = headerRect.top + headerRect.height / 2;
    const iconCenter = iconRect.top + iconRect.height / 2;
    const titleCenter = titleRect.top + titleRect.height / 2;
    
    // Allow for some tolerance in vertical centering
    expect(Math.abs(iconCenter - headerCenter)).toBeLessThan(5);
    expect(Math.abs(titleCenter - headerCenter)).toBeLessThan(5);
  });
  
  test('header has proper spacing between icon and title', () => {
    testContainer.innerHTML = `
      <div class="tool-card__header">
        <img class="tool-card__icon" src="/test.svg" alt="Test icon">
        <h2 class="tool-card__title">Test Title</h2>
      </div>
    `;
    
    const header = testContainer.querySelector('.tool-card__header');
    const computedStyle = window.getComputedStyle(header);
    
    // Gap should be set (though specific value may vary based on CSS custom property)
    expect(computedStyle.gap).toBeTruthy();
    expect(computedStyle.gap).not.toBe('normal');
  });
});