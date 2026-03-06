import Foundation

@available(macOS 10.15, *)
@resultBuilder
public enum SlideBuilder {
    public static func buildBlock(_ components: any Slide...) -> [any Slide] {
        components
    }
    
    public static func buildOptional(_ component: [any Slide]?) -> [any Slide] {
        component ?? []
    }
    
    public static func buildEither(first component: [any Slide]) -> [any Slide] {
        component
    }
    
    public static func buildEither(second component: [any Slide]) -> [any Slide] {
        component
    }
    
    public static func buildArray(_ components: [[any Slide]]) -> [any Slide] {
        components.flatMap { $0 }
    }
}

@available(macOS 10.15, *)
@resultBuilder
public enum SectionBuilder {
    public static func buildBlock(_ components: any Section...) -> [any Section] {
        components
    }
    
    public static func buildOptional(_ component: [any Section]?) -> [any Section] {
        component ?? []
    }
    
    public static func buildEither(first component: [any Section]) -> [any Section] {
        component
    }
    
    public static func buildEither(second component: [any Section]) -> [any Section] {
        component
    }
    
    public static func buildArray(_ components: [[any Section]]) -> [any Section] {
        components.flatMap { $0 }
    }
}

@available(macOS 10.15, *)
@resultBuilder
public enum ChapterBuilder {
    public static func buildBlock(_ components: any Chapter...) -> [any Chapter] {
        components
    }
    
    public static func buildOptional(_ component: [any Chapter]?) -> [any Chapter] {
        component ?? []
    }
    
    public static func buildEither(first component: [any Chapter]) -> [any Chapter] {
        component
    }
    
    public static func buildEither(second component: [any Chapter]) -> [any Chapter] {
        component
    }
    
    public static func buildArray(_ components: [[any Chapter]]) -> [any Chapter] {
        components.flatMap { $0 }
    }
}

@available(macOS 10.15, *)
@resultBuilder
public enum NodeBuilder {
    public static func buildBlock(_ components: any Node...) -> [any Node] {
        components
    }
    
    public static func buildOptional(_ component: [any Node]?) -> [any Node] {
        component ?? []
    }
    
    public static func buildEither(first component: [any Node]) -> [any Node] {
        component
    }
    
    public static func buildEither(second component: [any Node]) -> [any Node] {
        component
    }
    
    public static func buildArray(_ components: [[any Node]]) -> [any Node] {
        components.flatMap { $0 }
    }
}

@available(macOS 10.15, *)
public extension 册 {
    init(标题: String, @SlideBuilder slides: () -> [any Slide]) {
        self.init(标题: 标题, slides: slides())
    }
}

@available(macOS 10.15, *)
public extension SectionPresentation {
    init(标题: String, 作者: String? = nil, 主题: 主题? = nil, @SectionBuilder sections: () -> [any Section]) {
        self.init(标题: 标题, 作者: 作者, 主题: 主题, sections: sections())
    }
}

@available(macOS 10.15, *)
public extension ChapterPresentation {
    init(标题: String, 作者: String? = nil, 主题: 主题? = nil, @ChapterBuilder chapters: () -> [any Chapter]) {
        self.init(标题: 标题, 作者: 作者, 主题: 主题, chapters: chapters())
    }
}

@available(macOS 10.15, *)
public extension NodePresentation {
    init(标题: String, 作者: String? = nil, 主题: 主题? = nil, @NodeBuilder nodes: () -> [any Node]) {
        self.init(标题: 标题, 作者: 作者, 主题: 主题, nodes: nodes())
    }
}

@available(macOS 10.15, *)
public extension SlidePresentation {
    init(标题: String, 作者: String? = nil, 主题: 主题? = nil, @SlideBuilder slides: () -> [any Slide]) {
        self.init(标题: 标题, 作者: 作者, 主题: 主题, slides: slides())
    }
}
