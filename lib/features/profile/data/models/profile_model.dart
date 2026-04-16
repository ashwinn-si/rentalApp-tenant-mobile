class TenantProfile {
  const TenantProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.alternatePhone,
    required this.aadhaarMasked,
    required this.panMasked,
    required this.emergencyName,
    required this.emergencyRelation,
    required this.emergencyPhone,
  });

  final String name;
  final String email;
  final String phone;
  final String alternatePhone;
  final String aadhaarMasked;
  final String panMasked;
  final String emergencyName;
  final String emergencyRelation;
  final String emergencyPhone;

  factory TenantProfile.fromJson(Map<String, dynamic> json) {
    return TenantProfile(
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      alternatePhone: (json['alternatePhone'] ?? '').toString(),
      aadhaarMasked: (json['aadhaarMasked'] ?? '').toString(),
      panMasked: (json['panMasked'] ?? '').toString(),
      emergencyName: (json['emergencyContactName'] ?? '').toString(),
      emergencyRelation: (json['emergencyContactRelation'] ?? '').toString(),
      emergencyPhone:
          (json['emergencyPhone'] ?? json['emergencyContactPhone'] ?? '')
              .toString(),
    );
  }
}
