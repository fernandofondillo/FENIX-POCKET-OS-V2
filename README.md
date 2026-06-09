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
  - **SQLite** se emplea estrictamente para almacenar el Perfil Evolutivo y la tabla de métricas (Constantes vitales, recordatorios).
  - **ObjectBox** complementado con **sqlite-vec** ofrece un RAG híbrido nativo sin depender de APIs cloud. Corre mini-modelos de embeddings en `Isolates` (Treads de Dart) localmente.
- **Seguridad y Encriptación en Disco:** Se utiliza la librería `encrypt` para aplicar **AES-256** bajo un Pair-Key único emitido al iniciar el dispositivo.

### Backend Concurrente (FastAPI / Python 3.11+)

- **Gestión Asíncrona:** Alojado en un VPS Hostinger (16GB RAM / Solo CPU). FastAPI maneja de forma asíncrona la concurrencia delegando al hilo principal I/O-bound e instanciando un pool de subprocesos limitados.
- **Validación Estricta:** `Pydantic v2` garantiza que los contratos JSON `snake_case` coincidan al bit.
- **Motor Inferencial Intercambiable:** Se corre **Ollama (Qwen 2.5 7B Instruct cuantizado en Q4_K_M)** que permite una inferencia ultrarrápida. Si hay saturación, un flag `USE_CLOUD_FALLBACK=True` redirecciona la carga térmica a los SDKs de **Gemini** o OpenAI manteniendo idéntica compatibilidad en el payload de las llamadas locales.

\_(Nota: La base del código incorpora ahora las implementaciones técnicas reales para producción en arquitecturas reales:

- \`lib/services/secure_storage_service.dart\`: Encargado de la persistencia at-rest AES-256 en el móvil (Nano-Obsidian).
- \`app/services/inference*router.py\`: El orquestador backend asíncrono para FastAPI con soporte agnóstico Ollama/Gemini y manejo de Cloud Fallback).*

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

---

## 6. CONTRATO DEL PAYLOAD (Protocolo de Inferencia Rápida)

En `Pydantic` y `Dart`, las directivas se normalizan bajo convenciones compartidas `snake_case`. La latencia se minimiza podando el contexto experto local a ~400 palabras ANTES de viajar por la red rediciendo el peso cognitivo sobre CPU.

**Ejemplo de Petición HTTP POST hacia `/api/v1/chat`**:

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

---

## 7. GUÍA DE INSTALACIÓN, DESPLIEGUE Y OPERACIÓN COMPLETA

### 7.1 Optimizaciones en VPS para Ollama (Límite de Consumo RAM/CPU)

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

### 7.2 Lanzamiento Asíncrono de FastAPI

Restringimos fuertemente los workers explícitamente a 2 (`--workers 2`) para evitar que Python I/O robe tiempos de CPU críticos que requiere el pipeline matemático del LLM subyacente.

```bash
# Preparación de venv y dependencias
python3 -m venv fenix_env
source fenix_env/bin/activate
pip install fastapi pydantic uvicorn[standard] python-dotenv

# Lanzamiento bajo restricciones de Worker para evitar CPU-Saturations (-w 2)
uvicorn main:app --host 0.0.0.0 --port 8000 --workers 2 --proxy-headers
```

### 7.3 Firma en Entornos Reales Edge (iPhone Físico)

A.G.O.S no requiere pagar cuentas Apple Developer si se inyecta como Sandbox perimetral mediante Side-loading.

1.  Abre el Workspace en Xcode (`ios/Runner.xcworkspace`).
2.  Accede a **Signing & Capabilities**.
3.  Usa el Free Provisioning Profile vinculado a tu iCloud (Apple ID).
4.  Lanza el despliegue con: `flutter run -d <tuiPhoneId> --release`
5.  _Autorenovación Continua_: Como las firmas expiran en 7 días, se recomienda operar el teléfono utilizando el framework **AltStore** / **SideStore** con daemon local para re-firmar el runtime por WiFi sin perder las bases de datos SQLite y las claves criptográficas temporales.

---

## 8. SEGURIDAD COMPROBADA Y PARÁMETROS AGNOSTICOS

- **Evitando el Sobrepensamiento del Modelo:** La lógica implementada a lo largo del sistema y los inyectores imponen al framework (Ollama / Express gemini API fallback) condiciones espartanas obligatorias: `temperature=0.3`, `top_p=0.9` y `max_tokens` delimitados a `200/300` para evadir respuestas que ahoguen la CPU (Alucinaciones de cola larga de probabilidad).
- **Total Aislamiento Stateless:** Todo usuario que llega al Backend es procesado dentro de un endpoint inmutable. Si la red cae, el servidor no conservará retazos del perfil SQLite del usuario, logrando cero cruce de datos por diseño y mitigando ataques locales (LFI/RCE).
- **Transparencia de Roles:** El App Móvil de manera agnóstica usa `"user"` y `"assistant"`, el enrutador/Backend orquesta los mapeos transitorios a `"model"` solo en la red interna para compatibilidad de motores de forma transparente al front.

---

_“Nuestra privacidad no es un lujo. Es la barrera física entre el individuo y el sistema”._  
**El Equipo Core Fénix / A.G.O.S.**
