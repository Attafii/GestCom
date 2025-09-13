// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'treatment_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$treatmentRepositoryHash() =>
    r'24525e57f5ab0992b3b83cd2cbd28c96ac65d8d5';

/// See also [treatmentRepository].
@ProviderFor(treatmentRepository)
final treatmentRepositoryProvider =
    AutoDisposeProvider<TreatmentRepository>.internal(
  treatmentRepository,
  name: r'treatmentRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$treatmentRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TreatmentRepositoryRef = AutoDisposeProviderRef<TreatmentRepository>;
String _$activeTreatmentsHash() => r'b3b1f74ff5e5f15acbb338b530db7b4c742ee515';

/// See also [activeTreatments].
@ProviderFor(activeTreatments)
final activeTreatmentsProvider = AutoDisposeProvider<List<Treatment>>.internal(
  activeTreatments,
  name: r'activeTreatmentsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeTreatmentsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ActiveTreatmentsRef = AutoDisposeProviderRef<List<Treatment>>;
String _$treatmentListHash() => r'5991e1c47c649a5bc694fe04a2ba182ae3668138';

/// See also [TreatmentList].
@ProviderFor(TreatmentList)
final treatmentListProvider =
    AutoDisposeNotifierProvider<TreatmentList, List<Treatment>>.internal(
  TreatmentList.new,
  name: r'treatmentListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$treatmentListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TreatmentList = AutoDisposeNotifier<List<Treatment>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
