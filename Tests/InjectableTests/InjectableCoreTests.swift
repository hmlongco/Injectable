import XCTest
@testable import Injectable


final class InjectableCoreTests: XCTestCase {

    override func setUp() {
        super.setUp()
        sharedContainer.reset()
    }

    func testBasicInjection() throws {
        let services = Services()
        XCTAssertTrue(services.service.text() == "MyService")
    }

    func testMockInjection() throws {
        let services = Services()
        XCTAssertTrue(services.mock.text() == "MockService")
    }

    func testBasicResolution() throws {
        let service1 = sharedContainer.resolve(\.myService)
        XCTAssertTrue(service1.text() == "MyService")
        let service2 = sharedContainer.resolve(\.mockService)
        XCTAssertTrue(service2.text() == "MockService")
    }

    func testBasicResolutionOverride() throws {
        let service1 = sharedContainer.resolve(\.myService)
        XCTAssertTrue(service1.text() == "MyService")
        sharedContainer.register(factory: { MockService() as MyServiceType })
        let service2 = sharedContainer.resolve(\.myService)
        XCTAssertTrue(service2.text() == "MockService")
    }

    func testBasicResolutionOverrideReset() throws {
        sharedContainer.register(factory: { MockService() as MyServiceType })
        let service1 = sharedContainer.resolve(\.myService)
        XCTAssertTrue(service1.text() == "MockService")
        sharedContainer.reset()
        let service2 = sharedContainer.resolve(\.myService)
        XCTAssertTrue(service2.text() == "MyService")
    }

}
