const https = require('https');
const fs = require('fs');
const path = require('path');

const FONTS_DIR = path.join(__dirname, 'fonts');

// Ensure fonts directory exists
if (!fs.existsSync(FONTS_DIR)) {
    fs.mkdirSync(FONTS_DIR);
}

/**
 * Downloads a Google Font if it doesn't already exist.
 * @param {string} fontName - The name of the font (e.g., "Roboto").
 * @param {string} weight - The weight (e.g., "400").
 * @returns {Promise<boolean>} - Success status.
 */
async function downloadFont(fontName, weight = '400') {
    if (!fontName) return true;

    const fileName = `${fontName.replace(/\s+/g, '-')}-${weight}.ttf`;
    const filePath = path.join(FONTS_DIR, fileName);

    if (fs.existsSync(filePath)) {
        return true; // Already cached
    }

    console.log(`Downloading font: ${fontName} (${weight})...`);

    try {
        const cssUrl = `https://fonts.googleapis.com/css2?family=${fontName.replace(/\s+/g, '+')}:wght@${weight}`;
        const css = await fetchContent(cssUrl, {
            'User-Agent': 'Mozilla/5.0 (Linux; U; Android 2.2; en-us; Nexus One Build/FRF91) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1'
        });

        const fontUrlMatch = css.match(/src:\s*url\(([^)]+)\)/);
        if (!fontUrlMatch) {
            console.error(`Could not find font URL in CSS for ${fontName}`);
            return false;
        }

        const fontUrl = fontUrlMatch[1].replace(/['"]/g, '');
        const fontData = await fetchContentBuffer(fontUrl);

        fs.writeFileSync(filePath, fontData);
        console.log(`Successfully downloaded and cached: ${fileName}`);
        return true;
    } catch (err) {
        console.error(`Failed to download font ${fontName}:`, err.message);
        return false;
    }
}

function fetchContent(url, headers = {}) {
    return new Promise((resolve, reject) => {
        https.get(url, { headers }, (res) => {
            let data = '';
            res.on('data', (chunk) => data += chunk);
            res.on('end', () => resolve(data));
        }).on('error', reject);
    });
}

function fetchContentBuffer(url) {
    return new Promise((resolve, reject) => {
        https.get(url, (res) => {
            const chunks = [];
            res.on('data', (chunk) => chunks.push(chunk));
            res.on('end', () => resolve(Buffer.concat(chunks)));
        }).on('error', reject);
    });
}

module.exports = { downloadFont };
