# PDF Calendar Generator

A configurable PDF calendar system designed for digital note-taking apps like **GoodNotes**, **Notability**, and **Remarkable**. Create minimal, functional calendars with intelligent hyperlinks for seamless navigation.

## Features

- ✨ **Configurable Pages**: Choose from Year, Quarter, Month, Week, and Daily spreads
- 🔗 **Smart Hyperlinks**: Navigate between pages with clickable links
- 🎨 **Customizable**: Fonts, colors, paper styles (grid/dot/line/plain)
- 📱 **Digital-First**: Optimized for tablet note-taking apps
- 🎯 **Minimal Design**: Clean, functional aesthetics

## Quick Start

### 1. Install Typst

```bash
# macOS
brew install typst

# Or download from: https://github.com/typst/typst
```

### 2. Configure Your Calendar

Open `web/index.html` in your browser to create your configuration:

```bash
open web/index.html
```

Fill out the form and download your configuration JSON file.

### 3. Generate PDF

```bash
./build.sh path/to/your-config.json
```

The PDF will be generated in the `output/` directory.

## Configuration Options

### Pages to Include

- **Year Calendar**: Full year overview with 12-month grid
- **Quarter Spreads**: 3-month overview per quarter (Q1-Q4)
- **Month Spreads**: Detailed monthly calendars
- **Weekly Spreads**: 7-day layouts
- **Daily Pages**: One page per day

### Calendar Settings

- **Year**: 2000-2100
- **Week Starts On**: Monday or Sunday
- **Weekend Color**: Custom color for weekend highlighting
- **Month Format**: Full (January), Abbreviated (Jan), or Single (J)

### Paper Style

- **Plain**: No background pattern
- **Grid**: Grid pattern for structured notes
- **Dot**: Dot grid pattern
- **Line**: Horizontal lines

### Customization

- **Font**: Choose from preset fonts or specify custom
- **Primary Color**: Main color for text and accents
- **First Page Title**: Custom title for your calendar

## Example Configurations

### Full Calendar (All Pages)

```bash
./build.sh examples/full-calendar.json
```

Includes: Year + Quarters + Months + Weeks + Daily pages

### Monthly Only

```bash
./build.sh examples/monthly-only.json
```

Includes: Year overview + Monthly spreads

### Minimal (Daily Planner)

```bash
./build.sh examples/minimal.json
```

Includes: Year overview + Daily pages with lined paper

## Project Structure

```
papertools/
├── web/                    # Configuration interface
│   ├── index.html         # Web form
│   ├── styles.css         # Styling
│   └── app.js             # Configuration logic
├── templates/             # Typst templates
│   ├── main.typ           # Main orchestrator
│   ├── components/        # Page components
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
├── output/                # Generated PDFs
├── build.sh               # Build script
└── README.md
```

## How It Works

1. **Configure**: Use the web interface to select your preferences
2. **Export**: Download configuration as JSON
3. **Build**: Run build script to generate PDF
4. **Import**: Load PDF into your note-taking app
5. **Navigate**: Use hyperlinks to move between pages

## Hyperlink Navigation

The calendar includes intelligent hyperlinks:

- **Year → Months/Days**: Click month names or day numbers
- **Year → Quarters**: Click quarter links (if enabled)
- **Quarter → Months**: Click month names
- **Month → Weeks/Days**: Click day numbers
- **Week → Days**: Click day headers
- **Back Navigation**: Every page has links back to parent pages

## Compatibility

Tested with:
- ✅ **GoodNotes** (iOS/macOS)
- ✅ **Notability** (iOS/macOS)
- ⚠️ **Remarkable** (limited testing)

## Tips

1. **Start Simple**: Begin with monthly-only configuration, then add more pages
2. **Test Navigation**: Always test hyperlinks in your target app before printing
3. **Save Configurations**: Keep your JSON files for future years
4. **Customize Colors**: Match your app's theme for consistency
5. **Paper Styles**: Use "plain" for maximum flexibility, "line" for structured notes

## Troubleshooting

### Typst Not Found

```bash
# Install Typst
brew install typst
```

### Build Fails

- Check that your config JSON is valid
- Ensure all required fields are present
- Verify year is between 2000-2100

### Hyperlinks Don't Work

- Some PDF viewers don't support internal links
- Test in your target app (GoodNotes/Notability)
- Ensure you're using the latest version of the app

## Advanced Usage

### Custom Fonts

To use a custom font:

1. Select "Custom..." in the font dropdown
2. Enter the exact font name (must be installed on your system)
3. Generate PDF

### Multiple Years

Generate calendars for multiple years:

```bash
# Edit config to change year, then:
./build.sh my-config.json calendar-2025
./build.sh my-config.json calendar-2026
```

### Batch Generation

Create a script to generate multiple configurations:

```bash
for config in examples/*.json; do
    ./build.sh "$config"
done
```

## Contributing

This is a personal project, but suggestions and improvements are welcome!

## License

MIT License - Feel free to use and modify for personal use.

---

**Created with ❤️ for digital note-takers**
