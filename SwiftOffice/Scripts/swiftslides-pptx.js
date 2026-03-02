#!/usr/bin/env node

const pptxgen = require('pptxgenjs');
const https = require('https');
const pako = require('pako');

let input = '';

process.stdin.on('data', chunk => {
    input += chunk.toString();
});

process.stdin.on('end', async () => {
    try {
        const presentation = JSON.parse(input);
        await generatePPTX(presentation);
    } catch (error) {
        console.log(JSON.stringify({ 
            success: false, 
            error: error.message,
            stack: error.stack
        }));
        process.exit(1);
    }
});

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

async function generatePPTX(data) {
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
    
    for (const section of data.sections || []) {
        for (const slide of section.slides || []) {
            await addSlide(pres, slide, theme);
        }
    }
    
    const outputPath = process.argv[2] || `${data.title || 'presentation'}.pptx`;
    await pres.writeFile({ fileName: outputPath });
    
    console.log(JSON.stringify({ 
        success: true, 
        path: outputPath,
        slides: pres.slides.length
    }));
}

async function addSlide(pres, slide, theme) {
    const type = slide.type;
    const slideObj = pres.addSlide();
    
    switch (type) {
        case '封面页':
            addCoverSlide(slideObj, slide, theme);
            break;
        case '章节页':
            addSectionSlide(slideObj, slide, theme);
            break;
        case '列表页':
            addListSlide(slideObj, slide, theme);
            break;
        case '卡片页':
            addCardSlide(slideObj, slide, theme);
            break;
        case '表格页':
            addTableSlide(slideObj, slide, theme);
            break;
        case '引用页':
            addQuoteSlide(slideObj, slide, theme);
            break;
        case '对比页':
            addComparisonSlide(slideObj, slide, theme);
            break;
        case '时间线页':
            addTimelineSlide(slideObj, slide, theme);
            break;
        case '流程页':
            addProcessSlide(slideObj, slide, theme);
            break;
        case '结构图页':
            addStructureSlide(slideObj, slide, theme);
            break;
        case '结束页':
            addEndSlide(slideObj, slide, theme);
            break;
        case '定义页':
            addDefinitionSlide(slideObj, slide, theme);
            break;
        case '架构图页':
            addArchitectureSlide(slideObj, slide, theme);
            break;
        case '流程图页':
            addFlowchartSlide(slideObj, slide, theme);
            break;
        case '金字塔页':
            addPyramidSlide(slideObj, slide, theme);
            break;
        case '矩阵页':
            addMatrixSlide(slideObj, slide, theme);
            break;
        case '柏拉图页':
            addParetoSlide(slideObj, slide, theme);
            break;
        case '图片页':
            addImageSlide(slideObj, slide, theme);
            break;
        case '双栏页':
            addTwoColumnSlide(slideObj, slide, theme);
            break;
        case '图表页':
            addChartSlide(slideObj, slide, theme, pres);
            break;
        case 'Mermaid流程图页':
        case 'Mermaid时序图页':
        case 'Mermaid甘特图页':
            await addMermaidSlide(slideObj, slide, theme);
            break;
        default:
            addDefaultSlide(slideObj, slide, theme);
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
    
    const items = data.items || [];
    const textItems = items.map(item => ({
        text: item,
        options: { bullet: { type: 'bullet' }, fontSize: 18, color: theme.text }
    }));
    
    slide.addText(textItems, {
        x: 0.5, y: 1.2, w: 9, h: 4,
        valign: 'top'
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
    
    const headers = data.headers || [];
    const rows = data.rows || [];
    
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
    const leftItems = data.leftItems || [];
    const rightItems = data.rightItems || [];
    
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
    
    const levels = data.levels || [];
    const baseY = 4.5;
    const levelHeight = 0.8;
    
    levels.forEach((level, index) => {
        const width = 8 - index * 1.5;
        const x = (10 - width) / 2;
        const y = baseY - index * levelHeight;
        
        slide.addShape('trapezoid', {
            x, y, w: width, h: levelHeight,
            fill: { color: theme.primary }
        });
        
        slide.addText(level, {
            x, y, w: width, h: levelHeight,
            fontSize: 12, color: 'FFFFFF',
            align: 'center', valign: 'middle'
        });
    });
}

function addMatrixSlide(slide, data, theme) {
    addSlideTitle(slide, data.title, theme);
    
    const rows = data.rows || [];
    const columns = data.columns || [];
    const cells = data.cells || [];
    
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
            const cell = cells.find(c => c.row === row && c.column === col);
            
            slide.addShape('rect', {
                x: 0.5 + (colIndex + 1) * colWidth,
                y: 2.3 + rowIndex * rowHeight,
                w: colWidth, h: rowHeight,
                fill: { color: cell ? 'E8F4FD' : 'F5F5F5' },
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
    
    const items = data.items || [];
    const threshold = data.threshold || 80;
    
    const chartData = [{
        name: '数值',
        labels: items.map(i => i.label),
        values: items.map(i => i.value)
    }];
    
    slide.addChart(pres.ChartType.bar, chartData, {
        x: 0.5, y: 1.5, w: 5, h: 3.5,
        showTitle: false,
        showValue: true,
        barDir: 'bar'
    });
    
    let cumulative = 0;
    const total = items.reduce((sum, i) => sum + i.value, 0);
    
    items.forEach((item, index) => {
        cumulative += item.value;
        const percent = (cumulative / total * 100).toFixed(1);
        const isCore = item.isCoreProblem || percent <= threshold;
        
        const y = 1.5 + index * 0.5;
        
        slide.addShape('rect', {
            x: 6, y, w: 0.3, h: 0.4,
            fill: { color: isCore ? theme.primary : 'CCCCCC' }
        });
        
        slide.addText(`${percent}%`, {
            x: 6.4, y, w: 0.8, h: 0.4,
            fontSize: 10, color: theme.text
        });
    });
    
    slide.addText(`阈值: ${threshold}%`, {
        x: 6, y: 5, w: 3, h: 0.3,
        fontSize: 10, color: theme.lightText
    });
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
    
    if (mermaidCode) {
        const imageData = await fetchMermaidImage(mermaidCode, 'png');
        
        if (imageData) {
            slide.addImage({
                data: imageData,
                x: 0.3, y: 1.2, w: 9.4, h: 4.5,
                sizing: { type: 'contain', w: 9.4, h: 4.5 }
            });
        } else {
            slide.addShape('rect', {
                x: 0.5, y: 1.5, w: 9, h: 4,
                fill: { color: 'F8F8F8' },
                line: { color: theme.accent, width: 1, dashType: 'dash' }
            });
            
            slide.addText('图表渲染中...', {
                x: 0.5, y: 2.5, w: 9, h: 2,
                fontSize: 18, color: theme.lightText,
                align: 'center', valign: 'middle'
            });
            
            slide.addText(mermaidCode, {
                x: 0.7, y: 1.7, w: 8.6, h: 3.6,
                fontSize: 10, fontFace: 'Courier New', color: theme.text,
                valign: 'top'
            });
        }
    }
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
    
    if (data.content) {
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
