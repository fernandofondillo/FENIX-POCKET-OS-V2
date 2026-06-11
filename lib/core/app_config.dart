// lib/core/app_config.dart
import 'dart:io';

class AppConfig {
  /// Devuelve la URL base del backend FastAPI.
  /// Modifica esta IP con la tuya propia en tu red WiFi para pruebas con 
  /// dispositivos físicos (iPhone real o Android real). Ej: 'http://192.168.1.50:8000'
  static String get apiBaseUrl {
    // Si estás usando un iPhone/Android Real, cambia `const String customIp` por tu IP.
    const String customIp = 'http://192.168.1.50:8000'; // <- MODIFICA ESTO
    const bool usePhysicalIp = false; // Cambia a `true` si usas dispositivo real.

    if (usePhysicalIp) {
      return customIp;
    }

    try {
      if (Platform.isAndroid) {
         // Emulador Android
        return 'http://10.0.2.2:8000';
      } else if (Platform.isIOS) {
        // Simulador iOS
        return 'http://127.0.0.1:8000';
      }
    } catch (_) {
        // Fallback Web o no soportado
    }
    return 'http://127.0.0.1:8000'; // Default (localhost)
  }
}
