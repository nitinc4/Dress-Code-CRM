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
  { regex: /bg-slate-900/g, replace: 'bg-black' },
  { regex: /bg-zinc-950/g, replace: 'bg-black' },
  { regex: /bg-slate-800/g, replace: 'bg-neutral-900' },
  { regex: /bg-zinc-900/g, replace: 'bg-neutral-900' },
  { regex: /bg-slate-700/g, replace: 'bg-neutral-800' },
  { regex: /bg-zinc-800/g, replace: 'bg-neutral-800' },
  { regex: /bg-slate-600/g, replace: 'bg-neutral-700' },
  
  // Text
  { regex: /text-slate-500/g, replace: 'text-neutral-500' },
  { regex: /text-zinc-500/g, replace: 'text-neutral-500' },
  { regex: /text-slate-400/g, replace: 'text-neutral-400' },
  { regex: /text-zinc-400/g, replace: 'text-neutral-400' },
  { regex: /text-slate-300/g, replace: 'text-neutral-300' },
  { regex: /text-zinc-300/g, replace: 'text-neutral-300' },
  { regex: /text-slate-200/g, replace: 'text-neutral-200' },
  { regex: /text-zinc-200/g, replace: 'text-neutral-200' },
  { regex: /text-slate-100/g, replace: 'text-neutral-100' },
  { regex: /text-zinc-100/g, replace: 'text-neutral-100' },

  // Borders
  { regex: /border-slate-700/g, replace: 'border-neutral-800' },
  { regex: /border-zinc-800/g, replace: 'border-neutral-800' },
  { regex: /border-slate-600/g, replace: 'border-neutral-700' },
  { regex: /border-zinc-950/g, replace: 'border-black' },
  
  // Accents (Violet, Blue, Indigo) -> Gold
  { regex: /violet-500/g, replace: 'gold-500' },
  { regex: /violet-400/g, replace: 'gold-400' },
  { regex: /indigo-500/g, replace: 'gold-500' },
  { regex: /indigo-600/g, replace: 'gold-600' },
  { regex: /indigo-400/g, replace: 'gold-400' },
  { regex: /blue-500/g, replace: 'gold-500' },
  { regex: /blue-600/g, replace: 'gold-500' },
  { regex: /blue-700/g, replace: 'gold-600' },
  { regex: /blue-400/g, replace: 'gold-400' },
  
  // Specific shadow
  { regex: /shadow-\[0_0_15px_rgba\(139,92,246,0\.1\)\]/g, replace: 'shadow-[0_0_15px_rgba(234,179,8,0.1)]' }
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
