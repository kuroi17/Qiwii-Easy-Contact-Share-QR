class AppContact {
  const AppContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.initials,
    this.email,
    this.organization,
    this.jobTitle,
    this.isDuplicate = false,
  });

  final String id;
  final String name;
  final String phone;
  final String initials;
  final String? email;
  final String? organization;
  final String? jobTitle;
  final bool isDuplicate;

  AppContact copyWith({
    String? id,
    String? name,
    String? phone,
    String? initials,
    String? email,
    String? organization,
    String? jobTitle,
    bool? isDuplicate,
  }) {
    return AppContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      initials: initials ?? this.initials,
      email: email ?? this.email,
      organization: organization ?? this.organization,
      jobTitle: jobTitle ?? this.jobTitle,
      isDuplicate: isDuplicate ?? this.isDuplicate,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'initials': initials,
    if (email != null) 'email': email,
    if (organization != null) 'organization': organization,
    if (jobTitle != null) 'jobTitle': jobTitle,
  };

  factory AppContact.fromJson(Map<String, dynamic> json) => AppContact(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    initials: json['initials'] as String? ?? '',
    email: json['email'] as String?,
    organization: json['organization'] as String?,
    jobTitle: json['jobTitle'] as String?,
  );

  static String generateInitials(String displayName) {
    if (displayName.trim().isEmpty) return '?';
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}

// Backward compatibility alias for the prototype
typedef Contact = AppContact;

const demoContacts = [
  AppContact(id: '1', name: 'Maya Chen', phone: '+1 415 555 0198', initials: 'MC'),
  AppContact(id: '2', name: 'Jordan Rivera', phone: '+1 415 555 0142', initials: 'JR'),
  AppContact(id: '3', name: 'Amara Okafor', phone: '+1 628 555 0116', initials: 'AO'),
  AppContact(id: '4', name: 'Theo Martin', phone: '+1 510 555 0164', initials: 'TM'),
  AppContact(id: '5', name: 'Nina Patel', phone: '+1 650 555 0137', initials: 'NP'),
  AppContact(id: '6', name: 'Liam Park', phone: '+1 408 555 0121', initials: 'LP'),
];
