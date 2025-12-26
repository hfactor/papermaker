const express = require('express');
const cors = require('cors');
const { exec } = require('child_process');
const fs = require('fs');
const path = require('path');
const { downloadFont } = require('./font-loader');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json({ limit: '1mb' }));
app.use(express.static('web'));
app.use('/output', express.static('output'));
app.use('/uploads', express.static('uploads'));

// Ensure uploads directory exists
const UPLOADS_DIR = path.join(__dirname, 'uploads');
if (!fs.existsSync(UPLOADS_DIR)) fs.mkdirSync(UPLOADS_DIR);

// Automatic cleanup: Delete files in output/ older than 1 hour
function cleanupOutput() {
    const outputDir = path.join(__dirname, 'output');
    if (!fs.existsSync(outputDir)) return;

    const now = Date.now();
    const expiry = 60 * 60 * 1000; // 1 hour

    fs.readdir(outputDir, (err, files) => {
        if (err) return console.error('Cleanup error:', err);
        files.forEach(file => {
            if (file === '.gitkeep') return;
            const filePath = path.join(outputDir, file);
            fs.stat(filePath, (err, stats) => {
                if (err) return;
                if (now - stats.mtimeMs > expiry) {
                    fs.unlink(filePath, () => console.log(`[Cleanup] Deleted old file: ${file}`));
                }
            });
        });
    });
}
setInterval(cleanupOutput, 15 * 60 * 1000); // Run every 15 mins

// Upload endpoint
app.post('/upload', express.raw({ type: 'image/*', limit: '5mb' }), (req, res) => {
    const ext = req.headers['x-file-extension'] || 'png';
    const filename = `upload-${Date.now()}.${ext}`;
    const filePath = path.join(UPLOADS_DIR, filename);

    fs.writeFile(filePath, req.body, (err) => {
        if (err) return res.status(500).json({ error: 'Upload failed' });
        res.json({ success: true, url: `/uploads/${filename}`, path: filePath });
    });
});

// Generate PDF endpoint
app.post('/generate-pdf', async (req, res) => {
    const config = req.body;
    const year = config.year || (config.timeRange && config.timeRange.startYear) || new Date().getFullYear();

    // Create temporary config file
    const timestamp = Date.now();
    const configPath = path.join(__dirname, `temp-config-${timestamp}.json`);
    const outputBaseName = `plan-${timestamp}`;
    const outputFileName = `${outputBaseName}-${year}.pdf`;

    try {
        // 1. Download fonts needed for this build (supporting both V1 and old format)
        const primaryFont = config.typography?.primaryFont || config.style?.font;
        const secondaryFont = config.typography?.secondaryFont || config.style?.headingFont;

        const fonts = [
            { name: primaryFont, weight: '400' },
            { name: secondaryFont, weight: '700' }
        ].filter(f => f.name);

        for (const font of fonts) {
            const success = await downloadFont(font.name, font.weight);
            if (!success) {
                console.warn(`[Build] Warning: Failed to download font: ${font.name}. Build may use system fallbacks.`);
            }
        }

        // 2. Write config
        fs.writeFileSync(configPath, JSON.stringify(config, null, 2));

        console.log(`[Build] Starting PDF generation for ${year}...`);

        // 3. Run build script
        exec(`./build.sh "${configPath}" "${outputBaseName}"`, { maxBuffer: 10 * 1024 * 1024 }, (error, stdout, stderr) => {
            // Cleanup temp config immediately
            fs.unlink(configPath, () => { });

            if (error) {
                console.error(`[Build] Error:`, error.message);
                if (stderr) console.error(`[Build] Stderr:`, stderr);
                if (stdout) console.log(`[Build] Stdout:`, stdout);
                return res.status(500).json({ error: 'Generation failed', details: stderr || stdout || error.message });
            }

            const pdfPath = path.join(__dirname, 'output', outputFileName);
            if (fs.existsSync(pdfPath)) {
                // Return dynamic URL based on request host
                const protocol = req.headers['x-forwarded-proto'] || req.protocol;
                const host = req.headers.host;
                res.json({
                    success: true,
                    filename: outputFileName,
                    downloadUrl: `${protocol}://${host}/output/${outputFileName}`
                });
            } else {
                res.status(500).json({ error: 'File not created', details: stdout });
            }
        });
    } catch (err) {
        console.error(`[Server] Error:`, err);
        res.status(500).json({ error: 'Server error', details: err.message });
    }
});

app.get('/health', (req, res) => res.json({ status: 'ok', uptime: process.uptime() }));

app.listen(PORT, () => {
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('🚀 PaperTools V1 Backend Active');
    console.log(`📡 Port: ${PORT}`);
    console.log(`🕒 Cleanup: Every 15m (1h expiry)`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
});
