const StormDB = require('stormdb');
const fs = require('fs');
const path = require('path');

let input = '';

process.stdin.on('data', chunk => {
    input += chunk.toString();
});

process.stdin.on('end', () => {
    try {
        const params = input.trim() ? JSON.parse(input) : {};
        const action = params.action || 'get';
        
        const dbPath = params.dbPath || path.join(process.cwd(), 'test_db.json');
        
        if (action === 'init') {
            let initialData = {};
            if (params.dataJSON) {
                initialData = JSON.parse(params.dataJSON);
            } else if (params.data) {
                initialData = params.data;
            }
            fs.writeFileSync(dbPath, JSON.stringify(initialData, null, 2));
            
            const engine = new StormDB.localFileEngine(dbPath);
            const db = new StormDB(engine);
            
            console.log(JSON.stringify({ 
                success: true, 
                dbPath: dbPath,
                message: 'Database initialized'
            }));
        }
        else if (action === 'get') {
            if (!fs.existsSync(dbPath)) {
                console.log(JSON.stringify({ 
                    success: false, 
                    error: 'Database file not found' 
                }));
                process.exit(1);
            }
            
            const engine = new StormDB.localFileEngine(dbPath);
            const db = new StormDB(engine);
            
            const key = params.key;
            let value;
            
            if (key) {
                value = db.get(key).value();
            } else {
                value = db.value();
            }
            
            console.log(JSON.stringify({ 
                success: true, 
                value: value
            }));
        }
        else if (action === 'set') {
            let engine, db;
            
            if (!fs.existsSync(dbPath)) {
                fs.writeFileSync(dbPath, '{}');
            }
            
            engine = new StormDB.localFileEngine(dbPath);
            db = new StormDB(engine);
            
            const key = params.key;
            let value = params.value;
            if (params.valueJSON) {
                value = JSON.parse(params.valueJSON);
            }
            
            if (key) {
                db.set(key, value).save();
            } else {
                db.set(value).save();
            }
            
            console.log(JSON.stringify({ 
                success: true, 
                message: 'Value saved'
            }));
        }
        else if (action === 'push') {
            let engine, db;
            
            if (!fs.existsSync(dbPath)) {
                fs.writeFileSync(dbPath, '[]');
            }
            
            engine = new StormDB.localFileEngine(dbPath);
            db = new StormDB(engine);
            
            let value = params.value;
            if (params.valueJSON) {
                value = JSON.parse(params.valueJSON);
            }
            db.push(value).save();
            
            console.log(JSON.stringify({ 
                success: true, 
                message: 'Value pushed'
            }));
        }
        else if (action === 'delete') {
            if (!fs.existsSync(dbPath)) {
                console.log(JSON.stringify({ 
                    success: false, 
                    error: 'Database file not found' 
                }));
                process.exit(1);
            }
            
            const engine = new StormDB.localFileEngine(dbPath);
            const db = new StormDB(engine);
            
            const key = params.key;
            db.get(key).delete(true);
            db.save();
            
            console.log(JSON.stringify({ 
                success: true, 
                message: 'Key deleted'
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
