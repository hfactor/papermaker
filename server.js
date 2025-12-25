const express = require('express');
const cors = require('cors');
const { exec } = require('child_process');
const fs = require('fs');
const path = require('path');
const { downloadFont } = require('./font-loader');

const app = express();
const PORT = 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static('web'));
app.use('/output', express.static('output'));

// Generate PDF endpoint
app.post('/generate-pdf', (req, res) => {
    const config = req.body;

    // Validate config - support both old and new format
    const year = config.year || (config.timeRange && config.timeRange.startYear);
    if (!config || !year) {
        return res.status(400).json({ error: 'Invalid configuration: missing year' });
    }

    // Create temporary config file
    const timestamp = Date.now();
    const configPath = `temp-config-${timestamp}.json`;
    const outputName = `calendar-${config.year}-${timestamp}`;

    (async () => {
        try {
            // Download fonts first - support both old and new format
            const primaryFont = config.typography?.primaryFont || config.style?.font;
            const primaryWeight = config.typography?.fontScale ? '400' : (config.style?.fontWeight || '400');
            const secondaryFont = config.typography?.secondaryFont || config.style?.headingFont;
            const secondaryWeight = config.typography?.fontScale ? '700' : (config.style?.headingWeight || '700');

            if (primaryFont) await downloadFont(primaryFont, primaryWeight);
            if (secondaryFont && secondaryFont !== primaryFont) await downloadFont(secondaryFont, secondaryWeight);

            // Write config to temporary file
            fs.writeFileSync(configPath, JSON.stringify(config, null, 2));

            console.log(`[${new Date().toISOString()}] Generating PDF for year ${year}...`);
            console.log(`[${new Date().toISOString()}] Config file: ${configPath}`);
            console.log(`[${new Date().toISOString()}] Output name: ${outputName}`);

            // Run build script with increased buffer size (10MB)
            exec(`./build.sh ${configPath} ${outputName}`, { maxBuffer: 1024 * 1024 * 10 }, (error, stdout, stderr) => {
                // Clean up temp config file
                try {
                    fs.unlinkSync(configPath);
                } catch (e) {
                    console.error('Failed to delete temp config:', e);
                }

                // Log all output for debugging
                console.log(`[${new Date().toISOString()}] Build stdout:`, stdout);
                if (stderr) {
                    console.log(`[${new Date().toISOString()}] Build stderr:`, stderr);
                }

                if (error) {
                    console.error(`[${new Date().toISOString()}] Build error:`, error.message);
                    return res.status(500).json({
                        error: 'PDF generation failed',
                        details: stderr || stdout || error.message
                    });
                }

                const pdfPath = `output/${outputName}-${year}.pdf`;

                // Check if PDF was created
                if (fs.existsSync(pdfPath)) {
                    console.log(`[${new Date().toISOString()}] PDF generated successfully: ${pdfPath}`);
                    res.json({
                        success: true,
                        filename: `${outputName}-${year}.pdf`,
                        downloadUrl: `http://localhost:${PORT}/output/${outputName}-${year}.pdf`
                    });
                } else {
                    console.error(`[${new Date().toISOString()}] PDF file not found after build`);
                    res.status(500).json({
                        error: 'PDF file not created',
                        details: stdout || 'No output from build script'
                    });
                }
            });
        } catch (err) {
            console.error(`[${new Date().toISOString()}] Server error:`, err);
            res.status(500).json({
                error: 'Server error',
                details: err.message
            });
        }
    })();
});

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Start server
app.listen(PORT, () => {
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('📅 PDF Calendar Generator Server');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log(`✓ Server running at http://localhost:${PORT}`);
    console.log(`✓ Open http://localhost:${PORT} in your browser`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('Press Ctrl+C to stop the server\n');
});
