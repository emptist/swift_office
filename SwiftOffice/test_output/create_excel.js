const ExcelJS = require('exceljs');
(async () => {
    const workbook = new ExcelJS.Workbook();
    const sheet = workbook.addWorksheet('数据');
    
    sheet.columns = [
        { header: '名称', key: 'name' },
        { header: '数值', key: 'value' },
        { header: '备注', key: 'note' }
    ];
    
    sheet.addRow({ name: '产品A', value: 100, note: '测试数据' });
    sheet.addRow({ name: '产品B', value: 200, note: '测试数据' });
    sheet.addRow({ name: '产品C', value: 150, note: '测试数据' });
    
    await workbook.xlsx.writeFile('/Users/jk/gits/hub/prog_langs/swift/swift_office/SwiftOffice/test_output/sample_data.xlsx');
    console.log(JSON.stringify({ success: true }));
})().catch(e => {
    console.log(JSON.stringify({ success: false, error: e.message }));
    process.exit(1);
});