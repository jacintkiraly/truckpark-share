import 'package:equatable/equatable.dart';

class ParkingSource extends Equatable {
  const ParkingSource({
    required this.provider,
    this.sourceId,
    this.dataset,
    this.datasetVersion,
    this.sourceType,
  });

  final String provider;
  final String? sourceId;
  final String? dataset;
  final String? datasetVersion;
  final String? sourceType;

  @override
  List<Object?> get props => [
        provider,
        sourceId,
        dataset,
        datasetVersion,
        sourceType,
      ];
}
