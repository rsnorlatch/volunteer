enum RegistrationStatus { pending, accepted, rejected }

extension RegistrationStatusX on RegistrationStatus {
  String get label => switch (this) {
        RegistrationStatus.pending => 'Menunggu',
        RegistrationStatus.accepted => 'Diterima',
        RegistrationStatus.rejected => 'Ditolak',
      };

  String get description => switch (this) {
        RegistrationStatus.pending => 'Menunggu konfirmasi',
        RegistrationStatus.accepted => 'Pendaftaran diterima',
        RegistrationStatus.rejected => 'Pendaftaran ditolak',
      };
}

class Registration {
  Registration({
    required this.id,
    required this.activityId,
    required this.userKey,
    required this.donorName,
    required this.phone,
    required this.bloodType,
    this.status = RegistrationStatus.pending,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String activityId;
  final String userKey;
  final String donorName;
  final String phone;
  final String bloodType;
  RegistrationStatus status;
  final DateTime createdAt;
}
