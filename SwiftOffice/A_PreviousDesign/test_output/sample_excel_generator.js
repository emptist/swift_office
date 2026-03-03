const xlsx = require('json-as-xlsx');

const data = [
    {
        sheet: '数据',
        columns: [
            { label: '名称', value: 'name' },
            { label: '数值', value: 'value' },
            { label: '备注', value: 'note' }
        ],
        content: [
            { name: '产品A', value: 100, note: '测试数据' },
            { name: '产品B', value: 200, note: '测试数据' },
            { name: '产品C', value: 150, note: '测试数据' }
        ]
    }
];

const settings = {
    fileName: '/Users/jk/gits/hub/prog_langs/swift/swift_office/SwiftOffice/test_output/sample_data',
    extraLength: 5,
    writeOptions: {}
};

try {
    xlsx(data, settings);
    console.log(JSON.stringify({ success: true }));
} catch (e) {
    console.log(JSON.stringify({ success: false, error: e.message }));
    process.exit(1);
}
