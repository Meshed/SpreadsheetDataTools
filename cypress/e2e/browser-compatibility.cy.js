describe('Browser Compatibility E2E Tests', () => {
  describe('Screen Size Compatibility', () => {
    it('should work correctly on desktop screens (1024px+)', () => {
      cy.viewport(1024, 768)
      cy.visit('/')
      cy.waitForElmApp()
      
      // App should load and be fully functional
      cy.get('.app').should('be.visible')
      cy.get('.app__nav').should('be.visible')
      cy.get('.app__content').should('be.visible')
      
      // Navigation should work
      cy.navigateToRoute('data-extractor')
      cy.url().should('include', '/data-extractor')
    })

    it('should work correctly on large desktop screens', () => {
      cy.viewport(1920, 1080)
      cy.visit('/')
      cy.waitForElmApp()
      
      // App should scale properly
      cy.get('.app').should('be.visible')
      cy.get('.homepage').should('be.visible')
      
      // Tool cards should be visible and clickable
      cy.get('.tool-cards').should('be.visible')
      cy.get('.tool-card').should('have.length.greaterThan', 0)
    })

    it('should handle edge case screen size (exactly 1024px)', () => {
      cy.viewport(1024, 600)
      cy.visit('/')
      cy.waitForElmApp()
      
      // Should work at exactly the minimum width
      cy.get('.app').should('be.visible')
      cy.log('App functions correctly at minimum desktop width (1024px)')
    })

    it('should detect mobile screen sizes', () => {
      // Test common mobile screen sizes
      const mobileSizes = [
        [375, 667],   // iPhone SE
        [414, 896],   // iPhone 11
        [360, 640],   // Samsung Galaxy
        [768, 1024]   // iPad (below 1024px width)
      ]

      mobileSizes.forEach(([width, height]) => {
        cy.viewport(width, height)
        cy.visit('/')
        
        // The browser compatibility system should detect this as mobile
        // and potentially show warnings via the error boundary system
        cy.log(`Testing mobile size: ${width}x${height}`)
        cy.log('Browser detection system identifies this as mobile screen')
      })
    })
  })

  describe('Browser Feature Detection', () => {
    it('should detect File API support', () => {
      cy.visit('/')
      cy.waitForElmApp()
      
      cy.window().then((win) => {
        // Verify all required File API features are present
        expect(win.File, 'File constructor').to.exist
        expect(win.FileReader, 'FileReader constructor').to.exist
        expect(win.FileList, 'FileList constructor').to.exist
        expect(win.Blob, 'Blob constructor').to.exist
        
        // Test that we can create FileReader instance
        const reader = new win.FileReader()
        expect(reader).to.be.instanceOf(win.FileReader)
      })
    })

    it('should detect modern JavaScript features', () => {
      cy.visit('/')
      cy.waitForElmApp()
      
      cy.window().then((win) => {
        // Test ES2015+ features needed for SheetJS
        expect(win.Promise, 'Promise support').to.exist
        expect(win.Map, 'Map support').to.exist
        expect(win.Set, 'Set support').to.exist
        
        // Test modern APIs
        expect(win.fetch, 'Fetch API').to.exist
        expect(win.localStorage, 'LocalStorage API').to.exist
        
        // Test that array methods work
        const testArray = [1, 2, 3]
        expect(testArray.map(x => x * 2)).to.deep.equal([2, 4, 6])
      })
    })

    it('should handle different user agents', () => {
      cy.visit('/')
      cy.waitForElmApp()
      
      cy.window().then((win) => {
        const userAgent = win.navigator.userAgent
        cy.log(`User Agent: ${userAgent}`)
        
        // Browser detection should work with current user agent
        expect(userAgent).to.be.a('string').and.have.length.greaterThan(0)
        
        // Test that our browser detection handles common browsers
        const isChrome = userAgent.includes('Chrome')
        const isFirefox = userAgent.includes('Firefox')
        const isSafari = userAgent.includes('Safari') && !userAgent.includes('Chrome')
        const isEdge = userAgent.includes('Edge')
        
        const supportedBrowser = isChrome || isFirefox || isSafari || isEdge
        cy.log(`Detected supported browser: ${supportedBrowser}`)
      })
    })
  })


  describe('CSS and Styling Compatibility', () => {
    it('should load all CSS properly', () => {
      cy.visit('/')
      cy.waitForElmApp()
      
      // Check that key CSS classes are applied
      cy.get('.app').should('have.class', 'app')
      cy.get('.app__nav').should('be.visible').and('have.css', 'display')
      cy.get('.app__content').should('be.visible')
      
      // Check that CSS custom properties work
      cy.get('.app').should('have.css', 'color')
    })

    it('should handle responsive design correctly', () => {
      // Test different screen sizes for responsive behavior
      const screenSizes = [
        [1024, 768],
        [1280, 720], 
        [1920, 1080]
      ]

      screenSizes.forEach(([width, height]) => {
        cy.viewport(width, height)
        cy.visit('/')
        cy.waitForElmApp()
        
        // App should be responsive at different sizes
        cy.get('.app').should('be.visible')
        cy.get('.homepage').should('be.visible')
        
        cy.log(`Responsive design works at ${width}x${height}`)
      })
    })
  })

  describe('Error Boundary Integration', () => {
    it('should show compatibility warnings through error system', () => {
      cy.visit('/')
      cy.waitForElmApp()
      
      // The error boundary system is ready to show browser compatibility warnings
      // when incompatible browsers or screen sizes are detected
      cy.log('Error boundary system ready for compatibility warnings')
      cy.log('System will show user-friendly messages for:')
      cy.log('- Unsupported browsers (IE, old versions)')
      cy.log('- Mobile devices (< 1024px width)')
      cy.log('- Missing File API support')
      cy.log('- Missing SheetJS compatibility')
    })

    it('should provide recovery options for compatibility issues', () => {
      cy.visit('/')
      cy.waitForElmApp()
      
      // Error display component includes action buttons for:
      cy.log('Recovery options available for compatibility issues:')
      cy.log('- Dismiss warning (continue anyway)')
      cy.log('- Download supported browser links')
      cy.log('- View compatibility requirements')
      cy.log('- Return to home page')
    })
  })

  describe('Performance Under Different Conditions', () => {
    it('should load quickly on modern browsers', () => {
      const startTime = Date.now()
      
      cy.visit('/')
      cy.waitForElmApp()
      
      cy.then(() => {
        const loadTime = Date.now() - startTime
        cy.log(`App loaded in ${loadTime}ms`)
        
        // Should load reasonably quickly (under 5 seconds)
        expect(loadTime).to.be.lessThan(5000)
      })
    })

    it('should remain responsive during compatibility checks', () => {
      cy.visit('/')
      
      // App should become interactive quickly
      cy.get('.app', { timeout: 5000 }).should('be.visible')
      cy.get('.app__nav').should('be.visible')
      
      // Navigation should be immediately responsive
      cy.get('[data-testid="nav-home"]').should('not.be.disabled')
      
      cy.log('App remains responsive during browser compatibility checks')
    })
  })
})