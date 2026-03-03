let input = '';

process.stdin.on('data', chunk => {
    input += chunk.toString();
});

process.stdin.on('end', () => {
    try {
        const params = input.trim() ? JSON.parse(input) : {};
        
        const result = {
            echo: params.message || 'Hello from Node.js',
            timestamp: new Date().toISOString(),
            nodeVersion: process.version,
            received: params
        };
        
        console.log(JSON.stringify(result));
    } catch (error) {
        console.error('Error:', error.message);
        process.exit(1);
    }
});
