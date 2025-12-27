# PaperMaker

A modern, configurable PDF planner generator designed for digital note-taking apps like **GoodNotes**, **Notability**, and **Remarkable**. Create beautiful, functional planners with intelligent hyperlinks for seamless navigation.

![PaperMaker](https://img.shields.io/badge/version-1.0.0-blue)
![License](https://img.shields.io/badge/license-AGPL--3.0-green)

## ✨ Features

- 🎨 **Simple Web UI**: Modern, responsive interface for easy configuration
- 📅 **Flexible Pages**: Year, Quarter, Month, Week, and Daily spreads
- 🔗 **Smart Hyperlinks**: Navigate between pages with clickable links
- 🎨 **Visual Presets**: 8 curated color themes (Dracula, Nord, Gruvbox, etc.)
- 🖋️ **Customizable**: Fonts, colors, paper styles (grid/dot/line/plain)

## 🚀 Quick Start

### Prerequisites

- **Node.js** (v14 or higher)
- **Typst** (for PDF generation)

### 1. Install Dependencies

```bash
# Install Typst
brew install typst

# Install Node.js dependencies
npm install
```

### 2. Start the Web Server

```bash
npm start
```

The web interface will be available at `http://localhost:3000`

### 3. Configure Your Planner

1. Open `http://localhost:3000` in your browser
2. Configure your planner settings:
   - **Timeline**: Year, start month, duration
   - **Pages**: Select which spreads to include
   - **Style**: Choose orientation, paper style, colors
3. Click **Generate PDF**

Your planner will be generated in the `output/` directory.

## 📋 Configuration Options

### Step 1: Setup

- **Timeline**: Start year (2000-2100), month, duration
- **Week Settings**: Week start day, weekend type
- **Page Selection**: Year, Quarter, Month, Week, Daily pages

### Step 2: Customise

- **Output Format**: Portrait/Landscape, paper style, pattern density
- **Visual Presets**: 8 curated themes or custom colors
- **Daily Page**: Sidebar options, time format, active hours

### Step 3: Style

- **Typography**: Primary and secondary fonts with weights
- **Colors**: Dark, light, and accent colors
- **Visual Themes**: Dracula, Nord, Gruvbox, Solarized, and more

## 🎨 Visual Presets

- **Dracula**: Dark theme with vibrant purple accents
- **Nord**: Arctic, north-bluish color palette
- **Gruvbox**: Retro groove with warm, earthy tones
- **Solarized**: Precision colors for reduced eye strain
- **Monokai**: Iconic dark theme with vibrant highlights
- **Catppuccin**: Soothing pastel theme
- **Tokyo Night**: Clean dark theme inspired by Tokyo nights
- **GitHub**: Clean and familiar GitHub aesthetic

## 📁 Project Structure

```
papertools/
├── web/                    # Web interface
│   ├── index.html         # Main UI
│   ├── index.css          # Styling
│   └── app.js             # Configuration logic
├── templates/             # Typst templates
│   ├── main.typ           # Main orchestrator
│   ├── components/        # Page components
│   │   ├── cover.typ
│   │   ├── year.typ
│   │   ├── quarter.typ
│   │   ├── month.typ
│   │   ├── week.typ
│   │   └── daily.typ
│   └── utils/             # Helper functions
│       ├── dates.typ
│       ├── hyperlinks.typ
│       └── styles.typ
├── examples/              # Example configurations
├── fonts/                 # Font files
├── server.js              # Express server
├── build.sh               # Build script
└── package.json
```

## 🔗 Hyperlink Navigation

The planner includes intelligent hyperlinks for seamless navigation:

- **Year → Months/Days**: Click month names or day numbers
- **Quarter → Months**: Click month names
- **Month → Weeks/Days**: Click day numbers
- **Week → Days**: Click day headers
- **Back Navigation**: Every page links back to parent pages

## 💡 Tips

1. **Start Simple**: Begin with a monthly-only configuration
2. **Test Navigation**: Always test hyperlinks in your target app
3. **Save Configurations**: The web UI downloads your config as JSON
4. **Customize Colors**: Use visual presets or create custom themes
5. **Paper Styles**: "Plain" for maximum flexibility, "Line" for structured notes

## 🛠️ Advanced Usage

### Command Line Build

You can also build directly from the command line:

```bash
./build.sh path/to/config.json [output-name]
```

### Batch Generation

Generate multiple configurations:

```bash
for config in examples/*.json; do
    ./build.sh "$config"
done
```

## 📱 Compatibility

Tested with:
- ✅ **GoodNotes** (iOS/macOS)
- ✅ **Notability** (iOS/macOS)
- ✅ **Apple Notes** (iOS/macOS)
- ⚠️ **Remarkable** (limited testing)

## 🐛 Troubleshooting

### Server Won't Start

```bash
# Check if port 3000 is in use
lsof -i :3000

# Install dependencies
npm install
```

### Typst Not Found

```bash
# Install Typst
brew install typst

# Or download from: https://github.com/typst/typst
```

### PDF Generation Fails

- Check that your config JSON is valid
- Ensure all required fields are present
- Verify year is between 2000-2100

### Hyperlinks Don't Work

- Some PDF viewers don't support internal links
- Test in your target app (GoodNotes/Notability)
- Ensure you're using the latest version of the app

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Report bugs
- Suggest features
- Submit pull requests

## 📄 License

This project is licensed under the AGPL-3.0 License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

Created by [Hiran Venugopalan](https://hiran.in)

- GitHub: [@hfactor](https://github.com/hfactor)
- LinkedIn: [hfactor](https://linkedin.com/in/hfactor)

---

**Made with ❤️ for digital note-takers**
