import express from "express";
import path from "path";
import dotenv from "dotenv";
import { GoogleGenAI } from "@google/genai";
import { createServer as createViteServer } from "vite";

dotenv.config();

// Inicializamos el SDK de Google GenAI con la telemetría oficial de AI Studio
const ai = new GoogleGenAI({
  apiKey: process.env.GEMINI_API_KEY,
  httpOptions: {
    headers: {
      "User-Agent": "aistudio-build",
    },
  },
});

async function startServer() {
  const app = express();
  const PORT = 3000;

  // Analizador de cuerpo JSON con límite de tamaño para payloads de conocimiento
  app.use(express.json({ limit: "15mb" }));

  // API Route: VPS de Inferencia Modular Fénix
  app.post("/api/v1/chat", async (req: express.Request, res: express.Response): Promise<void> => {
    try {
      const {
        user_id,
        capsula_activa,
        active_skills,
        perfil_identidad,
        contexto_rag_hibrido,
        historial_reciente,
        mensaje_actual,
      } = req.body;

      // Validación simple defensiva
      if (!capsula_activa || !mensaje_actual) {
        res.status(400).json({
          error: "FenixVpsException - Payload malformado. Reclama cápsula activa y mensaje actual.",
        });
        return;
      }

      // Desglosar RAG híbrido
      const userHistoryNotes = contexto_rag_hibrido?.historial_usuario || "Ningún diario o nota personal recuperado en la consulta.";
      const expertEvidence = contexto_rag_hibrido?.conocimiento_experto || "Ninguna base de conocimiento cargada para esta cápsula.";
      const authSkills = active_skills || capsula_activa.allowed_skills || [];

      // Reconstrucción inteligente de Mensajes Recientes (formato compatible para turnos)
      const formattedHistory = (historial_reciente || []).map((msg: any) => ({
        role: msg.role === "assistant" ? "model" as const : "user" as const,
        parts: [{ text: msg.content }],
      }));

      // Inyección robusta de Sistema + RAG Híbrido + Identidad del Usuario en el Prompster de Gemini (Optimizada para CPU/Velocidad)
      const systemInstruction = `
Eres "Fénix", un Agente de Vida, Compañero Operativo.
Estás actuando BAJO LA SIGUIENTE CÁPSULA:
ID: ${capsula_activa.id}
Rol: ${capsula_activa.system_prompt}

### IDENTIDAD DEL USUARIO
${perfil_identidad || "No provisto"}

### RAG HÍBRIDO (NOTAS_LOCALES)
${userHistoryNotes}

### RAG HÍBRIDO (LITERATURA_EXPERTA)
${expertEvidence}

### REGLAS OPERATIVAS (MÁXIMA PRIORIDAD)
- Responde con el tono y estilo exacto de tu rol.
- Sé extra conciso, directo al grano.
- Si notas que el usuario revela un NUEVO detalle crítico de su salud o métodos, añade al final de tu respuesta una etiqueta JSON así: <perfil_update>{"healthConstraints": "dato nuevo"}</perfil_update>
- Apóyate en el RAG inyectado si es relevante.
      `;

      // Mensaje de turno actual estructurado
      const userTurn = {
        role: "user" as const,
        parts: [
          {
            text: `### MENSAJE ACTUAL:\n${mensaje_actual}`,
          },
        ],
      };

      // Combinar historial reciente de chat para mantener el contexto fluido de conversación
      const contents = [...formattedHistory, userTurn];

      // Configuración de herramientas
      const tools: any[] = [];
      if (authSkills.includes("web_search")) {
        tools.push({ googleSearch: {} });
      }

      // Disparar inferencia a Gemini con parámetros optimizados (Low Temp, Top P, Max Tokens)
      const response = await ai.models.generateContent({
        model: "gemini-3.5-flash",
        contents: contents,
        config: {
          systemInstruction: systemInstruction,
          temperature: 0.3,
          topP: 0.9,
          maxOutputTokens: 300,
          tools: tools.length > 0 ? tools : undefined,
        },
      });

      let responseText = response.text || "No se ha podido procesar una respuesta coherente.";
      let perfilUpdateObj = null;

      // Extract and remove <perfil_update> JSON tag
      const perfilMatch = responseText.match(/<perfil_update>([\s\S]*?)<\/perfil_update>/);
      if (perfilMatch) {
        try {
          perfilUpdateObj = JSON.parse(perfilMatch[1].trim());
          responseText = responseText.replace(perfilMatch[0], '').trim();
        } catch (e) {
          console.error("Failed to parse perfil_update JSON", e);
        }
      }

      // Detección heurística inteligente para activar skills si el modelo lo decide o si está implícito
      let skillToCall: string | null = null;
      let skillArgs: any = null;

      const lowerMessage = mensaje_actual.toLowerCase();
      if ((lowerMessage.includes("agend") || lowerMessage.includes("program") || lowerMessage.includes("calendario")) && authSkills.includes("agenda_crear")) {
        skillToCall = "agenda_crear";
        skillArgs = {
          title: capsula_activa.id === "fitness_expert" ? "Entrenamiento Fénix" : "Consulta de Hábito",
          desc: "Auto-programado de manera reactiva por Fénix basado en fatiga o ritmo actual.",
        };
      } else if ((lowerMessage.includes("notific") || lowerMessage.includes("record") || lowerMessage.includes("avis")) && authSkills.includes("notificacion_enviar")) {
        skillToCall = "notificacion_enviar";
        skillArgs = {
          body: "Fénix te recuerda: Prioriza la alineación mecánica señalada en tu cápsula de conocimiento.",
        };
      }

      // Retornar payload mapeado de manera idéntica al ChatResponseSchema del VPS en FastAPI
      res.json({
        response: responseText,
        perfil_update: perfilUpdateObj,
        trigger: skillToCall
          ? {
              skill_to_call: skillToCall,
              arguments: skillArgs,
            }
          : null,
      });
    } catch (e: any) {
      console.error("FenixVpsException:", e);
      res.status(500).json({
        error: "FenixVpsException - Fallo al ejecutar la inferencia de cerebro ciego.",
        details: e.message || String(e),
      });
    }
  });

  // API Route: VPS Generador de Notificaciones Push Personalizadas (RAG Híbrido + Gemini)
  app.post("/api/v1/generate-push", async (req: express.Request, res: express.Response): Promise<void> => {
    try {
      const {
        capsula_activa,
        active_skills,
        perfil_identidad,
        contexto_rag_hibrido,
        push_type, // "consejo" | "agenda" | "alerta"
      } = req.body;

      if (!capsula_activa) {
        res.status(400).json({
          error: "FenixVpsException - Falta la cápsula activa para contextualizar la notificación.",
        });
        return;
      }

      const authSkills = active_skills || capsula_activa.allowed_skills || [];
      const userHistoryNotes = contexto_rag_hibrido?.historial_usuario || "Ninguna nota de diarios.";
      const expertEvidence = contexto_rag_hibrido?.conocimiento_experto || "Ninguna base de de conocimiento experta.";
      const type = push_type || "consejo";

      // Reconstrucción del contexto para el Prompter de Notificaciones
      const systemInstruction = `
        Eres el motor inteligente de Notificaciones Push de "Fénix", la Enciclopedia Modular Soberana.
        Debes formular una sola alerta u recordatorio push altamente personalizado para la pantalla del móvil.
        Estás simulando la transmisión cifrada desde el VPS en Hostinger.
        
        DETALLES DE OPERACIÓN:
        - Tipo solicitado de Push: "${type.toUpperCase()}"
        - Cápsula remisora actual: "${capsula_activa.name}" (${capsula_activa.roleDescription})
        - Directiva Conductual: "${capsula_activa.system_prompt}"
        - Herramientas nativas del terminal móvil: ${JSON.stringify(authSkills)}
        
        PERFIL DE IDENTIDAD SQLite DEL USUARIO:
        ${JSON.stringify(perfil_identidad || "No provisto")}
        
        RAG HÍBRIDO RECUPERADO (Vínculos Locales Desencriptados):
        - Diario personal: "${userHistoryNotes}"
        - Evidencia científica/técnica: "${expertEvidence}"
        
        REGLAS DE FORMATO ESTRICTAS:
        - Debes devolver ÚNICAMENTE un objeto JSON bien formateado.
        - NO incluyas markdown de código como \`\`\`json ni texto explicativo antes o después. Devuelve raw JSON.
        - El JSON debe tener exactamente las siguientes claves:
          "title": Un título sumamente atractivo y compacto en español (máx. 35 caracteres). Por ejemplo: "⚠️ Alerta Biomecánica", "🥑 Balance Ceto-Sodio", "🧘 Recordatorio Estoico".
          "body": El mensaje push directo, perspicaz y accionable (máx. 110 caracteres). Debe referenciar de forma sutil las dolencias/metas o historiales del usuario y la cápsula activa basándose exclusivamente en el RAG.
          "skill_to_trigger": La herramienta de sistema a disparar. Elige una de estas: "notificacion_enviar" o "agenda_crear". Si es de tipo "agenda", prefiere "agenda_crear". Si es alerta o consejo, usa "notificacion_enviar". Solo usa lo permitido por las habilidades de la cápsula: ${JSON.stringify(authSkills)}.
          "skill_args": Un objeto con los parámetros de la skill. Si es "agenda_crear", debe llevar "title" y "desc". Si es "notificacion_enviar", debe llevar "body".
          "reasoning_context": Una breve frase que explique qué parte del RAG Híbrido se usó para construir este consejo.
          
        Tono por Cápsula:
        - Coach Carlos (Fitness): Tono preventivo, enérgico, enfocado en cuidar lumbares o articulaciones.
        - Dra. Sofía (Nutrición): Científico, empírico, enfocado en sales, hidratación, cetonas y bioenergética celular.
        - Mentor Aurelio (Zen): Pausado, filosófico, enfocado en control mental, respiración y resiliencia estoica.
        - Fénix Base (Coordinador General): Asistente general, amigable, natural y servicial. Coordina especialistas y sugiere abordajes multidisciplinares.
      `;

      let responseJSONText = "";

      // Si tenemos KEY configurada, usamos a Gemini de verdad (Simulando USE_CLOUD_FALLBACK=True)
      if (process.env.GEMINI_API_KEY) {
        const response = await ai.models.generateContent({
          model: "gemini-3.5-flash",
          contents: [{ role: "user", parts: [{ text: "Generar notificación push en JSON basado en las instrucciones del sistema." }] }],
          config: {
            systemInstruction: systemInstruction,
            temperature: 0.3,
            topP: 0.9,
            maxOutputTokens: 200,
            responseMimeType: "application/json",
          },
        });
        responseJSONText = response.text || "";
      }

      let parsedPush;
      
      if (responseJSONText.trim()) {
        try {
          parsedPush = JSON.parse(responseJSONText);
        } catch (jsonErr) {
          console.warn("Fallo al parsear raw JSON de Gemini para Push. Leyendo heurísticamente...", jsonErr);
          // Regex fallback por si acaso
          const match = responseJSONText.match(/\{[\s\S]*\}/);
          if (match) {
            parsedPush = JSON.parse(match[0]);
          }
        }
      }

      // Si no tenemos API key o falló el parseo, proveemos plantillas de fallback súper adaptadas usando el RAG en tiempo real localmente:
      if (!parsedPush) {
        console.log("Usando motor de templates heurísticos Fénix local...");
        if (capsula_activa.id === "fitness_expert") {
          const hasLumbar = perfil_identidad?.healthConstraints?.toLowerCase().includes("lumbar") || perfil_identidad?.toLowerCase?.().includes("lumbar");
          parsedPush = {
            title: type === "agenda" ? "🗓️ Ajuste Mecánico" : type === "alerta" ? "⚠️ Alerta Lumbar" : "🏋️‍♂️ Consejo de Carga",
            body: hasLumbar 
              ? "Evita flexión lumbar al descender. Bloquea dorsales e inicia con empuje de cadera (Hip Hinge)."
              : "Sincroniza tus series de esfuerzo. Mantener los dorsales activos asegura inmunidad biomecánica.",
            skill_to_trigger: type === "agenda" && authSkills.includes("agenda_crear") ? "agenda_crear" : "notificacion_enviar",
            skill_args: type === "agenda" && authSkills.includes("agenda_crear") 
              ? { title: "Ajuste Biomecánico Fénix", desc: "Monitoreo preventivo del músculo lumbar y cadera." }
              : { body: "Torsión neutral lumbosacra requerida." },
            reasoning_context: "Mapeado heurístico local del diario_fatiga.md y la biomecánica lumbar del RAG sobre Peso Muerto."
          };
        } else if (capsula_activa.id === "nutricion_expert") {
          const hasElectrolitos = userHistoryNotes.toLowerCase().includes("electrolito") || userHistoryNotes.toLowerCase().includes("cabeza");
          parsedPush = {
            title: "🥑 Fénix Bio-Nutrición",
            body: hasElectrolitos 
              ? "Dolor de cabeza leve detectado. Repón de 3g a 5g de sodio con agua mineral y consume sales adaptativas."
              : "La pérdida de glucógeno inicial debilita membranas. Asegura potasio (aguacate) para tu rendimiento energético.",
            skill_to_trigger: "notificacion_enviar",
            skill_args: { body: "Aporte mineral metabólico listo para asimilación celular." },
            reasoning_context: "Derivado local de la literatura científica de adaptación lipídica y dolores por pérdida de sodio."
          };
        } else if (capsula_activa.id === "zen_mentor") {
          parsedPush = {
            title: type === "agenda" ? "⏳ Sesión de Pausa" : "🧘 Foco Estoico",
            body: "Picos de estrés laboral listados. Dedica 10 minutos para discernir qué está bajo tu control absoluto hoy.",
            skill_to_trigger: type === "agenda" && authSkills.includes("agenda_crear") ? "agenda_crear" : "notificacion_enviar",
            skill_args: type === "agenda" && authSkills.includes("agenda_crear")
              ? { title: "Introspección Estoica", desc: "10 min de meditación estoica y control de respiración." }
              : { body: "Retoma control somático con respiración profunda." },
            reasoning_context: "Inyectado del diario de atención y literatura zen-estoica Aurelio para amortiguar el cortisol laboral."
          };
        } else if (capsula_activa.id === "elderly_care") {
          parsedPush = {
            title: type === "agenda" ? "🗓️ Rutina Geriátrica" : "🧓 Apoyo Continuo",
            body: "Recuerda revisar la presión arterial y asegurar la ingesta de líquidos constantes del usuario mayor.",
            skill_to_trigger: type === "agenda" && authSkills.includes("agenda_crear") ? "agenda_crear" : "notificacion_enviar",
            skill_args: type === "agenda" && authSkills.includes("agenda_crear")
              ? { title: "Revisar Medicación", desc: "Monitoreo continuo" }
              : { body: "Es momento de ofrecer un pequeño vaso de agua." },
            reasoning_context: "Generado en base a los protocolos locales de cuidado geriátrico."
          };
        } else if (capsula_activa.id === "biohacking_expert") {
          parsedPush = {
            title: type === "agenda" ? "⏳ Terapia Térmica" : "🧬 Optimización NAD+",
            body: "Iniciemos la regulación neurobiológica con protocolo de contraste térmico para disparar dopamina.",
            skill_to_trigger: type === "agenda" && authSkills.includes("agenda_crear") ? "agenda_crear" : "notificacion_enviar",
            skill_args: type === "agenda" && authSkills.includes("agenda_crear")
              ? { title: "Baño Hielo / Sauna", desc: "Protocolo de HSPs y dopamina" }
              : { body: "Revisa exposición a luz matutina." },
            reasoning_context: "Consultado a base local criptográfica sobre biohacking y ritmo circadiano."
          };
        } else if (capsula_activa.id === "pro_work_assistant") {
          parsedPush = {
            title: type === "agenda" ? "📅 Time-Boxing" : "💼 Deep Work",
            body: "Inicia el bloqueo de 50 minutos de Deep Work absoluto (Pomodoro). Desactiva de inmediato redes y atiende solo la tarea crítica actual.",
            skill_to_trigger: type === "agenda" && authSkills.includes("agenda_crear") ? "agenda_crear" : "notificacion_enviar",
            skill_args: type === "agenda" && authSkills.includes("agenda_crear")
              ? { title: "Sesión Deep Work", desc: "50 min de trabajo profundo" }
              : { body: "Aplica la regla de los 2 minutos, despeja el inbox." },
            reasoning_context: "Filtrando heurísticamente los esquemas de priorización de PMOs y GTD."
          };
        } else {
          parsedPush = {
            title: type === "agenda" ? "🗓️ Enlace Síncrono" : "👋 Base Fénix",
            body: "He notado registros nuevos en tus diarios. Recomiendo una revisión multi-disciplinar conmigo.",
            skill_to_trigger: type === "agenda" && authSkills.includes("agenda_crear") ? "agenda_crear" : "notificacion_enviar",
            skill_args: type === "agenda" && authSkills.includes("agenda_crear")
              ? { title: "Revisión Fénix", desc: "Revisión multidisciplinar de diarios." }
              : { body: "Estoy disponible para asistirte con todos los expertos." },
            reasoning_context: "Mapeado heurístico base del histórico general del usuario."
          };
        }
      }

      // Devolver la notificación generada
      res.json({
        title: parsedPush.title || "Fénix Notificación",
        body: parsedPush.body || "Consejo preventivo estructurado síncronamente.",
        type: type,
        skill_to_trigger: parsedPush.skill_to_trigger || "notificacion_enviar",
        skill_args: parsedPush.skill_args || { body: parsedPush.body },
        reasoning_context: parsedPush.reasoning_context || "Contexto RAG Híbrido Fénix",
        timestamp: new Date().toLocaleTimeString("es-ES", { hour: "2-digit", minute: "2-digit" }),
      });

    } catch (e: any) {
      console.error("FenixPushVpsException:", e);
      res.status(550).json({
        error: "FenixVpsException - Fallo al generar la notificación push contextualizada.",
        details: e.message || String(e),
      });
    }
  });

  // API Route: VPS Generador de Consolidación Nocturna (PROMPT_CONSOLIDACION)
  app.post("/api/v1/consolidate", async (req: express.Request, res: express.Response): Promise<void> => {
    try {
      const { historial_dia } = req.body;
      
      const systemInstruction = `
Actúa como la mente subconsciente de un asistente personal de élite. Tu trabajo es analizar todo el historial de conversaciones del usuario durante el día de hoy para extraer conocimiento profundo, actualizar su perfil evolutivo y generar su diario.

Analiza el texto adjunto y devuelve ESTRICTAMENTE un objeto JSON con la siguiente estructura:
{
"resumen_markdown": "Un diario del día en formato Markdown limpio. Incluye secciones como: ### Resumen del Día, ### Logros, ### Estado de Ánimo detectado, ### Notas de Salud.",
"nuevos_datos_perfil": [
{"campo": "Nombre del campo en SQLite", "valor": "Nueva información aprendida hoy"}
],
"alertas_coach": "Consejos o advertencias críticas para el día de mañana basadas en hoy."
}

Reglas estrictas:
- No inventes datos. Si el usuario no mencionó cambios en sus hábitos, deja 'nuevos_datos_perfil' vacío.
- Sé analítico y objetivo.
      `;

      if (process.env.GEMINI_API_KEY) {
        const response = await ai.models.generateContent({
          model: "gemini-3.5-flash",
          contents: [{ role: "user", parts: [{ text: `HISTORIAL DEL DÍA:\n${historial_dia || "Ningún mensaje."}` }] }],
          config: {
            systemInstruction: systemInstruction,
            temperature: 0.1,
            responseMimeType: "application/json",
          },
        });
        
        let responseJSONText = response.text || "";
        let parsedData = null;
        try {
            parsedData = JSON.parse(responseJSONText);
        } catch (jsonErr) {
            console.warn("Fallo al parsear JSON consolidación.", jsonErr);
            const match = responseJSONText.match(/\{[\s\S]*\}/);
            if (match) {
                parsedData = JSON.parse(match[0]);
            }
        }
        if (parsedData) {
            res.json(parsedData);
            return;
        }
      }

      // Fallback
      res.json({
        resumen_markdown: "### Resumen del Día\nEl VPS ha procesado este turno localmente con los datos heurísticos. Sistema offline activo.\n### Estado de Ánimo detectado\nEstable.\n### Notas de Salud\nMonitoreo general activo.",
        nuevos_datos_perfil: [],
        alertas_coach: "Mantener el programa operativo sin alteraciones para mañana."
      });
      
    } catch (e: any) {
      console.error("FenixConsolidateException:", e);
      res.status(500).json({
        error: "Fallo en la consolidación de la memoria subconsciente.",
        details: e.message || String(e),
      });
    }
  });

  // Health check simple de VPS
  app.get("/api/v1/health", (req, res) => {
    res.json({ status: "online", node: "VPS-Hostinger-Stateless-16GB", cpu_optimization: "AVX2-enabled" });
  });

  // Configuración del Frontend estático de Vite / Express Middleware
  if (process.env.NODE_ENV !== "production") {
    const vite = await createViteServer({
      server: { middlewareMode: true },
      appType: "spa",
    });
    app.use(vite.middlewares);
  } else {
    const distPath = path.join(process.cwd(), "dist");
    app.use(express.static(distPath));
    app.get("*", (req, res) => {
      res.sendFile(path.join(distPath, "index.html"));
    });
  }

  app.listen(PORT, "0.0.0.0", () => {
    console.log(`[Fenix Server] Corriendo en puerto ${PORT}`);
  });
}

startServer();
