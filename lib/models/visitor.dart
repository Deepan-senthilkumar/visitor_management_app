enum VisitorStatus {
  registered('Registered'),
  checkedIn('Checked In'),
  checkedOut('Checked Out');

  final String label;
  const VisitorStatus(this.label);

  static VisitorStatus fromString(String? s) {
    if (s == null) return VisitorStatus.registered;
    return VisitorStatus.values.firstWhere(
      (e) => e.label.toLowerCase() == s.trim().toLowerCase(),
      orElse: () => VisitorStatus.registered,
    );
  }
}

class Visitor {
  final String id;
  final String name;
  final String mobile;
  final String? email;
  final String visitorType;
  final String project;
  final String status;
  final String purpose;
  final String? checkInTime;
  final String? checkOutTime;
  final String createdAt;

  Visitor({
    required this.id,
    required this.name,
    required this.mobile,
    this.email,
    required this.visitorType,
    required this.project,
    required this.status,
    required this.purpose,
    this.checkInTime,
    this.checkOutTime,
    required this.createdAt,
  });

  factory Visitor.fromJson(Map<String, dynamic> json) {
    return Visitor(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      email: json['email']?.toString(),
      visitorType: json['visitorType']?.toString() ?? 'Customer',
      project: json['project']?.toString() ?? 'Project A',
      purpose: json['purpose']?.toString() ?? '',
      status: json['status']?.toString() ?? VisitorStatus.registered.label,
      checkInTime: json['checkInTime']?.toString(),
      checkOutTime: json['checkOutTime']?.toString(),
      createdAt: json['createdAt']?.toString() ??
          DateTime.now().toUtc().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'mobile': mobile,
      'email': email,
      'visitorType': visitorType,
      'project': project,
      'purpose': purpose,
      'status': status,
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      'createdAt': createdAt,
    };
  }

  Visitor copyWith({
    String? id,
    String? name,
    String? mobile,
    String? email,
    String? visitorType,
    String? project,
    String? status,
    String? purpose,
    String? checkInTime,
    String? checkOutTime,
    String? createdAt,
  }) {
    return Visitor(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      visitorType: visitorType ?? this.visitorType,
      project: project ?? this.project,
      status: status ?? this.status,
      purpose: purpose ?? this.purpose,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
