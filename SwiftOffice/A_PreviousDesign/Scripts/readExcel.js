const converter = require('convert-excel-to-json');

let input = '';

process.stdin.on('data', chunk => {
    input += chunk.toString();
});

process.stdin.on('end', () => {
    try {
        const params = input.trim() ? JSON.parse(input) : {};
        
        const result = converter({
            source: params.path,
            header: params.header || { rows: 1 },
            columnToKey: params.columnToKey || { '*': '{{columnHeader}}' },
            sheetStubs: params.sheetStubs !== false
        });
        
        console.log(JSON.stringify({ success: true, data: result }));
    } catch (error) {
        console.log(JSON.stringify({ 
            success: false, 
            error: error.message,
            stack: error.stack
        }));
        process.exit(1);
    }
});
