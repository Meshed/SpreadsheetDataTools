import { Elm } from './Main.elm';
import '../assets/styles/main.css';

const app = Elm.Main.init({
  node: document.getElementById('app')
});

// Port subscriptions for file operations (only if ports exist)
if (app.ports && app.ports.readExcelFile) {
  app.ports.readExcelFile.subscribe((fileData) => {
    // File reading implementation will be added in future stories
    console.log('File reading port called:', fileData);
  });
}

if (app.ports && app.ports.downloadCSV) {
  app.ports.downloadCSV.subscribe(({ filename, content }) => {
    // CSV download implementation will be added in future stories
    console.log('CSV download port called:', filename, content);
  });
}

if (app.ports && app.ports.clearMemory) {
  app.ports.clearMemory.subscribe(() => {
    // Memory cleanup implementation will be added in future stories
    console.log('Memory cleanup port called');
  });
}

// Browser information and compatibility checking
if (app.ports && app.ports.getBrowserInfo) {
  app.ports.getBrowserInfo.subscribe(() => {
    const browserInfo = detectBrowserInfo();
    app.ports.browserInfoReceived.send(browserInfo);
  });
}


/**
 * Detect browser capabilities and information
 * @returns {Object} Browser information object
 */
function detectBrowserInfo() {
  const userAgent = navigator.userAgent;
  const screenWidth = window.screen.width;
  const screenHeight = window.screen.height;
  
  // Detect if desktop (1024px+ width)
  const isDesktop = screenWidth >= 1024;
  
  // Check File API support
  const supportsFileAPI = !!(window.File && window.FileReader && window.FileList && window.Blob);
  
  // Basic browser detection
  let browserName = 'Unknown';
  let version = 'Unknown';
  
  if (userAgent.includes('Chrome') && !userAgent.includes('Edge')) {
    browserName = 'Chrome';
    const match = userAgent.match(/Chrome\/(\d+)/);
    version = match ? match[1] : 'Unknown';
  } else if (userAgent.includes('Firefox')) {
    browserName = 'Firefox';
    const match = userAgent.match(/Firefox\/(\d+)/);
    version = match ? match[1] : 'Unknown';
  } else if (userAgent.includes('Safari') && !userAgent.includes('Chrome')) {
    browserName = 'Safari';
    const match = userAgent.match(/Version\/(\d+)/);
    version = match ? match[1] : 'Unknown';
  } else if (userAgent.includes('Edge')) {
    browserName = 'Edge';
    const match = userAgent.match(/Edge\/(\d+)/);
    version = match ? match[1] : 'Unknown';
  } else if (userAgent.includes('MSIE') || userAgent.includes('Trident')) {
    browserName = 'Internet Explorer';
    const match = userAgent.match(/(?:MSIE |rv:)(\d+)/);
    version = match ? match[1] : 'Unknown';
  }
  
  // Check if browser supports modern features needed for SheetJS
  const supportsSheetJS = checkSheetJSSupport(browserName, parseInt(version));
  
  return {
    isDesktop: isDesktop,
    supportsFileAPI: supportsFileAPI,
    supportsSheetJS: supportsSheetJS,
    browserName: browserName,
    version: version,
    screenWidth: screenWidth,
    screenHeight: screenHeight
  };
}

/**
 * Check if browser supports features needed for SheetJS
 * @param {string} browserName 
 * @param {number} version 
 * @returns {boolean}
 */
function checkSheetJSSupport(browserName, version) {
  // Minimum browser versions that support SheetJS features
  const minVersions = {
    'Chrome': 80,
    'Firefox': 75,
    'Safari': 13,
    'Edge': 80
  };
  
  if (browserName === 'Internet Explorer') {
    return false; // IE not supported
  }
  
  const minVersion = minVersions[browserName];
  return minVersion ? version >= minVersion : false;
}

// Development error reporting (only in development mode)
const isDevelopment = process.env.NODE_ENV === 'development';

if (app.ports && app.ports.reportError && isDevelopment) {
  app.ports.reportError.subscribe((errorReport) => {
    // In development, log detailed error information to console
    console.group('🐛 Development Error Report');
    console.error('Error:', errorReport.error);
    console.log('Context:', errorReport.context);
    console.log('User Agent:', errorReport.userAgent);
    console.log('Timestamp:', new Date(errorReport.timestamp));
    console.log('Session ID:', errorReport.sessionId);
    console.groupEnd();
    
    // Could also send to development error tracking service here
    // Example: sendToErrorTrackingService(errorReport);
  });
}

// Global error handler for uncaught errors (development only)
if (isDevelopment) {
  window.addEventListener('error', (event) => {
    if (app.ports && app.ports.reportError) {
      const errorReport = {
        error: event.error ? event.error.toString() : event.message,
        context: `${event.filename}:${event.lineno}:${event.colno}`,
        userAgent: navigator.userAgent,
        timestamp: Date.now(),
        sessionId: generateSessionId()
      };
      app.ports.reportError.send(errorReport);
    }
  });
  
  window.addEventListener('unhandledrejection', (event) => {
    if (app.ports && app.ports.reportError) {
      const errorReport = {
        error: event.reason ? event.reason.toString() : 'Unhandled Promise Rejection',
        context: 'Promise rejection',
        userAgent: navigator.userAgent,
        timestamp: Date.now(),
        sessionId: generateSessionId()
      };
      app.ports.reportError.send(errorReport);
    }
  });
}

/**
 * Generate a simple session ID for error tracking
 * @returns {string} Session ID
 */
function generateSessionId() {
  return Math.random().toString(36).substring(2) + Date.now().toString(36);
}