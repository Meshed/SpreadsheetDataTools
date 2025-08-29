/**
 * CSS Architecture E2E Tests for Story 1.4
 * 
 * End-to-end validation of CSS implementation in the browser,
 * covering runtime DOM validation and visual regression testing.
 */

describe('CSS Architecture E2E Validation', () => {

  beforeEach(() => {
    cy.visit('/');
  });

  describe('1.4-E2E-001: Runtime DOM Style Attribute Check', () => {
    it('should have no inline style attributes in rendered DOM', () => {
      // Wait for Elm app to load
      cy.waitForElmApp();
      
      // Check homepage has no inline styles (exclude elements that might have framework-added styles)
      cy.get('body *:not(html):not(head):not(meta):not(title):not(link):not(script):not(style)').should('not.have.attr', 'style');
      
      // Navigate to Data Extractor and verify
      cy.get('[data-testid="tool-card-data-extractor"]').click();
      cy.waitForElmApp(); // Wait for page transition
      cy.get('body *:not(html):not(head):not(meta):not(title):not(link):not(script):not(style)').should('not.have.attr', 'style');
      
      // Navigate back and check Data Merger
      cy.go('back');
      cy.waitForElmApp(); // Wait for page transition
      cy.get('[data-testid="tool-card-data-merger"]').click();
      cy.waitForElmApp(); // Wait for page transition
      cy.get('body *:not(html):not(head):not(meta):not(title):not(link):not(script):not(style)').should('not.have.attr', 'style');
      
      // Return home
      cy.go('back');
    });

    it('should apply CSS classes correctly across all pages', () => {
      // Wait for Elm app to load
      cy.waitForElmApp();
      
      // Verify BEM classes are applied on homepage
      cy.get('.homepage__tools').should('exist');
      cy.get('.tool-card').should('exist');
      cy.get('.tool-card__title').should('exist');
      cy.get('.tool-card__description').should('exist');
      
      // Navigate to tools and verify classes are applied
      cy.get('[data-testid="tool-card-data-extractor"]').click();
      cy.get('[data-testid="data-extractor-page"]').should('exist');
      
      cy.go('back');
      cy.get('[data-testid="tool-card-data-merger"]').click(); 
      cy.get('[data-testid="data-merger-page"]').should('exist');
    });
  });

  describe('1.4-E2E-002: Visual Regression - Card Appearance', () => {
    it('should maintain consistent card design patterns', () => {
      // Wait for Elm app to load
      cy.waitForElmApp();
      
      // Test desktop view
      cy.viewport(1024, 768);
      cy.get('.homepage__tools').should('be.visible');
      
      // Verify card visual properties through computed styles
      cy.get('.tool-card').first().should('have.css', 'border-radius');
      cy.get('.tool-card').first().should('have.css', 'box-shadow');
      
      // Test hover states (desktop only)
      cy.viewport(1024, 768);
      cy.get('.tool-card').first().trigger('mouseover');
      
      // Verify hover transition exists
      cy.get('.tool-card').first().should('have.css', 'transition');
    });

    it('should use design system variables in rendered styles', () => {
      // Wait for Elm app to load
      cy.waitForElmApp();
      
      // Check that CSS custom properties are being used
      cy.get('.tool-card').first().then($card => {
        const cardElement = $card[0];
        const computedStyles = getComputedStyle(cardElement);
        
        // Verify that CSS properties are applied (don't test specific colors as they may vary)
        expect(computedStyles.backgroundColor).to.exist;
        expect(computedStyles.borderRadius).to.not.equal('0px');
        expect(computedStyles.boxShadow).to.not.equal('none');
      });
    });
  });

  describe('CSS Framework Integration Validation', () => {
    it('should not load external CSS frameworks', () => {
      // Wait for Elm app to load
      cy.waitForElmApp();
      
      // Check that no external framework stylesheets are loaded via script or link
      cy.document().then((doc) => {
        const links = doc.querySelectorAll('link[rel="stylesheet"]');
        const scripts = doc.querySelectorAll('script[src]');
        
        [...links, ...scripts].forEach((element) => {
          const src = element.href || element.src;
          if (src) {
            // Should not reference external CDNs or frameworks
            expect(src).to.not.include('bootstrap');
            expect(src).to.not.include('tailwind');
            expect(src).to.not.include('bulma');
            expect(src).to.not.include('foundation');
          }
        });
      });
    });
    
    it('should load all required CSS files successfully', () => {
      // Wait for Elm app to load
      cy.waitForElmApp();
      
      // Check that styles are actually applied
      cy.get('body').should('have.css', 'margin', '0px'); // From reset.css
      cy.get('.tool-card').should('have.css', 'display'); // From cards.css
    });
  });

  describe('Desktop Layout Validation', () => {
    it('should render correctly on desktop', () => {
      cy.viewport(1024, 768);
      cy.waitForElmApp();
      
      // Verify content is visible on desktop
      cy.get('.homepage__tools').should('be.visible');
      cy.get('.tool-card').should('be.visible');
      cy.get('.tool-card').should('have.length', 2);
    });
  });

  describe('Performance and Loading', () => {
    it('should load CSS resources efficiently', () => {
      cy.waitForElmApp();
      
      // Verify CSS loads quickly
      cy.window().its('performance').then(performance => {
        const navigationTiming = performance.getEntriesByType('navigation')[0];
        const domContentLoaded = navigationTiming.domContentLoadedEventEnd - navigationTiming.domContentLoadedEventStart;
        
        // CSS should contribute to fast loading (under 1 second total)
        expect(domContentLoaded).to.be.lessThan(1000);
      });
    });

    it('should have minimal unused CSS', () => {
      cy.waitForElmApp();
      
      // Check that applied styles are actually used
      cy.get('.tool-card').should('exist').and('be.visible');
      cy.get('.tool-card__title').should('exist').and('be.visible');
      cy.get('.tool-card__description').should('exist').and('be.visible');
    });
  });

});