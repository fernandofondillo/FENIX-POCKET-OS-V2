import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

/// Servicio encargado de la persistencia en reposo at-rest y la criptología
/// de la bóveda de memoria local (Nano-Obsidian). Garantiza Zero-Knowledge.
class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  static const String _keyOfKey = 'fenix_aes_256_master_key';

  /// Recupera o genera la clave maestra de encriptación
  /// Un cifrado AES-256 robusto requiere exactamente una clave de 32 bytes (256 bits).
  Future<encrypt.Key> _getMasterKey() async {
    String? base64Key = await _storage.read(key: _keyOfKey);
    if (base64Key == null) {
      // 1. Instanciamos un generador criptográficamente seguro
      final secureRandom = Random.secure();
      
      // 2. Generamos una semilla aleatoria de 32 bytes
      final keyBytes = List<int>.generate(32, (i) => secureRandom.nextInt(256));
      base64Key = base64Encode(keyBytes);
      
      // 3. Persistimos la llave vitalicia del dispositivo en el Secure Enclave del SO
      await _storage.write(key: _keyOfKey, value: base64Key);
    }
    return encrypt.Key.fromBase64(base64Key);
  }

  /// Encripta texto plano (Ej: Archivo Markdown) utilizando AES-256 en modo GCM
  /// GCM es el estándar preferido ya que también incluye verificación de integridad.
  Future<String> encryptMarkdown(String plainText) async {
    final key = await _getMasterKey();
    
    // GCM requiere un vector de inicialización único por cada operación (12 bytes estándar).
    final iv = encrypt.IV.fromSecureRandom(12);
    
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.gcm));
    
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    
    // El payload en el disco deberá mantener su propio IV. 
    // Lo unimos con ":" guardando ambas partes en codificación Base64.
    return '${iv.base64}:${encrypted.base64}';
  }

  /// Desencripta un Payload GCM al vuelo para la ingesta del RAG local del teléfono.
  Future<String> decryptMarkdown(String encryptedBundle) async {
    final parts = encryptedBundle.split(':');
    if (parts.length != 2) {
      throw const FormatException('Fallo Estructural Crítico: El documento local carece del IV encriptado.');
    }
    
    final iv = encrypt.IV.fromBase64(parts[0]);
    final encryptedData = encrypt.Encrypted.fromBase64(parts[1]);
    
    final key = await _getMasterKey();
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.gcm));
    
    // El texto descifrado solo vivirá temporalmente en la RAM física del teléfono.
    return encrypter.decrypt(encryptedData, iv: iv);
  }

  /// Recupera el directorio Sandbox de Archivos
  Future<Directory> _getVaultDirectory() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final vaultDir = Directory('${appDocDir.path}/NanoObsidian');
    if (!await vaultDir.exists()) {
      await vaultDir.create(recursive: true);
    }
    return vaultDir;
  }

  /// Operación I/O: Escribir Documento Markdown Cifrado a FileSystem.
  Future<void> writeEncryptedMarkdown(String filename, String plainContent) async {
    final encryptedContent = await encryptMarkdown(plainContent);
    final vaultDir = await _getVaultDirectory();
    
    // Guardar en el Scope Privado Local del SO (Invisible a otras apps de Android/iOS)
    final file = File('${vaultDir.path}/$filename');
    await file.writeAsString(encryptedContent, flush: true);
  }

  /// Operación I/O: Leer Documento protegido en disco y pasarlo desencriptado al RAG.
  Future<String> readDecryptedMarkdown(String filename) async {
    final vaultDir = await _getVaultDirectory();
    final file = File('${vaultDir.path}/$filename');
    
    if (!await file.exists()) {
      throw FileSystemException('Nano-Obsidian I/O Error: Bóveda local no posee el archivo $filename.');
    }
    
    final encryptedContent = await file.readAsString();
    return decryptMarkdown(encryptedContent);
  }
}
