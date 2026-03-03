// fakecode.swift
// 
// 这是一个设计思路的伪代码文件，展示了用户如何定义演示文稿结构
// 
// 核心设计理念：
// 1. 用户定义 struct(s) 来完成对输出文档的定义
// 2. 通过 protocol 继承和扩展功能，实现共享代码
// 3. CLI 工具通过 struct 名字作为参数来生成 PPTX
//
// 注意：当前文件内容已全部注释，不会影响编译
//

/*
struct C01医院管理总览: Presentation {
    let id = UUID()
    let title = "医院管理总览"
    let author = "JK"
    let sections: [Section] = [第一部分(), 第二部分()]
}

// 已经知道 pptx不支持 sub section
// 但是section后面可以接着section，这是可以的
// 所以，实际上仍然可以有类似子section的设计
// 但是为了简化，就不去麻烦了
struct 第一部分: Section {
    let id = UUID()
    let title = "第一部分"
    let slides: [Slide] = [
        第一章_医院的历史由来(),
        第二章_中国医院的发展历程(),
    ]
}


struct 第一章_医院的历史由来：Slide,ChapterFirstPage {
    let id = UUID()
    let title = "医院的历史由来"
    let content = "医院的历史由来"
    let chapter = 1
    let fellowSlides: [Slide] = [
        第一节_古今纵横(),
        第二节_制度类型(),
    ]
}


struct 第一节_古今纵横：Slide {
    let id = UUID()
    let title = "古今纵横"
    let content = "古今纵横"
    let fellowSlides: [Slide] = [
        医院出现之前(),
        黑暗时代(),
        现代医院的诞生(),
        AI时代的挑战(),
        后AI时代的展望(),
    ]
}

// 通过protocol 去设定页面的类型和一些定制元素
// 比如，第一章的第一个页面，需要有章节标题，并且要在页面的顶部居中显示
// 而其他页面，就不需要这些定制元素
//  比如文字页面，流程图页面，组合页面，数据可视化页面等等
// 又比如彩色页面，黑白页面，多媒体页面，重要不能跳过的页面，等等，各种实际需要的定制页面类型
// 通过 protocol 继承和扩展功能，实现共享代码，减少在struct当中需要重复定义的代码
struct 医院出现之前：Slide {
    let id = UUID()
    let title = "医院出现之前"
    let content = "医院出现之前"
}
struct 黑暗时代：Slide {
    let id = UUID()
    let title = "黑暗时代"
    let content = "黑暗时代"
}
struct 现代医院的诞生：Slide {
    let id = UUID()
    let title = "现代医院的诞生"
    let content = "现代医院的诞生"
}
struct AI时代的挑战：Slide {
    let id = UUID()
    let title = "AI时代的挑战"
    let content = "AI时代的挑战"
}
struct 后AI时代的展望：Slide {
    let id = UUID()
    let title = "后AI时代的展望"
    let content = "后AI时代的展望"
}

struct 第二节_制度类型：Slide {
    let id = UUID()
    let title = "制度类型"
    let content = "制度类型"
    let fellowSlides: [Slide] = [
        传统制度(),
        现代制度(),
    ]
}
struct 传统制度：Slide {
    let id = UUID()
    let title = "传统制度"
    let content = "传统制度"
}
struct 现代制度：Slide {
    let id = UUID()
    let title = "现代制度"
    let content = "现代制度"
}

struct 第二章_中国医院的发展历程：Slide,ChapterFirstPage {
    let id = UUID()
    let title = "中国医院的发展历程"
    let content = "中国医院的发展历程"
    let chapter = 2
    let fellowSlides: [Slide] = [
        第一节_中国现代医院的起源(),
    ]
}

struct 第一节_中国现代医院的起源：Slide {
    let id = UUID()
    let title = "中国现代医院的起源"
    let content = "中国现代医院的起源"
    let fellowSlides: [Slide] = [
        中国医院的前身(),
        中国医院的发展(),
    ]
}
struct 中国医院的前身：Slide {
    let id = UUID()
    let title = "中国医院的前身"
    let content = "中国医院的前身"
}
struct 中国医院的发展：Slide {
    let id = UUID()
    let title = "中国医院的发展"
    let content = "中国医院的发展"
}


struct 第二部分: Section {
    let id = UUID()
    let title = "第二部分"
    let slides: [Slide] = []
}

// to build this presentation, we need to:
// run CLI:

// buildSlide <options> C01医院管理总览
*/
