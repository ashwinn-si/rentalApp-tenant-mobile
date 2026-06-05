class FlatDetails {
  final String flatNumber;
  final String floor;
  final String type;
  final double baseRent;
  final ApartmentInfo apartment;
  final String moveInDate;
  final double advancePaid;
  final bool isOnLease;
  final double leaseAmount;

  FlatDetails({
    required this.flatNumber,
    required this.floor,
    required this.type,
    required this.baseRent,
    required this.apartment,
    required this.moveInDate,
    required this.advancePaid,
    required this.isOnLease,
    required this.leaseAmount,
  });

  factory FlatDetails.fromJson(Map<String, dynamic> json) {
    final floor = json['floor'];
    return FlatDetails(
      flatNumber: json['flatNumber'] as String? ?? 'N/A',
      floor: floor is int ? floor.toString() : (floor as String? ?? 'N/A'),
      type: json['type'] as String? ?? 'N/A',
      baseRent: (json['baseRent'] as num?)?.toDouble() ?? 0.0,
      apartment: ApartmentInfo.fromJson(
        (json['apartment'] as Map<String, dynamic>?) ?? {},
      ),
      moveInDate: json['moveInDate'] as String? ?? '',
      advancePaid: (json['advancePaid'] as num?)?.toDouble() ?? 0.0,
      isOnLease: json['isOnLease'] as bool? ?? false,
      leaseAmount: (json['leaseAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ApartmentInfo {
  final String name;
  final String address;
  final String city;
  final String state;
  final String pincode;

  ApartmentInfo({
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
  });

  factory ApartmentInfo.fromJson(Map<String, dynamic> json) {
    return ApartmentInfo(
      name: json['name'] as String? ?? 'N/A',
      address: json['address'] as String? ?? 'N/A',
      city: json['city'] as String? ?? 'N/A',
      state: json['state'] as String? ?? 'N/A',
      pincode: json['pincode'] as String? ?? 'N/A',
    );
  }
}

class AvailableFlat {
  final String flatId;
  final String apartmentId;
  final String flatNumber;
  final String apartmentName;
  final String label;
  final bool isOnLease;
  final double leaseAmount;

  AvailableFlat({
    required this.flatId,
    required this.apartmentId,
    required this.flatNumber,
    required this.apartmentName,
    required this.label,
    required this.isOnLease,
    required this.leaseAmount,
  });

  factory AvailableFlat.fromJson(Map<String, dynamic> json) {
    final leaseInfo = json['leaseInfo'] as Map<String, dynamic>? ?? {};
    return AvailableFlat(
      flatId: json['flatId'] as String? ?? '',
      apartmentId: json['apartmentId'] as String? ?? '',
      flatNumber: json['flatNumber'] as String? ?? '',
      apartmentName: json['apartmentName'] as String? ?? '',
      label: json['label'] as String? ?? '',
      isOnLease: leaseInfo['isOnLease'] as bool? ?? false,
      leaseAmount: (leaseInfo['leaseAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class FlatDetailsResponse {
  final String? activeFlatId;
  final List<AvailableFlat> availableFlats;
  final FlatDetails? details;

  FlatDetailsResponse({
    required this.activeFlatId,
    required this.availableFlats,
    required this.details,
  });

  factory FlatDetailsResponse.fromJson(Map<String, dynamic> json) {
    return FlatDetailsResponse(
      activeFlatId: json['activeFlatId'] as String?,
      availableFlats: ((json['availableFlats'] as List<dynamic>?) ?? [])
          .cast<Map<String, dynamic>>()
          .map(AvailableFlat.fromJson)
          .toList(),
      details: json['details'] != null
          ? FlatDetails.fromJson(json['details'] as Map<String, dynamic>)
          : null,
    );
  }
}
