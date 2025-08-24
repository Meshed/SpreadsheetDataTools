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