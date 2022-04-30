//
//  Injectable.swift
//  InjectableDemo
//
//  Created by Michael Long on 04/30/22.
//

import Foundation

// Injectable property wrapper

@propertyWrapper public struct Injectable<Service> {
    private var service: Service
    public init(_ keyPath: KeyPath<Injections, Service>) {
        self.service = Injections.container.resolve(keyPath)
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
    private var keyPath: KeyPath<Injections, Service>?
    private var service: Service!
    public init(_ keyPath: KeyPath<Injections, Service>) {
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
        if let keyPath = keyPath {
            self.service = Injections.container.resolve(keyPath)
        }
    }
}

// add core container class for factories with registration and resolution mechanisms for overrides

public class Injections {

    // global injection container

    public static let container = Injections()

    // registration functions

    public func register<Service>(factory: @escaping () -> Service?) {
        defer { lock.unlock() }
        lock.lock()
        let id = Int(bitPattern: ObjectIdentifier(Service.self))
        registrations[id] = factory
    }

    // resolution fuctions

    public func resolve<Service>(_ keyPath: KeyPath<Injections, Service>) -> Service {
        defer { lock.unlock() }
        lock.lock()
        return registered() ?? Self.container[keyPath: keyPath]
    }

    public func optional<Service>(_ keyPath: KeyPath<Injections, Service>) -> Service? {
        defer { lock.unlock() }
        lock.lock()
        return registered() ?? Self.container[keyPath: keyPath]
    }

    // singleton scope where services exist for lifetime of the app
    public var application: InjectableScope = InjectableCacheScope()

    // cached scope where services exist until scope is reset
    public var cached: InjectableScope = InjectableCacheScope()

    // shared scope where services are maintained until last reference is released
    public var shared: InjectableScope = InjectableSharedScope()

    public func reset() {
        defer { lock.unlock() }
        lock.lock()
        registrations = [:]
    }

    // private

    private func registered<Service>() -> Service? {
        let id = Int(bitPattern: ObjectIdentifier(Service.self))
        return registrations[id]?() as? Service
    }

    private init() {}
    private var registrations: [Int:() -> Any] = [:]
    private var lock = NSRecursiveLock()

}

public protocol InjectableScope {
    func callAsFunction<S>(_ factory: @autoclosure () -> S) -> S
    func release<S>(_ type: S.Type)
    func reset()
}

class InjectableCacheScope: InjectableScope {
    func callAsFunction<S>(_ factory: @autoclosure () -> S) -> S {
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
    func release<S>(_ type: S.Type) {
        defer { lock.unlock() }
        lock.lock()
        let id = Int(bitPattern: ObjectIdentifier(type))
        cache.removeValue(forKey: id)
    }
    func reset() {
        defer { lock.unlock() }
        lock.lock()
        cache = [:]
    }
    fileprivate var cache = [Int:Any]()
    fileprivate var lock = NSRecursiveLock()
}

class InjectableSharedScope: InjectableScope {
    private struct WeakBox {
        weak var service: AnyObject?
    }
    func callAsFunction<S>(_ factory: @autoclosure () -> S) -> S {
        defer { lock.unlock() }
        lock.lock()
        let id = Int(bitPattern: ObjectIdentifier(S.self))
        if let service = cache[id]?.service as? S {
            return service
        }
        let service = factory()
        cache[id] = WeakBox(service: service as AnyObject)
        return service
    }
    func release<S>(_ type: S.Type) {
        defer { lock.unlock() }
        lock.lock()
        let id = Int(bitPattern: ObjectIdentifier(type))
        cache.removeValue(forKey: id)
    }
    func reset() {
        defer { lock.unlock() }
        lock.lock()
        cache = [:]
    }
    private var cache = [Int:WeakBox]()
    private var lock = NSRecursiveLock()
}
