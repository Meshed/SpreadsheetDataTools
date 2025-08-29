// E2E tests for Story 2.2: Configure Matching Criteria - Validation Edge Cases
// Tests validation rules, error handling, and edge cases

describe('Story 2.2: Configure Matching Validation', () => {
  
  beforeEach(() => {
    cy.visit('/')
    cy.waitForElmApp()
    cy.navigateToRoute('data-extractor')
    cy.get('[data-testid="data-extractor-page"]').should('be.visible')
  })

  describe('AC9: Wizard Navigation and State Management', () => {
    it('displays proper wizard progress structure', () => {
      // Test that wizard navigation structure is correct
      cy.get('.wizard-progress').should('be.visible')
      cy.get('.wizard-progress__text').should('contain', 'Step 1 of 5')
      cy.get('.wizard-progress__step').should('have.length', 5)
      
      // Verify step 1 is initially active
      cy.get('.wizard-progress__step--active').should('contain', '1')
      cy.get('.wizard-progress__step--pending').should('have.length.at.least', 4)
    })

    it('validates wizard maintains consistent structure', () => {
      // Test that wizard structure is stable
      cy.get('.wizard-navigation').should('be.visible')
      
      // Verify navigation elements exist when they should
      cy.get('body').then($body => {
        const hasNavButtons = $body.find('.wizard-navigation__button').length > 0
        
        if (hasNavButtons) {
          cy.get('.wizard-navigation__button').should('be.visible')
        }
      })
    })
  })

  describe('File Upload Validation Structure', () => {
    it('validates file upload requirements are enforced', () => {
      // Test file upload validation structure
      cy.get('[data-testid="upload-zone-master"]').should('be.visible')
      cy.get('[data-testid="upload-zone-data"]').should('be.visible')
      
      // Verify file input restrictions are applied
      cy.get('[data-testid="upload-zone-master"] input[type="file"]')
        .should('have.attr', 'accept', '.xlsx,.xls,.csv')
        .should('not.have.attr', 'multiple')
      
      cy.get('[data-testid="upload-zone-data"] input[type="file"]')
        .should('have.attr', 'accept', '.xlsx,.xls,.csv')
        .should('not.have.attr', 'multiple')
    })

    it('displays format validation information to users', () => {
      // Check that format validation messages are present in upload zones
      cy.get('[data-testid="upload-zone-master"]').within(() => {
        cy.get('.upload-zone__format-text')
          .should('contain', '.xlsx')
          .should('contain', '.xls')
          .should('contain', '.csv')
      })
      
      cy.get('[data-testid="upload-zone-data"]').within(() => {
        cy.get('.upload-zone__format-text')
          .should('contain', '.xlsx')
          .should('contain', '.xls')
          .should('contain', '.csv')
      })
    })

    it('maintains validation state during navigation', () => {
      // Test that validation persists through navigation
      cy.get('.wizard-progress').should('be.visible')
      cy.url().should('include', 'data-extractor')
      
      // Navigate away and back
      cy.navigateToRoute('home')
      cy.get('[data-testid="homepage"]').should('be.visible')
      
      cy.navigateToRoute('data-extractor')
      cy.get('[data-testid="data-extractor-page"]').should('be.visible')
      
      // Verify wizard resets to initial state
      cy.get('.wizard-progress__text').should('contain', 'Step 1 of 5')
      cy.get('.wizard-progress__step--active').should('contain', '1')
    })
  })

  describe('Form Validation and Accessibility', () => {
    it('maintains proper form accessibility standards', () => {
      // Test that file inputs have proper accessibility attributes
      cy.get('input[type="file"]').should('have.length', 2)
      
      cy.get('input[type="file"]').each($input => {
        // Verify file inputs have accept attribute
        cy.wrap($input).should('have.attr', 'accept')
        
        // Verify file inputs have id attribute  
        cy.wrap($input).should('have.attr', 'id')
      })
      
      // Verify labels exist for file inputs
      cy.get('label[for="master-file-input"]').should('exist')
      cy.get('label[for="data-file-input"]').should('exist')
    })

    it('handles user interactions without breaking UI', () => {
      // Test that invalid interactions don't break UI
      cy.get('.data-extractor').should('be.visible')
      
      // Test clicking on wizard steps (should be safe even if disabled)
      cy.get('.wizard-progress__step').each($step => {
        cy.wrap($step).click({ force: true })
        // UI should remain stable after each click
        cy.get('.data-extractor').should('be.visible')
      })
    })

    it('maintains accessible error reporting structure', () => {
      // Test that error reporting follows accessibility patterns
      cy.get('.data-extractor').should('be.visible')
      
      // Check for proper ARIA attributes when they exist
      cy.get('input').each($input => {
        cy.wrap($input).then($el => {
          if ($el.attr('aria-describedby')) {
            const describedBy = $el.attr('aria-describedby')
            cy.get(`#${describedBy}`).should('exist')
          }
        })
      })
    })
  })

  describe('Error Recovery and Browser Compatibility', () => {
    it('recovers gracefully from browser refresh', () => {
      // Test browser refresh recovery
      cy.get('.data-extractor').should('be.visible')
      
      cy.reload()
      cy.waitForElmApp()
      
      // Verify app recovers to initial state
      cy.get('[data-testid="data-extractor-page"]').should('be.visible')
      cy.get('.wizard-progress__text').should('contain', 'Step 1 of 5')
      cy.get('.wizard-progress__step--active').should('contain', '1')
    })

    it('maintains UI stability during rapid interactions', () => {
      // Test rapid interactions don't cause issues
      cy.get('.data-extractor').should('be.visible')
      
      // Rapid clicking on various elements
      cy.get('.wizard-progress__step').first().click()
      cy.get('[data-testid="upload-zone-master"]').click()
      cy.get('[data-testid="upload-zone-data"]').click()
      cy.get('.wizard-progress__step').first().click()
      
      // Verify UI remains stable
      cy.get('.data-extractor').should('be.visible')
      cy.get('.wizard-progress').should('be.visible')
    })

    it('handles different viewport sizes without breaking', () => {
      // Test cross-viewport compatibility
      const viewports = [
        [320, 568],   // Mobile
        [768, 1024],  // Tablet  
        [1920, 1080]  // Desktop
      ]
      
      viewports.forEach(([width, height]) => {
        cy.viewport(width, height)
        
        // Verify core elements remain accessible
        cy.get('.data-extractor').should('be.visible')
        cy.get('.wizard-progress').should('be.visible')
        cy.get('[data-testid="upload-zone-master"]').should('be.visible')
        cy.get('[data-testid="upload-zone-data"]').should('be.visible')
        
        // Verify file inputs remain functional
        cy.get('input[type="file"]').should('have.length', 2)
        cy.get('input[type="file"]').each($input => {
          cy.wrap($input).should('have.attr', 'accept', '.xlsx,.xls,.csv')
        })
      })
    })
  })

  describe('Validation CSS Structure', () => {
    it('validates error display CSS classes exist', () => {
      // Test that validation error CSS is defined
      cy.document().then((doc) => {
        const styles = Array.from(doc.styleSheets)
          .map(sheet => {
            try {
              return Array.from(sheet.cssRules).map(rule => rule.selectorText).join(' ')
            } catch (e) {
              return ''
            }
          })
          .join(' ')
        
        // Verify validation-related CSS classes exist
        expect(styles).to.include('.validation-error')
        expect(styles).to.include('.wizard-navigation__help')
        expect(styles).to.include('.wizard-navigation__button--disabled')
      })
    })

    it('verifies wizard navigation button CSS states', () => {
      // Test that button state CSS exists
      cy.document().then((doc) => {
        const styles = Array.from(doc.styleSheets)
          .map(sheet => {
            try {
              return Array.from(sheet.cssRules).map(rule => rule.selectorText).join(' ')
            } catch (e) {
              return ''
            }
          })
          .join(' ')
        
        // Check for button state classes
        expect(styles).to.include('.wizard-navigation__button--primary')
        expect(styles).to.include('.wizard-navigation__button--secondary')
        expect(styles).to.include('.wizard-navigation__button--disabled')
      })
    })

    it('validates responsive navigation CSS exists', () => {
      // Test that navigation CSS handles responsive design
      cy.document().then((doc) => {
        const styles = Array.from(doc.styleSheets)
          .map(sheet => {
            try {
              return Array.from(sheet.cssRules)
                .filter(rule => rule.cssText.includes('navigation') || rule.cssText.includes('button'))
                .map(rule => rule.cssText)
                .join(' ')
            } catch (e) {
              return ''
            }
          })
          .join(' ')
        
        // Check for responsive navigation styling
        expect(styles).to.match(/(flex|grid|display|padding|margin)/)
      })
    })
  })

  describe('Interactive Behavior Validation', () => {
    it('validates upload zone interactive states', () => {
      // Test that upload zones respond to interaction
      cy.get('[data-testid="upload-zone-master"]')
        .should('be.visible')
        .click()
      
      cy.get('[data-testid="upload-zone-data"]')
        .should('be.visible') 
        .click()
      
      // UI should remain stable after interactions
      cy.get('.data-extractor').should('be.visible')
    })

    it('validates interactive elements are present', () => {
      // Test that interactive elements exist for user interaction
      cy.get('input, button, select, textarea, a[href], [tabindex]').should('exist')
      
      // Verify UI remains stable and accessible
      cy.get('.data-extractor').should('be.visible')
      cy.get('.wizard-progress').should('be.visible')
    })

    it('handles edge case interactions gracefully', () => {
      // Test that edge case interactions don't break the app
      cy.get('.data-extractor').should('be.visible')
      
      // Try to trigger potential edge cases
      cy.get('body').trigger('keydown', { key: 'Escape' })
      cy.get('.data-extractor').should('be.visible')
      
      cy.get('body').trigger('keydown', { key: 'Enter' })
      cy.get('.data-extractor').should('be.visible')
      
      // Verify app remains functional
      cy.get('.wizard-progress').should('be.visible')
    })
  })
})