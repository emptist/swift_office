#!/usr/bin/env node

const pptxgen = require('pptxgenjs');
const https = require('https');
const pako = require('pako');
const fs = require('fs');

async function main() {
    try {
        let presentation, outputPath;
        
        // Support both stdin and file arguments
        if (process.argv.length >= 4) {
            // File arguments mode: node script.js <input.json> <output.pptx>
            const inputPath = process.argv[2];
            outputPath = process.argv[3];
            const json = fs.readFileSync(inputPath, 'utf8');
            presentation = JSON.parse(json);
        } else {
            // Stdin mode
            let input = '';
            for await (const chunk of process.stdin) {
                input += chunk;
            }
            const params = JSON.parse(input);
            presentation = typeof params.presentation === 'string' 
                ? JSON.parse(params.presentation) 
                : params.presentation;
            outputPath = params.outputPath || `${presentation.title || 'presentation'}.pptx`;
        }
        
        await generatePPTX(presentation, outputPath);
    } catch (error) {
        console.log(JSON.stringify({ 
            success: false, 
            error: error.message,
            stack: error.stack
        }));
        process.exit(1);
    }
}

main();

function encodeMermaid(code) {
    const json = JSON.stringify({code: code});
    const compressed = pako.deflate(json);
    const base64 = Buffer.from(compressed).toString('base64')
        .replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
    return 'pako:' + base64;
}

async function fetchMermaidImage(code, format = 'png') {
    const encodedCode = encodeMermaid(code);
    const url = `https://mermaid.ink/${format}/${encodedCode}`;
    
    return new Promise((resolve, reject) => {
        https.get(url, (res) => {
            if (res.statusCode === 200) {
                const chunks = [];
                res.on('data', chunk => chunks.push(chunk));
                res.on('end', () => {
                    const buffer = Buffer.concat(chunks);
                    const mimeType = format === 'png' ? 'image/png' : 'image/svg+xml';
                    resolve(`data:${mimeType};base64,${buffer.toString('base64')}`);
                });
            } else if (res.statusCode === 302 || res.statusCode === 301) {
                https.get(res.headers.location, (res2) => {
                    const chunks = [];
                    res2.on('data', chunk => chunks.push(chunk));
                    res2.on('end', () => {
                        const buffer = Buffer.concat(chunks);
                        const mimeType = format === 'png' ? 'image/png' : 'image/svg+xml';
                        resolve(`data:${mimeType};base64,${buffer.toString('base64')}`);
                    });
                }).on('error', reject);
            } else {
                resolve(null);
            }
        }).on('error', () => resolve(null));
    });
}

async function generatePPTX(data, outputPath) {
    const pres = new pptxgen();
    
    pres.layout = 'LAYOUT_16x9';
    pres.title = data.title || 'SwiftSlides Presentation';
    if (data.author) pres.author = data.author;
    
    const theme = {
        primary: data.theme?.primary || '1F4E79',
        secondary: data.theme?.secondary || '2E75B6',
        accent: data.theme?.accent || '5B9BD5',
        text: data.theme?.text || '333333',
        lightText: data.theme?.lightText || '666666',
        background: data.theme?.background || 'FFFFFF',
        gradient: {
            蓝色: { start: data.theme?.primary || '1F4E79', end: data.theme?.accent || '5B9BD5' },
            绿色: { start: '2E7D32', end: '66BB6A' },
            紫色: { start: '6A1B9A', end: 'AB47BC' },
            橙色: { start: 'E65100', end: 'FF9800' },
            红色: { start: 'C62828', end: 'EF5350' },
        }
    };
    
    // Add presentation cover if it has cover properties
    if (data.subtitle || data.date) {
        await addPresentationCover(pres, data, theme);
    }
    
    // Process hierarchy levels in order: sections → chapters → nodes → slides
    // Each level is mutually exclusive based on the hierarchy used
    const sections = data.sections || [];
    const chapters = data.chapters || [];
    const nodes = data.nodes || [];
    const slides = data.slides || [];
    
    // Process sections (册)
    for (const section of sections) {
        // Sections can contain chapters, nodes, or slides
        const sectionChapters = section.chapters || [];
        const sectionNodes = section.nodes || [];
        const sectionSlides = section.slides || [];
        
        for (const chapter of sectionChapters) {
            await processChapter(pres, chapter, theme);
        }
        
        for (const node of sectionNodes) {
            await processNode(pres, node, theme);
        }
        
        for (const slide of sectionSlides) {
            await processSlideRecursive(pres, slide, theme);
        }
    }
    
    // Process chapters (章)
    for (const chapter of chapters) {
        await processChapter(pres, chapter, theme);
    }
    
    // Process nodes (节)
    for (const node of nodes) {
        await processNode(pres, node, theme);
    }
    
    // Process slides directly
    for (const slide of slides) {
        await processSlideRecursive(pres, slide, theme);
    }
    
    await pres.writeFile({ fileName: outputPath });
    
    console.log(JSON.stringify({ 
        success: true, 
        path: outputPath,
        slides: pres.slides.length
    }));
}

async function processChapter(pres, chapter, theme) {
    // Add chapter cover if it has cover properties
    if (chapter.subtitle) {
        await addChapterCover(pres, chapter, theme);
    }
    
    // Chapters can contain nodes or slides
    const nodes = chapter.nodes || [];
    const slides = chapter.slides || [];
    
    for (const node of nodes) {
        await processNode(pres, node, theme);
    }
    
    for (const slide of slides) {
        await processSlideRecursive(pres, slide, theme);
    }
}

async function processNode(pres, node, theme) {
    // Add node cover if it has cover properties
    if (node.subtitle) {
        await addNodeCover(pres, node, theme);
    }
    
    // Nodes contain slides
    const slides = node.slides || [];
    
    for (const slide of slides) {
        await processSlideRecursive(pres, slide, theme);
    }
}

async function addChapterCover(pres, data, theme) {
    const slideObj = pres.addSlide();
    addSectionSlide(slideObj, {
        title: data.title,
        subtitle: data.subtitle
    }, theme);
}

async function addNodeCover(pres, data, theme) {
    const slideObj = pres.addSlide();
    addSectionSlide(slideObj, {
        title: data.title,
        subtitle: data.subtitle
    }, theme);
}

async function processSlideRecursive(pres, slide, theme) {
    if (slide.fellowSlides && slide.fellowSlides.length > 0) {
        for (const subSlide of slide.fellowSlides) {
            await processSlideRecursive(pres, subSlide, theme);
        }
    } else {
        await addSlide(pres, slide, theme);
    }
}

async function addPresentationCover(pres, data, theme) {
    const slideObj = pres.addSlide();
    addCoverSlide(slideObj, {
        title: data.title,
        subtitle: data.subtitle,
        author: data.author,
        date: data.date,
        gradient: '蓝色'
    }, theme);
}

async function addSlide(pres, slide, theme) {
    const type = slide.slideType || slide.type;
    const slideObj = pres.addSlide();
    
    // Merge contents into slide for easier access
    const data = { ...slide, ...(slide.contents || {}) };
    
    switch (type) {
        case 'cover':
        case '封面页':
            addCoverSlide(slideObj, data, theme);
            break;
        case 'chapterCover':
        case '章节页':
            addSectionSlide(slideObj, data, theme);
            break;
        case 'content':
        case '列表页':
            addListSlide(slideObj, data, theme);
            break;
        case 'text':
        case '定义页':
            addTextSlide(slideObj, data, theme);
            break;
        case 'cards':
        case '卡片页':
            addCardSlide(slideObj, data, theme);
            break;
        case 'table':
        case '表格页':
            addTableSlide(slideObj, data, theme);
            break;
        case 'quote':
        case '引用页':
            addQuoteSlide(slideObj, data, theme);
            break;
        case 'twoColumn':
        case '对比页':
            addComparisonSlide(slideObj, data, theme);
            break;
        case 'timeline':
        case '时间线页':
            addTimelineSlide(slideObj, data, theme);
            break;
        case 'flowchart':
        case '流程页':
            addProcessSlide(slideObj, data, theme);
            break;
        case 'end':
        case 'endCover':
        case '结束页':
            addEndSlide(slideObj, data, theme);
            break;
        case 'chart':
        case '图表页':
            addChartSlide(slideObj, data, theme, pres);
            break;
        case 'image':
        case '图片页':
            addImageSlide(slideObj, data, theme);
            break;
        case 'pyramid':
        case '金字塔页':
            addPyramidSlide(slideObj, data, theme);
            break;
        case 'matrix':
        case '矩阵页':
            addMatrixSlide(slideObj, data, theme);
            break;
        case 'pareto':
        case '柏拉图页':
            addParetoSlide(slideObj, data, theme);
            break;
        case 'hierarchy':
        case '架构图页':
            addHierarchySlide(slideObj, data, theme);
            break;
        case 'cycleFlow':
            addCycleFlowSlide(slideObj, data, theme);
            break;
        case 'boxDiagram':
            addBoxDiagramSlide(slideObj, data, theme);
            break;
        case 'branchedHierarchy':
            addBranchedHierarchySlide(slideObj, data, theme);
            break;
        case 'quadrantMatrix':
            addQuadrantMatrixSlide(slideObj, data, theme);
            break;
        case 'mermaidFlowchart':
        case 'Mermaid流程图页':
            await addMermaidSlide(slideObj, data, theme);
            break;
        case 'mermaidSequence':
        case 'Mermaid时序图页':
            await addMermaidSlide(slideObj, data, theme);
            break;
        case 'gantt':
        case 'mermaidGantt':
        case 'Gantt图页':
        case 'Mermaid甘特图页':
            await addMermaidSlide(slideObj, data, theme);
            break;
        default:
            addDefaultSlide(slideObj, data, theme);
    }
}

function addCoverSlide(slide, data, theme) {
    const gradient = theme.gradient[data.gradient] || theme.gradient.蓝色;
    
    slide.background = {
        color: gradient.start
    };
    
    slide.addText(data.title || '', {
        x: 0.5, y: 2.5, w: 9, h: 1,
        fontSize: 44, bold: true, color: 'FFFFFF',
        align: 'center', valign: 'middle'
    });
    
    if (data.subtitle) {
        slide.addText(data.subtitle, {
            x: 0.5, y: 3.5, w: 9, h: 0.5,
            fontSize: 24, color: 'FFFFFF',
            align: 'center', valign: 'middle'
        });
    }
    
    if (data.author) {
        slide.addText(data.author, {
            x: 0.5, y: 4.5, w: 9, h: 0.3,
            fontSize: 14, color: 'FFFFFF',
            align: 'center'
        });
    }
}

function addSectionSlide(slide, data, theme) {
    slide.background = { color: theme.primary };
    
    if (data.number) {
        slide.addText(data.number, {
            x: 0.5, y: 1.5, w: 9, h: 0.5,
            fontSize: 18, color: theme.accent,
            align: 'center'
        });
    }
    
    slide.addText(data.title || '', {
        x: 0.5, y: 2.2, w: 9, h: 1,
        fontSize: 40, bold: true, color: 'FFFFFF',
        align: 'center', valign: 'middle'
    });
    
    if (data.subtitle) {
        slide.addText(data.subtitle, {
            x: 0.5, y: 3.3, w: 9, h: 0.5,
            fontSize: 20, color: 'FFFFFF',
            align: 'center'
        });
    }
}

function addListSlide(slide, data, theme) {
    addSlideTitle(slide, data.title, theme);
    
    const items = data.items || data.Items || [];
    
    // Simple bullet list format
    let yPos = 1.5;
    items.forEach(item => {
        slide.addText('• ' + item, {
            x: 0.5, y: yPos, w: 9, h: 0.4,
            fontSize: 18, color: theme.text
        });
        yPos += 0.5;
    });
}

function addCardSlide(slide, data, theme) {
    addSlideTitle(slide, data.title, theme);
    
    const cards = data.cards || [];
    const columns = data.columns || 2;
    const cardWidth = 8.5 / columns;
    const cardHeight = 1.8;
    
    cards.forEach((card, index) => {
        const col = index % columns;
        const row = Math.floor(index / columns);
        const x = 0.5 + col * (cardWidth + 0.2);
        const y = 1.5 + row * (cardHeight + 0.2);
        
        slide.addShape('rect', {
            x, y, w: cardWidth, h: cardHeight,
            fill: { color: 'F5F5F5' },
            line: { color: theme.accent, width: 1 }
        });
        
        slide.addText(card.title || '', {
            x: x + 0.1, y: y + 0.1, w: cardWidth - 0.2, h: 0.4,
            fontSize: 14, bold: true, color: theme.primary
        });
        
        slide.addText(card.content || '', {
            x: x + 0.1, y: y + 0.5, w: cardWidth - 0.2, h: cardHeight - 0.6,
            fontSize: 12, color: theme.text
        });
    });
}

function addTableSlide(slide, data, theme) {
    addSlideTitle(slide, data.title, theme);
    
    // Support both old format (headers/rows) and new format (multiple arrays)
    let headers = data.headers || [];
    let rows = data.rows || [];
    
    // If no headers/rows, try to build from multiple arrays
    if (headers.length === 0 && rows.length === 0) {
        const arrays = {};
        for (const [key, value] of Object.entries(data)) {
            if (Array.isArray(value) && typeof value[0] === 'string') {
                arrays[key] = value;
            }
        }
        const keys = Object.keys(arrays);
        if (keys.length >= 2) {
            headers = keys;
            const numRows = arrays[keys[0]].length;
            rows = [];
            for (let i = 0; i < numRows; i++) {
                rows.push(keys.map(k => arrays[k][i]));
            }
        }
    }
    
    const tableData = [
        headers.map(h => ({ text: h, options: { bold: true, fill: theme.primary, color: 'FFFFFF' } })),
        ...rows.map(row => row.map(cell => ({ text: cell })))
    ];
    
    slide.addTable(tableData, {
        x: 0.5, y: 1.5, w: 9,
        fontSize: 12,
        border: { type: 'solid', pt: 0.5, color: 'CCCCCC' },
        align: 'center',
        valign: 'middle'
    });
}

function addQuoteSlide(slide, data, theme) {
    slide.background = { color: 'F8F8F8' };
    
    slide.addText(`"${data.quote || ''}"`, {
        x: 1, y: 1.5, w: 8, h: 2,
        fontSize: 28, italic: true, color: theme.text,
        align: 'center', valign: 'middle'
    });
    
    if (data.author) {
        slide.addText(`— ${data.author}`, {
            x: 1, y: 3.5, w: 8, h: 0.5,
            fontSize: 16, color: theme.lightText,
            align: 'right'
        });
    }
}

function addComparisonSlide(slide, data, theme) {
    addSlideTitle(slide, data.title, theme);
    
    const leftTitle = data.leftTitle || '选项A';
    const rightTitle = data.rightTitle || '选项B';
    const leftItems = data.leftItems || data.left || [];
    const rightItems = data.rightItems || data.right || [];
    
    slide.addText(leftTitle, {
        x: 0.5, y: 1.5, w: 4, h: 0.5,
        fontSize: 18, bold: true, color: theme.primary,
        align: 'center'
    });
    
    slide.addText(rightTitle, {
        x: 5.5, y: 1.5, w: 4, h: 0.5,
        fontSize: 18, bold: true, color: theme.secondary,
        align: 'center'
    });
    
    slide.addShape('rect', {
        x: 0.5, y: 2, w: 4, h: 3,
        fill: { color: 'E8F4FD' },
        line: { color: theme.primary, width: 1 }
    });
    
    slide.addShape('rect', {
        x: 5.5, y: 2, w: 4, h: 3,
        fill: { color: 'FFF3E0' },
        line: { color: theme.secondary, width: 1 }
    });
    
    const leftText = leftItems.map(item => ({ text: item, options: { bullet: true } }));
    const rightText = rightItems.map(item => ({ text: item, options: { bullet: true } }));
    
    slide.addText(leftText, { x: 0.7, y: 2.2, w: 3.6, h: 2.6, fontSize: 14 });
    slide.addText(rightText, { x: 5.7, y: 2.2, w: 3.6, h: 2.6, fontSize: 14 });
}

function addTimelineSlide(slide, data, theme) {
    addSlideTitle(slide, data.title, theme);
    
    const events = data.events || [];
    const totalWidth = 8;
    const step = totalWidth / Math.max(events.length - 1, 1);
    
    slide.addShape('line', {
        x: 1, y: 2.5, w: totalWidth, h: 0,
        line: { color: theme.primary, width: 2 }
    });
    
    events.forEach((event, index) => {
        const x = 1 + index * step;
        
        slide.addShape('ellipse', {
            x: x - 0.1, y: 2.4, w: 0.2, h: 0.2,
            fill: { color: theme.primary }
        });
        
        if (event.date) {
            slide.addText(event.date, {
                x: x - 0.5, y: 2.7, w: 1, h: 0.3,
                fontSize: 10, color: theme.lightText,
                align: 'center'
            });
        }
        
        if (event.title) {
            slide.addText(event.title, {
                x: x - 0.7, y: 3.1, w: 1.4, h: 1,
                fontSize: 11, color: theme.text,
                align: 'center'
            });
        }
    });
}

function addProcessSlide(slide, data, theme) {
    addSlideTitle(slide, data.title, theme);
    
    const steps = data.steps || [];
    const totalWidth = 8;
    const stepWidth = totalWidth / steps.length;
    
    steps.forEach((step, index) => {
        const x = 0.5 + index * stepWidth;
        
        slide.addShape('rect', {
            x, y: 2, w: stepWidth - 0.3, h: 1,
            fill: { color: theme.primary },
            line: { color: theme.primary }
        });
        
        slide.addText(step, {
            x, y: 2, w: stepWidth - 0.3, h: 1,
            fontSize: 12, color: 'FFFFFF',
            align: 'center', valign: 'middle'
        });
        
        if (index < steps.length - 1) {
            slide.addShape('rightArrow', {
                x: x + stepWidth - 0.25, y: 2.3, w: 0.2, h: 0.4,
                fill: { color: theme.accent }
            });
        }
    });
}

function addStructureSlide(slide, data, theme) {
    addSlideTitle(slide, data.title, theme);
    
    const levels = data.levels || [];
    const levelHeight = 1;
    
    levels.forEach((level, levelIndex) => {
        const items = level.items || [];
        const itemWidth = 8 / items.length;
        
        items.forEach((item, itemIndex) => {
            const x = 0.5 + itemIndex * itemWidth;
            const y = 1.5 + levelIndex * levelHeight;
            
            slide.addShape('rect', {
                x, y, w: itemWidth - 0.2, h: 0.8,
                fill: { color: levelIndex === 0 ? theme.primary : theme.accent }
            });
            
            slide.addText(item, {
                x, y, w: itemWidth - 0.2, h: 0.8,
                fontSize: 12, color: 'FFFFFF',
                align: 'center', valign: 'middle'
            });
        });
    });
}

function addEndSlide(slide, data, theme) {
    slide.background = { color: theme.primary };
    
    slide.addText(data.title || '谢谢！', {
        x: 0.5, y: 2.5, w: 9, h: 1,
        fontSize: 48, bold: true, color: 'FFFFFF',
        align: 'center', valign: 'middle'
    });
    
    if (data.subtitle) {
        slide.addText(data.subtitle, {
            x: 0.5, y: 3.5, w: 9, h: 0.5,
            fontSize: 20, color: 'FFFFFF',
            align: 'center'
        });
    }
}

function addDefinitionSlide(slide, data, theme) {
    addSlideTitle(slide, data.title, theme);
    
    slide.addShape('rect', {
        x: 0.5, y: 1.5, w: 9, h: 3.5,
        fill: { color: 'F8F8F8' },
        line: { color: theme.accent, width: 2 }
    });
    
    slide.addText(data.definition || '', {
        x: 0.8, y: 1.8, w: 8.4, h: 3,
        fontSize: 16, color: theme.text,
        valign: 'top'
    });
}

function addArchitectureSlide(slide, data, theme) {
    addSlideTitle(slide, data.title, theme);
    
    const layers = data.layers || [];
    const layerHeight = 1.2;
    const colors = [theme.primary, theme.secondary, theme.accent];
    
    layers.forEach((layer, index) => {
        const y = 1.5 + index * layerHeight;
        const items = layer.items || [];
        const itemWidth = 8 / items.length;
        
        const layerName = layer.type === 'top' ? '顶层' : 
                          layer.type === 'middle' ? '中层' : '底层';
        
        slide.addText(layerName, {
            x: 0.1, y: y + 0.3, w: 0.4, h: 0.6,
            fontSize: 10, color: theme.lightText,
            rotate: 270
        });
        
        items.forEach((item, itemIndex) => {
            const x = 0.5 + itemIndex * itemWidth;
            
            slide.addShape('rect', {
                x, y, w: itemWidth - 0.2, h: layerHeight - 0.2,
                fill: { color: colors[index % colors.length] }
            });
            
            slide.addText(item, {
                x, y, w: itemWidth - 0.2, h: layerHeight - 0.2,
                fontSize: 12, color: 'FFFFFF',
                align: 'center', valign: 'middle'
            });
        });
    });
}

function addFlowchartSlide(slide, data, theme) {
    addSlideTitle(slide, data.title, theme);
    
    const steps = data.steps || [];
    const isLoop = data.isLoop || false;
    const centerX = 5;
    const centerY = 3;
    const radius = 1.5;
    
    if (isLoop && steps.length > 2) {
        const angleStep = (2 * Math.PI) / steps.length;
        
        steps.forEach((step, index) => {
            const angle = index * angleStep - Math.PI / 2;
            const x = centerX + radius * Math.cos(angle) - 0.6;
            const y = centerY + radius * Math.sin(angle) - 0.3;
            
            slide.addShape('ellipse', {
                x, y, w: 1.2, h: 0.6,
                fill: { color: theme.primary }
            });
            
            slide.addText(step, {
                x, y, w: 1.2, h: 0.6,
                fontSize: 10, color: 'FFFFFF',
                align: 'center', valign: 'middle'
            });
        });
        
        if (isLoop) {
            slide.addText('↻', {
                x: centerX - 0.2, y: centerY - 0.2, w: 0.4, h: 0.4,
                fontSize: 20, color: theme.accent,
                align: 'center'
            });
        }
    } else {
        const stepWidth = 8 / steps.length;
        
        steps.forEach((step, index) => {
            const x = 0.5 + index * stepWidth;
            
            slide.addShape('rect', {
                x, y: 2.5, w: stepWidth - 0.3, h: 0.8,
                fill: { color: theme.primary }
            });
            
            slide.addText(step, {
                x, y: 2.5, w: stepWidth - 0.3, h: 0.8,
                fontSize: 12, color: 'FFFFFF',
                align: 'center', valign: 'middle'
            });
            
            if (index < steps.length - 1) {
                slide.addShape('rightArrow', {
                    x: x + stepWidth - 0.25, y: 2.7, w: 0.2, h: 0.4,
                    fill: { color: theme.accent }
                });
            }
        });
    }
}

function addPyramidSlide(slide, data, theme) {
    addSlideTitle(slide, data.title, theme);
    
    const levels = data.pyramidLevels || [];
    const baseY = 4.5;
    const levelHeight = 0.8;
    
    levels.forEach((level, index) => {
        const width = 8 - index * 1.5;
        const x = (10 - width) / 2;
        const y = baseY - index * levelHeight;
        
        const levelColor = level.color || theme.primary;
        
        slide.addShape('trapezoid', {
            x, y, w: width, h: levelHeight,
            fill: { color: levelColor }
        });
        
        const text = level.items && level.items.length > 0 
            ? `${level.title}\n${level.items.join(', ')}`
            : level.title || level;
        
        slide.addText(text, {
            x, y, w: width, h: levelHeight,
            fontSize: 11, color: 'FFFFFF',
            align: 'center', valign: 'middle'
        });
    });
}

function addMatrixSlide(slide, data, theme) {
    addSlideTitle(slide, data.title, theme);
    
    const rows = data.rowHeaders || [];
    const columns = data.colHeaders || [];
    const cells = data.matrixCells || [];
    const matrixRows = data.matrixRows || rows.length;
    const matrixCols = data.matrixCols || columns.length;
    
    const colWidth = 8 / (columns.length + 1);
    const rowHeight = 0.8;
    
    slide.addText('', { x: 0.5, y: 1.5, w: colWidth, h: rowHeight });
    
    columns.forEach((col, index) => {
        slide.addText(col, {
            x: 0.5 + (index + 1) * colWidth, y: 1.5, w: colWidth, h: rowHeight,
            fontSize: 12, bold: true, color: theme.primary,
            align: 'center', valign: 'middle'
        });
    });
    
    rows.forEach((row, rowIndex) => {
        slide.addText(row, {
            x: 0.5, y: 2.3 + rowIndex * rowHeight, w: colWidth, h: rowHeight,
            fontSize: 12, bold: true, color: theme.primary,
            align: 'center', valign: 'middle'
        });
        
        columns.forEach((col, colIndex) => {
            const cell = cells.find(c => c.rowHeader === row && c.colHeader === col);
            
            const cellColor = cell?.color || 'E8F4FD';
            
            slide.addShape('rect', {
                x: 0.5 + (colIndex + 1) * colWidth,
                y: 2.3 + rowIndex * rowHeight,
                w: colWidth, h: rowHeight,
                fill: { color: cell ? cellColor : 'F5F5F5' },
                line: { color: 'CCCCCC', width: 0.5 }
            });
            
            if (cell) {
                slide.addText(cell.content || '', {
                    x: 0.5 + (colIndex + 1) * colWidth,
                    y: 2.3 + rowIndex * rowHeight,
                    w: colWidth, h: rowHeight,
                    fontSize: 10, color: theme.text,
                    align: 'center', valign: 'middle'
                });
            }
        });
    });
}

function addParetoSlide(slide, data, theme) {
    addSlideTitle(slide, data.title, theme);
    
    let items = data.paretoItems || data.items || [];
    if (items.length === 0) return;
    
    // Normalize items to have category/label and value
    items = items.map(item => ({
        category: item.category || item.label || '',
        value: item.value || 0,
        cumulativePercent: item.cumulativePercent || 0
    }));
    
    const maxVal = Math.max(...items.map(i => i.value));
    const barHeight = 0.4;
    const startY = 1.8;
    const barMaxWidth = 5;
    
    items.forEach((item, index) => {
        const y = startY + index * (barHeight + 0.15);
        const barWidth = (item.value / maxVal) * barMaxWidth;
        
        const isCore = item.cumulativePercent <= 80;
        
        slide.addShape('rect', {
            x: 2, y: y, w: barWidth, h: barHeight,
            fill: { color: isCore ? theme.primary : 'CCCCCC' }
        });
        
        slide.addText(item.category, {
            x: 0.5, y: y, w: 1.4, h: barHeight,
            fontSize: 10, color: theme.text,
            align: 'right', valign: 'middle'
        });
        
        slide.addText(`${item.value}`, {
            x: 2 + barWidth + 0.1, y: y, w: 0.8, h: barHeight,
            fontSize: 10, color: theme.text, valign: 'middle'
        });
        
        slide.addText(`${item.cumulativePercent}%`, {
            x: 7.5, y: y, w: 1, h: barHeight,
            fontSize: 10, color: theme.lightText, valign: 'middle'
        });
    });
    
    slide.addShape('line', {
        x: 7.5, y: startY, w: 0, h: items.length * (barHeight + 0.15),
        line: { color: theme.accent, width: 1 }
    });
    
    slide.addText('累计%', {
        x: 7.5, y: startY - 0.3, w: 1, h: 0.3,
        fontSize: 10, color: theme.lightText
    });
}

function addBranchedHierarchySlide(slide, data, theme) {
    addSlideTitle(slide, data.title, theme);
    
    const root = data.branchRoot;
    if (!root) return;
    
    const layout = data.branchLayout || 'pyramid';
    const levelColors = [theme.primary, theme.secondary, theme.accent, '4A90A4', '6B8E23'];
    
    function renderPyramidNode(node, x, y, width, level) {
        if (!node) return;
        
        const height = 0.7;
        const color = levelColors[level % levelColors.length];
        
        slide.addShape('rect', {
            x: x, y: y, w: width, h: height,
            fill: { color: color },
            line: { color: 'FFFFFF', width: 1 }
        });
        
        let text = node.title;
        if (node.subtitle) {
            text += '\n' + node.subtitle;
        }
        
        slide.addText(text, {
            x: x, y: y, w: width, h: height,
            fontSize: 10, color: 'FFFFFF',
            align: 'center', valign: 'middle'
        });
        
        if (node.annotation) {
            slide.addText(node.annotation, {
                x: x + width + 0.1, y: y + height / 2 - 0.15, w: 1.5, h: 0.3,
                fontSize: 8, color: theme.lightText
            });
        }
        
        if (node.children && node.children.length > 0) {
            const childWidth = width / node.children.length - 0.2;
            const startX = x + (width - (childWidth + 0.2) * node.children.length) / 2;
            
            node.children.forEach((child, index) => {
                const childX = startX + index * (childWidth + 0.2);
                const childY = y + height + 0.5;
                
                slide.addShape('line', {
                    x: x + width / 2, y: y + height, w: 0, h: 0.25,
                    line: { color: theme.lightText, width: 1 }
                });
                
                renderPyramidNode(child, childX, childY, childWidth, level + 1);
            });
        }
    }
    
    const rootWidth = 3;
    const startX = (10 - rootWidth) / 2;
    renderPyramidNode(root, startX, 1.5, rootWidth, 0);
}

function addQuadrantMatrixSlide(slide, data, theme) {
    addSlideTitle(slide, data.title, theme);
    
    const cells = data.quadrantCells || [];
    const xAxisLabel = data.xAxisLabel || '';
    const yAxisLabel = data.yAxisLabel || '';
    const xAxisLow = data.xAxisLowLabel || '低';
    const xAxisHigh = data.xAxisHighLabel || '高';
    const yAxisLow = data.yAxisLowLabel || '低';
    const yAxisHigh = data.yAxisHighLabel || '高';
    
    const matrixX = 1.5;
    const matrixY = 1.5;
    const matrixW = 7;
    const matrixH = 3.6;
    const cellW = matrixW / 2;
    const cellH = matrixH / 2;
    
    const quadrantColors = {
        'topLeft': 'E8F4FD',
        'topRight': 'D4EDDA',
        'bottomLeft': 'FFF3CD',
        'bottomRight': 'F8D7DA'
    };
    
    slide.addShape('line', {
        x: matrixX, y: matrixY + cellH, w: matrixW, h: 0,
        line: { color: 'CCCCCC', width: 1 }
    });
    
    slide.addShape('line', {
        x: matrixX + cellW, y: matrixY, w: 0, h: matrixH,
        line: { color: 'CCCCCC', width: 1 }
    });
    
    cells.forEach(cell => {
        let x, y;
        switch (cell.quadrant) {
            case 'topLeft':
                x = matrixX; y = matrixY;
                break;
            case 'topRight':
                x = matrixX + cellW; y = matrixY;
                break;
            case 'bottomLeft':
                x = matrixX; y = matrixY + cellH;
                break;
            case 'bottomRight':
                x = matrixX + cellW; y = matrixY + cellH;
                break;
        }
        
        const bgColor = cell.color || quadrantColors[cell.quadrant];
        
        slide.addShape('rect', {
            x: x + 0.1, y: y + 0.1, w: cellW - 0.2, h: cellH - 0.2,
            fill: { color: bgColor },
            line: { color: 'CCCCCC', width: 0.5 }
        });
        
        let text = cell.title;
        if (cell.subtitle) {
            text += '\n' + cell.subtitle;
        }
        
        slide.addText(text, {
            x: x + 0.1, y: y + 0.1, w: cellW - 0.2, h: cellH - 0.2,
            fontSize: 12, color: theme.text,
            align: 'center', valign: 'middle'
        });
    });
    
    slide.addText(yAxisHigh, {
        x: matrixX - 0.8, y: matrixY, w: 0.7, h: 0.3,
        fontSize: 9, color: theme.lightText, align: 'center'
    });
    
    slide.addText(yAxisLow, {
        x: matrixX - 0.8, y: matrixY + matrixH - 0.3, w: 0.7, h: 0.3,
        fontSize: 9, color: theme.lightText, align: 'center'
    });
    
    slide.addText(xAxisLow, {
        x: matrixX, y: matrixY + matrixH + 0.1, w: 0.5, h: 0.3,
        fontSize: 9, color: theme.lightText, align: 'center'
    });
    
    slide.addText(xAxisHigh, {
        x: matrixX + matrixW - 0.5, y: matrixY + matrixH + 0.1, w: 0.5, h: 0.3,
        fontSize: 9, color: theme.lightText, align: 'center'
    });
    
    if (yAxisLabel) {
        slide.addText(yAxisLabel, {
            x: 0.3, y: matrixY + matrixH / 2 - 0.2, w: 0.8, h: 0.4,
            fontSize: 10, color: theme.text, bold: true,
            rotate: 270, align: 'center'
        });
    }
    
    if (xAxisLabel) {
        slide.addText(xAxisLabel, {
            x: matrixX + matrixW / 2 - 0.5, y: matrixY + matrixH + 0.2, w: 1, h: 0.3,
            fontSize: 10, color: theme.text, bold: true, align: 'center'
        });
    }
}

function addImageSlide(slide, data, theme) {
    addSlideTitle(slide, data.title, theme);
    
    if (data.imagePath) {
        slide.addImage({
            path: data.imagePath,
            x: data.x || 1,
            y: data.y || 1.5,
            w: data.width || 8,
            h: data.height || 4
        });
    }
    
    if (data.caption) {
        slide.addText(data.caption, {
            x: 0.5, y: 5.2, w: 9, h: 0.3,
            fontSize: 12, color: theme.lightText,
            align: 'center'
        });
    }
}

async function addMermaidSlide(slide, data, theme) {
    addSlideTitle(slide, data.title, theme);
    
    const mermaidCode = data.mermaidCode || '';
    const diagramType = data.diagramType || 'flowchart';
    
    if (data.imageData) {
        const imageData = `data:image/png;base64,${data.imageData}`;
        
        const imgWidth = data.imageWidth || 800;
        const imgHeight = data.imageHeight || 600;
        const aspectRatio = imgWidth / imgHeight;
        
        const maxWidth = 9.4;
        const maxHeight = 4.8;
        
        let displayWidth, displayHeight;
        
        if (aspectRatio > maxWidth / maxHeight) {
            displayWidth = maxWidth;
            displayHeight = maxWidth / aspectRatio;
        } else {
            displayHeight = maxHeight;
            displayWidth = maxHeight * aspectRatio;
        }
        
        const x = (10 - displayWidth) / 2;
        const y = 1.0 + (maxHeight - displayHeight) / 2;
        
        slide.addImage({
            data: imageData,
            x: x, y: y, w: displayWidth, h: displayHeight
        });
    } else if (mermaidCode && diagramType !== 'gantt') {
        const imageData = await fetchMermaidImage(mermaidCode, 'png');
        
        if (imageData) {
            slide.addImage({
                data: imageData,
                x: 0.3, y: 1.2, w: 9.4, h: 4.5
            });
        } else {
            addMermaidFallback(slide, mermaidCode, theme);
        }
    } else if (mermaidCode) {
        addMermaidFallback(slide, mermaidCode, theme);
    }
}

function addMermaidFallback(slide, mermaidCode, theme) {
    slide.addShape('rect', {
        x: 0.5, y: 1.5, w: 9, h: 4,
        fill: { color: 'F8F8F8' },
        line: { color: theme.accent, width: 1, dashType: 'dash' }
    });
    
    slide.addText('Mermaid Diagram', {
        x: 0.5, y: 1.6, w: 9, h: 0.4,
        fontSize: 14, color: theme.lightText,
        align: 'center'
    });
    
    slide.addText(mermaidCode, {
        x: 0.7, y: 2.1, w: 8.6, h: 3.2,
        fontSize: 10, fontFace: 'Courier New', color: theme.text,
        valign: 'top'
    });
}

function addTwoColumnSlide(slide, data, theme) {
    addSlideTitle(slide, data.title, theme);
    
    if (data.leftTitle) {
        slide.addText(data.leftTitle, {
            x: 0.5, y: 1.5, w: 4.5, h: 0.4,
            fontSize: 16, bold: true, color: theme.primary
        });
    }
    
    if (data.rightTitle) {
        slide.addText(data.rightTitle, {
            x: 5.5, y: 1.5, w: 4, h: 0.4,
            fontSize: 16, bold: true, color: theme.primary
        });
    }
    
    if (data.leftContent) {
        slide.addText(data.leftContent, {
            x: 0.5, y: 2, w: 4.5, h: 3,
            fontSize: 14, color: theme.text,
            valign: 'top'
        });
    }
    
    if (data.rightContent) {
        slide.addText(data.rightContent, {
            x: 5.5, y: 2, w: 4, h: 3,
            fontSize: 14, color: theme.text,
            valign: 'top'
        });
    }
}

function addChartSlide(slide, data, theme, pres) {
    addSlideTitle(slide, data.title, theme);
    
    const chartType = data.chartType || 'bar';
    const labels = data.labels || [];
    const series = data.series || [];
    
    const chartData = series.map(s => ({
        name: s.name,
        labels: labels,
        values: s.values
    }));
    
    let pptxChartType;
    switch (chartType) {
        case 'bar':
            pptxChartType = pres.ChartType.bar;
            break;
        case 'line':
            pptxChartType = pres.ChartType.line;
            break;
        case 'pie':
            pptxChartType = pres.ChartType.pie;
            break;
        case 'doughnut':
            pptxChartType = pres.ChartType.doughnut;
            break;
        case 'radar':
            pptxChartType = pres.ChartType.radar;
            break;
        case 'scatter':
            pptxChartType = pres.ChartType.scatter;
            break;
        default:
            pptxChartType = pres.ChartType.bar;
    }
    
    const chartOptions = {
        x: 0.5, y: 1.5, w: 9, h: 4,
        showTitle: false,
        showLegend: data.showLegend !== false,
        legendPos: 'b',
        chartColors: [theme.primary, theme.secondary, theme.accent]
    };
    
    if (data.xAxisTitle) chartOptions.xAxisTitle = data.xAxisTitle;
    if (data.yAxisTitle) chartOptions.yAxisTitle = data.yAxisTitle;
    
    slide.addChart(pptxChartType, chartData, chartOptions);
}

function addDefaultSlide(slide, data, theme) {
    addSlideTitle(slide, data.title, theme);
    
    const contents = data.contents || {};
    const keys = Object.keys(contents);
    
    // Find first array in contents (likely items list)
    let itemsArray = null;
    for (const key of keys) {
        if (Array.isArray(contents[key]) && typeof contents[key][0] === 'string') {
            itemsArray = contents[key];
            break;
        }
    }
    
    // Find first string value (likely content text)
    let textContent = null;
    for (const key of keys) {
        if (typeof contents[key] === 'string' && !contents[key].startsWith('[')) {
            textContent = contents[key];
            break;
        }
    }
    
    if (itemsArray) {
        // Render as list
        const bulletText = itemsArray.map(item => `• ${item}`).join('\n');
        slide.addText(bulletText, {
            x: 0.5, y: 1.5, w: 9, h: 4,
            fontSize: 18, color: theme.text,
            valign: 'top'
        });
    } else if (textContent) {
        // Render as text
        slide.addText(textContent, {
            x: 0.5, y: 1.5, w: 9, h: 3.5,
            fontSize: 16, color: theme.text
        });
    } else if (data.content) {
        slide.addText(data.content, {
            x: 0.5, y: 1.5, w: 9, h: 3.5,
            fontSize: 16, color: theme.text
        });
    }
}

function addSlideTitle(slide, title, theme) {
    if (!title) return;
    
    slide.addText(title, {
        x: 0.5, y: 0.3, w: 9, h: 0.7,
        fontSize: 28, bold: true, color: theme.primary
    });
    
    slide.addShape('line', {
        x: 0.5, y: 1, w: 9, h: 0,
        line: { color: theme.accent, width: 1 }
    });
}

function addTextSlide(slide, data, theme) {
    addSlideTitle(slide, data.title, theme);
    
    const content = data.content || data.Content;
    if (content && typeof content === 'string') {
        slide.addShape('rect', {
            x: 0.5, y: 1.5, w: 9, h: 3.5,
            fill: { color: 'F8F8F8' },
            line: { color: theme.accent, width: 1 }
        });
        
        slide.addText(content, {
            x: 0.8, y: 1.8, w: 8.4, h: 3,
            fontSize: 14, color: theme.text,
            valign: 'top'
        });
    } else {
        addDefaultSlide(slide, data, theme);
    }
}

function addHierarchySlide(slide, data, theme) {
    addSlideTitle(slide, data.title, theme);
    
    // Support both hierarchyRoot and levels format
    const levels = data.levels || [];
    if (levels.length === 0 && !data.hierarchyRoot) return;
    
    // If using levels format (array of arrays)
    if (levels.length > 0) {
        const colors = [theme.primary, theme.secondary, theme.accent];
        const levelHeight = 1.0;
        const startY = 1.5;
        
        levels.forEach((levelItems, levelIndex) => {
            const items = Array.isArray(levelItems) ? levelItems : [levelItems];
            const y = startY + levelIndex * (levelHeight + 0.3);
            const itemWidth = 9 / items.length;
            
            items.forEach((item, itemIndex) => {
                const x = 0.5 + itemIndex * itemWidth;
                
                slide.addShape('rect', {
                    x: x, y: y, w: itemWidth - 0.2, h: levelHeight,
                    fill: { color: colors[levelIndex % colors.length] },
                    line: { color: 'FFFFFF', width: 1 }
                });
                
                slide.addText(item, {
                    x: x, y: y, w: itemWidth - 0.2, h: levelHeight,
                    fontSize: 12, color: 'FFFFFF',
                    align: 'center', valign: 'middle'
                });
            });
            
            // Draw connecting lines
            if (levelIndex < levels.length - 1) {
                const nextItems = Array.isArray(levels[levelIndex + 1]) ? levels[levelIndex + 1] : [levels[levelIndex + 1]];
                const nextItemWidth = 9 / nextItems.length;
                
                items.forEach((_, itemIndex) => {
                    const x = 0.5 + itemIndex * itemWidth + (itemWidth - 0.2) / 2;
                    slide.addShape('line', {
                        x: x, y: y + levelHeight,
                        w: 0, h: 0.3,
                        line: { color: theme.accent, width: 1 }
                    });
                });
            }
        });
        return;
    }
    
    // Original hierarchyRoot format
    const root = data.hierarchyRoot;
    if (!root) return;
    
    const direction = data.hierarchyDirection || 'topDown';
    const isHorizontal = direction === 'leftToRight' || direction === 'rightToLeft';
    
    function renderNodeHorizontal(node, x, y, level) {
        const width = 2.2;
        const height = 1.2;
        const colors = [theme.primary, theme.secondary, theme.accent];
        
        slide.addShape('rect', {
            x: x, y: y, w: width, h: height,
            fill: { color: colors[level % colors.length] },
            line: { color: 'FFFFFF', width: 1 }
        });
        
        let text = node.title;
        if (node.subtitle) {
            text += '\n' + node.subtitle;
        }
        
        slide.addText(text, {
            x: x, y: y, w: width, h: height,
            fontSize: 10, color: 'FFFFFF',
            align: 'center', valign: 'middle'
        });
        
        if (node.children && node.children.length > 0) {
            const childX = x + width + 0.5;
            const childSpacing = height + 0.3;
            const startY = y - (node.children.length - 1) * childSpacing / 2 + height / 2 - 0.6;
            
            node.children.forEach((child, i) => {
                const childY = startY + i * childSpacing;
                
                slide.addShape('line', {
                    x: x + width, y: y + height / 2,
                    w: 0.25, h: 0,
                    line: { color: theme.accent, width: 1 }
                });
                
                slide.addShape('line', {
                    x: x + width + 0.25,
                    y: Math.min(y + height / 2, childY + height / 2),
                    w: 0,
                    h: Math.abs(y + height / 2 - childY - height / 2),
                    line: { color: theme.accent, width: 1 }
                });
                
                slide.addShape('line', {
                    x: x + width + 0.25, y: childY + height / 2,
                    w: 0.25, h: 0,
                    line: { color: theme.accent, width: 1 }
                });
                
                renderNodeHorizontal(child, childX, childY, level + 1);
            });
        }
    }
    
    function renderNodeVertical(node, x, y, level) {
        const width = 2.8;
        const height = 0.7;
        const colors = [theme.primary, theme.secondary, theme.accent];
        
        slide.addShape('rect', {
            x: x, y: y, w: width, h: height,
            fill: { color: colors[level % colors.length] },
            line: { color: 'FFFFFF', width: 1 }
        });
        
        let text = node.title;
        if (node.subtitle) {
            text += '\n' + node.subtitle;
        }
        
        slide.addText(text, {
            x: x, y: y, w: width, h: height,
            fontSize: 10, color: 'FFFFFF',
            align: 'center', valign: 'middle'
        });
        
        if (node.children && node.children.length > 0) {
            const childY = y + height + 0.4;
            const childSpacing = width + 0.4;
            const startX = x - (node.children.length - 1) * childSpacing / 2;
            
            node.children.forEach((child, i) => {
                const childX = startX + i * childSpacing;
                
                slide.addShape('line', {
                    x: x + width / 2, y: y + height,
                    w: 0, h: 0.2,
                    line: { color: theme.accent, width: 1 }
                });
                
                slide.addShape('line', {
                    x: Math.min(x + width / 2, childX + width / 2),
                    y: y + height + 0.2,
                    w: Math.abs(x + width / 2 - childX - width / 2),
                    h: 0,
                    line: { color: theme.accent, width: 1 }
                });
                
                slide.addShape('line', {
                    x: childX + width / 2, y: y + height + 0.2,
                    w: 0, h: 0.2,
                    line: { color: theme.accent, width: 1 }
                });
                
                renderNodeVertical(child, childX, childY, level + 1);
            });
        }
    }
    
    if (isHorizontal) {
        const startX = 0.5;
        const startY = 2.5;
        renderNodeHorizontal(root, startX, startY, 0);
    } else {
        const startX = (10 - 2.8) / 2;
        const startY = 1.5;
        renderNodeVertical(root, startX, startY, 0);
    }
}

function addCycleFlowSlide(slide, data, theme) {
    addSlideTitle(slide, data.title, theme);
    
    const steps = data.cycleSteps || data.items || [];
    if (steps.length === 0) return;
    
    const centerX = 5;
    const centerY = 3.2;
    const radius = 1.8;
    const angleStep = (2 * Math.PI) / steps.length;
    
    steps.forEach((step, index) => {
        const angle = index * angleStep - Math.PI / 2;
        const x = centerX + radius * Math.cos(angle) - 0.7;
        const y = centerY + radius * Math.sin(angle) - 0.4;
        
        const colors = [theme.primary, theme.secondary, theme.accent, 'E65100'];
        
        slide.addShape('ellipse', {
            x: x, y: y, w: 1.4, h: 0.8,
            fill: { color: colors[index % colors.length] }
        });
        
        let text = step.title;
        if (step.description) {
            text += '\n' + step.description.substring(0, 10) + '...';
        }
        
        slide.addText(text, {
            x: x, y: y, w: 1.4, h: 0.8,
            fontSize: 9, color: 'FFFFFF',
            align: 'center', valign: 'middle'
        });
    });
    
    slide.addText('↻', {
        x: centerX - 0.3, y: centerY - 0.3, w: 0.6, h: 0.6,
        fontSize: 24, color: theme.accent,
        align: 'center', valign: 'middle'
    });
}

function addBoxDiagramSlide(slide, data, theme) {
    addSlideTitle(slide, data.title, theme);
    
    const boxes = data.boxes || [];
    const layout = data.boxLayout || 'horizontal';
    
    if (layout === 'horizontal') {
        const boxWidth = Math.min(1.5, 9 / boxes.length);
        const boxHeight = 3;
        const startX = (10 - boxes.length * boxWidth) / 2;
        
        boxes.forEach((box, index) => {
            const x = startX + index * boxWidth;
            const y = 1.5;
            
            slide.addShape('rect', {
                x: x + 0.05, y: y, w: boxWidth - 0.1, h: boxHeight,
                fill: { color: 'F5F5F5' },
                line: { color: theme.accent, width: 1 }
            });
            
            if (box.title) {
                slide.addText(box.title, {
                    x: x + 0.1, y: y + 0.1, w: boxWidth - 0.2, h: 0.4,
                    fontSize: 10, bold: true, color: theme.primary
                });
            }
            
            if (box.content && Array.isArray(box.content)) {
                const contentText = box.content.join('\n');
                slide.addText(contentText, {
                    x: x + 0.1, y: y + 0.5, w: boxWidth - 0.2, h: boxHeight - 0.6,
                    fontSize: 8, color: theme.text,
                    valign: 'top'
                });
            }
            
            if (index < boxes.length - 1) {
                slide.addShape('rightArrow', {
                    x: x + boxWidth - 0.05, y: y + boxHeight / 2 - 0.15, w: 0.1, h: 0.3,
                    fill: { color: theme.accent }
                });
            }
        });
    } else {
        const boxWidth = 8;
        const boxHeight = 0.8;
        
        boxes.forEach((box, index) => {
            const y = 1.5 + index * (boxHeight + 0.1);
            
            slide.addShape('rect', {
                x: 1, y: y, w: boxWidth, h: boxHeight,
                fill: { color: 'F5F5F5' },
                line: { color: theme.accent, width: 1 }
            });
            
            if (box.title) {
                slide.addText(box.title, {
                    x: 1.1, y: y + 0.05, w: 2, h: boxHeight - 0.1,
                    fontSize: 12, bold: true, color: theme.primary,
                    valign: 'middle'
                });
            }
            
            if (box.content && Array.isArray(box.content)) {
                const contentText = box.content.join(' | ');
                slide.addText(contentText, {
                    x: 3.2, y: y + 0.05, w: 5.7, h: boxHeight - 0.1,
                    fontSize: 10, color: theme.text,
                    valign: 'middle'
                });
            }
            
            if (index < boxes.length - 1) {
                slide.addShape('downArrow', {
                    x: 4.9, y: y + boxHeight, w: 0.2, h: 0.1,
                    fill: { color: theme.accent }
                });
            }
        });
    }
}
