part of 'notifications_cubit.dart';

// NOT USED but useful example
class NotificationsCubitState extends Equatable {
  final bool showNotification;

  const NotificationsCubitState({
    this.showNotification = false,
  });

  NotificationsCubitState copyWith({bool? showNotification}) {
    return NotificationsCubitState(showNotification: showNotification ?? this.showNotification);
  }

  @override
  List<Object?> get props => [showNotification];
}
