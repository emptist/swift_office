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
public extension 章节 {
    init(标题: String, @SlideBuilder slides: () -> [any Slide]) {
        self.init(标题: 标题, slides: slides())
    }
}
