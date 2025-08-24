import { Elm } from './Main.elm';
import '../assets/styles/main.css';

const app = Elm.Main.init({
  node: document.getElementById('app')
});

// Port subscriptions for file operations
app.ports.readExcelFile.subscribe((fileData) => {
  // File reading implementation will be added in future stories
  console.log('File reading port called:', fileData);
});

app.ports.downloadCSV.subscribe(({ filename, content }) => {
  // CSV download implementation will be added in future stories
  console.log('CSV download port called:', filename, content);
});

app.ports.clearMemory.subscribe(() => {
  // Memory cleanup implementation will be added in future stories
  console.log('Memory cleanup port called');
});