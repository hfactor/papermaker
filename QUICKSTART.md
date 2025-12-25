# PDF Calendar Generator - Quick Start

## 🚀 One-Command Start

```bash
./start.sh
```

This will:
1. Check if Node.js and Typst are installed
2. Install dependencies if needed
3. Start the server at `http://localhost:3000`

## 📝 Generate Your Calendar

1. **Open the web interface** (automatically opens or visit):
   ```
   http://localhost:3000
   ```

2. **Configure your calendar**:
   - Select pages (Year, Quarter, Month, Week, Daily)
   - Choose your year
   - Set preferences (colors, fonts, paper style)

3. **Click "Generate PDF"**:
   - The server compiles your calendar
   - PDF opens automatically in a new tab
   - Also saved in `output/` folder

## ✅ That's It!

No terminal commands, no manual steps. Just configure and click!

---

## 📋 Requirements

- **Node.js** (for the web server)
  ```bash
  brew install node  # macOS
  ```

- **Typst** (for PDF generation)
  ```bash
  brew install typst  # macOS
  ```

## 🛠️ Manual Commands (if needed)

```bash
# Install dependencies
npm install

# Start server
npm start

# Stop server
Ctrl+C
```

## 📁 Output

Generated PDFs are saved in:
```
output/calendar-YYYY-timestamp.pdf
```

## 🎯 Import to Note-Taking Apps

1. Open the generated PDF
2. Import to:
   - **GoodNotes**: Share → Import to GoodNotes
   - **Notability**: Import → Choose PDF
   - **Remarkable**: Transfer via USB/Cloud

Enjoy your hyperlinked calendar! 🎉
