import { Elm } from './Main.elm';
import '../assets/styles/main.css';
import * as XLSX from 'xlsx';
import { saveAs } from 'file-saver';

const app = Elm.Main.init({
  node: document.getElementById('app')
});

// Port subscriptions for file operations (only if ports exist)
if (app.ports && app.ports.readExcelFile) {
  app.ports.readExcelFile.subscribe((fileData) => {
    readExcelFile(fileData);
  });
}

if (app.ports && app.ports.downloadCSV) {
  app.ports.downloadCSV.subscribe(({ filename, content }) => {
    downloadCSV(filename, content);
  });
}

if (app.ports && app.ports.clearMemory) {
  app.ports.clearMemory.subscribe(() => {
    clearFileMemory();
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

// Global variables for memory management
let fileCache = new Map();
let fileIdCounter = 0;

/**
 * Read Excel/CSV file using SheetJS and send result back to Elm
 * @param {Object} fileData - File object from Elm
 */
function readExcelFile(fileData) {
  try {
    // Extract file information
    const file = fileData;
    const fileName = file.name || 'Unknown';
    const fileSize = file.size || 0;
    const fileType = file.type || '';
    const fileId = generateFileId();
    
    // Validate file type
    const supportedTypes = [
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', // .xlsx
      'application/vnd.ms-excel', // .xls
      'text/csv', // .csv
      'application/csv',
      'text/comma-separated-values'
    ];
    
    const supportedExtensions = ['.xlsx', '.xls', '.csv'];
    const hasValidExtension = supportedExtensions.some(ext => 
      fileName.toLowerCase().endsWith(ext)
    );
    
    const hasValidMimeType = supportedTypes.includes(fileType) || fileType === '';
    
    if (!hasValidExtension && !hasValidMimeType) {
      sendFileError(fileId, fileName, 'Invalid file type', {
        fileName: fileName,
        fileType: fileType || 'unknown',
        supportedTypes: ['.xlsx', '.xls', '.csv']
      });
      return;
    }
    
    // Validate file size (50MB limit)
    const maxSizeBytes = 50 * 1024 * 1024; // 50MB
    if (fileSize > maxSizeBytes) {
      sendFileError(fileId, fileName, 'File too large', {
        fileName: fileName,
        actualSize: fileSize,
        maxSize: maxSizeBytes
      });
      return;
    }
    
    // Read the file
    const reader = new FileReader();
    
    reader.onload = function(e) {
      try {
        const data = new Uint8Array(e.target.result);
        const workbook = XLSX.read(data, { type: 'array' });
        
        // Get the first sheet
        const sheetName = workbook.SheetNames[0];
        if (!sheetName) {
          sendFileError(fileId, fileName, 'File contains no readable sheets');
          return;
        }
        
        const worksheet = workbook.Sheets[sheetName];
        const jsonData = XLSX.utils.sheet_to_json(worksheet, { 
          header: 1,
          defval: '',
          raw: false
        });
        
        if (!jsonData || jsonData.length === 0) {
          sendFileError(fileId, fileName, 'File appears to be empty');
          return;
        }
        
        // Extract headers and rows
        const headers = jsonData[0] || [];
        const rows = jsonData.slice(1);
        
        // Validate data structure
        if (headers.length === 0) {
          sendFileError(fileId, fileName, 'File contains no headers');
          return;
        }
        
        // Store in cache for memory management
        const fileResult = {
          fileId: fileId,
          fileName: fileName,
          fileSize: fileSize,
          headers: headers,
          rows: rows,
          rowCount: rows.length,
          columnCount: headers.length
        };
        
        fileCache.set(fileId, fileResult);
        
        // Send success result back to Elm
        if (app.ports && app.ports.fileDataReceived) {
          app.ports.fileDataReceived.send(fileResult);
        }
        
      } catch (parseError) {
        sendFileError(fileId, fileName, 'Failed to parse file: ' + parseError.message);
      }
    };
    
    reader.onerror = function() {
      sendFileError(fileId, fileName, 'Failed to read file');
    };
    
    // Start reading the file
    reader.readAsArrayBuffer(file);
    
  } catch (error) {
    console.error('File reading error:', error);
    sendFileError('unknown', 'Unknown', 'Unexpected error reading file: ' + error.message);
  }
}

/**
 * Send file processing error back to Elm
 * @param {string} fileId - File identifier
 * @param {string} fileName - Original file name
 * @param {string} errorMessage - Error description
 * @param {Object} errorDetails - Additional error details
 */
function sendFileError(fileId, fileName, errorMessage, errorDetails = {}) {
  const errorResult = {
    fileId: fileId,
    fileName: fileName,
    success: false,
    error: errorMessage,
    errorDetails: errorDetails
  };
  
  if (app.ports && app.ports.fileDataReceived) {
    app.ports.fileDataReceived.send(errorResult);
  }
}

/**
 * Generate unique file identifier
 * @returns {string} File ID
 */
function generateFileId() {
  return 'file_' + (++fileIdCounter) + '_' + Date.now();
}

/**
 * Download CSV file using FileSaver.js
 * @param {string} filename - Target filename
 * @param {string} content - CSV content
 */
function downloadCSV(filename, content) {
  try {
    const blob = new Blob([content], { type: 'text/csv;charset=utf-8' });
    saveAs(blob, filename);
  } catch (error) {
    console.error('CSV download error:', error);
  }
}

/**
 * Clear file cache to free memory
 */
function clearFileMemory() {
  try {
    fileCache.clear();
    fileIdCounter = 0;
    
    // Force garbage collection if available
    if (window.gc) {
      window.gc();
    }
    
    console.log('File memory cleared successfully');
  } catch (error) {
    console.error('Memory cleanup error:', error);
  }
}