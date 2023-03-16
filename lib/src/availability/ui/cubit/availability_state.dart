part of 'availability_cubit.dart';

class AvailabilityCubitState extends Equatable {
  final AvailabilityNavigationState navigationState;
  final bool isManualOpen;
  final bool isRecurrentOpen;
  final List<AvailabilityConfig>? availabilities;

  const AvailabilityCubitState({
    this.navigationState = AvailabilityNavigationState.loading,
    this.availabilities,
    this.isManualOpen = true,
    this.isRecurrentOpen = true,
  });

  AvailabilityCubitState copyWith({
    AvailabilityNavigationState? navigationState,
    List<AvailabilityConfig>? availabilities,
    bool? isManualOpen,
    bool? isRecurrentOpen,
  }) {
    return AvailabilityCubitState(
      navigationState: navigationState ?? this.navigationState,
      availabilities: availabilities ?? this.availabilities,
      isManualOpen: isManualOpen ?? this.isManualOpen,
      isRecurrentOpen: isRecurrentOpen ?? this.isRecurrentOpen,
    );
  }

  @override
  List<Object?> get props => [navigationState, availabilities, isManualOpen, isRecurrentOpen];
}
