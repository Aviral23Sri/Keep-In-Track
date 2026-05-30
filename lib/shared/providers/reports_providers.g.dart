// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reports_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$reportDataHash() => r'f37eb6821923717b3498058985f960826dde7dc1';

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

/// See also [reportData].
@ProviderFor(reportData)
const reportDataProvider = ReportDataFamily();

/// See also [reportData].
class ReportDataFamily extends Family<AsyncValue<ReportData>> {
  /// See also [reportData].
  const ReportDataFamily();

  /// See also [reportData].
  ReportDataProvider call(
    ReportPeriod period,
  ) {
    return ReportDataProvider(
      period,
    );
  }

  @override
  ReportDataProvider getProviderOverride(
    covariant ReportDataProvider provider,
  ) {
    return call(
      provider.period,
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
  String? get name => r'reportDataProvider';
}

/// See also [reportData].
class ReportDataProvider extends AutoDisposeFutureProvider<ReportData> {
  /// See also [reportData].
  ReportDataProvider(
    ReportPeriod period,
  ) : this._internal(
          (ref) => reportData(
            ref as ReportDataRef,
            period,
          ),
          from: reportDataProvider,
          name: r'reportDataProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$reportDataHash,
          dependencies: ReportDataFamily._dependencies,
          allTransitiveDependencies:
              ReportDataFamily._allTransitiveDependencies,
          period: period,
        );

  ReportDataProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.period,
  }) : super.internal();

  final ReportPeriod period;

  @override
  Override overrideWith(
    FutureOr<ReportData> Function(ReportDataRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ReportDataProvider._internal(
        (ref) => create(ref as ReportDataRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        period: period,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ReportData> createElement() {
    return _ReportDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReportDataProvider && other.period == period;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, period.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ReportDataRef on AutoDisposeFutureProviderRef<ReportData> {
  /// The parameter `period` of this provider.
  ReportPeriod get period;
}

class _ReportDataProviderElement
    extends AutoDisposeFutureProviderElement<ReportData> with ReportDataRef {
  _ReportDataProviderElement(super.provider);

  @override
  ReportPeriod get period => (origin as ReportDataProvider).period;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
