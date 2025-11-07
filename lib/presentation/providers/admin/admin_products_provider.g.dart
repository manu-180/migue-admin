// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_products_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminProductsRepositoryHash() =>
    r'10ab53f161fe3b033d530d94c3d7f551074ac49e';

/// See also [adminProductsRepository].
@ProviderFor(adminProductsRepository)
final adminProductsRepositoryProvider =
    Provider<AdminProductsRepository>.internal(
  adminProductsRepository,
  name: r'adminProductsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminProductsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminProductsRepositoryRef = ProviderRef<AdminProductsRepository>;
String _$adminProductsNotifierHash() =>
    r'1bd7cf6ff101c24a88704ae703a87e0381ad1de0';

/// See also [AdminProductsNotifier].
@ProviderFor(AdminProductsNotifier)
final adminProductsNotifierProvider = AutoDisposeAsyncNotifierProvider<
    AdminProductsNotifier, List<Product>>.internal(
  AdminProductsNotifier.new,
  name: r'adminProductsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminProductsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AdminProductsNotifier = AutoDisposeAsyncNotifier<List<Product>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
