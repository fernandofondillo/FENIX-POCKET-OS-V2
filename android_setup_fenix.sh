#!/bin/bash
# ==============================================================================
# FÉNIX POCKET OS V2 - ANDROID AUTOCONFIG PIPELINE
# Script de auto-configuración y habilitación Android
# ==============================================================================

set -e

echo "🚀 [1/4] Regenerando andamiaje nativo Android (Flutter Create)..."
flutter create --platforms android .

echo "⚙️ [2/4] Actualizando 'build.gradle' para SDK Versions (minSdkVersion 23)..."
# flutter_secure_storage y otras librerías requieren minSdkVersion >= 23
APP_BUILD_GRADLE="android/app/build.gradle"
if [ -f "$APP_BUILD_GRADLE" ]; then
    # Usar sed para modificar flutter.minSdkVersion o minSdkVersion directamente
    # En proyectos Flutter modernos, usa local.properties o se encuentra en android/app/build.gradle
    sed -i.bak 's/minSdkVersion flutter.minSdkVersion/minSdkVersion 23/' $APP_BUILD_GRADLE
    sed -i.bak 's/minSdkVersion 16/minSdkVersion 23/' $APP_BUILD_GRADLE
    sed -i.bak 's/minSdkVersion 19/minSdkVersion 23/' $APP_BUILD_GRADLE
    sed -i.bak 's/minSdkVersion 21/minSdkVersion 23/' $APP_BUILD_GRADLE
    echo "minSdkVersion actualizado a 23 en $APP_BUILD_GRADLE"
fi

echo "🔐 [3/4] Inyectando Permisos y configuraciones (AndroidManifest.xml)..."
MANIFEST="android/app/src/main/AndroidManifest.xml"
if [ -f "$MANIFEST" ]; then
    # Agregar permiso de INTERNET si no existe (Flutter create a veces lo agrega por defecto, garantizamos)
    if ! grep -q "android.permission.INTERNET" "$MANIFEST"; then
        sed -i.bak '/<application/i \    <uses-permission android:name="android.permission.INTERNET"/>\n    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>' $MANIFEST
    fi
    # Habilitar tráfico Cleartext por si el servidor de llama-server / fastapi corre en HTTP local
    if ! grep -q "android:usesCleartextTraffic" "$MANIFEST"; then
        sed -i.bak 's/<application/<application android:usesCleartextTraffic="true"/' $MANIFEST
    fi
    echo "Permisos de red y traffic configuration inyectados."
fi

echo "📦 [4/4] Solucionando problemas de Kotlin / Gradle (Si aplica)..."
# Omitimos cambios manuales drásticos aquí si no hay versiones reportadas rotas.

echo "=============================================================================="
echo "✅ [SUCCESS] Proyecto Android Fénix estructurado y configurado."
echo "SIGUIENTE PASO: Puedes compilar y probar:"
echo "          $ flutter run -d <id_del_android>"
echo "=============================================================================="
