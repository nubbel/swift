// Copyright (c) 2014 - 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//
//
// RUN: %target-run-simple-swift
// REQUIRES: executable_test
// REQUIRES: objc_interop

import Foundation

#if FOUNDATION_XCTEST
import XCTest
class TestIndexSetSuper : XCTestCase { }
#else
import StdlibUnittest
class TestIndexSetSuper { }
#endif

class TestIndexSet : TestIndexSetSuper {
    
    func testEnumeration() {
        let someIndexes = IndexSet(integersIn: 3..<5)
        let first = someIndexes.startIndex
        let last = someIndexes.endIndex
        
        expectNotEqual(first, last)
        
        var count = 0
        var firstValue = 0
        var secondValue = 0
        for v in someIndexes {
            if count == 0 { firstValue = v }
            if count == 1 { secondValue = v }
            count += 1
        }
        
        expectEqual(2, count)
        expectEqual(3, firstValue)
        expectEqual(4, secondValue)
    }
    
    func testSubsequence() {
        var someIndexes = IndexSet(integersIn: 1..<3)
        someIndexes.insert(integersIn: 10..<20)
        
        let intersectingRange = someIndexes.indexRange(in: 5..<21)
        expectFalse(intersectingRange.isEmpty)
        
        let sub = someIndexes[intersectingRange]
        var count = 0
        for i in sub {
            if count == 0 {
                expectEqual(10, i)
            }
            if count == 9 {
                expectEqual(19, i)
            }
            count += 1
        }
        expectEqual(count, 10)
    }
    
    func testIndexRange() {
        var someIndexes = IndexSet(integersIn: 1..<3)
        someIndexes.insert(integersIn: 10..<20)

        var r : Range<IndexSet.Index>
        
        r = someIndexes.indexRange(in: 1..<3)
        expectEqual(1, someIndexes[r.lowerBound])
        expectEqual(10, someIndexes[r.upperBound])
        
        r = someIndexes.indexRange(in: 0..<0)
        expectEqual(r.lowerBound, r.upperBound)
        
        r = someIndexes.indexRange(in: 100..<201)
        expectEqual(r.lowerBound, r.upperBound)
        
        r = someIndexes.indexRange(in: 0..<100)
        expectEqual(r.lowerBound, someIndexes.startIndex)
        expectEqual(r.upperBound, someIndexes.endIndex)
        
        r = someIndexes.indexRange(in: 1..<11)
        expectEqual(1, someIndexes[r.lowerBound])
        expectEqual(11, someIndexes[r.upperBound])
    }
    
    func testMutation() {
        var someIndexes = IndexSet(integersIn: 1..<3)
        someIndexes.insert(3)
        someIndexes.insert(4)
        someIndexes.insert(5)
        
        someIndexes.insert(10)
        someIndexes.insert(11)
        
        expectEqual(someIndexes.count, 7)
    }
    
    func testIteration() {
        var someIndexes = IndexSet(integersIn: 1..<5)
        someIndexes.insert(integersIn: 8..<11)
        someIndexes.insert(15)
        
        let start = someIndexes.startIndex
        let end = someIndexes.endIndex
        
        // Count forwards
        var i = start
        var count = 0
        while i != end {
            count += 1
            i = someIndexes.index(after: i)
        }
        expectEqual(8, count)
        
        // Count backwards
        i = end
        count = 0
        while i != start {
            i = someIndexes.index(before: i)
            count += 1
        }
        expectEqual(8, count)
        
        // Count using a for loop
        count = 0
        for _ in someIndexes {
            count += 1
        }
        expectEqual(8, count)

        // Go the other way
        count = 0
        for _ in someIndexes.reversed() {
            count += 1
        }
        expectEqual(8, count)
    }
    
    func testRangeIteration() {
        var someIndexes = IndexSet(integersIn: 1..<5)
        someIndexes.insert(integersIn: 8..<11)
        someIndexes.insert(15)
        
        var count = 0
        for r in someIndexes.rangeView() {
            // print("\(r)")
            count += 1
            if count == 3 {
                expectEqual(r, 15..<16)
            }
        }
        expectEqual(3, count)
        
        // Backwards
        count = 0
        for r in someIndexes.rangeView().reversed() {
            // print("\(r)")
            count += 1
            if count == 3 {
                expectEqual(r, 1..<5)
            }
        }
        expectEqual(3, count)
    }
    
    func testSubrangeIteration() {
        var someIndexes = IndexSet(integersIn: 2..<5)
        someIndexes.insert(integersIn: 8..<11)
        someIndexes.insert(integersIn: 15..<20)
        someIndexes.insert(integersIn: 30..<40)
        someIndexes.insert(integersIn: 60..<80)
        
        var count = 0
        for _ in someIndexes.rangeView() {
            count += 1
        }
        expectEqual(5, count)
        
        
        count = 0
        for r in someIndexes.rangeView(of: 9..<35) {
            if count == 0 {
                expectEqual(r, 9..<11)
            }
            count += 1
            if count == 3 {
                expectEqual(r, 30..<35)
            }
        }
        expectEqual(3, count)
        
        count = 0
        for r in someIndexes.rangeView(of: 0..<35) {
            if count == 0 {
                expectEqual(r, 2..<5)
            }
            count += 1
            if count == 4 {
                expectEqual(r, 30..<35)
            }
        }
        expectEqual(4, count)

        // Empty intersection, before start
        count = 0
        for _ in someIndexes.rangeView(of: 0..<1) {
            count += 1
        }
        expectEqual(0, count)

        // Empty range
        count = 0
        for _ in someIndexes.rangeView(of: 0..<0) {
            count += 1
        }
        expectEqual(0, count)

        // Empty intersection, after end
        count = 0
        for _ in someIndexes.rangeView(of: 999..<1000) {
            count += 1
        }
        expectEqual(0, count)
    }
    
    func testSlicing() {
        var someIndexes = IndexSet(integersIn: 2..<5)
        someIndexes.insert(integersIn: 8..<11)
        someIndexes.insert(integersIn: 15..<20)
        someIndexes.insert(integersIn: 30..<40)
        someIndexes.insert(integersIn: 60..<80)
        
        var r : Range<IndexSet.Index>
        
        r = someIndexes.indexRange(in: 5..<25)
        expectEqual(8, someIndexes[r.lowerBound])
        expectEqual(19, someIndexes[someIndexes.index(before: r.upperBound)])
        var count = 0
        for _ in someIndexes[r] {
            count += 1
        }
        
        expectEqual(8, someIndexes.count(in: 5..<25))
        expectEqual(8, count)
        
        r = someIndexes.indexRange(in: 100..<200)
        expectTrue(r.isEmpty)
        
        let emptySlice = someIndexes[r]
        expectEqual(0, emptySlice.count)
        
        let boundarySlice = someIndexes[someIndexes.indexRange(in: 2..<3)]
        expectEqual(1, boundarySlice.count)
        
        let boundarySlice2 = someIndexes[someIndexes.indexRange(in: 79..<80)]
        expectEqual(1, boundarySlice2.count)
        
        let largeSlice = someIndexes[someIndexes.indexRange(in: 0..<100000)]
        expectEqual(someIndexes.count, largeSlice.count)
    }
    
    func testEmptyIteration() {
        let empty = IndexSet()
        let start = empty.startIndex
        let end = empty.endIndex
        
        expectEqual(start, end)
        
        var count = 0
        for _ in empty {
            count += 1
        }
        
        expectEqual(count, 0)
        
        count = 0
        for _ in empty.rangeView() {
            count += 1
        }
        
        expectEqual(count, 0)
    }
    
    func testSubsequences() {
        var someIndexes = IndexSet(integersIn: 1..<5)
        someIndexes.insert(integersIn: 8..<11)
        someIndexes.insert(15)

        // Get a subsequence of this IndexSet
        let range = someIndexes.indexRange(in: 4..<15)
        let subSet = someIndexes[range]
        
        expectEqual(subSet.count, 4)
        
        // Iterate a subset
        var count = 0
        for _ in subSet {
            count += 1
        }
        expectEqual(count, 4)
        
        // And in reverse
        count = 0
        for _ in subSet.reversed() {
            count += 1
        }
        expectEqual(count, 4)
    }
    
    func testFiltering() {
        var someIndexes = IndexSet(integersIn: 1..<5)
        someIndexes.insert(integersIn: 8..<11)
        someIndexes.insert(15)
        
        // An array
        let resultArray = someIndexes.filter { $0 % 2 == 0 }
        expectEqual(resultArray.count, 4)

        let resultSet = someIndexes.filteredIndexSet { $0 % 2 == 0 }
        expectEqual(resultSet.count, 4)
        
        let resultOutsideRange = someIndexes.filteredIndexSet(in: 20..<30, includeInteger: { _ in return true } )
        expectEqual(resultOutsideRange.count, 0)
        
        let resultInRange = someIndexes.filteredIndexSet(in: 0..<16, includeInteger: { _ in return true } )
        expectEqual(resultInRange.count, someIndexes.count)
    }
    
    func testFilteringRanges() {
        var someIndexes = IndexSet(integersIn: 1..<5)
        someIndexes.insert(integersIn: 8..<11)
        someIndexes.insert(15)

        let resultArray = someIndexes.rangeView().filter { $0.count > 1 }
        expectEqual(resultArray.count, 2)
    }
    
    func testShift() {
        var someIndexes = IndexSet(integersIn: 1..<5)
        someIndexes.insert(integersIn: 8..<11)
        someIndexes.insert(15)
        
        let lastValue = someIndexes.last!
        
        someIndexes.shift(startingAt: 13, by: 1)
        
        // Count should not have changed
        expectEqual(someIndexes.count, 8)
        
        // But the last value should have
        expectEqual(lastValue + 1, someIndexes.last!)
        
        // Shift starting at something not in the set
        someIndexes.shift(startingAt: 0, by: 1)
        
        // Count should not have changed, again
        expectEqual(someIndexes.count, 8)
        
        // But the last value should have, again
        expectEqual(lastValue + 2, someIndexes.last!)
    }
    
    func testSymmetricDifference() {
        var is1 : IndexSet
        var is2 : IndexSet
        var expected : IndexSet

        do {
            is1 = IndexSet()
            is1.insert(integersIn: 1..<3)
            is1.insert(integersIn: 4..<11)
            is1.insert(integersIn: 15..<21)
            is1.insert(integersIn: 40..<51)
            
            is2 = IndexSet()
            is2.insert(integersIn: 5..<18)
            is2.insert(integersIn: 45..<61)
            
            expected = IndexSet()
            expected.insert(integersIn: 1..<3)
            expected.insert(4)
            expected.insert(integersIn: 11..<15)
            expected.insert(integersIn: 18..<21)
            expected.insert(integersIn: 40..<45)
            expected.insert(integersIn: 51..<61)
            
            expectEqual(expected, is1.symmetricDifference(is2))
            expectEqual(expected, is2.symmetricDifference(is1))
        }
        
        do {
            is1 = IndexSet()
            is1.insert(integersIn: 5..<18)
            is1.insert(integersIn: 45..<61)
            
            is2 = IndexSet()
            is2.insert(integersIn: 5..<18)
            is2.insert(integersIn: 45..<61)

            expected = IndexSet()
            expectEqual(expected, is1.symmetricDifference(is2))
            expectEqual(expected, is2.symmetricDifference(is1))
        }
        
        do {
            is1 = IndexSet(integersIn: 1..<10)
            is2 = IndexSet(integersIn: 20..<30)
            
            expected = IndexSet()
            expected.insert(integersIn: 1..<10)
            expected.insert(integersIn: 20..<30)
            expectEqual(expected, is1.symmetricDifference(is2))
            expectEqual(expected, is2.symmetricDifference(is1))
        }
        
        do {
            is1 = IndexSet(integersIn: 1..<10)
            is2 = IndexSet(integersIn: 1..<11)
            expected = IndexSet(integer: 10)
            expectEqual(expected, is1.symmetricDifference(is2))
            expectEqual(expected, is2.symmetricDifference(is1))
        }
        
        do {
            is1 = IndexSet(integer: 42)
            is2 = IndexSet(integer: 42)
            expectEqual(IndexSet(), is1.symmetricDifference(is2))
            expectEqual(IndexSet(), is2.symmetricDifference(is1))
        }
        
        do {
            is1 = IndexSet(integer: 1)
            is1.insert(3)
            is1.insert(5)
            is1.insert(7)
            
            is2 = IndexSet(integer: 0)
            is2.insert(2)
            is2.insert(4)
            is2.insert(6)
            
            expected = IndexSet(integersIn: 0..<8)
            expectEqual(expected, is1.symmetricDifference(is2))
            expectEqual(expected, is2.symmetricDifference(is1))
        }
        
        do {
            is1 = IndexSet(integersIn: 0..<5)
            is2 = IndexSet(integersIn: 3..<10)
            
            expected = IndexSet(integersIn: 0..<3)
            expected.insert(integersIn: 5..<10)
            
            expectEqual(expected, is1.symmetricDifference(is2))
            expectEqual(expected, is2.symmetricDifference(is1))
        }
    }
    
    func testIntersection() {
        var is1 : IndexSet
        var is2 : IndexSet
        var expected : IndexSet

        do {
            is1 = IndexSet()
            is1.insert(integersIn: 1..<3)
            is1.insert(integersIn: 4..<11)
            is1.insert(integersIn: 15..<21)
            is1.insert(integersIn: 40..<51)
            
            is2 = IndexSet()
            is2.insert(integersIn: 5..<18)
            is2.insert(integersIn: 45..<61)
            
            expected = IndexSet()
            expected.insert(integersIn: 5..<11)
            expected.insert(integersIn: 15..<18)
            expected.insert(integersIn: 45..<51)
            
            expectEqual(expected, is1.intersection(is2))
            expectEqual(expected, is2.intersection(is1))
        }
        
        do {
            is1 = IndexSet()
            is1.insert(integersIn: 5..<11)
            is1.insert(integersIn: 20..<31)
            
            is2 = IndexSet()
            is2.insert(integersIn: 11..<20)
            is2.insert(integersIn: 31..<40)
            
            expectEqual(IndexSet(), is1.intersection(is2))
            expectEqual(IndexSet(), is2.intersection(is1))
        }
        
        do {
            is1 = IndexSet(integer: 42)
            is2 = IndexSet(integer: 42)
            expectEqual(IndexSet(integer: 42), is1.intersection(is2))
        }
        
        do {
            is1 = IndexSet(integer: 1)
            is1.insert(3)
            is1.insert(5)
            is1.insert(7)
            
            is2 = IndexSet(integer: 0)
            is2.insert(2)
            is2.insert(4)
            is2.insert(6)
            
            expected = IndexSet()
            expectEqual(expected, is1.intersection(is2))
            expectEqual(expected, is2.intersection(is1))
        }
        
        do {
            is1 = IndexSet(integersIn: 0..<5)
            is2 = IndexSet(integersIn: 4..<10)
            
            expected = IndexSet(integer: 4)
            
            expectEqual(expected, is1.intersection(is2))
            expectEqual(expected, is2.intersection(is1))
        }

    }
    
    func testUnion() {
        var is1 : IndexSet
        var is2 : IndexSet
        var expected : IndexSet
        
        do {
            is1 = IndexSet()
            is1.insert(integersIn: 1..<3)
            is1.insert(integersIn: 4..<11)
            is1.insert(integersIn: 15..<21)
            is1.insert(integersIn: 40..<51)
            
            is2 = IndexSet()
            is2.insert(integersIn: 5..<18)
            is2.insert(integersIn: 45..<61)
            
            expected = IndexSet()
            expected.insert(integersIn: 1..<3)
            expected.insert(integersIn: 4..<21)
            expected.insert(integersIn: 40..<61)
            
            expectEqual(expected, is1.union(is2))
            expectEqual(expected, is2.union(is1))
        }
        
        do {
            is1 = IndexSet()
            is1.insert(integersIn: 5..<11)
            is1.insert(integersIn: 20..<31)
            
            is2 = IndexSet()
            is2.insert(integersIn: 11..<20)
            is2.insert(integersIn: 31..<40)
            
            expected = IndexSet()
            expected.insert(integersIn: 5..<11)
            expected.insert(integersIn: 20..<31)
            expected.insert(integersIn: 11..<20)
            expected.insert(integersIn: 31..<40)
            
            expectEqual(expected, is1.union(is2))
            expectEqual(expected, is2.union(is1))
        }
        
        do {
            is1 = IndexSet(integer: 42)
            is2 = IndexSet(integer: 42)
            
            expectEqual(IndexSet(integer: 42), is1.union(is2))
        }
        
        do {
            is1 = IndexSet()
            is1.insert(integersIn: 5..<10)
            is1.insert(integersIn: 15..<20)
            
            is2 = IndexSet()
            is2.insert(integersIn: 1..<4)
            is2.insert(integersIn: 15..<20)
            
            expected = IndexSet()
            expected.insert(integersIn: 1..<4)
            expected.insert(integersIn: 5..<10)
            expected.insert(integersIn: 15..<20)
            
            expectEqual(expected, is1.union(is2))
            expectEqual(expected, is2.union(is1))
        }

        expectEqual(IndexSet(), IndexSet().union(IndexSet()))
        
        do {
            is1 = IndexSet(integer: 1)
            is1.insert(3)
            is1.insert(5)
            is1.insert(7)
            
            is2 = IndexSet(integer: 0)
            is2.insert(2)
            is2.insert(4)
            is2.insert(6)
            
            expected = IndexSet()
            expectEqual(expected, is1.intersection(is2))
            expectEqual(expected, is2.intersection(is1))
        }
        
        do {
            is1 = IndexSet(integersIn: 0..<5)
            is2 = IndexSet(integersIn: 3..<10)
            
            expected = IndexSet(integersIn: 0..<10)
            
            expectEqual(expected, is1.union(is2))
            expectEqual(expected, is2.union(is1))
        }

        do {
            is1 = IndexSet()
            is1.insert(2)
            is1.insert(6)
            is1.insert(21)
            is1.insert(22)
            
            is2 = IndexSet()
            is2.insert(8)
            is2.insert(14)
            is2.insert(21)
            is2.insert(22)
            is2.insert(24)
            
            expected = IndexSet()
            expected.insert(2)
            expected.insert(6)
            expected.insert(21)
            expected.insert(22)
            expected.insert(8)
            expected.insert(14)
            expected.insert(21)
            expected.insert(22)
            expected.insert(24)

            expectEqual(expected, is1.union(is2))
            expectEqual(expected, is2.union(is1))
        }
    }
    

    // MARK: -
    // MARK: Performance Testing
    
    func largeIndexSet() -> IndexSet {
        var result = IndexSet()
        
        for i in 1..<10000 {
            let start = i * 10
            let end = start + 9
            result.insert(integersIn: start..<end + 1)
        }
        
        return result
    }
    
    func testIndexingPerformance() {
        /*
        let set = largeIndexSet()
        self.measureBlock {
            var count = 0
            while count < 20 {
                for _ in set {
                }
                count += 1
            }
        }
        */
    }
}

#if !FOUNDATION_XCTEST
var IndexSetTests = TestSuite("TestIndexSet")
IndexSetTests.test("testSymmetricDifference") { TestIndexSet().testSymmetricDifference() }
IndexSetTests.test("testIntersection") { TestIndexSet().testIntersection() }
IndexSetTests.test("testUnion") { TestIndexSet().testUnion() }
IndexSetTests.test("testEnumeration") { TestIndexSet().testEnumeration() }
IndexSetTests.test("testSubsequence") { TestIndexSet().testSubsequence() }
IndexSetTests.test("testIndexRange") { TestIndexSet().testIndexRange() }
IndexSetTests.test("testMutation") { TestIndexSet().testMutation() }
IndexSetTests.test("testIteration") { TestIndexSet().testIteration() }
IndexSetTests.test("testRangeIteration") { TestIndexSet().testRangeIteration() }
IndexSetTests.test("testSubrangeIteration") { TestIndexSet().testSubrangeIteration() }
IndexSetTests.test("testSlicing") { TestIndexSet().testSlicing() }
IndexSetTests.test("testEmptyIteration") { TestIndexSet().testEmptyIteration() }
IndexSetTests.test("testSubsequences") { TestIndexSet().testSubsequences() }
IndexSetTests.test("testFiltering") { TestIndexSet().testFiltering() }
IndexSetTests.test("testFilteringRanges") { TestIndexSet().testFilteringRanges() }
IndexSetTests.test("testShift") { TestIndexSet().testShift() }
// IndexSetTests.test("testIndexingPerformance") { TestIndexSet().testIndexingPerformance() }
runAllTests()
#endif

