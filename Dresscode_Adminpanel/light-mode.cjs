const fs = require('fs');
const path = require('path');

const directory = 'src';

function walkSync(dir, filelist = []) {
  fs.readdirSync(dir).forEach(file => {
    const dirFile = path.join(dir, file);
    if (fs.statSync(dirFile).isDirectory()) {
      filelist = walkSync(dirFile, filelist);
    } else if (dirFile.endsWith('.jsx')) {
      filelist.push(dirFile);
    }
  });
  return filelist;
}

const files = walkSync(directory);

const replacements = [
  // Backgrounds
  { regex: /bg-black/g, replace: 'bg-gray-50' },
  { regex: /bg-neutral-900/g, replace: 'bg-white' },
  { regex: /bg-neutral-800\/50/g, replace: 'bg-gray-50/50' },
  { regex: /bg-neutral-800/g, replace: 'bg-gray-100' },
  { regex: /bg-neutral-700/g, replace: 'bg-gray-200' },
  { regex: /bg-slate-900/g, replace: 'bg-gray-50' },
  { regex: /bg-slate-800/g, replace: 'bg-white' },
  { regex: /bg-zinc-950/g, replace: 'bg-gray-50' },
  { regex: /bg-zinc-900/g, replace: 'bg-white' },
  
  // Text
  { regex: /text-white/g, replace: 'text-black' },
  { regex: /text-neutral-100/g, replace: 'text-gray-900' },
  { regex: /text-neutral-200/g, replace: 'text-gray-800' },
  { regex: /text-neutral-300/g, replace: 'text-gray-700' },
  { regex: /text-neutral-400/g, replace: 'text-gray-600' },
  { regex: /text-neutral-500/g, replace: 'text-gray-500' },
  { regex: /text-slate-400/g, replace: 'text-gray-600' },
  
  // Placeholders
  { regex: /placeholder-neutral-400/g, replace: 'placeholder-gray-500' },
  
  // Borders
  { regex: /border-black/g, replace: 'border-gray-200' },
  { regex: /border-neutral-800/g, replace: 'border-gray-200' },
  { regex: /border-neutral-700/g, replace: 'border-gray-300' },
  { regex: /border-neutral-600/g, replace: 'border-gray-300' },
  { regex: /border-slate-700/g, replace: 'border-gray-200' },
  { regex: /border-zinc-800/g, replace: 'border-gray-200' },
  
  // Ring Offset
  { regex: /ring-offset-neutral-800/g, replace: 'ring-offset-white' },
];

files.forEach(file => {
  let content = fs.readFileSync(file, 'utf8');
  let newContent = content;
  
  replacements.forEach(({ regex, replace }) => {
    newContent = newContent.replace(regex, replace);
  });
  
  if (content !== newContent) {
    fs.writeFileSync(file, newContent, 'utf8');
    console.log(`Updated ${file}`);
  }
});
