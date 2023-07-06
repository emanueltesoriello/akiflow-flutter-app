enum NextEventNotificationsModel {
  a(1, "1 minute before the event starts"),
  b(2, "2 minutes before the event starts"),
  c(3, "3 minutes before the event starts"),
  d(5, "5 minutes before the event starts"),
  e(10, "10 minutes before the event starts");

  const NextEventNotificationsModel(this.minutesBeforeToStart, this.title);
  final int minutesBeforeToStart;
  final String title;

  static Map<String, dynamic> toMap(NextEventNotificationsModel model) {
    return {"minutesBeforeToStart": model.minutesBeforeToStart, "title": model.title};
  }

  static NextEventNotificationsModel fromMap(Map<String, dynamic> map) {
    switch (map["minutesBeforeToStart"]) {
      case 1:
        return a;
      case 2:
        return b;
      case 3:
        return c;
      case 5:
        return d;
      case 10:
        return e;
      default:
        return d;
    }
  }
}
