# Project A.G.O.S. (Agente de Vida y Compañero Operativo Soberano)

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg) ![Build](https://img.shields.io/badge/build-passing-brightgreen.svg) ![License](https://img.shields.io/badge/license-MIT-green.svg) ![Security](https://img.shields.io/badge/security-Zero--Knowledge-purple.svg)

**A.G.O.S.** (Agente de Vida y Compañero Operativo Soberano) es un ecosistema de inteligencia artificial personal de grado empresarial, diseñado bajo una arquitectura radical de separación de responsabilidades: **identidad absoluta en el borde (Edge/Móvil)** y **cognición pura sin estado en la nube (Stateless VPS)**.

Este documento define la arquitectura, protocolos de comunicación, y despliegue técnico del sistema.

---

## 1. INTRODUCCIÓN Y FILOSOFÍA CORE

El diseño de A.G.O.S. resuelve el problema fundamental de la privacidad en la era de los LLMs mediante el paradigma de **"Zero-Knowledge" (Soberanía absoluta del dato)**.

### Cognición Desacoplada de la Identidad

El dispositivo móvil de cada usuario es la única fuente de verdad y el único contenedor de memoria, identidad, miedos, datos de salud y rutinas (bóveda cerrada). El servidor VPS asume el rol de un **"procesador matemático ciego"**. No guarda logs de conversaciones, no persiste vectores en la nube, ni asocia un UUID a una base de datos relacional externa.

Cuando el usuario habla, su teléfono empaqueta un contexto ultra-denso (Payload Híbrido), lo envía por la red, el VPS lo inyecta crudo en la ventana de contexto del LLM, y tras la inferencia, **la RAM del servidor se purga**. Esto habilita una arquitectura multiusuario escalable y segura, sin riesgo de cruce de datos o filtraciones masivas.

---

## 2. MAPA TÉCNICO Y ARQUITECTURA GENERAL

La coreografía del flujo de datos garantiza que el VPS actúe exclusivamente como motor computacional on-demand.

```text
+-------------------------------------------------------------+
|                     MÓVIL (EDGE) - FLUTTER                  |
|                                                             |
|  [Usuario] -> (Voz/Texto)                                   |
|       |                                                     |
|  [Gestor RAG Local] <---> (Cápsula Activa .json)            |
|       |                     (Diarios & Conocimiento .md)    |
|       v                                                     |
|  [Motor de Empaquetado] -> Ensambla JSON Payload (< 400 W)  |
+-------|--------------------------------------------------|--+
        |                                                  ^
        | HTTP POST (TLS 1.3 + JWT Auth Opcional)          | JSON Response + <perfil_update>
        v                                                  |
+-------|--------------------------------------------------|--+
|                     VPS SERVER (CLOUD)                      |
|                                                             |
|  [FastAPI /api/v1/chat] -> Valida Pydantic v2            |
|       |                                                     |
|  [Motor Agnostic LLM] <---> Ollama (Qwen 2.5 7B Q4_K_M)     |
|       |                <---> Gemini 2.0 Pro / GPT-4o        |
|       v                                                     |
|  [Parser de Salida] -> Extrae Function Calling / Skills     |
+-------------------------------------------------------------+
```

---

## 3. STACK TECNOLÓGICO DETALLADO: BREADTH & DEPTH

### Frontend Multiplataforma (Bóveda Perimetral)

- **Framework:** Flutter (Dart) para compilación nativa AOT en iOS y Android.
- **Encriptación Local:** AES-256 (vía librería `encrypt`) para cifrado en reposo absoluto de todos los diarios e historial de memoria en el sistema de archivos del terminal.
- **Bases de Datos Locales:**
  - **SQLite:** Maneja el **Perfil Evolutivo** (tablas estructuradas de identidad, constantes de salud, rutinas).
  - **ObjectBox / sqlite-vec:** Empleado como motor de inserción de embeddings on-device para búsquedas de similitud (RAG híbrido) ejecutando mini-modelos de embeddings (ej. MiniLM) nativamente sin llamadas de red para no comprometer el texto.

### Backend Concurrente (Motor Ciego sin Estado)

- **Hardware Base:** VPS Básico/Medio (ej. Hostinger) con 16GB RAM, procesadores vCPU x86_64 a ARM64. **(CPU-Only Inference pipeline)**.
- **API Gateway:** FastAPI ejecutado con Uvicorn bajo Python 3.11+. Permite asincronía real, concurrencia extrema y validación inyector-salida mediante **Pydantic v2**.
- **Motores Semánticos (Agnosticismo):**
  - _Offline / Libre:_ **Ollama** operando un modelo cuantizado **Qwen 2.5 7B Instruct (Q4_K_M)** que funciona veloz en CPU, optimizado con parámetros `top_p` limitados para respuestas rápidas.
  - _Cloud Fallback:_ SDKs de Google AI Studio (Gemini 3.1 Pro) o OpenAI para delegar inferencia pesada, manteniendo la API local idéntica.

---

## 4. SISTEMA DE MEMORIA MULTINIVEL SOBERANA

La retención cognitiva del Agente está fraccionada en 3 niveles biológicos locales:

1.  **Memoria Inmediata (RAM Móvil):** La ventana de trabajo. Limitada a los **últimos 8 mensajes** del chat activo. Limpia el ruido, conserva contexto rápido e impide saturar el límite de tokens de lectura en la CPU remota.
2.  **Memoria de Identidad (SQLite):** Un mapa relacional y evolutivo. Fénix deduce variaciones (ej. "Me duele la espalda esta semana") en el VPS mediante un tag JSON `<perfil_update>`. El móvil extrae esta llave y muta su registro local en SQLite. Mantiene también las consolidaciones que ocurren durante un proceso CRON cada noche ("Rutina de Sueño" local).
3.  **Memoria a Largo Plazo (Nano-Obsidian Vault):** Archivos `.md` físicos cifrados en el dispositivo. Divididos en:
    - `/Diarios`: Reflexiones íntimas y logs operativos creados por el usuario o el agente.
    - `/Conocimiento_Experto`: Manuales técnicos (ej. Literatura científica sobre ayuno intermitente, protocolos estoicos) atados a una cápsula específica.

---

## 5. ANATOMÍA COMPLETA DE UNA CÁPSULA DE PERSONALIDAD (.JSON)

Las "Cápsulas" orquestan cómo se comporta, cómo se ve y a qué sabe Fénix en un momento dado, con un sistema de plugins Hot-Swap.

Ejemplo estructural de `fitness_coach.json`:

```json
{
  "id": "fitness_expert",
  "name": "Coach Atómico (Alto Rendimiento)",
  "behavioral_dimension": {
    "role_description": "Instructor biomecánico y de acondicionamiento de alta exigencia.",
    "system_prompt": "Actúa asumiendo la gravedad de un entrenador olímpico soviético combinada con un científico deportivo moderno. Foco total en hipertrofia y prevención del daño lumbar. Nunca des consejos de nutrición general fuera del marco bio-orgánico; si careces del dato, pide que se cambie a la cápsula de Nutrición. Sé cortante, militar, pero orientado al cuidado físico extremo.",
    "allowed_skills": [
      "notificacion_enviar",
      "agenda_crear",
      "read_health_data"
    ]
  },
  "visual_dimension": {
    "avatar_asset": "assets/avatars/coach_atomico.png",
    "theme_color": "#FF2A00",
    "accent_hex": "#b91c1c",
    "bg_gradient": "from-red-950 via-zinc-900 to-black",
    "typography": "SpaceGrotesk-Bold"
  },
  "cognitive_dimension": {
    "linked_knowledge_md": [
      "/nano_obsidian/Conocimiento_Experto/Biomecanica_Levantamientos.md",
      "/nano_obsidian/Conocimiento_Experto/Fisiologia_Muscular_Adaptativa.md"
    ]
  }
}
```

---

## 6. CONTRATO DEL PAYLOAD (PROTOCOLO DE INFERENCIA RÁPIDA)

Para que un modelo de 7 billones de parámetros (Qwen 2.5) asiente una inferencia casi en tiempo real en una simple CPU, el Payload del móvil no puede delegarle el procesamiento de bibliotecas enteras. El App Móvil **pre-mástíca** la infomación.

**El filtro de latencia bloqueante de 400 palabras**: El RAG Híbrido móvil utiliza fragmentación (Chunking) basada en similaridad semántica o lexical (BM25 local) extrayendo un máximo absoluto de 2-3 párrafos clave.

**Ejemplo de Petición HTTP POST a `/api/v1/chat`**:

```json
{
  "user_id": "UUID-Fenix-Mobile-987X-Anon",
  "capsula_activa": {
    "id": "fitness_expert",
    "system_prompt": "Actúa asumiendo la gravedad de un entrenador olímpico..."
  },
  "perfil_identidad": "Carlos | Ingeniero Software | Reto: Hipertrofia | Restricciones: Molestia Sacroilíaca",
  "contexto_rag_hibrido": {
    "historial_usuario": "Hoy desperté con una punzada en la base lumbar (L4). No pude ejecutar el PM.",
    "conocimiento_experto": "(Fragmento): Para la fatiga sacroilíaca, sustituir Peso Muerto por Hip Hinge isométrico para bloquear rotantes."
  },
  "activeSkills": ["agenda_crear"],
  "historial_recent": [
    { "role": "user", "content": "Me toca el día de espalda baja." },
    { "role": "model", "content": "¿Cómo amaneciste del pilar estructural?" },
    {
      "role": "user",
      "content": "Con el dolor que dejé apuntado en mi bitácora ayer."
    }
  ]
}
```

Al estar purgado de ruido, el modelo en el VPS detecta la condición, aplica el consejo técnico y dispara un function calling para crear un recordatorio preventivo con el mínimo uso de tokens de lectura.

---

## 7. GUÍA DE INSTALACIÓN, DESPLIEGUE Y OPERACIÓN COMPLETA

### 7.1 Configuración del Motor LLM (Ollama en el VPS Linux)

Asumiendo un VPS genérico (Ubuntu 22.04 LTS), domar el motor para usar CPU de manera eficiente exige configurar parámetros del entorno de Ollama:

```bash
# 1. Instalar Ollama
curl -fsSL https://ollama.com/install.sh | sh

# 2. Configurar variables de entorno críticas en systemd
sudo vi /etc/systemd/system/ollama.service
```

Añadir en el bloque `[Service]`:

```ini
Environment="OLLAMA_HOST=127.0.0.1:11434"
Environment="OLLAMA_NUM_PARALLEL=2" # Impide cuellos de botella bloqueantes si 2 peticiones coinciden
Environment="OLLAMA_NUM_CTX=4096" # Limita ventana de contexto duro a 4k (salvando RAM vital)
Environment="OLLAMA_KEEP_ALIVE=-1" # Mantiene el modelo Qwen pre-cargado en memoria (clave para inferencia rápida subsecuente)
```

```bash
# 3. Recargar y bajar el modelo cuántizado Q4
sudo systemctl daemon-reload
sudo systemctl restart ollama
ollama run qwen:7b-instruct-q4_K_M
```

### 7.2 Lanzamiento de FastAPI (Entorno de Producción)

```bash
# 1. Preparar entorno Python
sudo apt install python3.11-venv
python3 -m venv fenix_env
source fenix_env/bin/activate

# 2. Dependencias Principales
pip install fastapi "uvicorn[standard]" pydantic python-dotenv

# 3. Lanzamiento optimizado en background con workers
uvicorn main:app --host 0.0.0.0 --port 8000 --workers 4 --proxy-headers
```

### 7.3 Despliegue en iOS Físico (Testeo Perimetral Móvil)

Compilar en iPhones físicos no requiere cuenta de pago si se utiliza firma renovable (Personal Team):

1.  Abre `ios/Runner.xcworkspace` en Xcode.
2.  Ve a **Singing & Capabilities**, selecciona tu cuenta de Apple ID (Personal Team).
3.  Asigna un **Bundle Identifier** único.
4.  Conecta tu iPhone, confía en el desarrollador en _Ajustes > General > Gestión de VPN y Dispositivos_.
5.  Ejecuta `flutter run -d <tuiPhoneId> --release`.

_Aviso:_ Los perfiles gratuitos caducan cada 7 días. Alternativas como **AltStore** o **SideStore** recomienzan la firma vía WiFi utilizando un daemon local; fundamental para que el usuario mantenga el Agente Fénix vivo 24/7 sin cuenta de Apple Developer pagada.

---

## 8. CONSIDERACIONES DE SEGURIDAD, CONCURRENCIA Y AGNOSTICISMO

- **Autenticación sin Estado (Stateless Auth):** Fénix no tiene tablas de sesión HTTP tradicionales. Si exponemos esto a producción abierta, se inyectaría un JWT en las cabeceras HTTP emitido localmente basado en el Pair-Key inicial.
- **Concurrencia con "CPU-Bleed Prevent":** Como el servidor enmascara operaciones bajo endpoints asíncronos (`async def`), múltiples peticiones rápidas encoladas en FastAPI no cuelgan la API esperando procesos matemáticos densos, Ollama acapara el I/O paralelizado pero la API nunca se bloquea al responder timeouts.
- **Agnosticismo del Motor de IA:** Si se excede el compute de Hostinger, el router del backend puede permutar la solicitud de `Ollama` a `Google GenAI SDK (Gemini)` basándose exclusivamente en una flag ambiental (`USE_CLOUD_FALLBACK=True`), dado que la inyección del prompt en bloques (`### MENSAJE ACTUAL`) es entendida de idéntica manera por todos los fundacionales masivos de nuestra era.

---

_“Nuestra privacidad no es un lujo. Es la barrera física entre el individuo y el sistema”._  
**El Equipo Core Fénix / A.G.O.S.**
