class ProfileData {
  UserProfile? userProfile;

  ProfileData({this.userProfile});

  ProfileData.fromJson(Map<String, dynamic> json) {
    userProfile = json['User Profile'] != null
        ? UserProfile.fromJson(json['User Profile'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.userProfile != null) {
      data['User Profile'] = this.userProfile!.toJson();
    }
    return data;
  }
}

class UserProfile {
  int? id;
  String? email;
  String? firstName;
  String? lastName;
  String? rollNo;
  String? profilePicture;
  String? createdAt;
  String? updatedAt;

  UserProfile(
      {this.id,
      this.email,
      this.firstName,
      this.lastName,
      this.rollNo,
      this.profilePicture,
      this.createdAt,
      this.updatedAt});

  UserProfile.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    rollNo = json['roll_no'];
    profilePicture = json['profile_picture'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['email'] = this.email;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['roll_no'] = this.rollNo;
    data['profile_picture'] = this.profilePicture;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
