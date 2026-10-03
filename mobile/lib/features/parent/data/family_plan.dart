/// Parent-entered demo records. Places are practice targets, not verified safety.
class FamilyPlan {
  const FamilyPlan({
    this.child = const ChildProfile(),
    this.contacts = const [],
    this.safePoints = const [],
  });

  static const maxContacts = 3;

  factory FamilyPlan.fromJson(Map<String, dynamic> json) {
    if (json['version'] != 1) {
      throw const FormatException('Unsupported family plan version');
    }
    final contacts = (json['contacts'] as List)
        .map((entry) => TrustedContact.fromJson(entry as Map<String, dynamic>))
        .toList();
    if (contacts.length > maxContacts) {
      throw const FormatException('Too many trusted contacts');
    }
    return FamilyPlan(
      child: ChildProfile.fromJson(json['child'] as Map<String, dynamic>),
      contacts: List.unmodifiable(contacts),
      safePoints: List.unmodifiable(
        (json['safePoints'] as List).map(
          (entry) => SafePoint.fromJson(entry as Map<String, dynamic>),
        ),
      ),
    );
  }

  final ChildProfile child;
  final List<TrustedContact> contacts;
  final List<SafePoint> safePoints;

  FamilyPlan copyWith({
    ChildProfile? child,
    List<TrustedContact>? contacts,
    List<SafePoint>? safePoints,
  }) => FamilyPlan(
    child: child ?? this.child,
    contacts: List.unmodifiable(contacts ?? this.contacts),
    safePoints: List.unmodifiable(safePoints ?? this.safePoints),
  );

  Map<String, dynamic> toJson() => {
    'version': 1,
    'child': child.toJson(),
    'contacts': contacts.map((contact) => contact.toJson()).toList(),
    'safePoints': safePoints.map((point) => point.toJson()).toList(),
  };
}

class ChildProfile {
  const ChildProfile({
    this.fullName = '',
    this.age,
    this.address = '',
    this.supportNotes = '',
  });

  factory ChildProfile.fromJson(Map<String, dynamic> json) => ChildProfile(
    fullName: json['fullName'] as String,
    age: json['age'] as int?,
    address: json['address'] as String,
    supportNotes: json['supportNotes'] as String,
  );

  final String fullName;
  final int? age;
  final String address;
  final String supportNotes;

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'age': age,
    'address': address,
    'supportNotes': supportNotes,
  };
}

class TrustedContact {
  const TrustedContact({
    this.name = '',
    this.phone = '',
    this.relationship = '',
  });

  factory TrustedContact.fromJson(Map<String, dynamic> json) => TrustedContact(
    name: json['name'] as String,
    phone: json['phone'] as String,
    relationship: json['relationship'] as String,
  );

  final String name;
  final String phone;
  final String relationship;

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'relationship': relationship,
  };
}

/// Geographic coordinates stay independent of the map's canvas/camera transform.
class SafePoint {
  const SafePoint({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory SafePoint.fromJson(Map<String, dynamic> json) {
    final point = SafePoint(
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
    if (!point.latitude.isFinite ||
        !point.longitude.isFinite ||
        point.latitude.abs() > 90 ||
        point.longitude.abs() > 180) {
      throw const FormatException('Invalid place coordinates');
    }
    return point;
  }

  final String name;
  final double latitude;
  final double longitude;

  String get displayName => name.trim().isEmpty ? 'Practice place' : name;

  Map<String, dynamic> toJson() => {
    'name': name,
    'latitude': latitude,
    'longitude': longitude,
  };
}
