#!/bin/bash
# ==============================================================================
# FÉNIX POCKET OS V2 - MOBILE AUTOCONFIG PIPELINE
# Script de auto-configuración y habilitación para Android y iOS
# Ejecutar desde la raíz del proyecto. Para iOS se requiere macOS.
# ==============================================================================

set -e

echo "🚀 [1/5] Regenerando andamiaje nativo multi-plataforma (Flutter Create)..."
flutter create --platforms android,ios .

echo "⚙️ [2/5] ANDROID: Actualizando 'build.gradle' para SDK Versions (minSdkVersion 23)..."
APP_BUILD_GRADLE="android/app/build.gradle"
if [ -f "$APP_BUILD_GRADLE" ]; then
    sed -i.bak 's/minSdkVersion flutter.minSdkVersion/minSdkVersion 23/' $APP_BUILD_GRADLE
    sed -i.bak 's/minSdkVersion 21/minSdkVersion 23/' $APP_BUILD_GRADLE
fi

MANIFEST="android/app/src/main/AndroidManifest.xml"
if [ -f "$MANIFEST" ]; then
    if ! grep -q "android.permission.INTERNET" "$MANIFEST"; then
        sed -i.bak '/<application/i \    <uses-permission android:name="android.permission.INTERNET"/>\n    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>' $MANIFEST
    fi
    if ! grep -q "android:usesCleartextTraffic" "$MANIFEST"; then
        sed -i.bak 's/<application/<application android:usesCleartextTraffic="true"/' $MANIFEST
    fi
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "⚙️ [3/5] IOS: Actualizando 'Podfile' garantizando compatibilidad iOS 15.0+..."
    sed -i '' "s/^# platform :ios, .*/platform :ios, '15.0'/g" ios/Podfile
    sed -i '' "s/^platform :ios, .*/platform :ios, '15.0'/g" ios/Podfile

    echo "🔐 [4/5] IOS: Inyectando Seguridad, ATS y Permisos (Info.plist)..."
    PLIST="ios/Runner/Info.plist"
    plutil -replace NSAppTransportSecurity -dictionary $PLIST || true
    plutil -replace NSAppTransportSecurity.NSAllowsArbitraryLoads -bool YES $PLIST
    plutil -replace NSLocalNetworkUsageDescription -string "Requerido para conexión al nodo backend FastAPI en tu red WiFi." $PLIST

    cat << 'EOF' > ios/Runner/AppDelegate.swift
import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    application.registerForRemoteNotifications()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
EOF
    echo "📦 [5/5] IOS: Actualizando dependencias de CocoaPods..."
    cd ios
    arch -x86_64 pod install --repo-update || pod install --repo-update
    cd ..
else
    echo "⚠️ [3/5] Omitiendo configuración de iOS: No estás operando desde macOS."
fi

echo "=============================================================================="
echo "✅ [SUCCESS] Proyecto Fénix estructurado para dispositivos reales."
echo "=============================================================================="
