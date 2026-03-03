import Testing
import Foundation

@Suite("Statistics Tests")
struct StatisticsTests {
    
    @Test("Two-sample t-test")
    func testTwoSampleTTest() async throws {
        let sampleA: [Double] = Array(1...6).map { Double($0) }
        let sampleB: [Double] = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6]
        let difference: Double = 0.025
        
        let result = try tTestTwoSample(sampleA: sampleA, sampleB: sampleB, difference: difference)
        
        print("✅ t-test result: \(result)")
        #expect(!result.isNaN)
    }
    
    @Test("Mean calculation")
    func testMeanCalculation() async throws {
        let data: [Double] = [1, 2, 3, 4, 5, 6]
        let mean = data.reduce(0, +) / Double(data.count)
        
        #expect(mean == 3.5)
        print("✅ Mean: \(mean)")
    }
    
    @Test("Standard deviation calculation")
    func testStdDevCalculation() async throws {
        let data: [Double] = [1, 2, 3, 4, 5, 6]
        let mean = data.reduce(0, +) / Double(data.count)
        let variance = data.reduce(0) { $0 + ($1 - mean) * ($1 - mean) } / Double(data.count)
        let stdDev = sqrt(variance)
        
        print("✅ Standard deviation: \(stdDev)")
        #expect(stdDev > 0)
    }
    
    private func tTestTwoSample(sampleA: [Double], sampleB: [Double], difference: Double) throws -> Double {
        let n1 = Double(sampleA.count)
        let n2 = Double(sampleB.count)
        
        let mean1 = sampleA.reduce(0, +) / n1
        let mean2 = sampleB.reduce(0, +) / n2
        
        let var1 = sampleA.reduce(0) { $0 + ($1 - mean1) * ($1 - mean1) } / (n1 - 1)
        let var2 = sampleB.reduce(0) { $0 + ($1 - mean2) * ($1 - mean2) } / (n2 - 1)
        
        let pooledVar = ((n1 - 1) * var1 + (n2 - 1) * var2) / (n1 + n2 - 2)
        let se = sqrt(pooledVar * (1/n1 + 1/n2))
        
        let t = (mean1 - mean2 - difference) / se
        return t
    }
}
