#!/bin/bash
# ==============================================================================
# FÉNIX POCKET OS V2 - IOS AUTOCONFIG PIPELINE
# Script de auto-configuración y habilitación iOS
# Ejecutar desde la raíz del proyecto en macOS.
# ==============================================================================

set -e

echo "🚀 [1/5] Regenerando andamiaje nativo iOS (Flutter Create)..."
flutter create --platforms ios .

echo "⚙️ [2/5] Actualizando 'Podfile' garantizando compatibilidad iOS 15.0+..."
# Reemplazar la versión comentada por defecto que impone Flutter (usualmente 11.0, 12.0 o superior)
sed -i '' "s/^# platform :ios, .*/platform :ios, '15.0'/g" ios/Podfile
sed -i '' "s/^platform :ios, .*/platform :ios, '15.0'/g" ios/Podfile

echo "🔐 [3/5] Inyectando Seguridad, ATS y Permisos (Info.plist)..."
PLIST="ios/Runner/Info.plist"

# App Transport Security (ATS) para tráfico no-HTTPS (Servidor Dev FastAPI y llama-server)
plutil -replace NSAppTransportSecurity -dictionary $PLIST || true
plutil -replace NSAppTransportSecurity.NSAllowsArbitraryLoads -bool YES $PLIST

# Permisos para red local en testing (necesario en iOS 14+ para HTTP Insecure connections LAN)
plutil -replace NSLocalNetworkUsageDescription -string "Requerido para conexión al nodo backend FastAPI en tu red WiFi." $PLIST
plutil -replace NSBonjourServices -array $PLIST || true
plutil -insert NSBonjourServices.0 -string "_http._tcp" $PLIST || true

# Permisos Background Modes para Scaffolding Push FCM/APNs
plutil -replace UIBackgroundModes -array $PLIST || true
plutil -insert UIBackgroundModes.0 -string "fetch" $PLIST || true
plutil -insert UIBackgroundModes.1 -string "remote-notification" $PLIST || true

echo "🍎 [4/5] Modificando AppDelegate.swift con stubs APNs y registro nativo..."
cat << 'EOF' > ios/Runner/AppDelegate.swift
import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // [NOTA CTO] Descomentar la siguiente línea tras instalar pod 'Firebase/Core'
    // FirebaseApp.configure()
    
    GeneratedPluginRegistrant.register(with: self)
    
    // Habilitación de framework delegado para notificaciones silenciosas/remotas (Background Fetch activado)
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    application.registerForRemoteNotifications()
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Callback Nativo para APNs Token
  override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      // Inyección de Token crudo a Fénix OS:
      // Messaging.messaging().apnsToken = deviceToken
      super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }
}
EOF

echo "📦 [5/5] Actualizando dependencias de CocoaPods..."
cd ios
# Si el Mac usa chip M1/M2/M3 (Apple Silicon), arch es útil.
arch -x86_64 pod install --repo-update || pod install --repo-update
cd ..

echo "=============================================================================="
echo "✅ [SUCCESS] Proyecto iOS Fénix estructurado y forjado."
echo "SIGUIENTE PASO: Abre el proyecto en Xcode e inyecta tu cuenta de Developer:"
echo "          $ open ios/Runner.xcworkspace"
echo "=============================================================================="
