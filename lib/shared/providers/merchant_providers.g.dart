// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'merchant_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$merchantRepositoryHash() =>
    r'022a079c08128dbbd041a75f0a433a6d7b87ec7c';

/// See also [merchantRepository].
@ProviderFor(merchantRepository)
final merchantRepositoryProvider = Provider<MerchantRepository>.internal(
  merchantRepository,
  name: r'merchantRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$merchantRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MerchantRepositoryRef = ProviderRef<MerchantRepository>;
String _$searchMerchantsHash() => r'e2fc4d56214422d15cf0ed7b34a81a4ab4588d25';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [searchMerchants].
@ProviderFor(searchMerchants)
const searchMerchantsProvider = SearchMerchantsFamily();

/// See also [searchMerchants].
class SearchMerchantsFamily extends Family<AsyncValue<List<MerchantModel>>> {
  /// See also [searchMerchants].
  const SearchMerchantsFamily();

  /// See also [searchMerchants].
  SearchMerchantsProvider call(
    String query,
  ) {
    return SearchMerchantsProvider(
      query,
    );
  }

  @override
  SearchMerchantsProvider getProviderOverride(
    covariant SearchMerchantsProvider provider,
  ) {
    return call(
      provider.query,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'searchMerchantsProvider';
}

/// See also [searchMerchants].
class SearchMerchantsProvider
    extends AutoDisposeFutureProvider<List<MerchantModel>> {
  /// See also [searchMerchants].
  SearchMerchantsProvider(
    String query,
  ) : this._internal(
          (ref) => searchMerchants(
            ref as SearchMerchantsRef,
            query,
          ),
          from: searchMerchantsProvider,
          name: r'searchMerchantsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$searchMerchantsHash,
          dependencies: SearchMerchantsFamily._dependencies,
          allTransitiveDependencies:
              SearchMerchantsFamily._allTransitiveDependencies,
          query: query,
        );

  SearchMerchantsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  Override overrideWith(
    FutureOr<List<MerchantModel>> Function(SearchMerchantsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SearchMerchantsProvider._internal(
        (ref) => create(ref as SearchMerchantsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<MerchantModel>> createElement() {
    return _SearchMerchantsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchMerchantsProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SearchMerchantsRef on AutoDisposeFutureProviderRef<List<MerchantModel>> {
  /// The parameter `query` of this provider.
  String get query;
}

class _SearchMerchantsProviderElement
    extends AutoDisposeFutureProviderElement<List<MerchantModel>>
    with SearchMerchantsRef {
  _SearchMerchantsProviderElement(super.provider);

  @override
  String get query => (origin as SearchMerchantsProvider).query;
}

String _$merchantsControllerHash() =>
    r'72cc891a4a4eed10cc06546767e61e61f8d558bf';

/// See also [MerchantsController].
@ProviderFor(MerchantsController)
final merchantsControllerProvider = AutoDisposeAsyncNotifierProvider<
    MerchantsController, List<MerchantModel>>.internal(
  MerchantsController.new,
  name: r'merchantsControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$merchantsControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MerchantsController = AutoDisposeAsyncNotifier<List<MerchantModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
