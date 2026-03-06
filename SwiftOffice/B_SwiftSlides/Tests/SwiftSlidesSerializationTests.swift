import Testing
import Foundation
import SwiftSlides

@Suite("SwiftSlides 序列化测试")
struct SwiftSlidesSerializationTests {
    
    @Test("封面页序列化")
    func testCoverSlideSerialization() {
        let slide = 封面页(标题: "测试标题", 副标题: "测试副标题", 渐变: .蓝色)
        let dict = slide.toDict()
        
        #expect(dict["type"] as? String == "封面页")
        #expect(dict["title"] as? String == "测试标题")
        #expect(dict["subtitle"] as? String == "测试副标题")
        #expect(dict["gradient"] as? String == "蓝色")
    }
    
    @Test("列表页序列化")
    func testListSlideSerialization() {
        let slide = 列表页(标题: "测试列表", 项目: ["项目1", "项目2", "项目3"])
        let dict = slide.toDict()
        
        #expect(dict["type"] as? String == "列表页")
        #expect(dict["title"] as? String == "测试列表")
        let items = dict["items"] as? [String]
        #expect(items?.count == 3)
    }
    
    @Test("表格页序列化")
    func testTableSlideSerialization() {
        let slide = 表格页(
            标题: "测试表格",
            表头: ["列1", "列2"],
            行: [["行1列1", "行1列2"], ["行2列1", "行2列2"]]
        )
        let dict = slide.toDict()
        
        #expect(dict["type"] as? String == "表格页")
        let headers = dict["headers"] as? [String]
        #expect(headers?.count == 2)
        let rows = dict["rows"] as? [[String]]
        #expect(rows?.count == 2)
    }
    
    @Test("章节序列化")
    func testSectionSerialization() {
        let section = 章节(标题: "测试章节", slides: [
            封面页(标题: "封面"),
            列表页(标题: "列表", 项目: ["项目1"]),
        ])
        let dict = section.toDict()
        
        #expect(dict["title"] as? String == "测试章节")
        let slides = dict["slides"] as? [[String: Any]]
        #expect(slides?.count == 2)
    }
    
    @Test("演示文稿序列化")
    func testPresentationSerialization() throws {
        let presentation = 演示文稿(
            标题: "测试演示",
            作者: "测试作者",
            sections: [
                章节(标题: "第一章", slides: [
                    封面页(标题: "封面"),
                ])
            ]
        )
        
        let dict = presentation.toDict()
        #expect(dict["title"] as? String == "测试演示")
        #expect(dict["author"] as? String == "测试作者")
        
        let json = try presentation.toJSON()
        #expect(json.contains("测试演示"))
        #expect(json.contains("封面"))
    }
    
    @Test("架构图序列化")
    func testArchitectureSlideSerialization() {
        let slide = 架构图页(标题: "测试架构", 层次: [
            .顶层(项目: ["方针", "目标"]),
            .中层(项目: ["组织", "制度"]),
            .底层(项目: ["控制", "改进"]),
        ])
        let dict = slide.toDict()
        
        #expect(dict["type"] as? String == "架构图页")
        let layers = dict["layers"] as? [[String: Any]]
        #expect(layers?.count == 3)
    }
    
    @Test("流程图序列化")
    func testFlowchartSlideSerialization() {
        let slide = 流程图页(标题: "PDCA", 步骤: ["Plan", "Do", "Check", "Act"], 循环: true)
        let dict = slide.toDict()
        
        #expect(dict["type"] as? String == "流程图页")
        #expect(dict["isLoop"] as? Bool == true)
        let steps = dict["steps"] as? [String]
        #expect(steps?.count == 4)
    }
    
    @Test("矩阵序列化")
    func testMatrixSlideSerialization() {
        let slide = 矩阵页(
            标题: "品牌矩阵",
            行: ["官方", "口碑"],
            列: ["传统", "新媒体"],
            单元格: [
                矩阵单元格(行: "官方", 列: "传统", 内容: "电视"),
                矩阵单元格(行: "官方", 列: "新媒体", 内容: "微信"),
            ]
        )
        let dict = slide.toDict()
        
        #expect(dict["type"] as? String == "矩阵页")
        let rows = dict["rows"] as? [String]
        #expect(rows?.count == 2)
    }
    
    @Test("柏拉图序列化")
    func testParetoSlideSerialization() {
        let slide = 柏拉图页(标题: "问题分析", 项目: [
            柏拉图项(标签: "人才", 数值: 35, 核心问题: true),
            柏拉图项(标签: "科研", 数值: 25, 核心问题: true),
        ])
        let dict = slide.toDict()
        
        #expect(dict["type"] as? String == "柏拉图页")
        #expect(dict["threshold"] as? Double == 80.0)
    }
}

@Suite("Flat Property API 测试")
struct FlatPropertyAPITests {
    
    struct TestSlide: Slide, ContentStyle {
        let title = "Test Slide"
        let items = ["Item 1", "Item 2", "Item 3"]
        let author = "JK"
        let year = 2024
    }
    
    @Test("Mirror discovers flat properties")
    func testMirrorDiscoversProperties() {
        let slide = TestSlide()
        let contents = slide.contents
        
        #expect(contents.dict["items"] != nil)
        #expect(contents.dict["author"] != nil)
        #expect(contents.dict["year"] != nil)
        
        let items = contents.dict["items"] as? [String]
        #expect(items?.count == 3)
        #expect(items?.first == "Item 1")
        
        let author = contents.dict["author"] as? String
        #expect(author == "JK")
        
        let year = contents.dict["year"] as? Int
        #expect(year == 2024)
    }
    
    @Test("toDict includes auto-generated contents")
    func testToDictIncludesContents() {
        let slide = TestSlide()
        let dict = slide.toDict()
        
        #expect(dict["title"] as? String == "Test Slide")
        
        let contents = dict["contents"] as? [String: Any]
        #expect(contents != nil)
        #expect(contents?["items"] != nil)
        #expect(contents?["author"] != nil)
    }
    
    @Test("Excluded properties not in contents")
    func testExcludedPropertiesNotInContents() {
        let slide = TestSlide()
        let contents = slide.contents
        
        #expect(contents.dict["id"] == nil)
        #expect(contents.dict["title"] == nil)
        #expect(contents.dict["notes"] == nil)
        #expect(contents.dict["hidden"] == nil)
        #expect(contents.dict["fellowSlides"] == nil)
        #expect(contents.dict["contents"] == nil)
    }
    
    struct ImageSlide: Slide {
        let title = "Image Slide"
        let photo: Image = "photo.jpg"
        let items = ["A", "B"]
    }
    
    @Test("Image type wrapper works")
    func testImageTypeWrapper() {
        let slide = ImageSlide()
        let contents = slide.contents
        
        let photo = contents.dict["photo"] as? [String: Any]
        #expect(photo?["type"] as? String == "image")
        #expect(photo?["path"] as? String == "photo.jpg")
        
        let items = contents.dict["items"] as? [String]
        #expect(items?.count == 2)
    }
    
    struct VideoSlide: Slide {
        let title = "Video Slide"
        let movie: Video = "movie.mp4"
    }
    
    @Test("Video type wrapper works")
    func testVideoTypeWrapper() {
        let slide = VideoSlide()
        let contents = slide.contents
        
        let movie = contents.dict["movie"] as? [String: Any]
        #expect(movie?["type"] as? String == "video")
        #expect(movie?["path"] as? String == "movie.mp4")
    }
    
    struct QRCodeSlide: Slide {
        let title = "QR Code Slide"
        let qr: QRCode = "https://example.com"
    }
    
    @Test("QRCode type wrapper works")
    func testQRCodeTypeWrapper() {
        let slide = QRCodeSlide()
        let contents = slide.contents
        
        let qr = contents.dict["qr"] as? [String: Any]
        #expect(qr?["type"] as? String == "qrcode")
        #expect(qr?["content"] as? String == "https://example.com")
    }
    
    struct MultiTypeSlide: Slide {
        let title = "Multi Type Slide"
        let photo: Image = "photo.jpg"
        let movie: Video = "movie.mp4"
        let link: URLString = "https://example.com"
        let color: HexColor = "#FF5500"
        let items = ["A", "B", "C"]
        let count = 42
        let enabled = true
    }
    
    @Test("Multiple type wrappers work together")
    func testMultipleTypeWrappers() {
        let slide = MultiTypeSlide()
        let contents = slide.contents
        
        #expect((contents.dict["photo"] as? [String: Any])?["type"] as? String == "image")
        #expect((contents.dict["movie"] as? [String: Any])?["type"] as? String == "video")
        #expect((contents.dict["link"] as? [String: Any])?["type"] as? String == "url")
        #expect((contents.dict["color"] as? [String: Any])?["type"] as? String == "color")
        #expect((contents.dict["items"] as? [String])?.count == 3)
        #expect(contents.dict["count"] as? Int == 42)
        #expect(contents.dict["enabled"] as? Bool == true)
    }
    
    struct ChinesePropertySlide: Slide {
        let title = "中文属性测试"
        let 项目 = ["项目一", "项目二"]
        let 作者 = "张三"
        let 年份 = 2024
    }
    
    @Test("Chinese property names work")
    func testChinesePropertyNames() {
        let slide = ChinesePropertySlide()
        let contents = slide.contents
        
        let items = contents.dict["项目"] as? [String]
        #expect(items?.count == 2)
        
        let author = contents.dict["作者"] as? String
        #expect(author == "张三")
        
        let year = contents.dict["年份"] as? Int
        #expect(year == 2024)
    }
}
