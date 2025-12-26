/**
 * PaperMaker V7.3 - Sleek Professional Planner
 */

const PRESETS = {
    professional: {
        planner: { paperStyle: 'dot', density: 'compact' },
        colors: { dark1: '#0f172a', light1: '#ffffff', accent: '#4f46e5' },
        typography: { primaryFont: 'Inter', primaryFontWeight: 700, secondaryFont: 'Inter', secondaryFontWeight: 400 }
    },
    minimal: {
        planner: { paperStyle: 'line', density: 'balanced' },
        colors: { dark1: '#000000', light1: '#ffffff', accent: '#000000' },
        typography: { primaryFont: 'Inter', primaryFontWeight: 700, secondaryFont: 'Inter', secondaryFontWeight: 400 }
    },
    academic: {
        planner: { paperStyle: 'line', density: 'balanced' },
        colors: { dark1: '#422006', light1: '#fdfbf7', accent: '#92400e' },
        typography: { primaryFont: 'Playfair Display', primaryFontWeight: 700, secondaryFont: 'Inter', secondaryFontWeight: 400 }
    },
    creative: {
        planner: { paperStyle: 'plain', density: 'spaced' },
        colors: { dark1: '#312e81', light1: '#faf5ff', accent: '#db2777' },
        typography: { primaryFont: 'Outfit', primaryFontWeight: 700, secondaryFont: 'Outfit', secondaryFontWeight: 400 }
    },
    focused: {
        planner: { paperStyle: 'line', density: 'compact' },
        colors: { dark1: '#ffffff', light1: '#09090b', accent: '#4f46e5' },
        typography: { primaryFont: 'Inter', primaryFontWeight: 700, secondaryFont: 'Inter', secondaryFontWeight: 400 }
    }
};

class PaperMaker {
    constructor() {
        this.config = this.loadState() || this.getDefaultConfig();
        this.currentStep = 1;
        this.init();
    }

    getDefaultConfig() {
        return {
            timeRange: {
                startYear: 2026,
                startMonth: 1,
                durationMonths: 12
            }, output: { pageSize: 'a4', orientation: 'landscape' },
            colors: { dark1: '#18181b', light1: '#ffffff', accent: '#4f46e5' },
            typography: { primaryFont: 'Inter', primaryFontWeight: 700, secondaryFont: 'Inter', secondaryFontWeight: 400, fontScale: 1.0, titleSize: 24 },
            generation: {
                order: 'sequential',
                pages: {
                    cover: { enabled: false, title: 'PaperMaker Planner', imageUrl: '' },
                    year: { enabled: true },
                    quarter: { enabled: false, type: 'calendar' },
                    month: { enabled: true },
                    week: { enabled: true },
                    day: { enabled: true, extraDaily: false, sidebar: 'right', sidebarEnabled: true, sidebarModule: 'planner', startTime: '08:00', endTime: '20:00', timeFormat: '24h', showHalfHour: false }
                }
            },
            planner: { paperStyle: 'line', density: 'balanced', weekStart: 1, weekendType: 'sat-sun', weekendDays: [0, 6] }
        };
    }

    init() {
        this.setupEventListeners();
        this.syncUI();
        this.setStep(1); // Ensure "Setup" is active on load
        this.updatePageCount();
        this.updateSummary();
    }

    setupEventListeners() {
        // Timeline & Rules
        ['startYear', 'startMonth', 'durationMonths', 'weekStart', 'weekendType', 'pageOrder'].forEach(id => {
            document.getElementById(id)?.addEventListener('change', (e) => this.update(id, e.target.value));
        });

        // Custom Weekends
        document.querySelectorAll('#customWeekendDays input').forEach(cb => {
            cb.addEventListener('change', () => {
                const checked = Array.from(document.querySelectorAll('#customWeekendDays input:checked')).map(c => parseInt(c.value));
                // Convert from Sunday-based (0=Sun, 1=Mon, ..., 6=Sat) to Monday-based (0=Mon, ..., 6=Sun)
                // Web: 0=Sun, 1=Mon, 2=Tue, 3=Wed, 4=Thu, 5=Fri, 6=Sat
                // Typst: 0=Mon, 1=Tue, 2=Wed, 3=Thu, 4=Fri, 5=Sat, 6=Sun
                const convertedDays = checked.map(day => {
                    if (day === 0) return 6; // Sunday: 0 -> 6
                    return day - 1;          // Mon-Sat: 1-6 -> 0-5
                });
                this.config.planner.weekendDays = convertedDays;
                this.saveState();
                this.updatePageCount();
            });
        });

        // Pages
        ['includeCover', 'includeYear', 'includeQuarter', 'includeMonth', 'includeWeek', 'includeDay', 'extraDaily'].forEach(id => {
            document.getElementById(id)?.addEventListener('change', (e) => {
                this.update(id, e.target.checked);
            });
        });

        // Step 2 Details
        document.getElementById('quarterType')?.addEventListener('change', (e) => this.update('quarterType', e.target.value));
        document.getElementById('coverTitle')?.addEventListener('input', (e) => this.updateConfig('coverTitle', e.target.value));
        document.getElementById('clearImageBtn')?.addEventListener('click', () => {
            const fileInput = document.getElementById('coverImageFile');
            const label = document.getElementById('uploadLabel');
            if (fileInput) fileInput.value = '';
            if (label) label.textContent = 'Choose Image...';
            this.update('coverImageUrl', '');
        });
        document.getElementById('includeSidebar')?.addEventListener('change', (e) => this.update('includeSidebar', e.target.checked));
        document.getElementById('sidebarModule')?.addEventListener('change', (e) => this.update('sidebarModule', e.target.value));

        ['startTime', 'endTime'].forEach(id => {
            document.getElementById(id)?.addEventListener('blur', (e) => this.validateTime(e.target));
        });

        // Quantity/Time Buttons (+/-)
        document.querySelectorAll('.btn-qty').forEach(btn => {
            btn.addEventListener('click', () => {
                const target = document.getElementById(btn.dataset.target);
                const action = btn.dataset.action;
                const delta = action === 'inc' ? 1 : -1;

                if (target.id === 'startTime' || target.id === 'endTime') {
                    this.incrementTime(target, delta);
                } else if (target.id === 'startYear') {
                    this.update('startYear', parseInt(target.value) + delta);
                } else if (target.id === 'durationMonths') {
                    this.update('durationMonths', Math.max(1, parseInt(target.value) + delta));
                }
            });
        });

        // Step 3 Styling
        document.getElementById('activePreset')?.addEventListener('change', (e) => this.applyPreset(e.target.value));
        ['primaryFont', 'primaryFontWeight', 'secondaryFont', 'secondaryFontWeight'].forEach(id => {
            document.getElementById(id)?.addEventListener('input', (e) => this.update(id, e.target.value));
        });

        // Visual Choices (Orientation)
        document.querySelectorAll('.visual-choice').forEach(vc => {
            vc.addEventListener('click', () => {
                const parent = vc.closest('.visual-choice-row');
                this.update(parent.dataset.id, vc.dataset.value);
            });
        });

        // Choice Rows (Paper Style, Density, etc.)
        document.querySelectorAll('.choice-row').forEach(row => {
            row.addEventListener('click', (e) => {
                const item = e.target.closest('.choice-item');
                if (!item) return;
                this.update(row.dataset.id, item.dataset.value);
            });
        });

        // Colors
        ['colorDark1', 'colorLight1', 'colorAccent'].forEach(id => {
            const el = document.getElementById(id);
            const hexInput = document.getElementById(`hex-${id}`);

            el?.addEventListener('input', (e) => {
                const key = id.replace('color', '').charAt(0).toLowerCase() + id.replace('color', '').slice(1);
                this.config.colors[key] = e.target.value;
                if (hexInput) hexInput.value = e.target.value;
            });
            el?.addEventListener('change', () => this.saveState());

            if (hexInput) {
                hexInput.addEventListener('input', (e) => {
                    let val = e.target.value;
                    if (!val.startsWith('#')) val = '#' + val;
                    if (/^#[0-9A-F]{6}$/i.test(val)) {
                        const key = id.replace('color', '').charAt(0).toLowerCase() + id.replace('color', '').slice(1);
                        this.config.colors[key] = val;
                        if (el) el.value = val;
                        this.saveState();
                        this.updateSummary();
                    }
                });
            }
        });

        // Image Upload
        document.getElementById('coverImageFile')?.addEventListener('change', async (e) => {
            const file = e.target.files[0];
            if (!file) return;

            const label = document.getElementById('uploadLabel');
            const trigger = document.querySelector('.upload-trigger');
            if (label) label.innerText = 'Uploading...';

            try {
                const ext = file.name.split('.').pop();
                const response = await fetch('/upload', {
                    method: 'POST',
                    headers: {
                        'Content-Type': file.type,
                        'x-file-extension': ext
                    },
                    body: file
                });
                const result = await response.json();
                if (result.success) {
                    this.update('coverImageUrl', result.url);
                    if (label) label.innerText = `Uploaded: ${file.name}`;
                    if (trigger) trigger.classList.add('has-file');
                    this.showToast('Cover image uploaded');
                }
            } catch (err) {
                console.error('Upload failed:', err);
                if (label) label.innerText = 'Upload failed';
                this.showToast('Upload failed', 'error');
            }
        });

        // Wizard Nav
        document.getElementById('nextBtn').addEventListener('click', () => {
            if (this.currentStep < 3) this.setStep(this.currentStep + 1);
            else this.generatePDF();
        });
        document.getElementById('prevBtn').addEventListener('click', () => this.setStep(this.currentStep - 1));

        document.querySelectorAll('.step-indicator').forEach(indicator => {
            indicator.addEventListener('click', () => this.setStep(parseInt(indicator.dataset.step)));
        });
    }

    incrementTime(el, delta) {
        let val = this.config.generation.pages.day[el.id]; // e.g., "08:00"
        let [h, m] = val.split(':').map(Number);
        h = (h + delta + 24) % 24;
        this.config.generation.pages.day[el.id] = (h < 10 ? '0' + h : h) + ':00';
        this.saveState();
        this.syncUI();
    }

    validateTime(el) {
        let val = el.value.trim().toUpperCase();
        const is12 = this.config.generation.pages.day.timeFormat === '12h';
        let h24 = 8;

        if (is12) {
            let match = val.match(/(\d{1,2})\s*(AM|PM|)/i);
            if (match) {
                let h = parseInt(match[1]);
                let ampm = (match[2] || "AM").toUpperCase();
                if (h < 1) h = 1; if (h > 12) h = 12;
                h24 = h;
                if (ampm === "PM" && h < 12) h24 += 12;
                if (ampm === "AM" && h === 12) h24 = 0;
            }
        } else {
            let h = parseInt(val.split(':')[0]);
            if (!isNaN(h)) {
                if (h < 0) h = 0; if (h > 23) h = 23;
                h24 = h;
            }
        }
        this.config.generation.pages.day[el.id] = (h24 < 10 ? '0' + h24 : h24) + ':00';
        this.saveState();
        this.syncUI();
        this.updateSummary();
    }

    update(id, val) {
        const c = this.config;
        switch (id) {
            case 'startYear': c.timeRange.startYear = parseInt(val); break;
            case 'startMonth': c.timeRange.startMonth = parseInt(val); break;
            case 'durationMonths': c.timeRange.durationMonths = parseInt(val) || 0; break;
            case 'weekStart': c.planner.weekStart = parseInt(val); break;
            case 'weekendType': c.planner.weekendType = val; break;
            case 'pageOrder': c.generation.order = val; break;

            case 'includeCover': c.generation.pages.cover.enabled = val; break;
            case 'coverTitle': c.generation.pages.cover.title = val; break;
            case 'coverImageUrl':
                c.generation.pages.cover.imageUrl = val;
                // Clear image preview if URL is empty
                if (!val || val.trim() === '') {
                    c.generation.pages.cover.imageUrl = '';
                    const preview = document.getElementById('coverImagePreview');
                    if (preview) preview.src = '';
                }
                break;
            case 'includeYear': c.generation.pages.year.enabled = val; break;
            case 'includeQuarter': c.generation.pages.quarter.enabled = val; break;
            case 'quarterType': c.generation.pages.quarter.type = val; break;
            case 'includeMonth': c.generation.pages.month.enabled = val; break;
            case 'includeWeek': c.generation.pages.week.enabled = val; break;
            case 'includeDay':
                c.generation.pages.day.enabled = val;
                if (!val) c.generation.pages.day.extraDaily = false;
                break;
            case 'extraDaily': c.generation.pages.day.extraDaily = val; break;

            case 'includeSidebar': c.generation.pages.day.sidebarEnabled = val; break;
            case 'sidebarModule': c.generation.pages.day.sidebarModule = val; break;
            case 'sidebarPosition': c.generation.pages.day.sidebar = val; break;
            case 'timeFormat':
                c.generation.pages.day.timeFormat = val;
                this.convertTimeInputs(val);
                break;
            case 'showHalfHour': c.generation.pages.day.showHalfHour = (val === 'true'); break;

            case 'orientation': c.output.orientation = val; break;
            case 'paperStyle': c.planner.paperStyle = val; break;
            case 'density': c.planner.density = val; break;

            case 'primaryFont': c.typography.primaryFont = val; break;
            case 'primaryFontWeight': c.typography.primaryFontWeight = parseInt(val); break;
            case 'secondaryFont': c.typography.secondaryFont = val; break;
            case 'secondaryFontWeight': c.typography.secondaryFontWeight = parseInt(val); break;
        }
        this.saveState();
        this.syncUI();
        this.updatePageCount();
        this.updateSummary();
    }

    convertTimeInputs(format) {
        const start = document.getElementById('startTime');
        const end = document.getElementById('endTime');
        const rangeLabel = document.getElementById('activeRangeLabel');
        if (!start || !end) return;

        const toDisplay = (h24) => {
            let [h, m] = h24.split(':').map(Number);
            if (format === '12h') {
                let ampm = h >= 12 ? 'PM' : 'AM';
                let h12 = h % 12 || 12;
                return (h12 < 10 ? '0' + h12 : h12) + ' ' + ampm;
            } else {
                return (h < 10 ? '0' + h : h) + ':00';
            }
        };

        start.value = toDisplay(this.config.generation.pages.day.startTime);
        end.value = toDisplay(this.config.generation.pages.day.endTime);
        if (rangeLabel) rangeLabel.innerText = `Active Range (${format})`;
    }

    setStep(n) {
        this.currentStep = n;
        document.querySelectorAll('.wizard-step').forEach((s, i) => {
            const stepNum = i + 1;
            s.style.display = stepNum === n ? 'block' : 'none';
            s.classList.toggle('active', stepNum === n);
            s.classList.toggle('done', stepNum < n);
        });
        document.querySelectorAll('.step-indicator').forEach((s, idx) => {
            const stepNum = idx + 1;
            s.classList.toggle('active', stepNum === n);
            s.classList.toggle('done', stepNum < n);
        });
        document.getElementById('prevBtn').disabled = n === 1;
        const nextBtn = document.getElementById('nextBtn');
        nextBtn.innerText = n === 3 ? 'Build Planner' : 'Continue →';

        // Disable build button if on step 3 and no pages selected
        if (n === 3) {
            const count = parseInt(document.getElementById('pageCount')?.textContent || '0');
            nextBtn.disabled = count === 0;
        }

        document.querySelector('.wizard-content')?.scrollTo(0, 0);
        this.syncUI();
        this.saveState();
        this.updateSummary();
    }

    applyPreset(id) {
        const p = PRESETS[id];
        if (!p) return;
        if (p.planner) Object.assign(this.config.planner, p.planner);
        if (p.colors) Object.assign(this.config.colors, p.colors);
        if (p.typography) Object.assign(this.config.typography, p.typography);
        this.syncUI();
        this.saveState();
        this.updateSummary();
        this.showToast(`${id.charAt(0).toUpperCase() + id.slice(1)} theme applied`);
    }

    syncUI() {
        const c = this.config;
        const setV = (id, v) => { const el = document.getElementById(id); if (el) el.value = v; };
        const setC = (id, v) => { const el = document.getElementById(id); if (el) el.checked = !!v; };
        const setD = (id, v) => { const el = document.getElementById(id); if (el) el.disabled = !!v; };

        setV('startYear', c.timeRange.startYear);
        setV('startMonth', c.timeRange.startMonth);
        setV('durationMonths', c.timeRange.durationMonths);
        setV('weekStart', c.planner.weekStart);
        setV('weekendType', c.planner.weekendType);
        setV('pageOrder', c.generation.order);

        setC('includeCover', c.generation.pages.cover.enabled);
        setV('coverTitle', c.generation.pages.cover.title);

        setC('includeYear', c.generation.pages.year.enabled);
        setC('includeQuarter', c.generation.pages.quarter.enabled);
        setV('quarterType', c.generation.pages.quarter.type);
        setC('includeMonth', c.generation.pages.month.enabled);
        setC('includeWeek', c.generation.pages.week.enabled);
        setC('includeDay', c.generation.pages.day.enabled);
        setC('extraDaily', c.generation.pages.day.extraDaily);
        setD('extraDaily', !c.generation.pages.day.enabled);

        setC('includeSidebar', c.generation.pages.day.sidebarEnabled);
        setV('sidebarModule', c.generation.pages.day.sidebarModule);

        setV('primaryFont', c.typography.primaryFont);
        setV('primaryFontWeight', c.typography.primaryFontWeight);
        setV('secondaryFont', c.typography.secondaryFont);
        setV('secondaryFontWeight', c.typography.secondaryFontWeight);

        // Disclosures
        const disc = (id, v) => { const el = document.getElementById(id); if (el) el.style.display = v ? 'block' : 'none'; };
        disc('customWeekendDays', c.planner.weekendType === 'custom');
        disc('coverOptions', c.generation.pages.cover.enabled);
        disc('quarterOptions', c.generation.pages.quarter.enabled);
        disc('sidebarSettings', c.generation.pages.day.sidebarEnabled);
        disc('plannerOptions', c.generation.pages.day.sidebarEnabled && c.generation.pages.day.sidebarModule === 'planner');

        // Page Placement Disclosure
        const needsPlacement = c.generation.pages.day.enabled &&
            (c.generation.pages.month.enabled || c.generation.pages.week.enabled || c.generation.pages.quarter.enabled);
        disc('placementOptions', needsPlacement);

        // Choice rows
        const syncChoice = (id, v) => {
            const row = document.querySelector(`.choice-row[data-id="${id}"]`) || document.querySelector(`.visual-choice-row[data-id="${id}"]`);
            if (!row) return;
            row.querySelectorAll('.choice-item, .visual-choice').forEach(item => {
                item.classList.toggle('active', String(item.dataset.value) === String(v));
            });
        };
        syncChoice('paperStyle', c.planner.paperStyle);
        syncChoice('density', c.planner.density);
        syncChoice('sidebarPosition', c.generation.pages.day.sidebar);
        syncChoice('timeFormat', c.generation.pages.day.timeFormat);
        syncChoice('showHalfHour', c.generation.pages.day.showHalfHour);
        syncChoice('orientation', c.output.orientation);

        // Color sync
        Object.keys(c.colors).forEach(k => {
            const id = 'color' + k.charAt(0).toUpperCase() + k.slice(1);
            const el = document.getElementById(id);
            const hexInput = document.getElementById(`hex-${id}`);
            if (el) {
                el.value = c.colors[k];
                if (hexInput) hexInput.value = c.colors[k];
            }
        });

        this.convertTimeInputs(c.generation.pages.day.timeFormat);

        if (c.planner.weekendType === 'custom') {
            document.querySelectorAll('#customWeekendDays input').forEach(cb => {
                const webDay = parseInt(cb.value); // 0=Sun, 1=Mon, ..., 6=Sat
                // Convert from Typst format (0=Mon, ..., 6=Sun) to web format
                const typstDays = c.planner.weekendDays || [];
                let isChecked = false;

                if (webDay === 0) {
                    // Sunday in web = 6 in Typst
                    isChecked = typstDays.includes(6);
                } else {
                    // Mon-Sat in web (1-6) = 0-5 in Typst
                    isChecked = typstDays.includes(webDay - 1);
                }

                cb.checked = isChecked;
            });
        }
    }

    updateSummary() {
        const c = this.config;
        const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
        const sumTimeEl = document.getElementById('sum-time');
        if (sumTimeEl) sumTimeEl.innerText = `${months[c.timeRange.startMonth - 1]} ${c.timeRange.startYear} (${c.timeRange.durationMonths}m)`;

        const inclusions = [];
        if (c.generation.pages.cover.enabled) inclusions.push('Cover');
        if (c.generation.pages.year.enabled) inclusions.push('Yearly Overview');
        if (c.generation.pages.quarter.enabled) inclusions.push('Quarterly Spreads');
        if (c.generation.pages.month.enabled) inclusions.push('Monthly Grid');
        if (c.generation.pages.week.enabled) inclusions.push('Weekly Planner');
        if (c.generation.pages.day.enabled) inclusions.push('Daily Page');

        const sumPagesEl = document.getElementById('sum-pages');
        if (sumPagesEl) sumPagesEl.innerText = inclusions.length > 0 ? inclusions.join(', ') : 'None selected';

        const orient = c.output.orientation;
        const style = c.planner.paperStyle;
        const sumStyleEl = document.getElementById('sum-style');
        if (sumStyleEl) sumStyleEl.innerText = `${orient.charAt(0).toUpperCase() + orient.slice(1)} / ${style.charAt(0).toUpperCase() + style.slice(1)}`;
    }

    updatePageCount() {
        const c = this.config;
        const dur = c.timeRange.durationMonths;
        let count = 0;

        // Count cover page if enabled
        if (c.generation.pages.cover.enabled) count += 1;

        if (c.generation.pages.year.enabled) count += 1;
        if (c.generation.pages.quarter.enabled) count += Math.ceil(dur / 3);
        if (c.generation.pages.month.enabled) count += dur;

        if (c.generation.pages.week.enabled) {
            count += Math.ceil((dur * 30.4) / 7);
        }

        if (c.generation.pages.day.enabled) {
            const daysPerYear = 365;
            const totalDays = Math.floor((dur / 12) * daysPerYear);
            count += totalDays * (c.generation.pages.day.extraDaily ? 2 : 1);
        }

        const pcEl = document.getElementById('pageCount');
        if (pcEl) pcEl.textContent = count;

        // Disable build button if on step 3 and no pages selected
        const nextBtn = document.getElementById('nextBtn');
        if (nextBtn && this.currentStep === 3) {
            nextBtn.disabled = count === 0;
        }
    }

    async generatePDF() {
        const nextBtn = document.getElementById('nextBtn');
        try {
            nextBtn.disabled = true;
            nextBtn.innerText = 'Engaging Engine...';
            const finalConfig = JSON.parse(JSON.stringify(this.config));
            if (finalConfig.generation.pages.cover.enabled && !finalConfig.generation.pages.cover.title) {
                finalConfig.generation.pages.cover.title = `Year ${finalConfig.timeRange.startYear}`;
            }

            const res = await fetch('/generate-pdf', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(finalConfig)
            });
            const data = await res.json();
            if (data.success) {
                const link = document.createElement('a');
                link.href = data.downloadUrl;
                link.download = `PaperMaker_Planner_${finalConfig.timeRange.startYear}.pdf`;
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
                this.showToast('File Successfully Downloaded', 'success');
            } else throw new Error(data.error);
        } catch (e) {
            this.showToast('Build failed. Check config.');
        } finally {
            nextBtn.disabled = false;
            nextBtn.innerText = 'Build Planner';
        }
    }

    showToast(m) {
        const t = document.getElementById('toast');
        if (!t) return;
        t.innerText = m;
        t.style.transform = 'translate(-50%, 0)';
        setTimeout(() => t.style.transform = 'translate(-50%, 6.25rem)', 3500);
    }

    saveState() {
        // Create a copy without imageUrl (don't persist images)
        const configToSave = JSON.parse(JSON.stringify(this.config));
        if (configToSave.generation?.pages?.cover) {
            delete configToSave.generation.pages.cover.imageUrl;
        }
        localStorage.setItem('papermaker-config', JSON.stringify(configToSave));
    }
    loadState() { return JSON.parse(localStorage.getItem('papermaker-config')); }
}

document.addEventListener('DOMContentLoaded', () => { window.app = new PaperMaker(); });
