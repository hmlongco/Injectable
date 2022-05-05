# Injectable
A new approach to Dependency Injection for Swift and SwiftUI.

## Why do something new?

Resolver was my first Dependency Injection system. While quite powerful and still in use in many of my applications, Resolver suffers from a few drawbacks.

1. Resolver requires pre-registration of all service factories up front. 
2. Resolver uses type inference to dynamically find and return registered services in a container.

The first issue can lead to a performance hit on application launch. That said, the registration process is usually quick and not normally noticable. No, it's the second issue that's somewhat more problematic. 

 Failure to find a matching type *could* lead to an application crash if we attempt to resolve a given type and if a matching registration is not found. In practice we've found that this isn't really a problem as it tends to be noticed and fixed rather quickly the very first time you run a unit test or when you run the application to see if your newest feature works.
 
 But... could we do better? That question lead me on a quest for compile-time type safety. Several other systems have attempted to solve this, but I didn't want to have to add a source code scanning and generation step to my build process, nor did I want to give up a lot of the control and flexibility inherent in a run-time-based system.
 
 Could I have my cake and eat it too?
 
 ## Features
 
 Injectable is strongly influenced by SwiftUI, and in my opinion is highly suited for use in that environment. Injectable is...
 
 * **Safe:** Injectable is compile-time safe; a dependency for a given type *must* exist or the code simply will not compile.
 * **Flexible:** It's easy to override dependencies at runtime and for use in SwiftUI Previews. And, like Resolver, Injectable supports application, cached, shared, and custom scopes.
 * **Lightweight:** Injectable is slim and trim, coming in just under a mere 200 lines of code.
 * **Performant:** Little to no setup time is needed for the vast majority of your servies, resolutions are extremely fast, and no compile-time scripts or build phases are needed.
 * **Concise:** Defining a given registration usually takes but a single line of code.
 
 Sound too good to be true? Let's take a look.
 
 ## A simple example
 
 Most container-based dependency injection systems require you to define in some way that a given service type is injectable and many reqire some sort of factory or mechanism that will provide a new instance of the service when needed.
 
 Injectable is no exception. Here's a simple registraion and its associated factory.
 
```
extension Injections {
    var myService: MySimpleService { MySimpleService() }
}
```
Unlike Resolver which requires a plethora of registration functions, in Injectable you simple define a computed variable on `Injections` that returns an instance of your service. That's it.

Injecting and using the service where needed is equally straightforward.

```
class ContentViewModel: ObservableObject {
    @Injectable(\.myService) var service
    ...
}
```
Here our view model uses an `@Injectable` property wrapper to request the desired dependency. Like `@EnvironmentObject` in SwiftUI, you simply provide the property wrapper with a keypath to the desired type and it handles the rest.

And that's the core mechanism. In order to use the property wrapper you *must* provide the keypath. That keypath points to an factory that *must* return the desired type. Fail to do either one and the code will simply not compile. It's compile-time safe.
