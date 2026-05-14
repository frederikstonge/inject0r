<p align="center">
  <h1 align="center">💉 inject0r</h1>
  <p align="center">
    <strong>A lightweight dependency injection library for Flutter & Jaspr</strong>
  </p>
  <p align="center">
    🎯 Type-safe &nbsp;•&nbsp; 🧹 Auto-disposal &nbsp;•&nbsp; 🧱 Scoped lifetimes &nbsp;•&nbsp; 🧩 Bloc compatible
  </p>
</p>

---

## ✨ Features

- 🔄 **Three lifetime strategies** — Singleton, Scoped, and Transient
- 🌳 **Hierarchical scoping** — Parent-child scope inheritance with smart delegation
- 🧹 **Automatic cleanup** — Instances are disposed when their scope is destroyed
- 🏷️ **Keyed registrations** — Register multiple instances of the same type
- 📱 **Flutter support** — `ContainerScope` widget with `BuildContext` extensions
- 🌐 **Jaspr support** — First-class Jaspr integration with identical API
- 🧊 **Bloc integration** — `BlocBuilder`, `BlocListener`, and `BlocConsumer` out of the box
- 🪶 **Zero boilerplate** — No code generation, no annotations

---

## 📦 Packages

| Package | Description | Version |
|---------|-------------|---------|
| [`inject0r`](packages/inject0r) | 🏗️ Core DI primitives | `0.0.1` |
| [`flutter_inject0r`](packages/flutter_inject0r) | 📱 Flutter widget integration | `0.0.1` |
| [`jaspr_inject0r`](packages/jaspr_inject0r) | 🌐 Jaspr component integration | `0.0.1` |
| [`flutter_inject0r_bloc`](packages/flutter_inject0r_bloc) | 🧊 Bloc support for Flutter | `0.0.1` |
| [`jaspr_inject0r_bloc`](packages/jaspr_inject0r_bloc) | 🧊 Bloc support for Jaspr | `0.0.1` |

---

## 🚀 Quick Start

### 1️⃣ Register your dependencies

```dart
final serviceProvider = ServiceProvider<BuildContext>();

serviceProvider.registerSingleton<ApiClient>(
  create: (context) => ApiClient(),
  dispose: (client) => client.close(),
);

serviceProvider.registerScoped<CounterCubit>(
  create: (context) => CounterCubit(),
  dispose: (cubit) => cubit.close(),
);

serviceProvider.registerTransient<Logger>(
  create: (context) => Logger(),
);
```

### 2️⃣ Wrap your app with `ContainerScope`

```dart
runApp(
  ContainerScope.primary(
    serviceProvider: serviceProvider,
    child: const MyApp(),
  ),
);
```

### 3️⃣ Resolve anywhere with `BuildContext`

```dart
final api = context.get<ApiClient>();
final cubit = context.get<CounterCubit>();
```

That's it! 🎉

---

## 🔄 Lifetime Strategies

| Strategy | Emoji | Behavior |
|----------|-------|----------|
| **Singleton** | 🔒 | One instance for the entire app lifetime |
| **Scoped** | 🏠 | One instance per scope — disposed when the scope is removed from the tree |
| **Transient** | 🆕 | A fresh instance every time you call `get<T>()` |

---

## 🌳 Scoped Containers

Create child scopes to isolate dependencies per page, route, or feature:

```dart
ContainerScope.createScope(
  context: context,
  child: const MyPage(),
  serviceProvider: ServiceProvider<BuildContext>()
    ..registerScoped<PageCubit>(
      create: (context) => PageCubit(),
      dispose: (cubit) => cubit.close(),
    ),
);
```

> 🧹 When the scope leaves the widget tree, all scoped and transient instances are **automatically disposed**.

---

## 🏷️ Keyed Registrations

Register multiple instances of the same type using keys:

```dart
serviceProvider.registerScoped<CounterCubit>(
  key: 'page',
  create: (context) => CounterCubit(),
  dispose: (cubit) => cubit.close(),
);

serviceProvider.registerScoped<CounterCubit>(
  key: 'modal',
  create: (context) => CounterCubit(),
  dispose: (cubit) => cubit.close(),
);
```

```dart
final pageCubit = context.get<CounterCubit>(key: 'page');
final modalCubit = context.get<CounterCubit>(key: 'modal');
```

---

## 🧊 Bloc Integration

No need for `flutter_bloc`'s `BlocProvider` — resolve blocs directly from the container!

### BlocBuilder

```dart
BlocBuilder<CounterCubit, int>(
  builder: (context, state) => Text('Count: $state'),
  rebuildWhen: (previous, current) => current != previous,
);
```

### BlocListener

```dart
BlocListener<CounterCubit, int>(
  listener: (context, state) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text('Count: $state'))),
  child: const MyWidget(),
);
```

### BlocConsumer

```dart
BlocConsumer<CounterCubit, int>(
  listener: (context, state) => print('State changed: $state'),
  builder: (context, state) => Text('$state'),
);
```

> 💡 Use `blocKey` to target a specific keyed registration:
> ```dart
> BlocBuilder<CounterCubit, int>(
>   blocKey: 'page',
>   builder: (context, state) => Text('$state'),
> );
> ```

---

## 🌐 Jaspr Support

The API is **identical** to Flutter — just swap widgets for components:

```dart
ContainerScope.primary(
  serviceProvider: serviceProvider,
  child: App(), // Jaspr Component
);
```

```dart
final service = context.get<MyService>();
```

All the same lifetime strategies, scoping, bloc integration, and auto-disposal work exactly the same. ✅

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────┐
│          ContainerScope.primary 🔒           │
│  ┌────────────────────────────────────────┐  │
│  │  Singletons    → shared across tree    │  │
│  │  Transients    → new every time        │  │
│  └────────────────────────────────────────┘  │
│                                               │
│  ┌──────────────────┐ ┌──────────────────┐   │
│  │  Scope A 🏠      │ │  Scope B 🏠      │   │
│  │  Scoped instances│ │  Scoped instances│   │
│  │  + Transients    │ │  + Transients    │   │
│  │  ↑ Singletons   │ │  ↑ Singletons   │   │
│  │    from root     │ │    from root     │   │
│  └──────────────────┘ └──────────────────┘   │
└─────────────────────────────────────────────┘
```

---

## 📄 License

See the [LICENSE](packages/inject0r/LICENSE) file for details.
