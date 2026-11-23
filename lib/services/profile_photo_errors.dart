class ProfilePhotoStorageException implements Exception {
  const ProfilePhotoStorageException(this.message);

  final String message;

  @override
  String toString() => message;
}
