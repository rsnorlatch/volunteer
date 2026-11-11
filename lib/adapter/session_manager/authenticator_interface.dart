abstract interface class SessionManagerInterface {
  Future<bool> validateAndSetCurrentUserAsync(String username, String password);
}
