import '../../../core/storage/token_storage.dart';
import '../domain/profile_model.dart';

class ProfileService {
  final TokenStorage _tokenStorage = TokenStorage();

  Future<ProfileModel?> getProfile() async {
    final userId = await _tokenStorage.getUserId() ?? '';
    final fullName = await _tokenStorage.getNombre() ?? 'Usuario';
    final email = await _tokenStorage.getUsername() ?? '';
    final rolId = await _tokenStorage.getRolId() ?? 'CLIENTE';

    // Generar un número de documento a partir del ID para la vista offline
    final docNum = userId.startsWith('USER_CLIENTE_') 
        ? userId.replaceAll('USER_CLIENTE_', '') 
        : userId;

    return ProfileModel(
      id: userId,
      fullName: fullName,
      email: email,
      documentNumber: docNum,
      phone: rolId, // Mostramos el rol en este campo o como información adicional
    );
  }
}
