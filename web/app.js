// Configuration state
let config = {
    pages: {
        year: true,
        quarter: false,
        month: true,
        week: false,
        daily: false
    },
    year: new Date().getFullYear(),
    startDay: 'monday',
    weekendColor: '#e8f4f8',
    monthFormat: 'full',
    paperStyle: 'plain',
    font: 'Inter',
    customFont: '',
    primaryColor: '#000000',
    firstPageTitle: ''
};

// DOM Elements
const form = document.getElementById('calendar-config-form');
const fontSelect = document.getElementById('font');
const customFontGroup = document.getElementById('custom-font-group');
const yearInput = document.getElementById('year');
const fileInput = document.getElementById('file-input');

// Initialize
function init() {
    // Set current year
    yearInput.value = config.year;

    // Load saved config from localStorage
    loadFromLocalStorage();

    // Event listeners
    form.addEventListener('submit', handleDownload);
    document.getElementById('save-config').addEventListener('click', saveToLocalStorage);
    document.getElementById('load-config').addEventListener('click', () => fileInput.click());
    fileInput.addEventListener('change', handleFileLoad);
    fontSelect.addEventListener('change', handleFontChange);

    // Page checkboxes
    document.querySelectorAll('input[name="pages"]').forEach(checkbox => {
        checkbox.addEventListener('change', handlePageToggle);
    });

    // Auto-save on any change
    form.addEventListener('change', updateConfigFromForm);
}

// Handle font selection
function handleFontChange(e) {
    if (e.target.value === 'custom') {
        customFontGroup.style.display = 'block';
    } else {
        customFontGroup.style.display = 'none';
    }
}

// Handle page toggle
function handlePageToggle(e) {
    const page = e.target.value;
    const isChecked = e.target.checked;

    // Update config
    config.pages[page] = isChecked;

    // Show warning if disabling year
    if (page === 'year' && !isChecked) {
        if (!confirm('Disabling the year calendar will remove the main overview page. Continue?')) {
            e.target.checked = true;
            config.pages[page] = true;
            return;
        }
    }

    updateConfigFromForm();
}

// Update config from form
function updateConfigFromForm() {
    // Pages
    document.querySelectorAll('input[name="pages"]').forEach(checkbox => {
        config.pages[checkbox.value] = checkbox.checked;
    });

    // Settings
    config.year = parseInt(yearInput.value);
    config.startDay = document.getElementById('start-day').value;
    config.weekendColor = document.getElementById('weekend-color').value;
    config.monthFormat = document.getElementById('month-format').value;

    // Paper style
    const paperStyle = document.querySelector('input[name="paperStyle"]:checked');
    config.paperStyle = paperStyle ? paperStyle.value : 'plain';

    // Customization
    const fontValue = fontSelect.value;
    if (fontValue === 'custom') {
        config.font = document.getElementById('custom-font').value || 'Inter';
    } else {
        config.font = fontValue;
    }
    config.primaryColor = document.getElementById('primary-color').value;
    config.firstPageTitle = document.getElementById('first-page-title').value;

    // Auto-save to localStorage
    localStorage.setItem('calendar-config', JSON.stringify(config));
}

// Update form from config
function updateFormFromConfig() {
    // Pages
    Object.keys(config.pages).forEach(page => {
        const checkbox = document.getElementById(`page-${page}`);
        if (checkbox) {
            checkbox.checked = config.pages[page];
        }
    });

    // Settings
    yearInput.value = config.year;
    document.getElementById('start-day').value = config.startDay;
    document.getElementById('weekend-color').value = config.weekendColor;
    document.getElementById('month-format').value = config.monthFormat;

    // Paper style
    const paperStyleRadio = document.querySelector(`input[name="paperStyle"][value="${config.paperStyle}"]`);
    if (paperStyleRadio) {
        paperStyleRadio.checked = true;
    }

    // Customization
    if (['Inter', 'Roboto', 'Open Sans', 'Lato', 'Montserrat'].includes(config.font)) {
        fontSelect.value = config.font;
        customFontGroup.style.display = 'none';
    } else {
        fontSelect.value = 'custom';
        document.getElementById('custom-font').value = config.font;
        customFontGroup.style.display = 'block';
    }
    document.getElementById('primary-color').value = config.primaryColor;
    document.getElementById('first-page-title').value = config.firstPageTitle;
}

// Save to localStorage
function saveToLocalStorage() {
    updateConfigFromForm();
    alert('Configuration saved locally!');
}

// Load from localStorage
function loadFromLocalStorage() {
    const saved = localStorage.getItem('calendar-config');
    if (saved) {
        try {
            config = JSON.parse(saved);
            updateFormFromConfig();
        } catch (e) {
            console.error('Failed to load saved config:', e);
        }
    }
}

// Handle file load
function handleFileLoad(e) {
    const file = e.target.files[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = (event) => {
        try {
            config = JSON.parse(event.target.result);
            updateFormFromConfig();
            alert('Configuration loaded successfully!');
        } catch (error) {
            alert('Error loading configuration file. Please check the file format.');
            console.error('Load error:', error);
        }
    };
    reader.readAsText(file);

    // Reset file input
    fileInput.value = '';
}

// Handle download
function handleDownload(e) {
    e.preventDefault();
    updateConfigFromForm();

    // Validate
    if (!config.year || config.year < 2000 || config.year > 2100) {
        alert('Please enter a valid year between 2000 and 2100');
        return;
    }

    // Check if at least one page is selected
    const hasPages = Object.values(config.pages).some(v => v);
    if (!hasPages) {
        alert('Please select at least one page type');
        return;
    }

    // Create filename
    const filename = `calendar-config-${config.year}.json`;

    // Download
    const blob = new Blob([JSON.stringify(config, null, 2)], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = filename;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);

    // Show success message
    setTimeout(() => {
        alert(`Configuration downloaded as ${filename}\n\nNext step: Run the build script to generate your PDF calendar.`);
    }, 100);
}

// Initialize on load
document.addEventListener('DOMContentLoaded', init);
