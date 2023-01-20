enum NextTaskNotificationsModel {
  a(1, "1 minute before the task starts"),
  b(2, "2 minutes before the task starts"),
  c(3, "3 minutes before the task starts"),
  d(5, "5 minutes before the task starts"),
  e(10, "10 minutes before the task starts");

  const NextTaskNotificationsModel(this.minutesBeforeToStart, this.title);
  final int minutesBeforeToStart;
  final String title;
}
