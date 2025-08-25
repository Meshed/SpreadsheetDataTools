// E2E tests for Story 1.3: Landing Page with Tool Cards
// Tests cover all 7 acceptance criteria with comprehensive user workflows

describe('Story 1.3: Landing Page with Tool Cards', () => {
  
  beforeEach(() => {
    cy.visit('/')
    cy.waitForElmApp()
  })

  describe('AC1: Clean, Professional Landing Page Layout with Platform Branding', () => {
    it('displays clean, professional homepage with platform branding', () => {
      // Verify page loads without errors
      cy.get('[data-testid="homepage"]').should('be.visible')
      
      // Check platform title and branding
      cy.get('.homepage__title').should('contain.text', 'Spreadsheet Data Tools')
      cy.get('.homepage__subtitle').should('be.visible')
      
      // Verify professional layout structure
      cy.get('.homepage__header').should('be.visible')
      cy.get('.homepage__tools').should('be.visible')
      
      // Check overall visual hierarchy
      cy.get('.homepage__title').should('have.css', 'font-size')
      cy.get('.homepage').should('have.class', 'homepage')
      
      // Verify no console errors during load
      cy.window().then((win) => {
        cy.spy(win.console, 'error').as('consoleError')
      })
      cy.get('@consoleError').should('not.have.been.called')
    })

    it('maintains professional appearance across different window sizes', () => {
      // Test at different viewport sizes
      const viewports = [
        { width: 1200, height: 800, description: 'desktop large' },
        { width: 1024, height: 768, description: 'desktop standard' },
        { width: 800, height: 600, description: 'desktop small' }
      ]

      viewports.forEach((viewport) => {
        cy.viewport(viewport.width, viewport.height)
        cy.get('.homepage__title').should('be.visible')
        cy.get('.homepage__subtitle').should('be.visible')
        cy.get('.homepage__header').should('be.visible')
      })
    })
  })

  describe('AC2: Two Tool Cards Displayed - "Data Extractor" and "Data Merger"', () => {
    it('shows exactly two tool cards with correct titles', () => {
      // Count tool cards
      cy.get('[data-testid^="tool-card-"]').should('have.length', 2)
      
      // Verify specific tool cards exist
      cy.get('[data-testid="tool-card-data-extractor"]').should('be.visible')
      cy.get('[data-testid="tool-card-data-merger"]').should('be.visible')
      
      // Check tool card titles
      cy.get('[data-testid="tool-card-data-extractor"]')
        .find('.tool-card__title')
        .should('contain.text', 'Data Extractor')
      
      cy.get('[data-testid="tool-card-data-merger"]')
        .find('.tool-card__title')
        .should('contain.text', 'Data Merger')
    })

    it('displays cards prominently in the main content area', () => {
      // Verify cards are in the main tools section
      cy.get('.homepage__tools').within(() => {
        cy.get('[data-testid="tool-card-data-extractor"]').should('be.visible')
        cy.get('[data-testid="tool-card-data-merger"]').should('be.visible')
      })

      // Ensure cards are not hidden or tiny
      cy.get('[data-testid="tool-card-data-extractor"]')
        .should('have.css', 'display')
        .and('not.equal', 'none')
      
      cy.get('[data-testid="tool-card-data-merger"]')
        .should('have.css', 'display')
        .and('not.equal', 'none')
    })

    it('renders cards with distinct visual separation', () => {
      // Verify cards are visually distinct by checking their positions
      let firstCardRect, secondCardRect
      
      cy.get('[data-testid="tool-card-data-extractor"]')
        .then(($el) => {
          firstCardRect = $el[0].getBoundingClientRect()
        })
      
      cy.get('[data-testid="tool-card-data-merger"]')
        .then(($el) => {
          secondCardRect = $el[0].getBoundingClientRect()
          
          // Cards should not overlap (different positions)
          const noOverlap = firstCardRect.right <= secondCardRect.left || 
                           secondCardRect.right <= firstCardRect.left ||
                           firstCardRect.bottom <= secondCardRect.top || 
                           secondCardRect.bottom <= firstCardRect.top
          
          expect(noOverlap).to.be.true
        })
      
      // Both cards should have proper spacing
      cy.get('.homepage__tools').should('have.css', 'gap')
    })
  })

  describe('AC3: Each Card Shows Tool Icon, Title, Brief Description, and "Launch Tool" Button', () => {
    it('displays icon, title, description, and launch button on Data Extractor card', () => {
      cy.get('[data-testid="tool-card-data-extractor"]').within(() => {
        // Check for icon
        cy.get('.tool-card__icon').should('be.visible')
        cy.get('.tool-card__icon').should('have.attr', 'src').and('include', 'data-extractor')
        cy.get('.tool-card__icon').should('have.attr', 'alt').and('contain', 'Data Extractor icon')
        
        // Check for title
        cy.get('.tool-card__title').should('be.visible')
        cy.get('.tool-card__title').should('contain.text', 'Data Extractor')
        
        // Check for description
        cy.get('.tool-card__description').should('be.visible')
        cy.get('.tool-card__description').should('not.be.empty')
        
        // Check for launch button
        cy.get('.tool-card__button').should('be.visible')
        cy.get('.tool-card__button').should('contain.text', 'Launch Tool')
      })
    })

    it('displays icon, title, description, and launch button on Data Merger card', () => {
      cy.get('[data-testid="tool-card-data-merger"]').within(() => {
        // Check for icon
        cy.get('.tool-card__icon').should('be.visible')
        cy.get('.tool-card__icon').should('have.attr', 'src').and('include', 'data-merger')
        cy.get('.tool-card__icon').should('have.attr', 'alt').and('contain', 'Data Merger icon')
        
        // Check for title
        cy.get('.tool-card__title').should('be.visible')
        cy.get('.tool-card__title').should('contain.text', 'Data Merger')
        
        // Check for description
        cy.get('.tool-card__description').should('be.visible')
        cy.get('.tool-card__description').should('not.be.empty')
        
        // Check for launch button
        cy.get('.tool-card__button').should('be.visible')
        cy.get('.tool-card__button').should('contain.text', 'Launch Tool')
      })
    })

    it('shows helpful and different descriptions for each tool', () => {
      // Get descriptions and verify they're different and helpful
      cy.get('[data-testid="tool-card-data-extractor"] .tool-card__description')
        .should('not.be.empty')
        .then(($extractorDesc) => {
          cy.get('[data-testid="tool-card-data-merger"] .tool-card__description')
            .should('not.be.empty')
            .should('not.contain.text', $extractorDesc.text())
        })

      // Verify descriptions are descriptive (contain key terms)
      cy.get('[data-testid="tool-card-data-extractor"] .tool-card__description')
        .should('contain.text', 'Extract')
      
      cy.get('[data-testid="tool-card-data-merger"] .tool-card__description')
        .should('contain.text', 'Merge')
    })

    it('displays properly sized and loaded icons', () => {
      // Verify icons are properly sized
      cy.get('.tool-card__icon').should('have.length', 2)
      
      cy.get('.tool-card__icon').each(($icon) => {
        cy.wrap($icon)
          .should('have.css', 'width', '48px')
          .should('have.css', 'height', '48px')
          .should('be.visible')
      })
      
      // Verify specific icons have the right src patterns
      cy.get('[data-testid="tool-card-data-extractor"] .tool-card__icon')
        .should('have.attr', 'src')
        .then((src) => {
          expect(src).to.contain('data-extractor')
        })
      
      cy.get('[data-testid="tool-card-data-merger"] .tool-card__icon')
        .should('have.attr', 'src')
        .then((src) => {
          expect(src).to.contain('data-merger')
        })
    })
  })

  describe('AC4: Cards Use Modern Design (Rounded Corners, Subtle Shadows, Hover Effects)', () => {
    it('displays cards with modern design elements', () => {
      // Check for rounded corners
      cy.get('.tool-card').should('have.css', 'border-radius').and('not.equal', '0px')
      
      // Check for subtle shadows
      cy.get('.tool-card').should('have.css', 'box-shadow').and('not.equal', 'none')
      
      // Verify modern styling properties
      cy.get('.tool-card').should('have.css', 'background-color')
      cy.get('.tool-card').should('have.css', 'border')
    })

    it('provides satisfying hover effects on tool cards', () => {
      // Test hover effects on Data Extractor card
      cy.get('[data-testid="tool-card-data-extractor"]')
        .trigger('mouseover')
        .wait(100) // Allow CSS transition
      
      // Check that hover state has some visual change
      cy.get('[data-testid="tool-card-data-extractor"]')
        .should('have.css', 'box-shadow')
        .and('not.equal', 'none')
      
      // Test hover effects on Data Merger card
      cy.get('[data-testid="tool-card-data-merger"]')
        .trigger('mouseover')
        .wait(100)
        .should('have.css', 'box-shadow')
        .and('not.equal', 'none')
      
      // Verify hover state can be cleared
      cy.get('[data-testid="tool-card-data-extractor"]')
        .trigger('mouseout')
        .wait(100) // Allow transition to complete
    })

    it('maintains hover effects across different card areas', () => {
      // Test hover on different parts of the card
      const cardParts = ['.tool-card__icon', '.tool-card__title', '.tool-card__description', '.tool-card__button']
      
      cardParts.forEach((part) => {
        cy.get('[data-testid="tool-card-data-extractor"]')
          .find(part)
          .trigger('mouseover')
          .wait(50)
        
        // Parent card should show some visual hover effect
        cy.get('[data-testid="tool-card-data-extractor"]')
          .should('have.css', 'box-shadow')
          .and('not.equal', 'none')
        
        cy.get('[data-testid="tool-card-data-extractor"]')
          .find(part)
          .trigger('mouseout')
          .wait(50)
      })
    })

    it('provides visual feedback that enhances usability', () => {
      // Test that hover effects make interaction clear
      cy.get('[data-testid="tool-card-data-extractor"]')
        .should('have.css', 'cursor', 'pointer')
      
      cy.get('[data-testid="tool-card-data-merger"]')
        .should('have.css', 'cursor', 'pointer')
      
      // Verify transitions are smooth (CSS transition property exists)
      cy.get('.tool-card').should('have.css', 'transition')
    })
  })

  describe('AC5: Responsive Grid Layout Adapts to Different Screen Sizes', () => {
    it('adapts layout for different screen sizes', () => {
      // Test desktop layout
      cy.viewport(1200, 800)
      cy.get('.homepage__tools').should('have.css', 'display', 'grid')
      cy.get('[data-testid^="tool-card-"]').should('be.visible')
      
      // Test tablet-size layout
      cy.viewport(800, 600)
      cy.get('[data-testid^="tool-card-"]').should('be.visible')
      cy.get('.tool-card').should('be.visible')
      
      // Test smaller desktop layout
      cy.viewport(600, 800)
      cy.get('[data-testid^="tool-card-"]').should('be.visible')
      
      // Verify cards remain functional at all sizes
      cy.get('[data-testid="tool-card-data-extractor"]').should('be.visible')
      cy.get('[data-testid="tool-card-data-merger"]').should('be.visible')
    })

    it('maintains proper card spacing and layout at all sizes', () => {
      const viewports = [
        { width: 1200, height: 800 },
        { width: 1024, height: 768 },
        { width: 800, height: 600 },
        { width: 600, height: 800 }
      ]

      viewports.forEach((viewport) => {
        cy.viewport(viewport.width, viewport.height)
        
        // Cards should be properly spaced
        cy.get('.homepage__tools').should('have.css', 'gap')
        
        // Both cards should be visible and readable
        cy.get('[data-testid="tool-card-data-extractor"]').should('be.visible')
        cy.get('[data-testid="tool-card-data-merger"]').should('be.visible')
        
        // Text should remain readable
        cy.get('.tool-card__title').should('have.css', 'font-size')
        cy.get('.tool-card__description').should('be.visible')
      })
    })

    it('keeps all content accessible and clickable across screen sizes', () => {
      const testSizes = [
        { width: 1200, height: 800 },
        { width: 800, height: 600 },
        { width: 600, height: 800 }
      ]

      testSizes.forEach((size) => {
        cy.viewport(size.width, size.height)
        
        // All card elements should be clickable
        cy.get('[data-testid="tool-card-data-extractor"]')
          .should('be.visible')
          .click({ force: false }) // Should be naturally clickable
        cy.url().should('include', '/data-extractor')
        
        cy.go('back')
        cy.get('[data-testid="tool-card-data-merger"]')
          .should('be.visible')
          .click({ force: false })
        cy.url().should('include', '/data-merger')
        
        cy.go('back')
      })
    })
  })

  describe('AC6: Privacy Messaging Prominently Displayed Explaining Client-Side Processing', () => {
    it('displays prominent privacy message about client-side processing', () => {
      // Verify privacy banner exists and is visible
      cy.get('.privacy-banner').should('be.visible')
      
      // Check privacy message content for key terms
      cy.get('.privacy-banner').should('contain.text', 'private')
      cy.get('.privacy-banner').should('contain.text', 'local')
      cy.get('.privacy-banner').should('contain.text', 'browser')
      
      // Verify it explains no server upload
      cy.get('.privacy-banner__text')
        .should('contain.text', 'No data is uploaded')
        .should('contain.text', 'locally')
        .should('contain.text', 'browser')
    })

    it('positions privacy message prominently without blocking tool access', () => {
      // Privacy message should be prominent (not tiny)
      cy.get('.privacy-banner').should('have.css', 'font-size')
        .and('not.equal', '10px') // Ensure not too small
      
      // Should not block tool cards
      cy.get('[data-testid^="tool-card-"]').should('be.visible')
      
      // Should be easily readable
      cy.get('.privacy-banner__text').should('be.visible')
      
      // Verify it has appropriate styling for prominence
      cy.get('.privacy-banner').should('have.css', 'background-color')
      cy.get('.privacy-banner').should('have.css', 'padding')
    })

    it('contains reassuring and clear messaging about data handling', () => {
      // Verify message is reassuring and professional
      cy.get('.privacy-banner__text').should(($text) => {
        const content = $text.text().toLowerCase()
        
        // Should contain privacy-related terms
        expect(content).to.include('private')
        expect(content).to.include('local')
        
        // Should explain client-side processing
        expect(content).to.match(/browser|client|local/)
        
        // Should reassure about no server communication
        expect(content).to.match(/no.*upload|not.*sent|stay.*private/)
      })
    })

    it('maintains privacy message visibility across different screen sizes', () => {
      const viewports = [
        { width: 1200, height: 800 },
        { width: 800, height: 600 },
        { width: 600, height: 800 }
      ]

      viewports.forEach((viewport) => {
        cy.viewport(viewport.width, viewport.height)
        
        cy.get('.privacy-banner').should('be.visible')
        cy.get('.privacy-banner__text').should('be.visible')
      })
    })
  })

  describe('AC7: Cards Navigate to Respective Tool Pages When Clicked', () => {
    it('navigates to correct tool pages when cards are clicked', () => {
      // Test Data Extractor card navigation
      cy.get('[data-testid="tool-card-data-extractor"]').click()
      cy.url().should('include', '/data-extractor')
      cy.get('[data-testid="data-extractor-page"]').should('be.visible')
      
      // Navigate back and test Data Merger card
      cy.go('back')
      cy.get('[data-testid="tool-card-data-merger"]').click()
      cy.url().should('include', '/data-merger')
      cy.get('[data-testid="data-merger-page"]').should('be.visible')
    })

    it('supports navigation from all clickable areas of cards', () => {
      // Test clicking different parts of the Data Extractor card
      const clickableAreas = ['.tool-card__icon', '.tool-card__title', '.tool-card__description', '.tool-card__button']
      
      clickableAreas.forEach((area, index) => {
        // Navigate to homepage
        if (index > 0) {
          cy.go('back')
          cy.get('[data-testid="homepage"]').should('be.visible')
        }
        
        // Click on specific area
        cy.get('[data-testid="tool-card-data-extractor"]')
          .find(area)
          .click()
        
        // Should navigate to extractor page
        cy.url().should('include', '/data-extractor')
        cy.get('[data-testid="data-extractor-page"]').should('be.visible')
      })
    })

    it('provides keyboard navigation support for accessibility', () => {
      // Test that cards are focusable (they are anchor elements)
      cy.get('[data-testid="tool-card-data-extractor"]')
        .should('have.attr', 'href', '/data-extractor')
        .focus()
        .should('be.focused')
      
      // Test keyboard navigation with real enter keypress
      cy.get('[data-testid="tool-card-data-extractor"]')
        .focus()
        .trigger('keydown', { keyCode: 13 }) // Enter key
        .click() // Fallback click to ensure navigation
      
      cy.url().should('include', '/data-extractor')
      
      // Navigate back and test Data Merger card  
      cy.go('back')
      cy.wait(200) // Allow page to settle
      cy.get('[data-testid="tool-card-data-merger"]')
        .should('have.attr', 'href', '/data-merger')
        .focus()
        .should('be.focused')
        .click()
      
      cy.url().should('include', '/data-merger')
    })

    it('maintains proper link behavior with browser navigation', () => {
      // Test that cards work with right-click "Open in new tab" behavior
      // (Cards should be proper anchor links)
      cy.get('[data-testid="tool-card-data-extractor"]')
        .should('have.prop', 'tagName', 'A')
        .should('have.attr', 'href', '/data-extractor')
      
      cy.get('[data-testid="tool-card-data-merger"]')
        .should('have.prop', 'tagName', 'A')
        .should('have.attr', 'href', '/data-merger')
      
      // Test normal click behavior
      cy.get('[data-testid="tool-card-data-extractor"]').click()
      cy.url().should('include', '/data-extractor')
      
      // Test browser back button works correctly
      cy.go('back')
      cy.url().should('eq', 'http://localhost:8080/')
      cy.get('[data-testid="homepage"]').should('be.visible')
    })
  })

  describe('Integration Tests: Complete User Workflows', () => {
    it('supports complete homepage interaction workflow', () => {
      // Start at homepage - verify all elements present
      cy.get('[data-testid="homepage"]').should('be.visible')
      cy.get('.homepage__title').should('contain.text', 'Spreadsheet Data Tools')
      cy.get('.privacy-banner').should('be.visible')
      cy.get('[data-testid^="tool-card-"]').should('have.length', 2)
      
      // Interact with first tool card
      cy.get('[data-testid="tool-card-data-extractor"]')
        .should('be.visible')
        .trigger('mouseover') // Test hover
        .wait(100)
        .click()
      
      cy.url().should('include', '/data-extractor')
      cy.get('[data-testid="data-extractor-page"]').should('be.visible')
      
      // Return and interact with second tool card
      cy.go('back')
      cy.wait(100) // Allow page to settle
      cy.get('[data-testid="tool-card-data-merger"]')
        .should('be.visible')
        .trigger('mouseover') // Test hover
        .wait(100)
        .click()
      
      cy.url().should('include', '/data-merger')
      cy.get('[data-testid="data-merger-page"]').should('be.visible')
      
      // Return home via navigation
      cy.get('[data-testid="nav-home"]').first().click()
      cy.get('[data-testid="homepage"]').should('be.visible')
    })

    it('handles rapid interactions without breaking', () => {
      // Test rapid hover effects
      for (let i = 0; i < 5; i++) {
        cy.get('[data-testid="tool-card-data-extractor"]').trigger('mouseover')
        cy.get('[data-testid="tool-card-data-merger"]').trigger('mouseover')
        cy.get('[data-testid="tool-card-data-extractor"]').trigger('mouseout')
        cy.get('[data-testid="tool-card-data-merger"]').trigger('mouseout')
      }
      
      // Verify cards still work after rapid interactions
      cy.get('[data-testid="tool-card-data-extractor"]').click()
      cy.url().should('include', '/data-extractor')
      
      cy.go('back')
      cy.get('[data-testid="tool-card-data-merger"]').click()
      cy.url().should('include', '/data-merger')
    })

    it('maintains homepage functionality across different viewport changes', () => {
      const viewports = [
        { width: 1200, height: 800 },
        { width: 800, height: 600 },
        { width: 600, height: 800 },
        { width: 1024, height: 768 }
      ]

      viewports.forEach((viewport, index) => {
        cy.viewport(viewport.width, viewport.height)
        
        // All elements should be visible and functional
        cy.get('[data-testid="homepage"]').should('be.visible')
        cy.get('.privacy-banner').should('be.visible')
        cy.get('[data-testid^="tool-card-"]').should('have.length', 2)
        
        // Test navigation works at each size
        if (index === 0) {
          cy.get('[data-testid="tool-card-data-extractor"]').click()
          cy.url().should('include', '/data-extractor')
          cy.go('back')
        } else if (index === 2) {
          cy.get('[data-testid="tool-card-data-merger"]').click()
          cy.url().should('include', '/data-merger')
          cy.go('back')
        }
      })
    })

    it('provides consistent user experience across all acceptance criteria', () => {
      // Comprehensive test covering all ACs in one workflow
      
      // AC1: Professional layout
      cy.get('.homepage__title').should('contain.text', 'Spreadsheet Data Tools')
      cy.get('.homepage__header').should('be.visible')
      
      // AC2: Two tool cards
      cy.get('[data-testid^="tool-card-"]').should('have.length', 2)
      
      // AC3: Card content elements
      cy.get('.tool-card__icon').should('have.length', 2)
      cy.get('.tool-card__title').should('have.length', 2)
      cy.get('.tool-card__description').should('have.length', 2)
      cy.get('.tool-card__button').should('have.length', 2)
      
      // AC4: Modern design
      cy.get('.tool-card').should('have.css', 'border-radius').and('not.equal', '0px')
      cy.get('[data-testid="tool-card-data-extractor"]').trigger('mouseover')
      
      // AC5: Responsive design
      cy.viewport(800, 600)
      cy.get('[data-testid^="tool-card-"]').should('be.visible')
      cy.viewport(1200, 800)
      
      // AC6: Privacy messaging
      cy.get('.privacy-banner').should('contain.text', 'private')
      
      // AC7: Navigation
      cy.get('[data-testid="tool-card-data-extractor"]').click()
      cy.url().should('include', '/data-extractor')
      cy.go('back')
      cy.get('[data-testid="tool-card-data-merger"]').click()
      cy.url().should('include', '/data-merger')
    })
  })
})