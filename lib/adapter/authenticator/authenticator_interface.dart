abstract interface class AuthenticatorInterface {
  Future<bool> authenticateAsync(String username, String password);
}
