import XCTest
@testable import iwasbored

final class ArrayTests: XCTestCase {
    var iwb: IWasBored!
    
    override func setUp() {
        super.setUp()
        iwb = IWasBored()
    }
    
    func testArrayCreation() {
        let hasErrors = iwb.run("""
        var arr = [1, 2, 3]
        print(arr)
        """)
        XCTAssertFalse(hasErrors)
    }
    
    func testEmptyArray() {
        let hasErrors = iwb.run("""
        var arr = []
        print(arr)
        """)
        XCTAssertFalse(hasErrors)
    }
    
    func testMixedTypeArray() {
        let hasErrors = iwb.run("""
        var arr = [1, "hello", true, nil]
        print(arr)
        """)
        XCTAssertFalse(hasErrors)
    }
    
    func testArrayAccess() {
        let hasErrors = iwb.run("""
        var arr = [10, 20, 30]
        print(arr[0])
        print(arr[1])
        print(arr[2])
        """)
        XCTAssertFalse(hasErrors)
    }
    
    func testArrayPush() {
        let hasErrors = iwb.run("""
        var arr = [1, 2, 3]
        arr = arr.push(4)
        print(arr)
        """)
        XCTAssertFalse(hasErrors)
    }
    
    func testArrayPop() {
        let hasErrors = iwb.run("""
        var arr = [1, 2, 3]
        var popped = arr.pop()
        print(popped)
        print(arr)
        """)
        XCTAssertFalse(hasErrors)
    }
    
    func testArrayGet() {
        let hasErrors = iwb.run("""
        var arr = [10, 20, 30]
        var value = arr.get(1)
        print(value)
        """)
        XCTAssertFalse(hasErrors)
    }
    
    func testArraySet() {
        let hasErrors = iwb.run("""
        var arr = [10, 20, 30]
        arr = arr.set(1, 25)
        print(arr)
        """)
        XCTAssertFalse(hasErrors)
    }
    
    func testArrayEquality() {
    }
    
    func testArrayInBlock() {
        let hasErrors = iwb.run("""
        var outerArr = [1, 2, 3]
        {
            var innerArr = [4, 5, outerArr[2]]
            print(innerArr)
        }
        """)
        XCTAssertFalse(hasErrors)
    }
    
    func testNestedArrays() {
        let hasErrors = iwb.run("""
        var nested = [[1, 2], [3, 4]]
        print(nested[0][1])
        """)
        XCTAssertFalse(hasErrors)
    }
    
    func testArrayWithVariables() {
        let hasErrors = iwb.run("""
        var a = 10
        var b = 20
        var arr = [a, b, a + b]
        print(arr)
        """)
        XCTAssertFalse(hasErrors)
    }
}
