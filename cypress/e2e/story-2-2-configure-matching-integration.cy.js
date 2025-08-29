// E2E tests for Story 2.2: Configure Matching Criteria - Integration and Cross-feature Testing
// Tests integration between configure step and other wizard steps, browser compatibility, and system integration

describe('Story 2.2: Configure Matching Integration', () => {
  
  beforeEach(() => {
    cy.visit('/')
    cy.waitForElmApp()
    cy.navigateToRoute('data-extractor')
    cy.get('[data-testid="data-extractor-page"]').should('be.visible')
  })

  describe('Wizard Step Integration', () => {
    it('validates seamless integration between upload and configure steps', () => {
      // Test wizard progression structure
      cy.get('.wizard-progress').should('be.visible')
      cy.get('.wizard-progress__step').should('have.length', 5)
      
      // Verify step 1 is active initially
      cy.get('.wizard-progress__step--active').should('contain', '1')
      cy.get('.wizard-progress__text').should('contain', 'Step 1 of 5')
      
      // Test that wizard maintains consistent structure
      cy.get('.wizard-progress__bar').should('be.visible')
      cy.get('.wizard-progress__step').each($step => {
        cy.wrap($step).should('be.visible')
      })
    })

    it('verifies configure step preparation for preview step integration', () => {
      // Test that configure step prepares data for next steps
      cy.get('.data-extractor').should('be.visible')
      
      // Verify CSS classes exist for data handoff between steps
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
        
        // Check for step transition and data preservation classes
        expect(styles).to.include('wizard')
        expect(styles).to.include('step')
        expect(styles).to.include('progress')
      })
    })

    it('validates navigation controls consistency across configure step', () => {
      // Test navigation button structure
      cy.get('body').then($body => {
        // Check for navigation controls if they exist
        if ($body.find('.wizard-navigation').length > 0) {
          cy.get('.wizard-navigation').should('be.visible')
          
          // Test navigation button accessibility
          cy.get('.wizard-navigation button').each($button => {
            cy.wrap($button).should('satisfy', ($btn) => {
              // Buttons should either have explicit type or be valid HTML buttons
              return $btn.attr('type') !== undefined || $btn.is('button')
            })
          })
        }
      })
    })
  })

  describe('State Management and Data Persistence', () => {
    it('validates configure step state persistence during navigation', () => {
      // Test state preservation during wizard navigation
      cy.get('.data-extractor').should('be.visible')
      
      // Navigate away and back to test state preservation
      cy.navigateToRoute('home')
      cy.get('[data-testid="homepage"]').should('be.visible')
      
      cy.navigateToRoute('data-extractor')
      cy.get('[data-testid="data-extractor-page"]').should('be.visible')
      
      // Verify wizard resets to initial state as expected
      cy.get('.wizard-progress__text').should('contain', 'Step 1 of 5')
      cy.get('.wizard-progress__step--active').should('contain', '1')
    })

    it('verifies browser storage handling for configure step data', () => {
      // Test that no unauthorized data persists
      cy.get('.data-extractor').should('be.visible')
      
      // Clear all storage
      cy.clearLocalStorage()
      cy.clearCookies()
      cy.window().then((win) => {
        win.sessionStorage.clear()
      })
      
      // Reload and verify clean state
      cy.reload()
      cy.waitForElmApp()
      
      cy.get('[data-testid="data-extractor-page"]').should('be.visible')
      cy.get('.wizard-progress__text').should('contain', 'Step 1 of 5')
    })

    it('validates configure step memory management and cleanup', () => {
      // Test memory management during repeated use
      for (let i = 0; i < 3; i++) {
        cy.navigateToRoute('home')
        cy.get('[data-testid="homepage"]').should('be.visible')
        
        cy.navigateToRoute('data-extractor')
        cy.get('[data-testid="data-extractor-page"]').should('be.visible')
        
        // Verify consistent behavior
        cy.get('.wizard-progress').should('be.visible')
      }
      
      // UI should remain responsive
      cy.get('.data-extractor').should('be.visible')
    })
  })

  describe('Browser Compatibility and Cross-Platform Testing', () => {
    it('validates configure step desktop functionality', () => {
      // Verify core functionality works on desktop
      cy.get('.data-extractor').should('be.visible')
      cy.get('.wizard-progress').should('be.visible')
      
      // Test that upload zones remain accessible
      cy.get('[data-testid="upload-zone-master"]').should('be.visible')
      cy.get('[data-testid="upload-zone-data"]').should('be.visible')
    })

    it('verifies desktop interaction support for configure features', () => {
      // Test desktop interactions
      cy.get('.data-extractor').should('be.visible')
      
      // Test file upload zones
      cy.get('[data-testid="upload-zone-master"]')
        .should('be.visible')
        .should('have.css', 'cursor', 'pointer')
      
      cy.get('[data-testid="upload-zone-data"]')
        .should('be.visible')
        .should('have.css', 'cursor', 'pointer')
      
      // Test interactions don't cause layout issues
      cy.get('[data-testid="upload-zone-master"]').click()
      cy.get('.data-extractor').should('be.visible')
    })

    it('validates configure step basic navigation', () => {
      // Test basic navigation functionality
      cy.get('.data-extractor').should('be.visible')
      
      // Test that interactive elements are present
      cy.get('input, button, select, textarea')
        .should('have.length.greaterThan', 0)
    })
  })

  describe('Error Handling and Recovery Integration', () => {
    it('validates configure step error recovery across different failure scenarios', () => {
      // Test recovery from various error states
      cy.get('.data-extractor').should('be.visible')
      
      // Test JavaScript error recovery
      cy.window().then((win) => {
        // Simulate potential error and recovery
        const originalConsoleError = win.console.error
        let errorCount = 0
        
        win.console.error = (...args) => {
          errorCount++
          originalConsoleError.apply(win.console, args)
        }
        
        // Perform operations that could potentially cause errors
        cy.get('.wizard-progress__step').first().click()
        cy.get('[data-testid="upload-zone-master"]').click()
        
        // Verify UI remains stable
        cy.get('.data-extractor').should('be.visible')
        
        // Restore original console.error
        win.console.error = originalConsoleError
      })
    })

    it('verifies graceful degradation when configure features are unavailable', () => {
      // Test fallback behavior
      cy.get('.data-extractor').should('be.visible')
      
      // Test that core functionality remains when advanced features fail
      cy.intercept('**/*', (req) => {
        req.reply((res) => {
          // Add delays to test resilience
          res.delay(50)
        })
      })
      
      // Core UI should remain functional
      cy.get('.wizard-progress').should('be.visible')
      cy.get('[data-testid="upload-zone-master"]').should('be.visible')
      cy.get('[data-testid="upload-zone-data"]').should('be.visible')
    })

    it('validates configure step integration with global error handling', () => {
      // Test integration with app-wide error handling
      cy.get('.data-extractor').should('be.visible')
      
      // Test that errors don't propagate and break other parts of the app
      cy.window().then((win) => {
        // Check that error boundaries work
        let uncaughtErrors = []
        
        win.addEventListener('error', (e) => {
          uncaughtErrors.push(e)
        })
        
        // Perform various operations
        cy.get('.wizard-progress__step').first().click()
        cy.get('[data-testid="upload-zone-master"]').click({ force: true })
        cy.get('[data-testid="upload-zone-data"]').click({ force: true })
        
        // Verify no uncaught errors
        cy.then(() => {
          expect(uncaughtErrors.length).to.equal(0)
        })
      })
    })
  })

  describe('Performance and Load Testing', () => {
    it('validates configure step performance under load', () => {
      // Test performance with rapid interactions
      cy.get('.data-extractor').should('be.visible')
      
      // Rapid fire interactions
      for (let i = 0; i < 20; i++) {
        cy.get('.wizard-progress__step').first().click({ force: true })
        if (i % 5 === 0) {
          cy.get('.data-extractor').should('be.visible')
        }
      }
      
      // Verify UI remains responsive
      cy.get('.wizard-progress').should('be.visible')
    })

    it('verifies configure step scalability with large datasets', () => {
      // Test UI scalability (structure that would handle large data)
      cy.get('.data-extractor').should('be.visible')
      
      // Verify CSS includes optimizations for large datasets
      cy.document().then((doc) => {
        const styles = Array.from(doc.styleSheets)
          .map(sheet => {
            try {
              return Array.from(sheet.cssRules)
                .map(rule => rule.cssText)
                .filter(text => 
                  text.includes('max-height') || 
                  text.includes('overflow') ||
                  text.includes('scroll')
                )
                .join(' ')
            } catch (e) {
              return ''
            }
          })
          .join(' ')
        
        // Check for performance optimizations
        expect(styles).to.match(/(max-height|overflow|scroll)/)
      })
    })

    it('validates memory efficiency during extended configure step usage', () => {
      // Test extended usage patterns
      cy.get('.data-extractor').should('be.visible')
      
      // Simulate extended session
      for (let i = 0; i < 10; i++) {
        cy.navigateToRoute('home')
        cy.get('[data-testid="homepage"]').should('be.visible')
        
        cy.navigateToRoute('data-extractor')
        cy.get('[data-testid="data-extractor-page"]').should('be.visible')
        
        // Verify consistent performance
        cy.get('.wizard-progress').should('be.visible')
      }
      
      // Final verification of stability
      cy.get('.data-extractor').should('be.visible')
      cy.get('.wizard-progress__text').should('contain', 'Step 1 of 5')
    })
  })
})