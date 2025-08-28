// ***********************************************
// This example commands.js shows you how to
// create various custom commands and overwrite
// existing commands.
//
// For more comprehensive examples of custom
// commands please read more here:
// https://on.cypress.io/custom-commands
// ***********************************************

// Custom command to wait for Elm app to be ready
Cypress.Commands.add('waitForElmApp', () => {
  // Wait for the app container and any page content to be ready
  cy.get('.app', { timeout: 10000 }).should('be.visible')
  cy.get('.app__content', { timeout: 10000 }).should('be.visible')
})

// Custom command to navigate using the app's navigation
// Enforces that tool navigation must go through the landing page
Cypress.Commands.add('navigateToRoute', (route) => {
  const routes = {
    'home': '[data-testid="nav-home"]',
    'data-extractor': '[data-testid="tool-card-data-extractor"]', 
    'data-merger': '[data-testid="tool-card-data-merger"]'
  }
  
  if (routes[route]) {
    if (route === 'home') {
      // Direct navigation to home via header link
      cy.get(routes[route]).first().click()
      cy.get('[data-testid="homepage"]').should('be.visible')
    } else {
      // Tool navigation: MUST go through landing page first
      cy.url().then((url) => {
        if (!url.endsWith('/') && !url.endsWith('/home')) {
          // Navigate to home first if not already there
          cy.get('[data-testid="nav-home"]').first().click()
          cy.get('[data-testid="homepage"]').should('be.visible')
        }
      })
      // Then click the tool card from the landing page
      cy.get(routes[route]).first().should('be.visible').click()
    }
  } else {
    throw new Error(`Unknown route: ${route}`)
  }
})


// Custom command to check error display
Cypress.Commands.add('expectErrorDisplay', (severity = null) => {
  cy.get('[data-testid="error-display"]').should('be.visible')
  
  if (severity) {
    cy.get('[data-testid="error-display"]').should('have.class', `error-display--${severity}`)
  }
})

// Custom command to check loading state
Cypress.Commands.add('expectLoadingState', (type = null) => {
  if (type) {
    cy.get(`[data-testid="loading-${type}"]`).should('be.visible')
  } else {
    // Check for any loading state
    cy.get('[data-testid^="loading-"]').should('be.visible')
  }
})

// Custom command to check browser compatibility warnings
Cypress.Commands.add('checkBrowserCompatibility', () => {
  cy.window().then((win) => {
    // Verify browser supports required features
    expect(win.File).to.exist
    expect(win.FileReader).to.exist
    expect(win.navigator.userAgent).to.be.a('string')
    
    // Check screen size
    const isDesktop = win.screen.width >= 1024
    if (!isDesktop) {
      cy.log(`Warning: Screen width ${win.screen.width}px is below desktop minimum (1024px)`)
    }
  })
})

// Custom command to trigger error scenarios for testing
Cypress.Commands.add('triggerTestError', (errorType = 'generic') => {
  cy.window().then((win) => {
    // This would be used to trigger specific error scenarios
    // when error boundary testing is needed
    cy.log(`Triggering test error of type: ${errorType}`)
  })
})

// Custom command to upload file to specific Data Extractor upload zone
Cypress.Commands.add('uploadFileToZone', (zoneType, fileName, fileFixture = null) => {
  const testId = `upload-zone-${zoneType}`
  const inputSelector = `[data-testid="${testId}"] input[type="file"]`
  
  if (fileFixture) {
    // Use provided fixture
    cy.fixture(fileFixture, 'binary').then((fileContent) => {
      const blob = Cypress.Blob.binaryStringToBlob(fileContent)
      const file = new File([blob], fileName, { 
        type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' 
      })
      
      cy.get(inputSelector).selectFile({ contents: file, fileName: fileName }, { force: true })
    })
  } else {
    // Create a simple test file
    const testContent = 'col1,col2\nvalue1,value2\n'
    cy.get(inputSelector).selectFile({ 
      contents: Cypress.Buffer.from(testContent), 
      fileName: fileName,
      mimeType: 'text/csv'
    }, { force: true })
  }
})

// Custom command to verify file upload success in specific zone
Cypress.Commands.add('verifyFileUploadSuccess', (zoneType, fileName) => {
  const zoneSelector = `[data-testid="upload-zone-${zoneType}"]`
  const fileTypeLabel = zoneType === 'master' ? 'Master' : 'Data'
  
  cy.get(zoneSelector)
    .should('contain.text', `${fileTypeLabel} spreadsheet uploaded successfully`)
  
  cy.get(`.upload-area--${zoneType} .upload-area__file-info`)
    .should('be.visible')
    .should('contain.text', `${fileTypeLabel} Spreadsheet`)
    .should('contain.text', fileName)
})

// Custom command to verify file upload error in specific zone
Cypress.Commands.add('verifyFileUploadError', (zoneType, errorMessage = null) => {
  const zoneSelector = `.upload-area--${zoneType} .upload-area__error`
  
  cy.get(zoneSelector).should('be.visible')
  
  if (errorMessage) {
    cy.get(zoneSelector).should('contain.text', errorMessage)
  }
})