## Features

Another dependency injection package for Flutter. Based on Microsoft's AspNetCore dependency injection, define your singleton/scoped/transient providers in `ServiceProvider`. 

In AspNetCore, each request is a scope, but you can also create your own scope. in the example project, I wrote an implementation with `go_router` by creating a `ScopedGoRoute`, to turn each GoRoute into its own scope. This allows you to have scoped bloc injected and disposed by navigating to a page.