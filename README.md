# Project A.G.O.S. (Agente de Vida y Compañero Operativo Soberano)

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg) ![Build](https://img.shields.io/badge/build-passing-brightgreen.svg) ![License](https://img.shields.io/badge/license-MIT-green.svg) ![Security](https://img.shields.io/badge/security-Zero--Knowledge-purple.svg)

**A.G.O.S.** (Agente de Vida y Compañero Operativo Soberano) es un ecosistema de inteligencia artificial personal de grado empresarial, diseñado bajo una arquitectura radical de separación de responsabilidades: **identidad absoluta en el borde (Edge/Móvil)** y **cognición pura sin estado en la nube (Stateless VPS)**.

Este documento define la arquitectura definitiva, los protocolos de comunicación y el proceso de despliegue técnico del sistema.

---

## 1. INTRODUCCIÓN Y FILOSOFÍA CORE

El sistema A.G.O.S. materializa la filosofía **"Zero-Knowledge"** (Soberanía absoluta del dato). Garantiza que ninguna corporación, ataque al servidor o brecha de datos pueda comprender la vida del usuario.

### Cognición Desacoplada de la Identidad

El dispositivo móvil contiene toda la identidad y la memoria relacional, y asume un cifrado total. El servidor en la nube actúa estrictamente como un **procesador matemático sin estado (Stateless)**. La nube "olvida" el contexto tan pronto como se devuelve la respuesta HTTP, sin persistir UUIDs en bases de datos relacionales, ni cachés prolongadas en la RAM.

---

## 2. MAPA TÉCNICO Y ARQUITECTURA GENERAL

```text
+-------------------------------------------------------------+
|                     MÓVIL (EDGE) - FLUTTER                  |
|                                                             |
|  [Usuario] -> (Voz/Texto)                                   |
|       |                                                     |
|  [Gestor RAG Local] <---> (Cápsula Activa .json)            |
|       |                     (Diarios & Conocimiento .md)    |
|       v                                                     |
|  [Motor de Empaquetado] -> Ensambla JSON Payload (< 400 w)  |
+-------|--------------------------------------------------|--+
        |                                                  ^
        | HTTP POST (TLS 1.3 / JWT Auth Stateless)         | JSON + <perfil_update>
        v                                                  |
+-------|--------------------------------------------------|--+
|                     VPS SERVER (CLOUD)                      |
|                                                             |
|  [FastAPI /api/v1/chat] -> Valida Pydantic v2            |
|       |                                                     |
|  [Router Agnóstico] <-----> Ollama (Qwen 2.5 7B Q4_K_M)     |
|       |                     (Fallback: Gemini 2.0 Pro)      |
|       v                                                     |
|  [Formateo de Salida] -> Extrae JSON/Function Calling       |
+-------------------------------------------------------------+
```

---

## 3. STACK TECNOLÓGICO EXPLICADO (BREADTH & DEPTH)

### Frontend Multiplataforma (Dart / Flutter)

- **Identidad y Vectorización Local**:
  - **SQLite (\`lib/services/perfil_db_service.dart\`)** se emplea estrictamente para almacenar el Perfil Evolutivo y la tabla de métricas (Patrón EAV) procesando Json dinámico al vuelo (Upsert).
  - **ObjectBox / sqlite-vec** ofrece un RAG híbrido nativo sin depender de APIs cloud. Corre mini-modelos de embeddings en `Isolates` localmente.
- **Seguridad y Encriptación en Disco:** Se utiliza la librería `encrypt` (\`lib/services/secure_storage_service.dart\`) para aplicar **AES-256** bajo un Pair-Key nativo del Secure Enclave.

### Backend Concurrente (FastAPI / Python 3.11+)

- **Gestión Asíncrona (\`app/main.py\`):** Alojado en un VPS Hostinger (16GB RAM). FastAPI maneja I/O de manera stateless. Cero retenciones post-respuesta de la memoria para proteger la seguridad.
- **Validación Estricta (\`app/schemas/chat_schema.py\`):** `Pydantic v2` garantiza que los contratos JSON `snake_case` coincidan al milímetro entre Flutter y FastAPI.
- **Motor Inferencial Intercambiable (\`app/services/inference_router.py\`):** Se corre **Ollama (Qwen 2.5 7B Instruct)** u orquestador Cloud. Inyecta JSON XML `<perfil_update>` en base a inferencias al vuelo.

\_(Nota: La base de datos incluye la arquitectura Base Real para Producción con tipado Pydantic y un manejador Flutter estricto).\*

---

## 4. SISTEMA DE MEMORIA MULTINIVEL SOBERANA

La retención cognitiva del Agente se divide biológicamente en 3 etapas:

1.  **Memoria Inmediata (RAM del Móvil):** La ventana de atención pura. Limitada rígidamente a los **últimos 8 mensajes** conversacionales. Previene desbordar la atención en la CPU del VPS.
2.  **Memoria de Identidad (SQLite):** Construida de forma viva a través de retornos asíncronos del VPS que incluyen el flag de heurística `<perfil_update>`.
3.  **Memoria a Largo Plazo (Nano-Obsidian Vault):**
    - Archivos encriptados `.md`.
    - Se diferencian en `/Diarios` (notas en primera persona y registro automático desde el endpoint asíncrono asimilativo de Consolidación Nocturna que corre local).
    - `/Conocimiento_Experto` (Pautas médicas o de literatura técnica bajadas de las cápsulas).

---

## 5. ANATOMÍA COMPLETA DE UNA CÁPSULA DE PERSONALIDAD (.JSON)

Contrato arquitectural representativo (`fitness_coach.json`). Estandarizado en el móvil para ingesta local:

```json
{
  "id": "fitness_expert",
  "name": "Entrenador Fénix",
  "behavioral_dimension": {
    "role_description": "Biomomecánico y motivador estoico.",
    "system_prompt": "Actúa con un tono militar. Tu único objetivo es evitar las lesiones del usuario. Usa la ciencia adaptativa y enfócate en sus métricas diarias.",
    "allowed_skills": [
      "notificacion_enviar",
      "agenda_crear",
      "read_health_data"
    ]
  },
  "visual_dimension": {
    "theme_color": "#FF2A00",
    "accent_hex": "#b91c1c",
    "bg_gradient": "from-red-950 via-zinc-900 to-black",
    "typography": "SpaceGrotesk-Bold",
    "avatar_asset": "assets/avatars/coach_atomico.png"
  },
  "cognitive_dimension": {
    "linked_knowledge_md": [
      "/nano_obsidian/Conocimiento_Experto/Fundamentos_Hipertrofia.md",
      "/nano_obsidian/Conocimiento_Experto/Prevencion_Lumbar.md"
    ]
  }
}
```

### 5.1 Interfaz Acústica y Conectividad con el Ecosistema Google (Workspace)

Para proveer un puente holístico entre el entorno Fénix y el ecosistema cerrado:

1. **Interfaz de Voz Transparente (Speech-to-Text):** A.G.O.S. posee acceso nativo al micrófono en el chat del móvil. Lo que el usuario dicte se transcribe al vuelo de voz a texto y se inyecta directamente en la bandeja de envío, reduciendo la fricción conversacional en situaciones operativas de manos libres.
2. **Integración OAuth con Google Workspace:** A través de autorizaciones soberanas OAuth2, el Agente puede conectar e interoperar de forma asíncrona con los dominios de Google (Gmail, Calendar, Docs, Sheets).
   - **Ejemplo Práctico:** Puedes solicitarle en el chat _"Léeme los últimos correos del trabajo y saca unas viñetas"_, y la aplicación se validará mediante el nodo de las cápsulas ejecutivas que posean habilitada la skill `gmail_read` o `calendar_manage`, para consolidar las operaciones manteniendo plena coherencia contextual.

---

## 6. FLUJO DE BIENVENIDA Y MATRIZ DE IDENTIDAD (ONBOARDING)

Al iniciar la bóveda por primera vez en Flutter (`welcome_screen.dart`), el Agente ejecuta un proceso de auto-gestión y blindaje de perfiles:

1.  **Diferenciación Zero-Knowledge:** Genera un `user_id` único mediante la librería `UUID` local que aisla tu cuenta de las demás de forma completamente descentralizada.
2.  **Llavero Biométrico:** Crea una clave de encriptación maestra `AES-256` en el llavero hermético del móvil (`SecureStorageService`).
3.  **Identidad Estructural SQLite:** Pide los metadatos más básicos (Nombre, Roles, Metas) e instancia las primeras filas "semilla" del perfil EAV de la base de datos de la forma más amigable posible con una interfaz ultra purista, redirigiendo al vuelo hacia el chat principal interactivo al acabar.

---

## 7. ARQUITECTURA DEL PERFIL EVOLUTIVO (SQLite EAV)

Para garantizar que el modelo de IA (Qwen 2.5) local del VPS pueda persistir el conocimiento dinámicamente sin requerir migraciones de base de datos, modificaciones estructurales o de código en el móvil, hemos formalizado el **Patrón EAV (Entity-Attribute-Value)**. Tradicionalmente, agregar un nuevo campo (ej. "nivel_colesterol") requeriría una migración `ALTER TABLE`. Con EAV, la IA estructura el conocimiento como filas independientes de metadatos.

**Esquema de la Tabla (`perfil_usuario`):**

- `id`: `INTEGER PRIMARY KEY AUTOINCREMENT`
- `categoria`: `TEXT NOT NULL` (La Entidad agrupadora, ej. 'salud', 'longevidad', 'preferencias')
- `clave`: `TEXT NOT NULL UNIQUE` (El Atributo único, ej. 'lesion_sacroiliaca', 'stack_tecnologico')
- `valor`: `TEXT NOT NULL` (El Valor: la información cruda u observación deducida)
- `ultima_actualizacion`: `TEXT NOT NULL` (Timestamp ISO8601)

### 7.1. Integridad Estructural y Upserts Atómicos

El sistema gestiona la actualización ininterrumpida a través de transacciones SQL **Upsert** (`INSERT OR REPLACE INTO`).
Cuando el LLM deduce un estado a partir del diálogo (ej. _el usuario dice "Me duele la espalda hoy"_), el orquestador backend detecta el patrón y responde emitiendo una inyección estructurada oculta en la respuesta:

```xml
<perfil_update>
  [
    {"categoria": "salud", "clave": "molestia_lumbar", "valor": "Dolor activo comunicado por el usuario"}
  ]
</perfil_update>
```

Al recibirse en Flutter (`perfil_db_service.dart`), la app móvil procesa este objeto json, y si la clave `molestia_lumbar` ya existe, **actualiza** su valor y el timestamp `ultima_actualizacion` manteniendo el `id` o **insertando** la nueva observación en caso de ausencia. Este mecanismo garantiza un perfil constantemente evolutivo sin requerir alteraciones en la arquitectura relacional (Zero Migrations Strategy).

---

## 8. CONTRATO DE DATOS (Protocolo de Inferencia Rápida)

En `Pydantic` (FastAPI) y `Dart` (Flutter), todos los objetos de transporte se normalizan bajo un contrato **strict snake_case**. La latencia se minimiza podando el contexto experto local a ~400 palabras ANTES de que el payload cruce la red, mitigando la carga sobre la CPU remota.

### 8.1. Solicitud (HTTP POST `ChatRequest` a `/api/v1/chat`)

```json
{
  "user_id": "UUID-Fenix-Mobile-987X-Anon",
  "capsula_activa": {
    "id": "fitness_expert",
    "system_prompt": "Actúa con tono militar y estoico...",
    "allowed_skills": ["agenda_crear", "notificacion_enviar"]
  },
  "active_skills": ["agenda_crear", "notificacion_enviar"],
  "perfil_identidad": "Carlos | Entrena 5/semana | Foco: Hipertrofia",
  "contexto_rag_hibrido": {
    "historial_usuario": "(Diario) Ayer fallé sentadillas, ligera presión L4 L5...",
    "conocimiento_experto": "(Manual) Si ocurre presión en L4, cambiar a Hip Hinge isométrico."
  },
  "historial_reciente": [
    { "role": "user", "content": "Hoy no me siento bien..." },
    { "role": "model", "content": "¿Puntaje de fatiga en piernas o lumbar?" },
    { "role": "user", "content": "Lumbar." }
  ],
  "mensaje_actual": "¿Debería forzar la serie?"
}
```

### 8.2. Respuesta (HTTP `ChatResponse` desde el VPS)

El servidor extrae cualquier mandato de modificación EAV escondido en un formato pseudo-XML `<perfil_update>` emitido por la IA para inyectarlo en el array `perfil_update`:

```json
{
  "status": "success",
  "assistant_response": "Evita toda carga axial hoy. Hemos registrado la presión en el área sacrolumbar. Haz estiramientos.",
  "perfil_update": [
    {
      "categoria": "salud",
      "clave": "molestia_lumbar",
      "valor": "Presión en L4 detectada"
    }
  ],
  "inferenced_by": "google_gemini_sdk_cloud"
}
```

---

## 9. GUÍA DE INSTALACIÓN, DESPLIEGUE Y OPERACIÓN COMPLETA

### 9.1 Optimizaciones en VPS para Ollama (Límite de Consumo RAM/CPU)

Para asegurar que el modelo sobreviva a concurrencia alta en un servidor económico.

```bash
# Instalación del core
curl -fsSL https://ollama.com/install.sh | sh

# Modificar el entorno SystemD para domar recursos:
sudo vi /etc/systemd/system/ollama.service
```

Deben estipularse las siguientes directivas fundamentales dentro del daemon `[Service]`:

```ini
Environment="OLLAMA_NUM_PARALLEL=2" # Reduce fragmentación localizando hilos de manera estricta
Environment="OLLAMA_NUM_CTX=4096" # Hard limit del contexto a 4k (salva RAM)
Environment="OLLAMA_KEEP_ALIVE=-1" # Impide que se evicte el modelo de 7B tras inactividad
```

### 9.2 Lanzamiento Asíncrono de FastAPI

Restringimos fuertemente los workers explícitamente a 2 (`--workers 2`) para evitar que Python I/O robe tiempos de CPU críticos que requiere el pipeline matemático del LLM subyacente.

```bash
# Preparación de venv y dependencias
python3 -m venv fenix_env
source fenix_env/bin/activate
pip install fastapi pydantic uvicorn[standard] python-dotenv

# Lanzamiento bajo restricciones de Worker para evitar CPU-Saturations (-w 2)
uvicorn main:app --host 0.0.0.0 --port 8000 --workers 2 --proxy-headers
```

### 9.3 Despliegue en Entornos Reales Edge (iPhone Físico)

A.G.O.S se ha diseñado para poder probarlo y desplegarlo en dispositivos físicos iOS sin necesidad inmediata de una cuenta Apple Developer de pago.

#### Opción A: Flutter Live Companion (Vía FlutLab.io) — La más rápida

Esta opción es el equivalente a Expo Go para el ecosistema de Flutter, ideal porque no requiere compilar un archivo `.ipa`, usar ordenadores Mac, ni cables:

1. Entra en [FlutLab.io](https://flutlab.io) (un entorno de desarrollo de Flutter en la nube).
2. Sube el código de tu repositorio de GitHub con un solo clic.
3. Instala la app **FlutLab Runner** en tu iPhone desde la App Store oficial (es gratuita y segura).
4. Escanea el código QR que se genera en la pantalla de tu ordenador en la web de FlutLab.
5. Tu app de Fénix se ejecutará instantáneamente en tu iPhone, conectándose por HTTPS a tu VPS de Hostinger, pudiendo usar la encriptación AES nativa y SQLite.

#### Opción B: TestFlight Público Externo — La más profesional

Si cuentas con acceso esporádico a un equipo Mac:

1. Sube la app compilada a la plataforma TestFlight de Apple (requiere cuenta de equipo).
2. Genera un enlace público (`https://testflight.apple.com/...`).
3. Instala la app oficial **TestFlight** en tu iPhone (gratis en la App Store).
4. Al pulsar el enlace, la app se descarga en tu teléfono. Funciona de manera nativa al 100% y la versión no caducará hasta pasados 90 días, otorgando tiempo suficiente para la prueba de concepto prolongada.

#### Opción C: Side-loading Local (Cableado con Xcode)

A.G.O.S no requiere pagar cuentas Apple Developer si se inyecta como Sandbox perimetral:

1. Abre el Workspace en Xcode (`ios/Runner.xcworkspace`).
2. Accede a **Signing & Capabilities**.
3. Usa el Free Provisioning Profile vinculado a tu iCloud (Apple ID).
4. Lanza el despliegue con: `flutter run -d <tuiPhoneId> --release`
5. _Autorenovación Continua_: Como las firmas gratuitas expiran en 7 días, se recomienda operar el teléfono utilizando **AltStore** / **SideStore** con daemon local para re-firmar el runtime por WiFi sin perder las bases de datos SQLite y las claves criptográficas temporales.

---

## 10. SEGURIDAD COMPROBADA Y PARÁMETROS AGNOSTICOS

- **Evitando el Sobrepensamiento del Modelo:** La lógica implementada a lo largo del sistema y los inyectores imponen al framework (Ollama / Express gemini API fallback) condiciones espartanas obligatorias: `temperature=0.3`, `top_p=0.9` y `max_tokens` delimitados a `200/300` para evadir respuestas que ahoguen la CPU (Alucinaciones de cola larga de probabilidad).
- **Total Aislamiento Stateless:** Todo usuario que llega al Backend es procesado dentro de un endpoint inmutable. Si la red cae, el servidor no conservará retazos del perfil SQLite del usuario, logrando cero cruce de datos por diseño y mitigando ataques locales (LFI/RCE).
- **Transparencia de Roles:** El App Móvil de manera agnóstica usa `"user"` y `"assistant"`, el enrutador/Backend orquesta los mapeos transitorios a `"model"` solo en la red interna para compatibilidad de motores de forma transparente al front.

---

_“Nuestra privacidad no es un lujo. Es la barrera física entre el individuo y el sistema”._  
**El Equipo Core Fénix / A.G.O.S.**
