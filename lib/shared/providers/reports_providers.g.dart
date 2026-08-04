// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reports_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$reportDataHash() => r'6e0ddccae68a5fcc0fe1445548ba119a403a2423';

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
    ReportFilter filter,
  ) {
    return ReportDataProvider(
      filter,
    );
  }

  @override
  ReportDataProvider getProviderOverride(
    covariant ReportDataProvider provider,
  ) {
    return call(
      provider.filter,
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
    ReportFilter filter,
  ) : this._internal(
          (ref) => reportData(
            ref as ReportDataRef,
            filter,
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
          filter: filter,
        );

  ReportDataProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.filter,
  }) : super.internal();

  final ReportFilter filter;

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
        filter: filter,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ReportData> createElement() {
    return _ReportDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReportDataProvider && other.filter == filter;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, filter.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ReportDataRef on AutoDisposeFutureProviderRef<ReportData> {
  /// The parameter `filter` of this provider.
  ReportFilter get filter;
}

class _ReportDataProviderElement
    extends AutoDisposeFutureProviderElement<ReportData> with ReportDataRef {
  _ReportDataProviderElement(super.provider);

  @override
  ReportFilter get filter => (origin as ReportDataProvider).filter;
}

String _$momComparisonHash() => r'992019a8e385a1856e940a679b49189fa20ef499';

/// See also [momComparison].
@ProviderFor(momComparison)
const momComparisonProvider = MomComparisonFamily();

/// See also [momComparison].
class MomComparisonFamily extends Family<AsyncValue<MoMComparison>> {
  /// See also [momComparison].
  const MomComparisonFamily();

  /// See also [momComparison].
  MomComparisonProvider call(
    DateTime selectedMonth,
  ) {
    return MomComparisonProvider(
      selectedMonth,
    );
  }

  @override
  MomComparisonProvider getProviderOverride(
    covariant MomComparisonProvider provider,
  ) {
    return call(
      provider.selectedMonth,
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
  String? get name => r'momComparisonProvider';
}

/// See also [momComparison].
class MomComparisonProvider extends AutoDisposeFutureProvider<MoMComparison> {
  /// See also [momComparison].
  MomComparisonProvider(
    DateTime selectedMonth,
  ) : this._internal(
          (ref) => momComparison(
            ref as MomComparisonRef,
            selectedMonth,
          ),
          from: momComparisonProvider,
          name: r'momComparisonProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$momComparisonHash,
          dependencies: MomComparisonFamily._dependencies,
          allTransitiveDependencies:
              MomComparisonFamily._allTransitiveDependencies,
          selectedMonth: selectedMonth,
        );

  MomComparisonProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.selectedMonth,
  }) : super.internal();

  final DateTime selectedMonth;

  @override
  Override overrideWith(
    FutureOr<MoMComparison> Function(MomComparisonRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MomComparisonProvider._internal(
        (ref) => create(ref as MomComparisonRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        selectedMonth: selectedMonth,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<MoMComparison> createElement() {
    return _MomComparisonProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MomComparisonProvider &&
        other.selectedMonth == selectedMonth;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, selectedMonth.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MomComparisonRef on AutoDisposeFutureProviderRef<MoMComparison> {
  /// The parameter `selectedMonth` of this provider.
  DateTime get selectedMonth;
}

class _MomComparisonProviderElement
    extends AutoDisposeFutureProviderElement<MoMComparison>
    with MomComparisonRef {
  _MomComparisonProviderElement(super.provider);

  @override
  DateTime get selectedMonth => (origin as MomComparisonProvider).selectedMonth;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
