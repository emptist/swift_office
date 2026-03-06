import Foundation
import SwiftSlides
import Runner

// MARK: - Presentation

/// Data Asset Management Course Presentation
/// 
/// Architecture Decision:
/// - No Section layer: This is a single 12-hour course, no need for physical grouping (册)
/// - Direct Chapter layer: 7 chapters organized by logical content
/// - Node layer for subsections: Each chapter has multiple logical subsections (节)
/// - Slide layer for content: Individual slides within each subsection
///
/// This follows the 5-level hierarchy: Presentation → Chapter → Node → Slide
/// (Skipping Section as it's not needed for a single course)
///
/// Note: Presentation itself is a cover, conforms to CoverStyle for styling
struct DataAssetCoursePresentation: ChapterBasedPresentation, CoverStyle {
    let title = "AI时代的数据资产管理"
    let author: String? = "医院管理课程"
    let subtitle: String? = "医院管理保障与支撑板块课程"
    let date: String? = "2024"
    
    let chapters: [any Chapter] = [
        AIEraChapter(),
        HospitalDataAssetChapter(),
        DataGovernanceChapter(),
        DataSecurityChapter(),
        ManagementSystemChapter(),
        DataApplicationChapter(),
        CaseStudyChapter()
    ]
}

// MARK: - Chapter 1: AI Era and Data Assets

/// Chapter 1: AI Era and Data Assets (1 hour)
///
/// Architecture: Chapter → Node → Slide
/// - 3 subsections (nodes) covering AI background, data asset concepts, and data economy
struct AIEraChapter: Chapter {
    let title = "第一章：AI时代与数据资产"
    let nodes: [any Node] = [
        AIEraBackgroundNode(),
        DataAssetConceptNode(),
        DataEconomyNode()
    ]
}

/// Node 1.1: AI Era Background (30 minutes)
///
/// Content: AI development history and industry data asset practices
struct AIEraBackgroundNode: Node {
    let title = "1.1 AI时代背景"
    let slides: [any Slide] = [
        AIDevelopmentHistorySlide(),
        IndustryDataAssetPracticeSlide()
    ]
}

/// Slide: AI Development History
/// Shows the three eras of AI development
struct AIDevelopmentHistorySlide: Slide, ContentStyle {
    let title = "AI时代发展历程"
    let items = [
        "传统AI时代（1950-2010）",
        "  - 规则驱动",
        "  - 专家系统",
        "  - 局限性明显",
        "",
        "大数据时代（2010-2020）",
        "  - 数据驱动",
        "  - 深度学习突破",
        "  - 应用爆发",
        "",
        "大模型时代（2020-至今）",
        "  - 超大规模模型",
        "  - 泛化能力增强",
        "  - 人机交互革命"
    ]
}

/// Slide: Industry Data Asset Practices
/// Shows data asset applications across different industries
struct IndustryDataAssetPracticeSlide: Slide, TableSlideStyle {
    let title = "各行业数据资产实践"
    let headers = ["行业", "数据资产应用", "典型案例"]
    let rows = [
        ["金融", "风控模型、精准营销", "蚂蚁信用评分"],
        ["零售", "用户画像、推荐系统", "亚马逊推荐"],
        ["制造", "智能制造、预测性维护", "西门子数字工厂"],
        ["医疗", "辅助诊断、药物研发", "IBM Watson"],
        ["交通", "自动驾驶、智慧交通", "滴滴出行"]
    ]
}

/// Node 1.2: Data Asset Concept (15 minutes)
///
/// Content: Data asset definition and comparison with traditional assets
struct DataAssetConceptNode: Node {
    let title = "1.2 数据资产概念"
    let slides: [any Slide] = [
        DataAssetDefinitionSlide(),
        DataAssetVsTraditionalSlide()
    ]
}

/// Slide: Data Asset Definition
struct DataAssetDefinitionSlide: Slide, TextStyle {
    let title = "数据资产的定义"
    let content = "数据资产是指企业或组织拥有或控制的、能够带来经济效益的数据资源。"
    let items = [
        "✓ 可识别",
        "✓ 可计量",
        "✓ 可带来收益",
        "✓ 可交易流通"
    ]
}

/// Slide: Data Asset vs Traditional Assets
struct DataAssetVsTraditionalSlide: Slide, TableSlideStyle {
    let title = "数据资产vs传统资产"
    let headers = ["维度", "传统资产", "数据资产"]
    let rows = [
        ["价值", "折旧递减", "增值递增"],
        ["使用", "独占性", "可共享"],
        ["复制", "成本高", "成本趋零"],
        ["权属", "清晰", "复杂"]
    ]
}

/// Node 1.3: Data Economy Development (15 minutes)
///
/// Content: Data factor marketization and data exchanges
struct DataEconomyNode: Node {
    let title = "1.3 数据经济发展"
    let slides: [any Slide] = [
        DataFactorMarketizationSlide(),
        DataExchangeSlide()
    ]
}

/// Slide: Data Factor Marketization
struct DataFactorMarketizationSlide: Slide, ContentStyle {
    let title = "数据要素市场化"
    let items = [
        "2020年：数据成为生产要素",
        "2021年：数据安全法实施",
        "2022年：数据二十条发布",
        "2023年：数据资产入表"
    ]
}

/// Slide: Data Exchanges
struct DataExchangeSlide: Slide, ContentStyle {
    let title = "国内主要数据交易所"
    let items = [
        "北京国际大数据交易所（2021）",
        "上海数据交易所（2021）",
        "深圳数据交易所（2022）",
        "贵阳大数据交易所（2015）",
        "",
        "主要交易产品：",
        "- 数据集",
        "- 数据API",
        "- 数据产品",
        "- 隐私计算服务"
    ]
}

// MARK: - Chapter 2: Hospital Data Assets

/// Chapter 2: Hospital Data Assets (1.5 hours)
///
/// Architecture: Chapter → Node → Slide
/// - 3 subsections covering hospital data types, asset value, and relationship with traditional IP
struct HospitalDataAssetChapter: Chapter {
    let title = "第二章：医院数据资产"
    let nodes: [any Node] = [
        HospitalDataTypeNode(),
        DataAssetValueNode(),
        TraditionalIPRelationshipNode()
    ]
}

/// Node 2.1: Hospital Data Types (30 minutes)
///
/// Content: Comprehensive classification of hospital data assets
struct HospitalDataTypeNode: Node {
    let title = "2.1 医院数据类型"
    let slides: [any Slide] = [
        HospitalDataAssetClassificationSlide()
    ]
}

/// Slide: Hospital Data Asset Classification
struct HospitalDataAssetClassificationSlide: Slide, ContentStyle {
    let title = "医院数据资产分类"
    let items = [
        "临床数据（核心资产）",
        "  - 电子病历",
        "  - 检验检查数据",
        "  - 影像数据",
        "  - 处方医嘱数据",
        "  - 护理记录",
        "",
        "运营管理数据",
        "  - 财务数据",
        "  - 人事数据",
        "  - 物资数据",
        "  - 设备数据",
        "",
        "科研教学数据",
        "  - 临床研究数据",
        "  - 随访数据",
        "  - 教学数据",
        "",
        "物联感知数据",
        "  - 医疗设备数据",
        "  - 穿戴设备数据",
        "  - 环境监测数据"
    ]
}

/// Node 2.2: Data Asset Value (30 minutes)
///
/// Content: Four major values of hospital data assets
struct DataAssetValueNode: Node {
    let title = "2.2 数据资产价值"
    let slides: [any Slide] = [
        FourMajorValuesSlide(),
        ValueRealizationPathSlide()
    ]
}

/// Slide: Four Major Values
struct FourMajorValuesSlide: Slide, TableSlideStyle {
    let title = "医院数据资产四大价值"
    let headers = ["价值类型", "应用场景", "具体例子"]
    let rows = [
        ["临床价值", "辅助诊断、精准医疗", "AI影像诊断"],
        ["管理价值", "运营优化、决策支持", "院长驾驶舱"],
        ["科研价值", "临床研究、药物研发", "真实世界研究"],
        ["AI价值", "模型训练、智能应用", "智能问诊"]
    ]
}

/// Slide: Value Realization Path
struct ValueRealizationPathSlide: Slide, ContentStyle {
    let title = "医院数据资产价值实现路径"
    let items = [
        "数据采集 → 数据治理 → 数据应用 → 价值",
        "主要方式：",
        "- 内部使用：运营效率提升",
        "- 外部合作：科研合作",
        "- 商业化：数据产品销售（合规）",
        "- 资产化：数据资产入表"
    ]
}

/// Node 2.3: Relationship with Traditional IP (30 minutes)
///
/// Content: Comparison between data assets and traditional intellectual property
struct TraditionalIPRelationshipNode: Node {
    let title = "2.3 与传统知识产权的关系"
    let slides: [any Slide] = [
        DataAssetVsIPSlide(),
        DataAssetIPIntegrationSlide()
    ]
}

/// Slide: Data Asset vs Intellectual Property
struct DataAssetVsIPSlide: Slide, TableSlideStyle {
    let title = "数据资产vs知识产权"
    let headers = ["对比维度", "传统知识产权", "数据资产"]
    let rows = [
        ["权利性质", "绝对权", "新型权益"],
        ["取得方式", "登记/审批", "实质性加工"],
        ["保护期限", "有限期", "持续有效"],
        ["客体形态", "有形", "无形可复制"],
        ["价值基础", "创造性", "数据量+质量+应用"]
    ]
}

/// Slide: Data Asset and IP Integration
struct DataAssetIPIntegrationSlide: Slide, ContentStyle {
    let title = "数据资产与传统知识产权的关系"
    let items = [
        "互补关系：",
        "- 专利需要数据支撑研发",
        "- 数据可作为商业秘密保护",
        "",
        "转化关系：",
        "- 研发数据→专利",
        "- 分析成果→著作权",
        "",
        "区别保护：",
        "- 数据：侧重于资产属性",
        "- 知识产权：侧重于创造性"
    ]
}

// MARK: - Chapter 3: Data Governance

/// Chapter 3: Data Governance (2 hours)
///
/// Architecture: Chapter → Node → Slide
/// - 3 subsections covering governance system, standardization, and quality management
struct DataGovernanceChapter: Chapter {
    let title = "第三章：数据治理"
    let nodes: [any Node] = [
        GovernanceSystemNode(),
        DataStandardizationNode(),
        DataQualityManagementNode()
    ]
}

/// Node 3.1: Data Governance System (40 minutes)
///
/// Content: Organizational structure for data governance
struct GovernanceSystemNode: Node {
    let title = "3.1 数据治理体系"
    let slides: [any Slide] = [
        GovernanceOrganizationSlide()
    ]
}

/// Slide: Governance Organization Structure
struct GovernanceOrganizationSlide: Slide, ContentStyle {
    let title = "医院数据治理组织架构"
    let items = [
        "数据管理委员会（院领导）",
        "  ↓",
        "数据管理部（信息科） + 业务部门（临床/职能）",
        "",
        "职责：",
        "- 统筹规划",
        "- 标准制定",
        "- 质量监控",
        "- 价值开发"
    ]
}

/// Node 3.2: Data Standardization (40 minutes)
///
/// Content: Data standardization requirements and priorities
struct DataStandardizationNode: Node {
    let title = "3.2 数据标准化"
    let slides: [any Slide] = [
        StandardizationContentSlide(),
        HospitalStandardizationPrioritiesSlide()
    ]
}

/// Slide: Standardization Content
struct StandardizationContentSlide: Slide, TableSlideStyle {
    let title = "数据标准化内容"
    let headers = ["标准类型", "内容", "例子"]
    let rows = [
        ["术语标准", "疾病编码、药品编码", "ICD-10、ATC"],
        ["数据标准", "数据元、代码集", "HL7 CDA"],
        ["接口标准", "系统对接规范", "HL7 FHIR"]
    ]
}

/// Slide: Hospital Standardization Priorities
struct HospitalStandardizationPrioritiesSlide: Slide, ContentStyle {
    let title = "医院数据标准化重点"
    let items = [
        "1. 患者主索引（EMPI）",
        "   - 唯一标识",
        "   - 身份核验",
        "",
        "2. 电子病历标准化",
        "   - 病历结构化",
        "   - 术语标准化",
        "",
        "3. 检验检查标准化",
        "   - LOINC编码",
        "   - DICOM标准",
        "",
        "4. 药品耗材标准化",
        "   - 国家药品编码",
        "   - 医保药品目录"
    ]
}

/// Node 3.3: Data Quality Management (40 minutes)
///
/// Content: Quality assessment dimensions and improvement cycle
struct DataQualityManagementNode: Node {
    let title = "3.3 数据质量管理"
    let slides: [any Slide] = [
        QualityAssessmentDimensionsSlide(),
        QualityImprovementCycleSlide()
    ]
}

/// Slide: Quality Assessment Dimensions
struct QualityAssessmentDimensionsSlide: Slide, TableSlideStyle {
    let title = "数据质量评估维度"
    let headers = ["维度", "定义", "指标"]
    let rows = [
        ["完整性", "数据完整程度", "空值率"],
        ["准确性", "数据准确程度", "错误率"],
        ["一致性", "数据一致程度", "冲突率"],
        ["时效性", "数据及时程度", "更新延迟"],
        ["可用性", "数据可使用程度", "可用率"]
    ]
}

/// Slide: Quality Improvement Cycle
struct QualityImprovementCycleSlide: Slide, ContentStyle {
    let title = "数据质量持续改进闭环"
    let items = [
        "质量评估 → 问题识别 → 原因分析 → 制定方案 → 改进措施",
        "↑",
        "常用工具：",
        "- 数据质量仪表盘",
        "- 质量规则引擎",
        "- 异常预警"
    ]
}

// MARK: - Chapter 4: Data Security and Compliance

/// Chapter 4: Data Security and Compliance (1.5 hours)
///
/// Architecture: Chapter → Node → Slide
/// - 3 subsections covering security system, privacy protection comparison, and medical data compliance
struct DataSecurityChapter: Chapter {
    let title = "第四章：数据安全与合规"
    let nodes: [any Node] = [
        SecuritySystemNode(),
        PrivacyProtectionComparisonNode(),
        MedicalDataComplianceNode()
    ]
}

/// Node 4.1: Data Security System (30 minutes)
///
/// Content: Comprehensive data security framework
struct SecuritySystemNode: Node {
    let title = "4.1 数据安全体系"
    let slides: [any Slide] = [
        SecurityFrameworkSlide()
    ]
}

/// Slide: Security Framework
struct SecurityFrameworkSlide: Slide, ContentStyle {
    let title = "医院数据安全体系"
    let items = [
        "数据分类分级：",
        "- 公开数据",
        "- 内部数据",
        "- 敏感数据",
        "- 核心数据",
        "",
        "安全技术措施：",
        "- 访问控制",
        "- 加密存储",
        "- 脱敏处理",
        "- 审计日志",
        "",
        "安全管理措施：",
        "- 安全制度",
        "- 培训演练",
        "- 应急响应"
    ]
}

/// Node 4.2: Privacy Protection Comparison (45 minutes)
///
/// Content: Comparison of privacy protection laws domestically and internationally
struct PrivacyProtectionComparisonNode: Node {
    let title = "4.2 国内外隐私保护比较"
    let slides: [any Slide] = [
        PrivacyLawsComparisonSlide()
    ]
}

/// Slide: Privacy Laws Comparison
struct PrivacyLawsComparisonSlide: Slide, ContentStyle {
    let title = "国内外隐私保护法律对比"
    let items = [
        "中国：个人信息保护法（2021）",
        "欧盟：GDPR（2018）",
        "美国：CCPA（2020）",
        "",
        "中国医疗数据合规核心要求：",
        "1. 知情同意",
        "   - 收集前告知",
        "   - 明确授权",
        "   - 特殊敏感需单独同意",
        "",
        "2. 最小必要",
        "   - 只收集必要数据",
        "   - 只保留必要期限",
        "   - 只用于必要目的",
        "",
        "3. 安全保护",
        "   - 采取技术措施",
        "   - 建立管理制度",
        "   - 定期安全评估",
        "",
        "4. 数据跨境",
        "   - 需要安全评估",
        "   - 需要出境审批"
    ]
}

/// Node 4.3: Medical Data Compliance (15 minutes)
///
/// Content: Medical data compliance requirements
struct MedicalDataComplianceNode: Node {
    let title = "4.3 医疗数据合规"
    let slides: [any Slide] = [
        ComplianceRequirementsSlide()
    ]
}

/// Slide: Compliance Requirements
struct ComplianceRequirementsSlide: Slide, TableSlideStyle {
    let title = "医疗数据合规要求"
    let headers = ["合规领域", "核心要求", "违规后果"]
    let rows = [
        ["患者隐私", "保护患者信息", "行政处罚、赔偿"],
        ["病历数据", "规范书写、保管", "医疗纠纷"],
        ["基因数据", "严格保护", "刑事责任"],
        ["医保数据", "合规使用", "医保处罚"]
    ]
}

// MARK: - Chapter 5: Management System Impact

/// Chapter 5: Management System Impact on Data Quality (1 hour)
///
/// Architecture: Chapter → Node → Slide
/// - 3 subsections covering medical management systems, performance evaluation, and medical insurance data
struct ManagementSystemChapter: Chapter {
    let title = "第五章：医院管理制度对数据质量的影响"
    let nodes: [any Node] = [
        MedicalManagementSystemNode(),
        PerformanceEvaluationNode(),
        MedicalInsuranceDataNode()
    ]
}

/// Node 5.1: Medical Management System (20 minutes)
///
/// Content: Impact of management systems on data quality
struct MedicalManagementSystemNode: Node {
    let title = "5.1 医疗管理制度"
    let slides: [any Slide] = [
        ManagementSystemImpactSlide()
    ]
}

/// Slide: Management System Impact
struct ManagementSystemImpactSlide: Slide, ContentStyle {
    let title = "医疗管理制度对数据质量的影响"
    let items = [
        "病历书写规范 → 病历数据质量",
        "- 书写及时性 → 时效性",
        "- 内容完整性 → 完整性",
        "- 诊断准确性 → 准确性",
        "",
        "核心制度 → 诊疗数据质量",
        "- 三级查房 → 查房记录质量",
        "- 会诊制度 → 会诊数据质量",
        "- 手术核查 → 手术数据质量",
        "",
        "院感制度 → 院感数据质量",
        "- 监测规范 → 监测数据准确性"
    ]
}

/// Node 5.2: Performance Evaluation (20 minutes)
///
/// Content: Impact of national performance evaluation on data
struct PerformanceEvaluationNode: Node {
    let title = "5.2 绩效评价制度"
    let slides: [any Slide] = [
        NationalExamImpactSlide()
    ]
}

/// Slide: National Exam Impact
struct NationalExamImpactSlide: Slide, TableSlideStyle {
    let title = "国考对数据的影响"
    let headers = ["国考指标", "对数据的要求", "影响"]
    let rows = [
        ["CMI", "病案首页诊断编码", "推动编码准确"],
        ["四级手术", "手术记录完整性", "推动手术规范"],
        ["药占比", "费用数据准确性", "推动费用规范"],
        ["抗菌药物", "处方数据准确性", "推动合理用药"]
    ]
}

/// Node 5.3: Medical Insurance Data (20 minutes)
///
/// Content: Impact of medical insurance requirements on data
struct MedicalInsuranceDataNode: Node {
    let title = "5.3 医保数据"
    let slides: [any Slide] = [
        MedicalInsuranceImpactSlide()
    ]
}

/// Slide: Medical Insurance Impact
struct MedicalInsuranceImpactSlide: Slide, TableSlideStyle {
    let title = "医保数据对医院的影响"
    let headers = ["医保要求", "数据影响"]
    let rows = [
        ["DRG/DIP分组", "病案首页质量"],
        ["费用结算", "费用明细准确性"],
        ["飞行检查", "数据可追溯性"],
        ["智能审核", "数据合规性"]
    ]
}

// MARK: - Chapter 6: Data Application and Innovation

/// Chapter 6: Data Application and Innovation (1 hour)
///
/// Architecture: Chapter → Node → Slide
/// - 3 subsections covering clinical applications, management applications, and AI/big data applications
struct DataApplicationChapter: Chapter {
    let title = "第六章：数据应用与创新"
    let nodes: [any Node] = [
        ClinicalDataApplicationNode(),
        ManagementDataApplicationNode(),
        AIBigDataApplicationNode()
    ]
}

/// Node 6.1: Clinical Data Application (20 minutes)
///
/// Content: Clinical data application scenarios
struct ClinicalDataApplicationNode: Node {
    let title = "6.1 临床数据应用"
    let slides: [any Slide] = [
        ClinicalApplicationScenariosSlide()
    ]
}

/// Slide: Clinical Application Scenarios
struct ClinicalApplicationScenariosSlide: Slide, TableSlideStyle {
    let title = "临床数据应用场景"
    let headers = ["应用场景", "数据类型", "应用价值"]
    let rows = [
        ["辅助诊断", "病历+检验+影像", "提高诊断准确率"],
        ["精准医疗", "基因+临床", "个体化治疗"],
        ["临床决策支持", "历史病例", "诊疗建议"]
    ]
}

/// Node 6.2: Management Data Application (20 minutes)
///
/// Content: Management data application scenarios
struct ManagementDataApplicationNode: Node {
    let title = "6.2 管理数据应用"
    let slides: [any Slide] = [
        ManagementApplicationScenariosSlide()
    ]
}

/// Slide: Management Application Scenarios
struct ManagementApplicationScenariosSlide: Slide, ContentStyle {
    let title = "医院管理数据应用"
    let items = [
        "运营分析：",
        "- 业务量分析",
        "- 收入结构分析",
        "- 成本效益分析",
        "",
        "质量监控：",
        "- 医疗质量指标",
        "- 护理质量指标",
        "- 院感监控",
        "",
        "决策支持：",
        "- 院长驾驶舱",
        "- 科室运营分析",
        "- 绩效分析"
    ]
}

/// Node 6.3: AI and Big Data Application (20 minutes)
///
/// Content: AI model training data requirements
struct AIBigDataApplicationNode: Node {
    let title = "6.3 AI与大数据应用"
    let slides: [any Slide] = [
        AIModelDataRequirementsSlide()
    ]
}

/// Slide: AI Model Data Requirements
struct AIModelDataRequirementsSlide: Slide, TableSlideStyle {
    let title = "AI模型训练数据需求"
    let headers = ["AI应用", "数据需求", "挑战"]
    let rows = [
        ["影像识别", "大量标注影像", "标注成本"],
        ["辅助诊断", "完整病历数据", "数据质量"],
        ["药物研发", "分子数据+临床数据", "数据共享"],
        ["智能问诊", "对话数据", "隐私保护"]
    ]
}

// MARK: - Chapter 7: Case Studies and Practice

/// Chapter 7: Case Studies and Practice (1 hour)
///
/// Architecture: Chapter → Node → Slide
/// - 2 subsections covering case analysis and practical exercises
struct CaseStudyChapter: Chapter {
    let title = "第七章：案例与实践"
    let nodes: [any Node] = [
        CaseAnalysisNode(),
        PracticalExerciseNode()
    ]
}

/// Node 7.1: Case Analysis (30 minutes)
///
/// Content: Real-world case study of a tertiary hospital's data asset management system
struct CaseAnalysisNode: Node {
    let title = "7.1 案例分析"
    let slides: [any Slide] = [
        TertiaryHospitalCaseSlide()
    ]
}

/// Slide: Tertiary Hospital Case
struct TertiaryHospitalCaseSlide: Slide, ContentStyle {
    let title = "某三甲医院数据资产管理体系建设"
    let items = [
        "建设内容：",
        "1. 建立数据治理组织",
        "2. 制定数据标准",
        "3. 建设数据平台",
        "4. 开展数据应用",
        "",
        "效果：",
        "- 数据质量提升30%",
        "- 运营效率提升20%",
        "- AI应用取得突破"
    ]
}

/// Node 7.2: Practical Exercise (30 minutes)
///
/// Content: Hands-on practice exercises
struct PracticalExerciseNode: Node {
    let title = "7.2 实操练习"
    let slides: [any Slide] = [
        PracticalExerciseSlide()
    ]
}

/// Slide: Practical Exercise
struct PracticalExerciseSlide: Slide, TextStyle {
    let title = "实操练习"
    let content = "根据课程内容，完成以下练习："
    let items = [
        "1. 分析本院数据资产现状",
        "2. 制定数据治理计划",
        "3. 设计数据应用场景",
        "4. 评估数据合规风险"
    ]
}

// MARK: - Course Summary

/// Course Summary Slide
/// Summarizes the key points of the course
struct CourseSummarySlide: Slide, ContentStyle {
    let title = "课程总结"
    let items = [
        "核心要点：",
        "1. 时代背景：AI时代数据资产成为核心资产",
        "2. 价值多元：临床、管理、科研、AI多维价值",
        "3. 合规重要：隐私保护与数据安全是底线",
        "4. 管理影响：医院管理制度影响数据质量"
    ]
}

/// End Slide
/// Thank you and recommended reading
struct EndSlide: Slide, EndCoverStyle {
    let title = "谢谢"
    let subtitle = "AI时代的数据资产管理"
    let author = "医院管理课程"
}

// MARK: - Main Entry Point

@main
struct DataAssetCourseDemo {
    static func main() async {
        let presentation = DataAssetCoursePresentation()
        
        do {
            try await PresentationRunner.generate(presentation, saveJSON: true)
        } catch {
            print("❌ Error: \(error)")
        }
    }
}
