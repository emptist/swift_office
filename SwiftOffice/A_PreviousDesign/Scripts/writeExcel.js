const xlsx = require('json-as-xlsx');

let input = '';

process.stdin.on('data', chunk => {
    input += chunk.toString();
});

process.stdin.on('end', () => {
    try {
        const params = input.trim() ? JSON.parse(input) : {};
        
        if (!params.data) {
            throw new Error('Missing required parameter: data');
        }
        if (!params.fileName) {
            throw new Error('Missing required parameter: fileName');
        }
        
        const settings = {
            fileName: params.fileName,
            extraLength: params.extraLength || 5,
            writeOptions: params.writeOptions || {}
        };
        
        xlsx(params.data, settings);
        
        console.log(JSON.stringify({ 
            success: true, 
            fileName: params.fileName + '.xlsx'
        }));
    } catch (error) {
        console.log(JSON.stringify({ 
            success: false, 
            error: error.message,
            stack: error.stack
        }));
        process.exit(1);
    }
});
