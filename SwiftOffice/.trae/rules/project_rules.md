# SwiftOffice Project Rules

## Core Design Philosophy

### Content-Presentation Separation

**"内容是一味，呈现看协议" (Content is the essence, presentation depends on protocol)**

The core design principle is that everything is a dictionary, and protocols determine presentation.

```
┌─────────────────────────────────────────────────────────┐
│                    Data Sources (Unified Format)         │
├─────────────────────────────────────────────────────────┤
│  JSON file  →  Dictionary  ←  Database  ←  Hand-written │
│                                                         │
│  { "key": "value" }                                     │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│                    Protocols (Determine Presentation)    │
├─────────────────────────────────────────────────────────┤
│  TableSlideStyle    →  Table slide                      │
│  CardStyle          →  Card layout                      │
│  ContentStyle       →  List display                     │
│  HierarchyStyle     →  Hierarchy diagram                │
└─────────────────────────────────────────────────────────┘
```

### Core Elements: Title + SlideContent

Every slide has two essential elements:
- **title** - The slide title (identifier)
- **contents** - Dictionary data (substance)

Other properties (notes, hidden, fellowSlides) are optional.

### Language Convention

- **Technical terms**: English (title, contents, Slide, TextStyle, etc.)
- **User content**: Any language (Chinese, Japanese, Arabic, etc.)

## Architecture

### MVVM + POP

```
Model (Data)
  ↓
ViewModel (Protocols)
  ↓
View (PPTX/JSON Output)
```

### Key Protocols

| Protocol | Purpose | SlideContent Format |
|----------|---------|-----------------|
| `TextStyle` | Single text | `["label": "content"]` |
| `ContentStyle` | List items | `["label": ["item1", "item2"]]` |
| `TableSlideStyle` | Table | `["column1": [...], "column2": [...]]` |
| `TwoColumnStyle` | Two columns | `["left": [...], "right": [...]]` |
| `CardStyle` | Card layout | `["cards": [...]]` |
| `HierarchyStyle` | Hierarchy structure | `["levels": [[...]]]` |
| `CycleFlowStyle` | Cycle flow | `["items": [...]]` |
| `ParetoStyle` | Pareto chart | `["items": [...]]` |
| `ContainerStyle` | Container for multiple slides | `["layout": "horizontal", "ratio": [0.382, 0.618]]` |

## Page Types

### Structural Layout Pages

- **Examples**: 章首页 (Chapter Cover), 节首页 (Node Cover)
- **Characteristics**: Use vague keys (e.g., "包含", "fellowSlides", "子页面")
- **Purpose**: Convey hierarchy structure information
- **Protocols**: ChapterCoverStyle, NodeCoverStyle
- **Key**: **带页面就不传意念** (Carry pages, don't convey content ideas)

### Content Idea Pages

- **Examples**: Specific content pages
- **Characteristics**: Use precise keys (e.g., "普外2科年度目标", "医疗质量定义")
- **Purpose**: Convey content to be presented on the page
- **Protocols**: ContentStyle, TextStyle, TableSlideStyle, etc.
- **Key**: **传内容意念就不带页面** (Convey content ideas, don't carry pages)

**Fundamental Difference**:
- **带页面就不传意念**: Structural layout pages convey hierarchy structure through `[any Slide]` arrays in `contents` dictionary, not specific content ideas
- **传内容意念就不带页面**: Content idea pages convey specific content ideas through `contents` dictionary, not other pages

**Important**: A page is either a structural layout page or a content idea page, never both. There's no such page in reality.

## Hierarchy Structure

### Hierarchy Structure

```
Presentation (演示文稿)
  └── Section (PPTX 的 Section)
        └── 章
              └── 节
                    └── 幻灯片
```

**Structure Type**: This is a tree structure, but not a strict tree structure.

**Characteristics**:
- Each level can directly jump to slides
- Not a strict parent-child relationship
- More like a flexible hierarchical structure

**Important**: Any level can directly jump to slides, users can choose which levels to use based on their needs.

### Why Need Multiple Levels?

#### 1. PowerPoint's Section Function

**Section is PowerPoint's proprietary feature**:
- PowerPoint has Section functionality for grouping slides
- Section is a PowerPoint-specific feature that users can see and use in PowerPoint
- PPTX generation needs to support Section functionality
- Users can manage and navigate slides through Section in PowerPoint

#### 2. Logical Organization

**Users need to organize content into chapters and sections logically**:
- Chapters and sections are ways users organize content logically
- Helps users better manage and understand content structure
- Example: "第一章 医疗质量概念" -> "1.1 医疗质量定义" -> "1.2 医疗质量维度"

#### 3. Necessity of Level Cover Pages

**In practice, it's often necessary to divide into levels**:
- The cover page for that level is needed
- It only has a title, doesn't convey content ideas
- Its contents is a group of other slides
- But even this title has differences in color, font, layout, etc.

**Why level cover pages are necessary**:
- Level cover pages provide visual separation and navigation
- Help the audience understand the current content structure
- Provide visual differences in color, font, layout, etc.
- Even with only one title, it's necessary

#### 4. Flexibility and Scalability

**Multi-level design provides great flexibility**:
- Users can choose which levels to use based on specific needs
- Not forced to use all levels
- Can choose appropriate levels based on project complexity

#### 5. Reusability

**Each level can be independently defined and reused**:
- The same `[any Slide]` array can be used at different levels
- The same slide can be referenced in multiple places
- Easy to maintain and modify

#### 6. Clear Structure

**Multi-level design makes document structure clearer**:
- Easier to understand and navigate complex content
- Improves overall readability and usability
- Accumulates to form the entire layout

### No Chapter Number Principle

**Why not automatically add "第几章第几节"**:
- **Because reusability is needed, chapters change when reused**
- If the system automatically adds "第几章第几节", then when users reuse this slide, the chapter number will be incorrect
- Users should decide whether to write chapter numbers themselves
- Users can freely name based on specific circumstances

**Return to "No Chapter Number" Principle**:
- **Users are smart and quickly realize they shouldn't hardcode a chapter number**
- **The system will add it for them, or it's not needed at all**
- **Otherwise, they need to delete the chapter number when they want to reuse**
- **Return to the no chapter number principle**

**This is actually very basic, just like page numbers**:
- **Which software hardcodes page numbers?**
- Page numbers are automatically generated by the system
- Users don't need to manually write page numbers
- Chapter numbers should also be automatically generated by the system, just like page numbers
- Users only need to provide content, the system is responsible for generating page numbers and chapter numbers

**Can Automatically Add, But Cannot Force**:
- **Automatically adding chapter numbers in the generated result: This is acceptable**
  - This doesn't affect users using this slide elsewhere
  - This is just a display effect, doesn't affect original data
- **Cannot automatically modify what users wrote**
  - Cannot automatically modify user-written titles
  - Cannot automatically modify user-written content
  - What users write is original data and cannot be automatically modified by the system
- Users can choose whether to use automatically added chapter numbers
- Users can also manually write chapter numbers themselves
- This provides both convenience and flexibility

**Best Practice**:
- When defining slides, users **should not hardcode chapter numbers**
- Example: `let title = "医疗质量概念"` instead of `let title = "第一章 医疗质量概念"`
- The system automatically adds chapter numbers in the generated result
- This way users can freely reuse slides without manually deleting chapter numbers

## Maximum Reusability Flexibility

### Key Points

1. **Presentation only knows how many `[any Slide]` there are, doesn't know how many sub-levels they "carry"**
   - Every level is the same
   - The final level has no "carried" pages, so there's no problem

2. **If there are carried pages, what they carry must be determined by asking the carried thing to know which protocol it follows**
   - Content is given
   - Protocols are variable
   - **This approach gives users maximum reusability flexibility**

3. **Accumulates to form the entire layout**
   - Users provide `[any Slide]` arrays at different levels
   - These arrays accumulate to form the entire PPTX layout

### Design Advantages

1. **Users write very naturally**
   - Users can provide `[any Slide]` arrays at any level
   - Not forced to use all levels
   - Can choose which levels to use based on needs

2. **Very convenient to use**
   - Can have basic components that are not used
   - Can be reused for different occasions
   - Flexible combination, adapts to different needs

3. **Strong reusability**
   - The same `[any Slide]` array can be used at different levels
   - The same slide can be referenced in multiple places
   - Easy to maintain and modify

## Coding Standards

### 1. Swift Version

Use Swift 6.2 to take advantage of new features and improvements.

### 2. Testing

Use new Swift testing features instead of XCTest framework.

### 3. Code Style

- Use English for code and comments
- Follow Swift naming conventions
- Use `let` for immutable properties
- Use protocol composition for flexibility

### 4. Security

- Never expose or log secrets and keys
- Never commit secrets to repository
- Update .gitignore to exclude sensitive files

### 5. Documentation

- Update documentation after completing tasks
- Keep README files up to date
- Document API changes

## Build Commands

```bash
# Build project
swift build

# Run tests
swift test

# Run demo
swift run SwiftSlidesDemo

# Generate PPTX
node B_SwiftSlides/Scripts/swiftslides-pptx.js <input.json> <output.pptx>
```

## File Structure

```
SwiftOffice/
├── B_SwiftSlides/
│   ├── Sources/
│   │   └── Protocols/
│   │       ├── Slide.swift              # Core Slide protocol
│   │       ├── SlideStyleProtocols.swift # Style protocols
│   │       ├── Presentation.swift       # Presentation protocol
│   │       └── Section.swift            # Section protocol
│   ├── Demo/
│   │   └── APITest.swift                # API test examples
│   ├── Scripts/
│   │   └── swiftslides-pptx.js          # PPTX generation script
│   └── Documentation/
│       └── API设计.md                    # API design document
├── Cases/                                # User content (gitignored)
├── Outputs/                              # Generated files (gitignored)
└── Package.swift                         # Swift package configuration
```

## Git Ignore

The following directories are excluded from version control:
- `Cases/` - User content files
- `Outputs/` - Generated files
- `.build/` - Build artifacts
- `node_modules/` - Node.js dependencies

## Best Practices

1. **Before making changes**: Understand existing code conventions
2. **Search documentation first**: Check official docs before using tools/libraries
3. **Use latest versions**: Keep dependencies up to date
4. **Think before acting**: Plan complex changes carefully
5. **Clean up**: Delete unnecessary files after testing
6. **Be consistent**: Follow existing code style
7. **Protect privacy**: Never commit sensitive data
8. **No hardcoded keys**: Never hardcode user-provided dictionary keys in protocols
9. **Type-based extraction**: Protocols should extract data from dictionaries based on value types, not hardcoded keys
10. **Multi-language support**: Support user-defined keys in any language (Chinese, English, etc.)
11. **No chapter numbers**: Users should not hardcode chapter numbers; system should auto-generate them in the output
12. **Maximum reusability**: Content is given, protocols are variable to provide maximum reusability flexibility
