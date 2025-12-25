// Configuration state
let config = {
    pages: {
        cover: true,
        year: true,
        quarter: false,
        month: true,
        week: false,
        daily: true,
        extraDaily: false
    },
    year: 2026,
    startMonth: 1,
    totalMonths: 12,
    pageOrder: 'sequential',
    coverImage: '',
    startDay: 0,
    monthFormat: 'full',
    dayFormat: 'full',
    paperStyle: 'plain',
    guides: 'none',
    firstPageTitle: '',
    plannerPos: 'left',
    plannerStartHour: 5,
    plannerEndHour: 23,
    showDivisions: false,
    style: {
        font: 'Inter',
        fontWeight: '400',
        headingFont: 'Inter',
        headingWeight: '700',
        baseFontSize: 10,
        headerSize: 14,
        titleSize: 24,
        primaryColor: '#2c3e50',
        bgColor: '#ffffff',
        headerColor: '#2c3e50',
        margin: 6,
        gridSpacing: 5,
        strokeWidth: 0.5,
        borderRadius: 2
    },
    preset: 'custom'
};

const THEMES = {
    light: {
        primary: '#2563eb',
        header: '#1e40af',
        bg: '#ffffff'
    },
    dark: {
        primary: '#88c0d0',
        header: '#eceff4',
        bg: '#2e3440'
    },
    paper: {
        primary: '#b58900',
        header: '#586e75',
        bg: '#fdf6e3'
    }
};

// UI Elements
const generateBtn = document.getElementById('generate-btn');
const downloadBtn = document.getElementById('download-btn');
const statusMessage = document.getElementById('status-message');
const pageCountEl = document.getElementById('page-count');

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    loadConfig();
    updateFormFromConfig();
    setupColorSync();
    setupChangeListeners();
    setupPresetListener();
    updateLiveMetrics();
    setupFontLoader();
});

function setupPresetListener() {
    const presetSelect = document.getElementById('theme-preset');
    presetSelect.addEventListener('change', (e) => {
        const theme = THEMES[e.target.value];
        if (theme) {
            updateColorField('primary', theme.primary);
            updateColorField('header', theme.header);
            updateColorField('bg', theme.bg);
            updateConfigFromForm();
        }
    });
}

function setupFontLoader() {
    const fontInputs = ['font', 'heading-font'];
    fontInputs.forEach(id => {
        const input = document.getElementById(id);
        const weightSelect = document.getElementById(`${id}-weight`);

        input.addEventListener('change', () => loadGoogleFont(input.value, weightSelect.value, id));
        weightSelect.addEventListener('change', () => loadGoogleFont(input.value, weightSelect.value, id));
        loadGoogleFont(input.value, weightSelect.value, id); // Initial load
    });
}

function loadGoogleFont(fontName, weight = '400', elId = 'font') {
    if (!fontName || fontName === 'Inter') return;

    // Create or update link tag
    const linkId = `gfont-${fontName.replace(/\s+/g, '-').toLowerCase()}-${weight}`;
    if (document.getElementById(linkId)) return;

    const link = document.createElement('link');
    link.id = linkId;
    link.rel = 'stylesheet';
    link.href = `https://fonts.googleapis.com/css2?family=${fontName.replace(/\s+/g, '+')}:wght@${weight}&display=swap`;
    document.head.appendChild(link);

    // Apply preview style
    const el = document.getElementById(elId);
    if (el) {
        el.style.fontFamily = `'${fontName}', sans-serif`;
        el.style.fontWeight = weight;
    }
}


function setupColorSync() {
    const colorFields = ['primary', 'header', 'bg'];
    colorFields.forEach(field => {
        const picker = document.getElementById(`${field}-color`);
        const hex = document.getElementById(`${field}-color-hex`);

        if (!picker || !hex) return;

        picker.addEventListener('input', () => {
            hex.value = picker.value;
            updateConfigFromForm();
        });

        hex.addEventListener('input', () => {
            if (/^#[0-9A-F]{6}$/i.test(hex.value)) {
                picker.value = hex.value;
                updateConfigFromForm();
            }
        });
    });
}

function setupChangeListeners() {
    document.querySelectorAll('input, select').forEach(el => {
        el.addEventListener('change', () => {
            updateConfigFromForm();
            updateLiveMetrics();
        });
    });

    // Daily dependency
    document.getElementById('page-daily').addEventListener('change', (e) => {
        const extraField = document.getElementById('extra-daily-field');
        if (e.target.checked) {
            extraField.classList.add('active');
        } else {
            extraField.classList.remove('active');
            document.getElementById('page-extraDaily').checked = false;
        }
    });
}

function updateLiveMetrics() {
    const isDaily = document.getElementById('page-daily').checked;
    const isMonth = document.getElementById('page-month').checked;
    const isWeek = document.getElementById('page-week').checked;

    // Toggle extra daily field
    const extraField = document.getElementById('extra-daily-field');
    if (isDaily) extraField.classList.add('active');
    else extraField.classList.remove('active');

    // Logical Sequencing Blocking
    const seqSelect = document.getElementById('page-order');
    const optMD = document.getElementById('opt-month-days');
    const optWD = document.getElementById('opt-week-days');

    optMD.disabled = !(isMonth && isDaily);
    optWD.disabled = !(isWeek && isDaily);

    if (seqSelect.value === 'month-days' && optMD.disabled) seqSelect.value = 'sequential';
    if (seqSelect.value === 'week-days' && optWD.disabled) seqSelect.value = 'sequential';

    // Page count
    const count = calculateTotalPages();
    pageCountEl.textContent = count;
}

function calculateTotalPages() {
    let total = 0;
    const months = parseInt(document.getElementById('total-months').value) || 0;

    if (document.getElementById('page-cover').checked) total += 1;
    if (document.getElementById('page-year').checked) total += 1;

    if (document.getElementById('page-quarter').checked) {
        total += Math.ceil(months / 3);
    }

    if (document.getElementById('page-month').checked) {
        total += months;
    }

    if (document.getElementById('page-week').checked) {
        total += Math.ceil(months * 4.34);
    }

    if (document.getElementById('page-daily').checked) {
        const startYear = parseInt(document.getElementById('year').value);
        const startMonth = parseInt(document.getElementById('start-month').value);
        const startDate = new Date(startYear, startMonth - 1, 1);
        const endDate = new Date(startYear, startMonth - 1 + months, 0);
        const days = Math.round((endDate - startDate) / (1000 * 60 * 60 * 24)) + 1;

        total += days;
        if (document.getElementById('page-extraDaily').checked) {
            total += days;
        }
    }

    return total;
}

function updateConfigFromForm() {
    ['cover', 'year', 'quarter', 'month', 'week', 'daily', 'extraDaily'].forEach(p => {
        config.pages[p] = document.getElementById(`page-${p}`).checked;
    });

    config.year = parseInt(document.getElementById('year').value);
    config.startMonth = parseInt(document.getElementById('start-month').value);
    config.totalMonths = parseInt(document.getElementById('total-months').value);
    config.pageOrder = document.getElementById('page-order').value;
    config.startDay = parseInt(document.getElementById('start-day').value);
    config.firstPageTitle = document.getElementById('cover-title').value;
    config.coverImage = document.getElementById('cover-image').value;

    const monthFormat = document.querySelector('input[name="monthFormat"]:checked');
    config.monthFormat = monthFormat ? monthFormat.value : 'full';

    const dayFormat = document.querySelector('input[name="dayFormat"]:checked');
    config.dayFormat = dayFormat ? dayFormat.value : 'full';

    const paperStyle = document.querySelector('input[name="paperStyle"]:checked');
    config.paperStyle = paperStyle ? paperStyle.value : 'plain';

    const guides = document.querySelector('input[name="guides"]:checked');
    config.guides = guides ? guides.value : 'none';


    const plannerPos = document.querySelector('input[name="plannerPos"]:checked');
    config.plannerPos = plannerPos ? plannerPos.value : 'left';
    config.plannerStartHour = parseInt(document.getElementById('planner-start').value);
    config.plannerEndHour = parseInt(document.getElementById('planner-end').value);
    config.showDivisions = document.getElementById('show-divisions').checked;

    config.style.font = document.getElementById('font').value;
    config.style.fontWeight = document.getElementById('font-weight').value;
    config.style.headingFont = document.getElementById('heading-font').value;
    config.style.headingWeight = document.getElementById('heading-font-weight').value;
    config.style.baseFontSize = parseFloat(document.getElementById('base-font-size').value);
    config.style.headerSize = parseFloat(document.getElementById('header-size').value);
    config.style.titleSize = parseFloat(document.getElementById('title-size').value);

    config.style.primaryColor = document.getElementById('primary-color').value;
    config.style.headerColor = document.getElementById('header-color').value;
    config.style.bgColor = document.getElementById('bg-color').value;

    config.style.margin = parseFloat(document.getElementById('margin').value);
    config.style.gridSpacing = parseFloat(document.getElementById('grid-spacing').value);
    config.style.strokeWidth = parseFloat(document.getElementById('stroke-width').value);
    config.style.borderRadius = parseFloat(document.getElementById('border-radius').value);

    config.preset = document.getElementById('theme-preset').value;

    saveConfig();
}

function updateFormFromConfig() {
    ['cover', 'year', 'quarter', 'month', 'week', 'daily', 'extraDaily'].forEach(p => {
        const el = document.getElementById(`page-${p}`);
        if (el) el.checked = !!config.pages[p];
    });

    document.getElementById('year').value = config.year;
    document.getElementById('start-month').value = config.startMonth;
    document.getElementById('total-months').value = config.totalMonths;
    document.getElementById('page-order').value = config.pageOrder;
    document.getElementById('start-day').value = config.startDay;
    document.getElementById('cover-title').value = config.firstPageTitle || 'Calendar';
    document.getElementById('cover-image').value = config.coverImage || '';

    document.getElementById('theme-preset').value = config.preset || 'custom';

    syncRadioField('monthFormat', config.monthFormat);
    syncRadioField('dayFormat', config.dayFormat);
    syncRadioField('paperStyle', config.paperStyle);
    syncRadioField('guides', config.guides);
    syncRadioField('plannerPos', config.plannerPos || 'left');

    document.getElementById('planner-start').value = config.plannerStartHour || 5;
    document.getElementById('planner-end').value = config.plannerEndHour || 23;
    document.getElementById('show-divisions').checked = !!config.showDivisions;

    const s = config.style || {};
    document.getElementById('font').value = s.font || 'Inter';
    document.getElementById('font-weight').value = s.fontWeight || '400';
    document.getElementById('heading-font').value = s.headingFont || 'Inter';
    document.getElementById('heading-font-weight').value = s.headingWeight || '700';
    document.getElementById('base-font-size').value = s.baseFontSize || 10;
    document.getElementById('header-size').value = s.headerSize || 14;
    document.getElementById('title-size').value = s.titleSize || 24;

    updateColorField('primary', s.primaryColor || '#2c3e50');
    updateColorField('header', s.headerColor || '#2c3e50');
    updateColorField('bg', s.bgColor || '#ffffff');

    document.getElementById('margin').value = s.margin || 6;
    document.getElementById('grid-spacing').value = s.gridSpacing || 5;
    document.getElementById('stroke-width').value = s.strokeWidth || 0.5;
    document.getElementById('border-radius').value = s.borderRadius || 2;

    // Load fonts in UI
    loadGoogleFont(s.font);
    loadGoogleFont(s.headingFont);
}

function syncRadioField(name, value) {
    const radio = document.querySelector(`input[name="${name}"][value="${value}"]`);
    if (radio) radio.checked = true;
}

function updateColorField(id, value) {
    const picker = document.getElementById(`${id}-color`);
    const hex = document.getElementById(`${id}-color-hex`);
    if (picker) picker.value = value;
    if (hex) hex.value = value;
}

function saveConfig() {
    localStorage.setItem('calendarConfigV4', JSON.stringify(config));
}

function loadConfig() {
    const saved = localStorage.getItem('calendarConfigV4');
    if (saved) {
        try {
            const parsed = JSON.parse(saved);
            config = { ...config, ...parsed };
        } catch (e) {
            console.error('Failed to load config', e);
        }
    }
}

// Generate PDF
generateBtn.addEventListener('click', async () => {
    updateConfigFromForm();

    statusMessage.textContent = 'Processing...';
    statusMessage.style.color = 'var(--accent)';
    generateBtn.disabled = true;
    downloadBtn.style.display = 'none';

    try {
        const response = await fetch('/generate-pdf', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(config)
        });

        if (!response.ok) {
            throw new Error(`HTTP Error: ${response.status}`);
        }

        const data = await response.json();

        if (data.success) {
            statusMessage.textContent = 'PDF Ready!';
            statusMessage.style.color = '#10b981';
            downloadBtn.style.display = 'block';
            downloadBtn.onclick = () => {
                window.location.href = `/output/${data.filename}`;
            };
        } else {
            statusMessage.textContent = 'Build Error: ' + data.message;
            statusMessage.style.color = '#ef4444';
        }
    } catch (error) {
        console.error('Generation failed:', error);
        statusMessage.textContent = 'Network Error: ' + error.message + '. Is the server running?';
        statusMessage.style.color = '#ef4444';
    } finally {
        generateBtn.disabled = false;
    }
});
