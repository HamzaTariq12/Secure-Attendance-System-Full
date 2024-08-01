class User {
  int studentID;
  String status;
  int Date;

  User({required this.studentID, required this.status, required this.Date});

  static List<User> getUsers() {
    return <User>[
      User(studentID: 1, Date: 23 - 11 - 2024, status: "present"),
      User(studentID: 2, Date: 24 - 11 - 2024, status: "present"),
      User(studentID: 3, Date: 18 - 10 - 2024, status: "present"),
      User(studentID: 4, Date: 17 - 10 - 2024, status: "present"),
      User(studentID: 5, Date: 19 - 12 - 2024, status: "present"),
      User(studentID: 6, Date: 09 - 09 - 2024, status: "present"),
      User(studentID: 7, Date: 04 - 08 - 2024, status: "present"),
      User(studentID: 9, Date: 21 - 05 - 2024, status: "present"),
      User(studentID: 10, Date: 21 - 05 - 2024, status: "present"),
      User(studentID: 11, Date: 21 - 05 - 2024, status: "present"),
      User(studentID: 12, Date: 21 - 05 - 2024, status: "present"),
      User(studentID: 13, Date: 21 - 05 - 2024, status: "present"),
      User(studentID: 14, Date: 21 - 05 - 2024, status: "present"),
      User(studentID: 15, Date: 21 - 05 - 2024, status: "present"),
      User(studentID: 16, Date: 21 - 05 - 2024, status: "present"),
      User(studentID: 17, Date: 21 - 05 - 2024, status: "present"),
      User(studentID: 18, Date: 21 - 05 - 2024, status: "present"),
      User(studentID: 19, Date: 21 - 05 - 2024, status: "present"),
      User(studentID: 20, Date: 21 - 05 - 2024, status: "present"),
      User(studentID: 21, Date: 21 - 05 - 2024, status: "present"),
    ];
  }
}
