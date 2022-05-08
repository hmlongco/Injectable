//
//  Injectable.swift
//  InjectableDemo
//
//  Created by Michael Long on 04/30/22.
//

import Foundation

// Injectable property wrappers

@propertyWrapper public struct Injectable<Service> {
    private var service: Service
    public init(_ keyPath: KeyPath<Injections, Service>) {
        self.service = sharedContainer.resolve(keyPath)
    }
    public init(container: Injections, _ keyPath: KeyPath<Injections, Service>) {
        self.service = container.resolve(keyPath)
    }
    public var wrappedValue: Service {
        get { return service }
        mutating set { service = newValue }
    }
    public var projectedValue: Injectable<Service> {
        get { return self }
        mutating set { self = newValue }
    }
}

@propertyWrapper public struct LazyInjectable<Service> {
    private var container: Injections
    private var keyPath: KeyPath<Injections, Service>
    private var service: Service!
    public init(_ keyPath: KeyPath<Injections, Service>) {
        self.container = sharedContainer
        self.keyPath = keyPath
    }
    public init(container: Injections, _ keyPath: KeyPath<Injections, Service>) {
        self.container = container
        self.keyPath = keyPath
    }
    public var wrappedValue: Service {
        mutating get {
            resolve()
            return service
        }
        mutating set {
            service = newValue
        }
    }
    public var projectedValue: LazyInjectable<Service> {
        mutating get {
            resolve()
            return self
        }
        mutating set {
            self = newValue
        }
    }
    private mutating func resolve() {
        guard service == nil else {
            return
        }
        self.service = container.resolve(keyPath)
    }
}

// global shared defaults

public var sharedContainer: Injections = InjectableContainer()
public var sharedApplicationScope: InjectableScope = InjectableCacheScope()

// injectable container protocol

public protocol Injections {
    // registration / resolution functions
    func register<Service>(factory: @escaping () -> Service?)
    func resolve<Service>(_ keyPath: KeyPath<Injections, Service>) -> Service
    func optional<Service>(_ keyPath: KeyPath<Injections, Service>) -> Service?

    // experimental functional resolution
    func registered<Service>(_ factory:  @autoclosure () -> Service) -> Service

    // scopes
    var application: InjectableScope { get }
    var cached: InjectableScope { get }
    var shared: InjectableScope { get }

    // management
    func reset()
}

// add core container class for factories with registration and resolution mechanisms for overrides

public class InjectableContainer: Injections {

    // lifecycle

    public init() {}

    // registration

    /// Registers a factory that will be used to override a specific injection of the same type.
    /// Usefull for mocking and altering the default behavior of the system at runtime.
    ///
    /// - Parameter factory: Factory closure used to create an instance of a service.
    public func register<Service>(factory: @escaping () -> Service?) {
        defer { lock.unlock() }
        lock.lock()
        let id = Int(bitPattern: ObjectIdentifier(Service.self))
        registrations[id] = factory
    }

    /// Returns a registered service of that type or calls the factory to create a new instance of that type.
    ///
    /// - Parameter keyPath: Keypath of the service to resolve
    /// - Returns the requested service from the keypath or from a registration override.
    public func registered<Service>(_ factory:  @autoclosure () -> Service) -> Service {
        defer { lock.unlock() }
        lock.lock()
        let id = Int(bitPattern: ObjectIdentifier(Service.self))
        return registrations[id]?() as? Service ?? factory()
    }

    // resolution

    /// Resolves a service based on the keypath provided. Since the keypath must exist and since the types must match, this function is
    /// compile-time safe.
    ///
    /// - Parameter keyPath: Keypath of the service to resolve
    /// - Returns the requested service from the keypath or from a registration override.
    public func resolve<Service>(_ keyPath: KeyPath<Injections, Service>) -> Service {
        defer { lock.unlock() }
        lock.lock()
        let id = Int(bitPattern: ObjectIdentifier(Service.self))
        return registrations[id]?() as? Service ?? self[keyPath: keyPath]
    }

    /// Resolves a service based on the keypath provided. Since the keypath must exist and since the types must match, this function is
    /// compile-time safe.
    ///
    /// Note that while it's possible to register a factory that returns nil, the primary purpose of this function is to allow for the correct
    /// type inference on parameters or variables of an optional type.
    ///
    /// - Parameter keyPath: Keypath of the service to resolve
    /// - Returns the requested service from the keypath or from a registration override.
    public func optional<Service>(_ keyPath: KeyPath<Injections, Service>) -> Service? {
        defer { lock.unlock() }
        lock.lock()
        let id = Int(bitPattern: ObjectIdentifier(Service.self))
        return registrations[id]?() as? Service ?? self[keyPath: keyPath]
    }

    /// singleton scope where services exist for lifetime of the app
    public var application: InjectableScope { sharedApplicationScope }

    /// cached scope where services exist until scope is reset
    public var cached: InjectableScope = InjectableCacheScope()

    /// shared scope where services are maintained until last reference is released
    public var shared: InjectableScope = InjectableSharedScope()

    public func reset() {
        defer { lock.unlock() }
        lock.lock()
        registrations = [:]
    }

    // private

    private var registrations: [Int:() -> Any] = [:]
    private var lock = NSRecursiveLock()

}

public protocol InjectableScope {
    func callAsFunction<S>(_ factory: @autoclosure () -> S) -> S
    func release<S>(_ type: S.Type)
    func reset()
}

///
public class InjectableCacheScope: InjectableScope {
    public init() {}
    public func callAsFunction<S>(_ factory: @autoclosure () -> S) -> S {
        defer { lock.unlock() }
        lock.lock()
        let id = Int(bitPattern: ObjectIdentifier(S.self))
        if let service = cache[id] as? S {
            return service
        }
        let service = factory()
        cache[id] = service
        return service
    }
    public func release<S>(_ type: S.Type) {
        defer { lock.unlock() }
        lock.lock()
        let id = Int(bitPattern: ObjectIdentifier(type))
        cache.removeValue(forKey: id)
    }
    public func reset() {
        defer { lock.unlock() }
        lock.lock()
        cache = [:]
    }
    fileprivate var cache = [Int:Any]()
    fileprivate var lock = NSRecursiveLock()
}

///
public class InjectableSharedScope: InjectableCacheScope {
    private struct WeakBox {
        weak var service: AnyObject?
    }
    override public func callAsFunction<S>(_ factory: @autoclosure () -> S) -> S {
        defer { lock.unlock() }
        lock.lock()
        let id = Int(bitPattern: ObjectIdentifier(S.self))
        if let service = (cache[id] as? WeakBox)?.service as? S {
            return service
        }
        let service = factory()
        cache[id] = WeakBox(service: service as AnyObject)
        return service
    }
}
