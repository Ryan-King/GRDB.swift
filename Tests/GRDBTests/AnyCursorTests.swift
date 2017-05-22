import XCTest
#if GRDBCIPHER
    import GRDBCipher
#elseif GRDBCUSTOMSQLITE
    import GRDBCustomSQLite
#else
    import GRDB
#endif

private struct TestError : Error { }

class AnyCursorTests: GRDBTestCase {
    
    func testAnyCursorFromClosure() {
        var i = 0
        let cursor: AnyCursor<Int> = AnyCursor {
            guard i < 2 else { return nil }
            defer { i += 1 }
            return i
        }
        XCTAssertEqual(try cursor.next()!, 0)
        XCTAssertEqual(try cursor.next()!, 1)
        XCTAssertTrue(try cursor.next() == nil) // end
    }
    
    func testAnyCursorFromThrowingClosure() {
        var i = 0
        let cursor: AnyCursor<Int> = AnyCursor {
            guard i < 2 else { throw TestError() }
            defer { i += 1 }
            return i
        }
        XCTAssertEqual(try cursor.next()!, 0)
        XCTAssertEqual(try cursor.next()!, 1)
        do {
            _ = try cursor.next()
            XCTFail()
        } catch is TestError {
        } catch {
            XCTFail()
        }
    }
    
    func testAnyCursorFromCursor() {
        var i = 0
        let base = IteratorCursor([0, 1])
        func makeAnyCursor<C: Cursor>(_ cursor: C) -> AnyCursor<Int> where C.Element == Int {
            return AnyCursor(cursor)
        }
        let cursor = makeAnyCursor(base)
        XCTAssertEqual(try cursor.next()!, 0)
        XCTAssertEqual(try cursor.next()!, 1)
        XCTAssertTrue(try cursor.next() == nil) // end
    }
    
    func testAnyCursorFromThrowingCursor() {
        var i = 0
        let base: AnyCursor<Int> = AnyCursor {
            guard i < 2 else { throw TestError() }
            defer { i += 1 }
            return i
        }
        func makeAnyCursor<C: Cursor>(_ cursor: C) -> AnyCursor<Int> where C.Element == Int {
            return AnyCursor(cursor)
        }
        let cursor = makeAnyCursor(base)
        XCTAssertEqual(try cursor.next()!, 0)
        XCTAssertEqual(try cursor.next()!, 1)
        do {
            _ = try cursor.next()
            XCTFail()
        } catch is TestError {
        } catch {
            XCTFail()
        }
    }
}
