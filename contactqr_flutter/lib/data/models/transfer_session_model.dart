enum TransferMode {
  direct,
  localNetwork,
}

enum TransferStatus {
  idle,
  waiting,
  connected,
  transferring,
  completed,
  cancelled,
  expired,
  failed,
}

class TransferSession {
  const TransferSession({
    required this.sessionId,
    required this.protocolVersion,
    required this.mode,
    required this.contactCount,
    required this.createdAt,
    required this.expiresAt,
    this.status = TransferStatus.waiting,
    this.host,
    this.port,
    this.token,
    this.encryptionKey,
    this.directPayload,
    this.errorMessage,
    this.isPinProtected = false,
    this.pinSalt,
  });

  final String sessionId;
  final int protocolVersion;
  final TransferMode mode;
  final int contactCount;
  final DateTime createdAt;
  final DateTime expiresAt;
  final TransferStatus status;
  final String? host;
  final int? port;
  final String? token;
  final String? encryptionKey;
  final String? directPayload;
  final String? errorMessage;
  final bool isPinProtected;
  final String? pinSalt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  TransferSession copyWith({
    String? sessionId,
    int? protocolVersion,
    TransferMode? mode,
    int? contactCount,
    DateTime? createdAt,
    DateTime? expiresAt,
    TransferStatus? status,
    String? host,
    int? port,
    String? token,
    String? encryptionKey,
    String? directPayload,
    String? errorMessage,
    bool? isPinProtected,
    String? pinSalt,
  }) {
    return TransferSession(
      sessionId: sessionId ?? this.sessionId,
      protocolVersion: protocolVersion ?? this.protocolVersion,
      mode: mode ?? this.mode,
      contactCount: contactCount ?? this.contactCount,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
      host: host ?? this.host,
      port: port ?? this.port,
      token: token ?? this.token,
      encryptionKey: encryptionKey ?? this.encryptionKey,
      directPayload: directPayload ?? this.directPayload,
      errorMessage: errorMessage ?? this.errorMessage,
      isPinProtected: isPinProtected ?? this.isPinProtected,
      pinSalt: pinSalt ?? this.pinSalt,
    );
  }

  Map<String, dynamic> toJson() => {
    'app': 'contactqr',
    'ver': protocolVersion,
    'sessionId': sessionId,
    'mode': mode.name,
    'count': contactCount,
    'expiresAt': expiresAt.toIso8601String(),
    if (host != null) 'host': host,
    if (port != null) 'port': port,
    if (token != null) 'token': token,
    if (encryptionKey != null) 'key': encryptionKey,
    if (directPayload != null) 'data': directPayload,
    if (isPinProtected) 'pin': true,
    if (pinSalt != null) 'salt': pinSalt,
  };

  factory TransferSession.fromJson(Map<String, dynamic> json) => TransferSession(
    sessionId: json['sessionId'] as String? ?? '',
    protocolVersion: json['ver'] as int? ?? 1,
    mode: json['mode'] == 'direct' ? TransferMode.direct : TransferMode.localNetwork,
    contactCount: json['count'] as int? ?? 0,
    createdAt: DateTime.now(),
    expiresAt: json['expiresAt'] != null
        ? DateTime.tryParse(json['expiresAt'] as String) ?? DateTime.now().add(const Duration(minutes: 10))
        : DateTime.now().add(const Duration(minutes: 10)),
    host: json['host'] as String?,
    port: json['port'] as int?,
    token: json['token'] as String?,
    encryptionKey: json['key'] as String?,
    directPayload: json['data'] as String?,
    isPinProtected: json['pin'] as bool? ?? false,
    pinSalt: json['salt'] as String?,
  );
}
