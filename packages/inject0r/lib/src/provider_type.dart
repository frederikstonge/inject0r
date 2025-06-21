/// Defines the type of provider for dependency injection.
/// - `singleton`: A single instance is created and reused.
/// - `scoped`: An instance is created per scope, typically per request or per widget tree.
/// - `transient`: A new instance is created every time it is requested.
enum ProviderType { singleton, scoped, transient }
