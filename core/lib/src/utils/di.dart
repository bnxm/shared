import 'package:get_it/get_it.dart';

const DI di = DI._();

class DI {
  const DI._();
  static const DI instance = di;

  set allowReassignment(bool value) => GetIt.I.allowReassignment = value;

  /// Singleton.
  void put<T extends Object>(T dependency) => GetIt.I.registerSingleton<T>(dependency);

  /// Factory.
  void builder<T extends Object>(T Function() builder) =>
      GetIt.I.registerFactory(builder);

  /// Lazy singleton.
  void lazy<T extends Object>(T Function() builder) =>
      GetIt.I.registerLazySingleton<T>(builder);

  /// Async singleton.
  void putAsync<T extends Object>(Future<T> Function() builder) =>
      GetIt.I.registerSingletonAsync(builder);

  T call<T>() => find<T>();
  T find<T>() => GetIt.I<T>();
}
