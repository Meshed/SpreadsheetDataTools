/**
 * E2E Tests for Icon Layout Visual Verification
 * 
 * Tests that verify the horizontal icon-title layout works correctly in the browser
 */

describe('Icon Layout Visual Tests', () => {
  beforeEach(() => {
    cy.visit('/')
  })

  it('displays icons horizontally next to titles', () => {
    // Find both tool cards
    cy.get('[data-testid="tool-card-data-extractor"]').within(() => {
      // Check header structure exists
      cy.get('.tool-card__header').should('exist')
      
      // Check icon and title are both present
      cy.get('.tool-card__icon').should('be.visible')
      cy.get('.tool-card__title').should('contain', 'Data Extractor')
    })

    cy.get('[data-testid="tool-card-data-merger"]').within(() => {
      // Check header structure exists
      cy.get('.tool-card__header').should('exist')
      
      // Check icon and title are both present
      cy.get('.tool-card__icon').should('be.visible')
      cy.get('.tool-card__title').should('contain', 'Data Merger')
    })
  })

  it('positions icons to the left of titles horizontally', () => {
    // Test Data Extractor card layout
    cy.get('[data-testid="tool-card-data-extractor"] .tool-card__header').within(() => {
      cy.get('.tool-card__icon').then($icon => {
        cy.get('.tool-card__title').then($title => {
          const iconRect = $icon[0].getBoundingClientRect()
          const titleRect = $title[0].getBoundingClientRect()
          
          // Icon should be to the left of title
          expect(iconRect.left).to.be.lessThan(titleRect.left)
          
          // Icon and title should be roughly on the same horizontal line (within 20px tolerance)
          expect(Math.abs(iconRect.top - titleRect.top)).to.be.lessThan(20)
        })
      })
    })

    // Test Data Merger card layout  
    cy.get('[data-testid="tool-card-data-merger"] .tool-card__header').within(() => {
      cy.get('.tool-card__icon').then($icon => {
        cy.get('.tool-card__title').then($title => {
          const iconRect = $icon[0].getBoundingClientRect()
          const titleRect = $title[0].getBoundingClientRect()
          
          // Icon should be to the left of title
          expect(iconRect.left).to.be.lessThan(titleRect.left)
          
          // Icon and title should be roughly on the same horizontal line
          expect(Math.abs(iconRect.top - titleRect.top)).to.be.lessThan(20)
        })
      })
    })
  })

  it('loads both custom SVG icons properly', () => {
    // Check Data Extractor icon loads
    cy.get('[data-testid="tool-card-data-extractor"] .tool-card__icon')
      .should('have.attr', 'src', '/assets/images/icons/data-extractor.svg')
      .should('have.attr', 'alt', 'Data Extractor icon')
      .and(($img) => {
        // Verify image actually loads (not a broken image)
        expect($img[0].naturalWidth).to.be.greaterThan(0)
      })

    // Check Data Merger icon loads
    cy.get('[data-testid="tool-card-data-merger"] .tool-card__icon')
      .should('have.attr', 'src', '/assets/images/icons/data-merger.svg')
      .should('have.attr', 'alt', 'Data Merger icon')
      .and(($img) => {
        // Verify image actually loads (not a broken image)
        expect($img[0].naturalWidth).to.be.greaterThan(0)
      })
  })

  it('applies proper CSS classes for BEM methodology', () => {
    cy.get('.tool-card__header').should('have.length', 2)
    cy.get('.tool-card__icon').should('have.length', 2)
    cy.get('.tool-card__title').should('have.length', 2)
    
    // Each header should contain exactly one icon and one title
    cy.get('.tool-card__header').each($header => {
      cy.wrap($header).within(() => {
        cy.get('.tool-card__icon').should('have.length', 1)
        cy.get('.tool-card__title').should('have.length', 1)
      })
    })
  })

  it('maintains layout structure on mobile viewport', () => {
    cy.viewport('iphone-6')
    
    // Icons should still be horizontal on mobile
    cy.get('[data-testid="tool-card-data-extractor"] .tool-card__header').within(() => {
      cy.get('.tool-card__icon').then($icon => {
        cy.get('.tool-card__title').then($title => {
          const iconRect = $icon[0].getBoundingClientRect()
          const titleRect = $title[0].getBoundingClientRect()
          
          // Icon should still be to the left of title on mobile
          expect(iconRect.left).to.be.lessThan(titleRect.left)
        })
      })
    })
  })
})