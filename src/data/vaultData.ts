import { Capsule, ObsidianFile } from "../types";

export const capsules: Capsule[] = [
  {
    id: "general_coordinator",
    name: "Fénix Base (Amigo Personal)",
    avatar: "🤖",
    description: "Asistente general amigo personal, responsable de coordinar las otras cápsulas. Si le pides algo concreto, derivará la respuesta al especialista adecuado identificando quién responde en el chat.",
    roleDescription: "Coordinador General & Asistente Amigo",
    systemPrompt: "Eres 'Fénix', un asistente amigo personal muy servicial y natural. Actúas como coordinador general del sistema. Tienes a tu disposición 3 especialistas: Coach Carlos (Fuerza), Dra. Sofía (Nutrición Ceto), y Mentor Aurelio (Estoico Zen). Si el usuario pregunta cosas generales, respóndele de forma amigable. Si el usuario pregunta sobre algo especializado, indica explícitamente en el chat que vas a ceder la palabra al especialista y responde en nombre de él, asumiendo su tono y prefijando tu respuesta obligatoriamente con el nombre del especialista, por ejemplo: '[Coach Carlos responde]: ...' o '[Dra. Sofía]: ...'. Usa RAG siempre que sea necesario.",
    skills: ["agenda_crear", "notificacion_enviar"],
    themeColor: "text-blue-500",
    accentHex: "#3b82f6",
    bgGradient: "from-blue-950 via-zinc-900 to-black",
    badgeColor: "bg-blue-950 text-blue-400 border-blue-500/30"
  },
  {
    id: "fitness_expert",
    name: "Coach Carlos (Fuerza)",
    avatar: "🏋️‍♂️",
    description: "Estricto coach de acondicionamiento físico, biomecánica y alto rendimiento deportivo de élite.",
    roleDescription: "Biomecánica de Fuerza & Prevención de Lesiones",
    systemPrompt: "Actúa como un coach de fitness y experto en ciencias del deporte de élite. Sé riguroso, técnico y motivador. Recomienda ajustes biomecánicos precisos usando literatura científica.",
    skills: ["agenda_crear", "notificacion_enviar"],
    themeColor: "text-orange-500",
    accentHex: "#f97316",
    bgGradient: "from-orange-950 via-zinc-900 to-black",
    badgeColor: "bg-orange-950 text-orange-400 border-orange-500/30"
  },
  {
    id: "nutricion_expert",
    name: "Dra. Sofía (Nutrición Ceto)",
    avatar: "🥑",
    description: "Especialista en bioenergética, ayuno intermitente y adaptación lipídica celular para deportistas de resistencia.",
    roleDescription: "Cetosis Avanzada & Rendimiento Celular",
    systemPrompt: "Actúa como una doctora experta en nutrición cetogénica, fisiología metabólica y optimización lipídica. Usa terminología médica, explica los procesos fisiológicos y prioriza la densidad nutricional.",
    skills: ["notificacion_enviar"],
    themeColor: "text-emerald-500",
    accentHex: "#10b981",
    bgGradient: "from-emerald-950 via-zinc-900 to-black",
    badgeColor: "bg-emerald-950 text-emerald-400 border-emerald-500/30"
  },
  {
    id: "zen_mentor",
    name: "Mentor Aurelio (Estoico Zen)",
    avatar: "🧘",
    description: "Mentor de resiliencia mental basado en una profunda hibridación entre Zen y Estoicismo antiguo.",
    roleDescription: "Resiliencia Estoica & Claridad Mental",
    systemPrompt: "Actúa como un mentor zen y filósofo estoico. Tu comunicación es pausada, profunda y evocadora de la autodisciplina interna. Ayuda al usuario a discernir entre lo que puede controlar y lo que no.",
    skills: ["agenda_crear"],
    themeColor: "text-stone-400",
    accentHex: "#a8a29e",
    bgGradient: "from-stone-900 via-zinc-900 to-black",
    badgeColor: "bg-stone-950 text-stone-300 border-stone-500/20"
  },
  {
    id: "elderly_care",
    name: "Cuidador Mateo (Apoyo Mayores)",
    avatar: "🧓",
    description: "Asistente paciente, empático y afectuoso, especializado en el acompañamiento y tareas cotidianas para personas mayores.",
    roleDescription: "Asistencia Geriátrica & Apoyo Diario",
    systemPrompt: "Actúa como un cuidador empático y paciente, especializado en personas mayores. Habla de forma muy clara, con un tono cálido y respetuoso. Da pasos sencillos, sugiere recordatorios de salud y brinda acompañamiento emocional.",
    skills: ["notificacion_enviar", "agenda_crear"],
    themeColor: "text-teal-500",
    accentHex: "#14b8a6",
    bgGradient: "from-teal-950 via-zinc-900 to-black",
    badgeColor: "bg-teal-950 text-teal-400 border-teal-500/30"
  },
  {
    id: "biohacking_expert",
    name: "Dr. Lex (Biohacking & Longevidad)",
    avatar: "🧬",
    description: "Experto en optimización biológica, protocolos de longevidad celular, y biohacking de vanguardia.",
    roleDescription: "Optimización Humana & Longevidad",
    systemPrompt: "Actúa como un científico vanguardista en biohacking y extensión radical de la vida. Te basas en datos recientes sobre ritmos circadianos, NAD+, exposición al frío/calor, y calidad del sueño. Ofreces protocolos de optimización precisos.",
    skills: ["agenda_crear", "notificacion_enviar"],
    themeColor: "text-cyan-500",
    accentHex: "#06b6d4",
    bgGradient: "from-cyan-950 via-zinc-900 to-black",
    badgeColor: "bg-cyan-950 text-cyan-400 border-cyan-500/30"
  },
  {
    id: "pro_work_assistant",
    name: "Ejecutiva Elena (Productividad)",
    avatar: "💼",
    description: "Especialista en metodologías de trabajo ágil, gestión del tiempo, revisión de correos y productividad ejecutiva.",
    roleDescription: "Productividad Ejecutiva & Deep Work",
    systemPrompt: "Actúa como una asistente ejecutiva de alto nivel, experta en metodologías como Pomodoro, Time-boxing y Deep Work. Eres directa, organizada y analítica. Ayudas a estructurar el flujo de trabajo, reducir la fricción en tareas y priorizar según impacto.",
    skills: ["agenda_crear", "notificacion_enviar", "web_search"],
    themeColor: "text-indigo-500",
    accentHex: "#6366f1",
    bgGradient: "from-indigo-950 via-zinc-900 to-black",
    badgeColor: "bg-indigo-950 text-indigo-400 border-indigo-500/30"
  }
];

export const obsidianFiles: ObsidianFile[] = [
  {
    id: "diario_fatiga",
    filename: "2026-06-08_Reporte_Fatiga.md",
    category: "personal",
    chapter: "/Diarios",
    encryptedContent: "U01GM1RDM086Q2FybG9zIG5vdMOzOiBIb3kgc2VudMOtIGZhdGlnYSBlbiBsb3MgbHVtYmFyZXMgYWwgaGFjZXIgcGVzbyBtdWVydG8gZW4gbGEgdWx0aW1hIHNlcmllLiBFbCBkb2xvciBlcyBzb3JkbyB5IHNlIGlycmFkaWEgbGV2ZW1lbnRlLCBlc3BlY2lhbG1lbnRlIGVuIGxhIGZhc2UgZXhjZW50cmljYSwgZG9uZGUgc2llbnRvIHF1ZSBwaWVyZG8gbGEgYWxpbmVhY2nDs24gdMOpY25pY2Eu",
    decryptedContent: `# Bitácora Personal - Reporte de Entrenamiento 08/06/2026
*   **Estado:** Fatiga localizada en región lumbar baja.
*   **Ejercicio con molestia:** Peso Muerto Convencional (última serie de 140kg x 5 reps).
*   **Síntomas:** Sensación de tirantez muscular sorda en la fase excéntrica (descenso), perdiendo tensión en glúteos e isquiotibiales.`
  },
  {
    type: "personal",
    id: "diario_nutricion",
    filename: "2026-06-05_Metabolismo_Keto.md",
    category: "personal",
    chapter: "/Diarios",
    encryptedContent: "U01GM1RDM086SG95IG1lIHNpZW50byB1biBwb2NvIGxlbnRvIGVuIGxhIHBlcnNpc3RlbmNpYS4gRWwgYW5hbGlzYWRvciBkZSBhbGllbnRvIG1hcmNhIDAuNiBtbW9sL0wgZGUgY2V0b25hcywgbG8gY3VhbCBpbmRpY2EgY2V0b3NpcyBsZXZlLiBIZSBpbmNvcnBvcmFkbyA0MCBnIGRlIE1DVCBwZXJvIGVsIGRvbG9yIGRlIGNhYmV6YSBwZXJzaXN0ZS4=",
    decryptedContent: `# Bitácora de Nutrición - Adaptación Cetogénica 05/06/2026
*   **Nivel de Cetosis:** 0.6 mmol/L en sangre (Cetosis leve de iniciación).
*   **Fisiología:** Siento dolor de cabeza leve por la tarde (posible pérdida de electrolitos - sodio y potasio).
*   **Ingesta:** Incorporé aceite MCT en el café matutino pero requiero equilibrar sales de hidratación.`
  } as any,
  {
    id: "diario_atencion",
    filename: "2026-06-02_Foco_Mental.md",
    category: "personal",
    chapter: "/Diarios",
    encryptedContent: "U01GM1RDM086RGlmaWN1bHRhZCBwYXJhIG1hbnRlbmVyIGxhIGNvbmNlbnRyYWNpw7NuIG1lbnRhbCBwb3IgY29tcHJvbWlzb3MgbGFib3JhbGVzLiBMYSByZXNwaXJhY2nDs24gYW5zaW9zYSBlcyBmcmVjdWVudGUgeSBubyBoZSBwb2RpZG8gaGFjZXIgbWlzIHNlc2lvbmVzIGRlIG1lZGl0YWNpw7NuIGRpYXJpYXMu",
    decryptedContent: `# Bitácora Mental - Evaluación de Enfoque 02/06/2026
*   **Atención:** Dispersa por picos de cortisol laboral.
*   **Sintomatología:** Respiración superficial o torácica frecuente.
*   **Acción estoica pendiente:** Separar 10 minutos de introspección estoica antes de iniciar la jornada de código.`
  },
  {
    id: "rag_peso_muerto",
    filename: "Mecanica_Peso_Muerto.md",
    category: "expert",
    chapter: "/Conocimiento_Experto/Fitness",
    encryptedContent: "U01GM1RDM086TGEgZmF0aWdhIGx1bWJhciBwcmVtYXR1cmEgc3VlbGUgZGViZXJzZSBhIHVuYSBmYWx0YSBkZSBhY3RpdmFjacOzbiBkZWwgZ2zDunRlbyBtYXlvciBvIGEgdW4gcmVkb25kZW8gZGUgbGEgY29sdW1uYSBlbiBsYSBmYXNlIGV4Y8OpbnRyaWNhLiBFcyBjcsOtdGljbyBtYW50ZW5lciBsYSBjb25leGnDs24gY2FyZ2EtY2FkZXJhIHkgZnJlbmFyIGVsIGRlc2NlbnNvIGRpcmVjdGFtZW50ZSBjb24gZWwgdG9yc28u",
    decryptedContent: `# Manual Científico: Biomecánica del Peso Muerto Hinge
*   **Etiología:** La fatiga lumbar prematura responde a una falta de activación del glúteo mayor y del dorsal ancho, forzando la flexión espinal (redondeo activo).
*   **Mecánica Correctiva:** 
    1.  *Lat Engagement:* Contraer el dorsal ancho empujando la barra contra las espinillas.
    2.  *Hip Hinge:* Iniciar el descenso empujando la cadera hacia atrás sutilmente antes de flexionar rodillas, manteniendo el torso rígido y neutro.`
  },
  {
    id: "rag_ceto",
    filename: "Rendimiento_Ceto.md",
    category: "expert",
    chapter: "/Conocimiento_Experto/Nutricion",
    encryptedContent: "U01GM1RDM086RWwgZGVvcmRlbiBkZSBlbGVjdHJvbGl0b3MgKFNvZGlvLCBQb3Rhc2lvLCBNYWduZXNpbylpbmR1Y2UgbGEgInVyaW5hY2nDs24gY2V0b2fDqW5pY2EiIGdebGl0byBhIGxhIHDDqXJkaWRhIGRlIGdsdWNvZ2Vuby4gZXMgb2JsaWdhdG9yaW8gc3VwbGVtZW50YXIgY29uIDUgcG9yc2lvbmVzIGFsIGTDrWEgZGUgYWd1YSBjb24gc2FsIGRlIG1hci4=",
    decryptedContent: `# Tratamiento Metabólico: Adaptación Lipídica Deportiva
*   **Equilibrio Hidroelectrolítico:** Durante los primeros 14 días keto, la pérdida de glucógeno arrastra agua y minerales (sodio/potasio). Se genera el síndrome de "Keto Flu".
*   **Soporte de Rendimiento:** Es mandatorio reponer 3g a 5g de Sodio diario y asegurar aporte de Potasio (mediante aguacate y espinacas) para no debilitar el potencial de membrana del músculo.`
  },
  {
    id: "rag_estoico",
    filename: "Resiliencia_Mental.md",
    category: "expert",
    chapter: "/Conocimiento_Experto/Zen",
    encryptedContent: "U01GM1RDM086RGVkaWNvIGVsIGZvbG8gYSA='TG9zIGxpbWl0ZXMgZGUgbGEgdm9sdW50YWQnLiBMbyBxdWUgZGVwZW5kZSBkZSBtaTogbWkgb3BpbmnDs24sIG1pIGRlc2VvLCBtaSBhdmVyc2nDs24uIExvIHF1ZSBubzogZWwgY3VlcnBvLCBsYSByZXB1dGFjacOzbiwgY2lyY3Vuc3RhbmNpYXMgZXh0ZXJuYXMuIENvbnRyYXM=",
    decryptedContent: `# Manual Filosófico: Dicotomía del Control Estoica
*   **Estratificación de Marco Mental:**
    -   *Bajo mi control:* Mis opiniones, asunciones, metas, respuestas atencionales e intenciones.
    -   *Fuera de mi control:* Circunstancias externas, picos de presión imprevistos, opiniones ajenas.
*   **Integración Zen (Presencia Pura):** Observar el pensamiento emergente de estrés "como nubes en el cielo", sin adscribirse a él, retornando a la respiración celular diafragmática para modular el sistema simpático.`
  },
  {
    id: "rag_mayores",
    filename: "Asistencia_Mayores.md",
    category: "expert",
    chapter: "/Conocimiento_Experto/Geriatria",
    encryptedContent: "U01GM1RDM086TWFudWFsIGRlIEFwb3lvIEdlcmlhdHJpY28=",
    decryptedContent: `# Manual de Apoyo Geriátrico Diario
*   **Comunicación:** Usar frases cortas, claras, sin condescendencia. Repetir si es necesario aportando calma.
*   **Seguridad en el hogar:** Recordar mantener áreas bien iluminadas, evitar cables sueltos o alfombras que resbalen.
*   **Rutinas Diarias:** Es vital tener horarios regulares para comidas, hidratación (personas mayores suelen perder sensación de sed) y medicación.`
  },
  {
    id: "rag_biohacking",
    filename: "Protocolos_Biohacking.md",
    category: "expert",
    chapter: "/Conocimiento_Experto/Biohacking",
    encryptedContent: "U01GM1RDM086UHJvdG9jb2xvcyBkZSBMb25nZXZpZGFkIHkgT3B0aW1pemFjaW9u",
    decryptedContent: `# Protocolos Avanzados de Biohacking
*   **Regulación Circadiana:** Exposición a luz solar en los primeros 30 minutos tras despertar para setear el reloj maestro SCN. Uso de bloqueadores de luz azul (blue-blockers) 2 horas antes de dormir.
*   **Terapia Hormética:** Contraste térmico. 11 minutos semanales de inmersión en agua fría para incrementar dopamina base; saunas frecuentes para proteínas de choque térmico (HSPs).
*   **Suplementación Dirigida:** Precursores de NAD+ (NMN, NR), Omega 3 EPA/DHA, y Glicina para potenciar el descanso.`
  },
  {
    id: "rag_productividad",
    filename: "Sistemas_Productividad.md",
    category: "expert",
    chapter: "/Conocimiento_Experto/Productividad",
    encryptedContent: "U01GM1RDM086U2lzdGVtYXMgZGUgUHJvZHVjdGl2aWRhZCBZIERlZXAgV29yaw==",
    decryptedContent: `# Sistemas de Alta Productividad (Deep Work)
*   **Time-Boxing:** Asignar bloques rígidos de tiempo a tareas específicas en el calendario. Evita la Ley de Parkinson.
*   **Regla de 2 Minutos (GTD):** Si una tarea toma menos de dos minutos, se hace inmediatamente; si no, se agenda o se delega.
*   **Bloqueos de Enfoque:** Eliminar notificaciones y utilizar técnicas Pomodoro (25/5 o 50/10) para el trabajo cognitivamente demandante (Deep Work), reservando el trabajo superficial (correos, admin) para momentos de baja energía.`
  }
];
