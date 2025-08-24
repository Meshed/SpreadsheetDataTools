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
Cypress.Commands.add('navigateToRoute', (route) => {
  const routes = {
    'home': '[data-testid="nav-home"]',
    'data-extractor': '[data-testid="nav-data-extractor"]', 
    'data-merger': '[data-testid="nav-data-merger"]'
  }
  
  if (routes[route]) {
    cy.get(routes[route]).first().click()
  } else {
    throw new Error(`Unknown route: ${route}`)
  }
})