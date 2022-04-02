class UserRecord {
  final String type;
  final String name;
  final String user;
  final String address;
  final String university;

  UserRecord({
    required this.type,
    required this.name,
    required this.user,
    required this.address,
    required this.university,
  });

  Map<String, dynamic> get toJson => {
        "type": type,
        "name": name,
        "user": user,
        "address": address,
        "university": university,
      };
}
