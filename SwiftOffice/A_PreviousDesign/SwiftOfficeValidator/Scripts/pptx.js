const pptxgen = require('pptxgenjs');

let input = '';

process.stdin.on('data', chunk => {
    input += chunk.toString();
});

process.stdin.on('end', async () => {
    try {
        const params = input.trim() ? JSON.parse(input) : {};
        const action = params.action || 'create';
        
        if (action === 'create') {
            const pres = new pptxgen();
            pres.layout = params.layout || 'LAYOUT_16x9';
            pres.title = params.title || 'SwiftOffice Report';
            pres.author = params.author || 'SwiftOffice';
            
            console.log(JSON.stringify({ 
                success: true, 
                pptId: Date.now().toString(),
                message: 'PPT created'
            }));
        } 
        else if (action === 'save') {
            const pres = new pptxgen();
            pres.layout = params.layout || 'LAYOUT_16x9';
            pres.title = params.title || 'SwiftOffice Report';
            pres.author = params.author || 'SwiftOffice';
            
            let slides = [];
            if (params.slidesJSON) {
                slides = JSON.parse(params.slidesJSON);
            } else if (params.slides) {
                slides = params.slides;
            }
            
            if (Array.isArray(slides)) {
                for (const slideData of slides) {
                    const slide = pres.addSlide();
                    
                    if (slideData.title) {
                        slide.addText(slideData.title, { 
                            x: 0.5, y: 0.5, 
                            fontSize: 24, bold: true 
                        });
                    }
                    
                    if (slideData.content) {
                        slide.addText(slideData.content, { 
                            x: 0.5, y: 1.5, 
                            fontSize: 14 
                        });
                    }
                    
                    if (slideData.chart) {
                        const chartData = slideData.chart;
                        const chartType = pres.ChartType[chartData.type] || pres.ChartType.bar;
                        slide.addChart(chartType, chartData.data, {
                            x: chartData.x || 0.5,
                            y: chartData.y || 1.5,
                            w: chartData.w || 9,
                            h: chartData.h || 4,
                            showTitle: true,
                            title: chartData.title || ''
                        });
                    }
                    
                    if (slideData.table) {
                        slide.addTable(slideData.table.rows, {
                            x: slideData.table.x || 0.5,
                            y: slideData.table.y || 1.5,
                            w: slideData.table.w || 9,
                            colW: slideData.table.colW
                        });
                    }
                }
            }
            
            await pres.writeFile({ fileName: params.path });
            console.log(JSON.stringify({ 
                success: true, 
                path: params.path,
                message: 'PPT saved'
            }));
        }
        else {
            console.log(JSON.stringify({ 
                success: false, 
                error: `Unknown action: ${action}` 
            }));
            process.exit(1);
        }
    } catch (error) {
        console.log(JSON.stringify({ 
            success: false, 
            error: error.message,
            stack: error.stack
        }));
        process.exit(1);
    }
});
