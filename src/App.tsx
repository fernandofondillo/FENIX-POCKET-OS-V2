import React, { useState, useEffect, useRef } from "react";
import { motion, AnimatePresence } from "motion/react";
import {
  Shield,
  Cpu,
  Layers,
  Lock,
  Unlock,
  Send,
  RefreshCw,
  FileText,
  Database,
  Terminal,
  Copy,
  Check,
  Settings,
  User,
  Folder,
  BookOpen,
  Sparkles,
  Flame,
  ArrowRight,
  CodeXml,
  Menu,
  Activity,
  Calendar,
  BellRing,
  Blocks,
  Plus,
  Trash2,
  Eye,
  Speaker,
  Globe,
  HardDrive,
  AlertTriangle,
  Mic,
  MicOff
} from "lucide-react";

import { capsules, obsidianFiles } from "./data/vaultData";
import { productionFiles } from "./data/productionCode";
import { Capsule, ObsidianFile, IdentityProfile, ChatMessage } from "./types";

export default function App() {
  // --- AUTH STATUS (SIMULACIÓN ONBOARDING MÓVIL) ---
  const [isAuthenticated, setIsAuthenticated] = useState<boolean>(false);
  const [onboardingStep, setOnboardingStep] = useState<number>(1);
  const [authForm, setAuthForm] = useState({
    nombre: "",
    profesion: "",
    meta: "",
    vpsUrl: "https://api.fenix.me"
  });
  const [isInitializingVault, setIsInitializingVault] = useState<boolean>(false);

  // --- STATE CORE ---
  const [activeCapsule, setActiveCapsule] = useState<Capsule>(capsules[0]);
  const [activeTab, setActiveTab] = useState<"operations" | "obsidian" | "vps" | "code" | "notifications" | "skills">("operations");
  
  // Perfil evolutivo de identidad SQLite móvil
  const [identity, setIdentity] = useState<IdentityProfile | null>(null);

  // --- MEMORY WATCHER (RAM) ---
  const [memoryUsage, setMemoryUsage] = useState({ used: 412, total: 4096 });
  const [memoryWarning, setMemoryWarning] = useState(false);

  useEffect(() => {
    // Simulador de fluctuación de memoria constante
    const interval = setInterval(() => {
      setMemoryUsage(prev => {
        let fluctuation = Math.floor(Math.random() * 40) - 20; // -20 to +20 MB
        let newUsed = prev.used + fluctuation;
        
        if (newUsed < 200) newUsed = 200;
        if (newUsed > 3800) newUsed = 3800; // Cap
        
        setMemoryWarning(newUsed > 3000); // Trigger warning at 3GB
        
        return { ...prev, used: newUsed };
      });
    }, 2000);
    return () => clearInterval(interval);
  }, []);



  // Estado del Nano-Obsidian Dual
  const [localVaultFiles, setLocalVaultFiles] = useState<ObsidianFile[]>(obsidianFiles);
  const [selectedFile, setSelectedFile] = useState<ObsidianFile>(obsidianFiles[0]);
  const [isDecrypting, setIsDecrypting] = useState<boolean>(false);
  const [decryptedFiles, setDecryptedFiles] = useState<Record<string, boolean>>({});
  
  // Añadir nuevo archivo a la boveda
  const [showAddDoc, setShowAddDoc] = useState(false);
  const [newDocForm, setNewDocForm] = useState({ filename: "", category: "personal" as "personal" | "expert", content: "" });

  const handleCreateDocument = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newDocForm.filename || !newDocForm.content) return;
    
    const newId = newDocForm.filename.toLowerCase().replace(/[^a-z0-9_]/g, '_') + '_' + Date.now();
    const isPersonal = newDocForm.category === "personal";
    
    const newDoc: ObsidianFile = {
      id: newId,
      filename: newDocForm.filename + ".md",
      category: newDocForm.category,
      chapter: isPersonal ? "/Diarios/Registro_Usuario" : "/Conocimiento_Experto/Definido_Por_Usuario",
      encryptedContent: "U01GM1RDM086TlVFVk8gRE9DVU1FTlRPG" + btoa(newDocForm.content.substring(0, 10)).substring(0, 10) + "==",
      decryptedContent: newDocForm.content
    };
    
    setLocalVaultFiles(prev => [...prev, newDoc]);
    setShowAddDoc(false);
    setNewDocForm({ filename: "", category: "personal", content: "" });
  };
  
  // Chat Historial (Memoria de Trabajo de 15 msg)
  const [messages, setMessages] = useState<ChatMessage[]>([
    {
      id: "init",
      role: "assistant",
      content: "¡Saludos, soberano! Soy tu compañero Fénix. He cargado la base cognitiva de tu cápsula activa y decodificado los diarios locales en RAM de forma segura. ¿Qué ajuste biomecánico o consulta fisiológica coordinamos hoy?",
      timestamp: "17:48",
      ragContextUsed: {
        userNote: "Cargados diarios locales cifrados.",
        expertArticle: "Enlazado compendio científico correspondido."
      }
    }
  ]);
  const [inputMessage, setInputMessage] = useState<string>("");
  const [isProcessingChat, setIsProcessingChat] = useState<boolean>(false);
  const [isRecording, setIsRecording] = useState<boolean>(false);
  const recognitionRef = useRef<any>(null);

  // Payload actual observable
  const [currentPayload, setCurrentPayload] = useState<any>(null);

  // Code repository active file
  const [selectedCodeIdx, setSelectedCodeIdx] = useState<number>(0);
  const [copiedFileIndex, setCopiedFileIndex] = useState<number | null>(null);

  // VPS mock logs
  const [vpsLogs, setVpsLogs] = useState<string[]>([
    "[SYSTEM] VPS Fénix Stateless Online en Hostinger 16GB",
    "[SYSTEM] Escuchando consultas HTTPS cifradas con TLS v1.3",
    "[SYSTEM] Motor de inferencia listo (CPU optimizada con vectorizado AVX2/FMA)"
  ]);

  // --- STATE SISTEMA NOTIFICACIONES PUSH REAL-TIME ---
  const [activePush, setActivePush] = useState<{
    id: string;
    title: string;
    body: string;
    type: "consejo" | "agenda" | "alerta";
    skill: string;
    args: any;
    reasoning: string;
    timestamp: string;
  } | null>(null);

  const [pushHistory, setPushHistory] = useState<any[]>([
    {
      id: "push-init-1",
      title: "🔒 Bóveda Sincronizada",
      body: "La bóveda Nano-Obsidian está encriptada y lista. Llaves locales inyectadas en síncrono.",
      type: "consejo",
      skill: "notificacion_enviar",
      reasoning: "Inicio automático síncrono del sistema.",
      timestamp: "17:48",
      status: "executed",
      capsuleId: "fitness_expert",
    }
  ]);

  const [isGeneratingPush, setIsGeneratingPush] = useState<boolean>(false);
  const [pushSettings, setPushSettings] = useState({
    homomorphicEncryption: true,
    backgroundInference: true,
    activeIntervalHours: 4,
  });

  useEffect(() => {
    if (isDecrypting || isProcessingChat || isGeneratingPush) {
      setMemoryUsage(prev => {
        let newUsed = prev.used + Math.floor(Math.random() * 400) + 200; // Bump 200-600MB
        if (newUsed > 3800) newUsed = 3800;
        setMemoryWarning(newUsed > 3000);
        return { ...prev, used: newUsed };
      });
    }
  }, [isDecrypting, isProcessingChat, isGeneratingPush]);

  // --- STATE SKILLS DEL DISPOSITIVO ---
  const [installedSkills, setInstalledSkills] = useState<any[]>([
    { id: "agenda_crear", name: "Agenda Dinámica", category: "Sistema Base", description: "Programación de eventos y recordatorios en el calendario local del móvil.", installed: true, icon: "Calendar" },
    { id: "notificacion_enviar", name: "Motor Push Local", category: "Sistema Base", description: "Inyección de alertas en el hub de mensajería nativa del teléfono.", installed: true, icon: "BellRing" },
  ]);

  const availableSkillsList = [
    { id: "agenda_crear", name: "Agenda Dinámica", category: "Sistema Base", description: "Programación de eventos y recordatorios en el calendario local del móvil.", installed: true, icon: "Calendar" },
    { id: "notificacion_enviar", name: "Motor Push Local", category: "Sistema Base", description: "Inyección de alertas en el hub de mensajería nativa del teléfono.", installed: true, icon: "BellRing" },
    { id: "read_health_data", name: "Health/Fitbit Sync", category: "Salud", description: "Lectura cifrada de pasos y HRV vía API nativa iOS/Android.", installed: false, icon: "Activity" },
    { id: "audio_transcribe", name: "Sensor ASR (Whisper)", category: "Voz", description: "Transcriptor local de voz a texto on-device offline.", installed: false, icon: "Speaker" },
    { id: "vision_document", name: "Escáner Óptico OCR", category: "Visión OCR", description: "Extrae analíticas de fotos (ej. analíticas de sangre o diarios fitness).", installed: false, icon: "Eye" },
    { id: "read_db", name: "Nativo SQL Sinc", category: "Mantenimiento", description: "Ejecución de sincronización offline First en Local SQLite.", installed: false, icon: "Database" },
    { id: "web_search", name: "Búsqueda Web Avanzada", category: "Nube / API", description: "Realiza búsquedas semánticas y en tiempo real en internet.", installed: false, icon: "Globe" },
    { id: "gmail_read", name: "Google Workspace - Gmail", category: "Nube / API (Soberano)", description: "OAuth2 Sync: Lectura, resumen local y estructuración de correos.", installed: false, icon: "CodeXml" },
    { id: "calendar_manage", name: "Google Workspace - Calendar", category: "Nube / API (Soberano)", description: "OAuth2 Sync: Gestión y orquestación de reuniones/agenda.", installed: false, icon: "Calendar" },
  ];

  const [availableSkills, setAvailableSkills] = useState<any[]>(availableSkillsList);
  const [showAddSkill, setShowAddSkill] = useState(false);
  const [newSkillForm, setNewSkillForm] = useState({ id: "", name: "", category: "Personalizado", description: "" });

  const handleCreateSkill = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newSkillForm.id || !newSkillForm.name) return;
    
    const newSkillId = newSkillForm.id.toLowerCase().replace(/[^a-z0-9_]/g, '_');
    const newSkill = { ...newSkillForm, id: newSkillId, installed: true, icon: "Blocks" };
    
    setAvailableSkills(prev => [...prev, newSkill]);
    setInstalledSkills(prev => [...prev, newSkill]);
    setShowAddSkill(false);
    setNewSkillForm({ id: "", name: "", category: "Personalizado", description: "" });
  };

  const handleInstallSkill = (skillId: string) => {
    setAvailableSkills(prev => prev.map(s => s.id === skillId ? { ...s, installed: true } : s));
    const skillToInstall = availableSkills.find(s => s.id === skillId);
    if (skillToInstall && !installedSkills.some(s => s.id === skillId)) {
      setInstalledSkills(prev => [...prev, { ...skillToInstall, installed: true }]);
    }
  };

  const handleUninstallSkill = (skillId: string) => {
    setAvailableSkills(prev => prev.map(s => s.id === skillId ? { ...s, installed: false } : s));
    setInstalledSkills(prev => prev.filter(s => s.id !== skillId));
  };

  const messagesEndRef = useRef<HTMLDivElement>(null);

  // --- AUTOMATIC RAG INJECTION GENERATOR (OPTIMIZED FOR FAST CPU INFERENCE) ---
  // Genera el RAG híbrido de manera asíncrona simulada (Isolate móvil) para no bloquear el UI
  const getSimulatedRagContextAsync = async (capsuleId: string) => {
    // Simulamos la latencia de desencriptación AES en un hilo secundario (Isolate)
    await new Promise(resolve => setTimeout(resolve, 30)); 
    let personalNote = "";
    let expertArticle = "";

    // Filtro estricto RAG: máximo ~200 palabras por segmento
    const clipWords = (text: string, maxWords: number = 200) => {
      if (!text) return "";
      const words = text.split(/\s+/);
      return words.length > maxWords ? words.slice(0, maxWords).join(" ") + " [TRUNCADO_POR_RAG_LIMIT]" : text;
    };

    if (capsuleId === "fitness_expert") {
      const pFile = localVaultFiles.find(f => f.id === "diario_fatiga");
      const eFile = localVaultFiles.find(f => f.id === "rag_peso_muerto");
      personalNote = pFile?.decryptedContent || "";
      expertArticle = eFile?.decryptedContent || "";
    } else if (capsuleId === "nutricion_expert") {
      const pFile = localVaultFiles.find(f => f.id === "diario_nutricion");
      const eFile = localVaultFiles.find(f => f.id === "rag_ceto");
      personalNote = pFile?.decryptedContent || "";
      expertArticle = eFile?.decryptedContent || "";
    } else if (capsuleId === "zen_mentor") {
      const pFile = localVaultFiles.find(f => f.id === "diario_atencion");
      const eFile = localVaultFiles.find(f => f.id === "rag_estoico");
      personalNote = pFile?.decryptedContent || "";
      expertArticle = eFile?.decryptedContent || "";
    } else if (capsuleId === "elderly_care") {
      const pFile = localVaultFiles.find(f => f.category === "personal");
      const eFile = localVaultFiles.find(f => f.id === "rag_mayores");
      personalNote = pFile?.decryptedContent || "Diario general.";
      expertArticle = eFile?.decryptedContent || "";
    } else if (capsuleId === "biohacking_expert") {
      const pFile = localVaultFiles.find(f => f.category === "personal");
      const eFile = localVaultFiles.find(f => f.id === "rag_biohacking");
      personalNote = pFile?.decryptedContent || "Diario general.";
      expertArticle = eFile?.decryptedContent || "";
    } else if (capsuleId === "pro_work_assistant") {
      const pFile = localVaultFiles.find(f => f.category === "personal");
      const eFile = localVaultFiles.find(f => f.id === "rag_productividad");
      personalNote = pFile?.decryptedContent || "Diario general.";
      expertArticle = eFile?.decryptedContent || "";
    } else if (capsuleId === "general_coordinator") {
      // Combines all diaries and all expert knowledge
      personalNote = localVaultFiles.filter(f => f.category === "personal").map(f => f.decryptedContent).join("\n\n---\n\n");
      expertArticle = localVaultFiles.filter(f => f.category === "expert").map(f => f.decryptedContent).join("\n\n---\n\n");
    }

    // Limitamos estrictamente el RAG a fragmentos de max 400 palabras en total
    return {
      historial_usuario: clipWords(personalNote, 150),
      conocimiento_experto: clipWords(expertArticle, 250)
    };
  };

  // Actualiza el JSON del payload en vivo cada vez que cambian variables del estado en el móvil
  useEffect(() => {
    let isMounted = true;
    
    getSimulatedRagContextAsync(activeCapsule.id).then(rag => {
      if (!isMounted) return;
      
      // Podado estricto del historial (mantener últimos 8 mensajes para no saturar CPU en VPS)
      // Excluimos mensajes del sistema para mayor limpieza
      const recentHist = messages.slice(-8).filter(m => m.role !== "system").map(m => ({
        role: m.role,
        content: m.content
      }));

      const installedSkillIds = installedSkills.map(s => s.id);
      const mockRequestPayload = {
        user_id: "UUID-Fenix-Mobile-987X-Anon",
        capsula_activa: {
          id: activeCapsule.id,
          system_prompt: activeCapsule.systemPrompt,
          allowed_skills: activeCapsule.skills
        },
        active_skills: installedSkillIds,
        perfil_identidad: `${identity?.name} | ${identity?.profession} | Entrena ${identity?.trainingRythmn} | Foco: ${identity?.focusGoal} | Restricciones: ${identity?.healthConstraints}`,
        contexto_rag_hibrido: {
          historial_usuario: rag.historial_usuario ? "[Cargado de /Diarios]: " + rag.historial_usuario.substring(0, 75) + "..." : "Ninguno",
          conocimiento_experto: rag.conocimiento_experto ? "[Cargado de /Conocimiento_Experto]: " + rag.conocimiento_experto.substring(0, 75) + "..." : "Ninguno"
        },
        historial_reciente: recentHist,
        mensaje_actual: inputMessage || "(Escribiendo...)"
      };

      setCurrentPayload(mockRequestPayload);
    });
    
    return () => { isMounted = false; };
  }, [activeCapsule, identity, messages, inputMessage, localVaultFiles, installedSkills]);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages, isProcessingChat]);

  // Al conmutar de cápsula, agregamos una notificación del sistema interna en el chat y cambiamos el RAG
  const handleCapsuleChange = (capsule: Capsule) => {
    setActiveCapsule(capsule);
    const systemNotice: ChatMessage = {
      id: "notice-" + Date.now(),
      role: "system",
      content: `Capsule Swapped: ${capsule.name} iniciada visual y cognitivamente en el móvil de forma síncrona.`,
      timestamp: new Date().toLocaleTimeString("es-ES", { hour: '2-digit', minute: '2-digit' })
    };
    setMessages(prev => [...prev, systemNotice]);
  };

  // --- LOCAL MD DECRYPTION SIMULATION ---
  const handleDecryptFile = (fileId: string) => {
    setIsDecrypting(true);
    setTimeout(() => {
      setDecryptedFiles(prev => ({ ...prev, [fileId]: true }));
      setIsDecrypting(false);
    }, 1200); // laser decrypt delay
  };

  // --- TRIGGER CONSOLIDATE MEMORY ---
  const [isConsolidating, setIsConsolidating] = useState<boolean>(false);
  const [consolidationResult, setConsolidationResult] = useState<any>(null);

  const triggerConsolidation = async () => {
    if (isConsolidating) return;
    setIsConsolidating(true);
    setConsolidationResult(null);
    setVpsLogs(prev => [
      ...prev,
      `[POST /consolidate] ${new Date().toISOString()} - Iniciando consolidación subconsciente`,
      ` -> Extrayendo historial del chat del día...`
    ]);

    const historial_str = messages.filter(m => m.role !== 'system').map(m => `[${m.timestamp}] ${m.role.toUpperCase()}: ${m.content}`).join("\n");

    try {
      const response = await fetch("/api/v1/consolidate", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ historial_dia: historial_str })
      });

      if (!response.ok) throw new Error(`Status: ${response.status}`);
      const data = await response.json();

      if (data.nuevos_datos_perfil && data.nuevos_datos_perfil.length > 0) {
        let newUpdates: any = {};
        data.nuevos_datos_perfil.forEach((d: any) => { newUpdates[d.campo] = d.valor; });
        setIdentity(prev => ({ ...prev, ...newUpdates }));
      }

      setConsolidationResult({
        markdown: data.resumen_markdown,
        alertas: data.alertas_coach,
        changes: data.nuevos_datos_perfil
      });

      setVpsLogs(prev => [
        ...prev,
        ` -> Éxito en consolidación. Archivos generados y perfil actualizado.`
      ]);

      // Generar nuevo archivo en Nano-Obsidian
      const timestamp = Date.now();
      const newDocId = "diario_dia_" + timestamp;
      const newFile: ObsidianFile = {
        id: newDocId,
        filename: `Diario_Consolidado_${new Date().toLocaleDateString('es-ES').replace(/\//g,'-')}.md`,
        category: "personal",
        chapter: "/Diarios/Registro_Automatico",
        encryptedContent: "U01GM1RDM086RDI0UklPX0NVTlNP=",
        decryptedContent: data.resumen_markdown + "\n\n---\n\n**Alertas Coach:** " + data.alertas_coach
      };
      setLocalVaultFiles(prev => [newFile, ...prev]);

    } catch (err) {
      console.error(err);
      setVpsLogs(prev => [...prev, `[FALLO] Consolidación nocturna falló.`]);
      setConsolidationResult({
        markdown: "### Error\nNo se pudo ejecutar la inferencia remota para la consolidación.",
        changes: [],
        alertas: ""
      });
    } finally {
      setIsConsolidating(false);
    }
  };

  // --- TRIGGER LIVE PUSH NOTIFICATION (VPS + GEMINI) ---
  const triggerLivePushNotification = async (type: "consejo" | "agenda" | "alerta") => {
    if (isGeneratingPush) return;
    setIsGeneratingPush(true);

    const activeRag = await getSimulatedRagContextAsync(activeCapsule.id);
    const requestPayload = {
      capsula_activa: {
        id: activeCapsule.id,
        name: activeCapsule.name,
        system_prompt: activeCapsule.systemPrompt,
        allowed_skills: activeCapsule.skills
      },
      active_skills: installedSkills.map(s => s.id),
      perfil_identidad: identity,
      contexto_rag_hibrido: activeRag,
      push_type: type
    };

    setVpsLogs(prev => [
      ...prev,
      `[POST /generate-push] ${new Date().toISOString()} - Despachando consulta de push síncrona`,
      ` -> Canal: Push Inteligente (${type.toUpperCase()})`,
      ` -> Inyectando Bóveda Nano-Obsidian descriptada en RAM...`
    ]);

    try {
      const response = await fetch("/api/v1/generate-push", {
        method: "POST",
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify(requestPayload)
      });

      if (!response.ok) {
        throw new Error(`Error de servidor status: ${response.status}`);
      }

      const data = await response.json();

      const newPush = {
        id: "push-" + Date.now(),
        title: data.title,
        body: data.body,
        type: data.type,
        skill: data.skill_to_trigger,
        args: data.skill_args,
        reasoning: data.reasoning_context,
        timestamp: data.timestamp,
        status: "received",
        capsuleId: activeCapsule.id
      };

      // Establecer como push activo flotante en la pantalla notch de celular
      setActivePush(newPush);
      // Agregar al histórico Ledger Seguro
      setPushHistory(prev => [newPush, ...prev]);

      setVpsLogs(prev => [
        ...prev,
        ` -> Éxito en Inferencia. Título: [${data.title}]`,
        ` -> Skill detectada: [${data.skill_to_trigger}]`
      ]);

    } catch (err: any) {
      console.error(err);
      setVpsLogs(prev => [
        ...prev,
        ` [FALLO PUSH] Inferencia fallida para push de tipo ${type}. Corriendo template alternativo local...`
      ]);

      // Fallback seguro en local para que la experiencia sea fluida si no hay internet o API key
      const isFitness = activeCapsule.id === "fitness_expert";
      const isNutri = activeCapsule.id === "nutricion_expert";
      const isGeneral = activeCapsule.id === "general_coordinator";
      
      const localTitle = type === "agenda" 
        ? "🗓️ Fénix Agenda Local" 
        : type === "alerta" 
          ? "⚠️ Alerta de Alineación" 
          : "🧠 Fénix Consejo Local";
          
      const localBody = isFitness
        ? "Carlos, fatiga lumbar reportada. Aplica de inmediato el Hip Hinge del manual y dorsales activos."
        : isNutri
          ? "Cetosis leve detectada. Asegura de 3g a 5g de sodio para mitigar la Keto Flu latente."
          : isGeneral
            ? "He detectado varios reportes en tus diarios. Sugiero que me pidas una revisión multi-disciplinar pronto."
            : "Atención desalineada. Tómate 10 min de introspección estoica frente al cortisol de trabajo.";

      const localSkill = type === "agenda" && activeCapsule.skills.includes("agenda_crear") ? "agenda_crear" : "notificacion_enviar";
      const localArgs = localSkill === "agenda_crear" 
        ? { title: "Dedicación Postural", desc: "Automantenimiento lumbar preventivo." }
        : { body: localBody };

      const fallbackPush = {
        id: "push-local-" + Date.now(),
        title: localTitle,
        body: localBody,
        type: type,
        skill: localSkill,
        args: localArgs,
        reasoning: "Generada heurísticamente basado en perfiles locales SQLite y lectura en frío de bases Markdown.",
        timestamp: new Date().toLocaleTimeString("es-ES", { hour: "2-digit", minute: "2-digit" }),
        status: "received",
        capsuleId: activeCapsule.id
      };

      setActivePush(fallbackPush);
      setPushHistory(prev => [fallbackPush, ...prev]);
    } finally {
      setIsGeneratingPush(false);
    }
  };

  // --- EJECUTAR SKILL NATIVA DESDE NOTIFICACIÓN (MÓVIL SOBERANO) ---
  const handleExecutePushSkill = (push: any) => {
    setVpsLogs(prev => [
      ...prev,
      `[MÓVIL NATIVO] Disparando automatización local desde Push [${push.id}]`,
      ` -> Ejecutando Skill: ${push.skill}`,
      ` -> Parámetros resueltos: ${JSON.stringify(push.args || {})}`
    ]);

    // Insertar aviso en el chat
    const isAgenda = push.skill === "agenda_crear";
    const userNotice: ChatMessage = {
      id: "push-notice-" + Date.now(),
      role: "system",
      content: isAgenda
        ? `📅 Automatización Móvil: Evento programado en agenda ("${push.args?.title || push.title}") - Desc: ${push.args?.desc || "Sincronizado con RAG"}`
        : `🔔 Automatización Móvil: Alerta despachada en pantalla ("${push.body}")`,
      timestamp: new Date().toLocaleTimeString("es-ES", { hour: '2-digit', minute: '2-digit' })
    };

    setMessages(prev => [...prev, userNotice]);

    // Marcar como ejecutada en el historial local
    setPushHistory(prev => prev.map(p => p.id === push.id ? { ...p, status: "executed" } : p));

    // Descartar visual de notch
    setActivePush(null);
  };

  // --- MIC LOGIC ---
  const handleMicrophone = () => {
    if (isRecording) {
      if (recognitionRef.current) {
        recognitionRef.current.stop();
      }
      setIsRecording(false);
      return;
    }
    
    // Check for native browser support
    const SpeechRecognitionAPI = (window as any).SpeechRecognition || (window as any).webkitSpeechRecognition;
    
    if (SpeechRecognitionAPI) {
      setIsRecording(true);
      try {
        const recognition = new SpeechRecognitionAPI();
        recognitionRef.current = recognition;
        recognition.lang = 'es-ES';
        // Interims can be true to show text typing in real time, but that requires more complex state handling
        // We'll stick to final for simplicity, or handle interims if needed.
        recognition.interimResults = false;
        recognition.maxAlternatives = 1;
        
        recognition.start();
        
        recognition.onresult = (event: any) => {
          const speechResult = event.results[0][0].transcript;
          setInputMessage(prev => prev + (prev.trim() ? " " : "") + speechResult);
          setIsRecording(false);
        };
        
        recognition.onerror = (event: any) => {
          console.error("Speech recognition error", event.error);
          setIsRecording(false);
          // Fallback to simulation if there is a permission error (e.g. no mic allowed)
          if (event.error === 'not-allowed') {
             console.warn("Microphone not allowed, check iframe permissions. Simulating...");
             simulateSpeech();
          }
        };
        
        recognition.onend = () => {
          setIsRecording(false);
        };
      } catch (err) {
        console.error("Failed to start speech recognition", err);
        setIsRecording(false);
        simulateSpeech();
      }
    } else {
      console.warn("Speech API not supported in this browser. Simulating...");
      // Simulation fallback for unsupported browsers
      setIsRecording(true);
      simulateSpeech();
    }
  };

  const simulateSpeech = () => {
    setTimeout(() => {
      setInputMessage(prev => prev + (prev.trim() ? " " : "") + "¿Me podrías leer los últimos correos del trabajo y agendar esa reunión?");
      setIsRecording(false);
    }, 3000);
  };

  // --- SEND CHAT TO REAL SERVER ENDPOINT ---
  const handleSendMessage = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!inputMessage.trim() || isProcessingChat) return;

    const userText = inputMessage;
    setInputMessage("");

    // Agregar mensaje del usuario a la lista
    const newUserMessage: ChatMessage = {
      id: "msg-user-" + Date.now(),
      role: "user",
      content: userText,
      timestamp: new Date().toLocaleTimeString("es-ES", { hour: '2-digit', minute: '2-digit' })
    };

    setMessages(prev => [...prev, newUserMessage]);
    setIsProcessingChat(true);

    const activeRag = await getSimulatedRagContextAsync(activeCapsule.id);
    const installedSkillIds = installedSkills.map(s => s.id);
    const requestPayload = {
      user_id: "UUID-Fenix-Mobile-987X-Anon",
      capsula_activa: {
        id: activeCapsule.id,
        system_prompt: activeCapsule.systemPrompt,
        allowed_skills: activeCapsule.skills
      },
      active_skills: installedSkillIds,
      perfil_identidad: `${identity?.name}, ${identity?.profession}, entrenamientos: ${identity?.trainingRythmn}, meta principal: ${identity?.focusGoal}, restricción física médica: ${identity?.healthConstraints}`,
      contexto_rag_hibrido: activeRag,
      // Podado estricto: VPS CPU optimization, solo últimos 8
      historial_reciente: messages.slice(-8).filter(m => m.role !== "system").map(m => ({
        role: m.role,
        content: m.content
      })),
      mensaje_actual: userText
    };

    // Registrar logs en la terminal VPS simulada
    setVpsLogs(prev => [
      ...prev,
      `[POST /chat] ${new Date().toISOString()} - Petición de user_id: UUID-Fenix-Mobile-987X-Anon`,
      ` -> Inyectando RAG dual: ${activeCapsule.id} (Historial y Manual Científico)`,
      ` -> Ejecutando llamadas con gemini-3.5-flash y TLS v1.3...`
    ]);

    try {
      // Disparamos conexión real a nuestra ruta API en server.ts
      const response = await fetch("/api/v1/chat", {
        method: "POST",
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify(requestPayload)
      });

      if (!response.ok) {
        throw new Error("Respuesta inválida del VPS Fénix.");
      }

      const data = await response.json();

      if (data.perfil_update) {
        setIdentity(prev => ({ ...prev, ...data.perfil_update }));
        setVpsLogs(prev => [
          ...prev,
          `[UPDATE /perfil] ${new Date().toISOString()} - SQLite Perfil Evolutivo Actualizado desde VPS (Function Calling)`
        ]);
      }

      setMessages(prev => [
        ...prev,
        {
          id: "msg-asst-" + Date.now(),
          role: "assistant",
          content: data.response,
          timestamp: new Date().toLocaleTimeString("es-ES", { hour: '2-digit', minute: '2-digit' }),
          ragContextUsed: {
            userNote: activeRag.historial_usuario.split("\n")[0] || "Ninguno",
            expertArticle: activeRag.conocimiento_experto.split("\n")[0] || "Ninguno"
          },
          triggeredSkill: data.trigger
            ? {
                name: data.trigger.skill_to_call,
                description: data.trigger.skill_to_call === "agenda_crear"
                  ? "Programado evento en Agenda Móvil"
                  : "Empujada alerta preventiva",
                args: data.trigger.arguments
              }
            : null
        }
      ]);

      if (data.trigger) {
        const triggerName = data.trigger.skill_to_call;
        const triggerArgs = data.trigger.arguments || {};
        const isAgenda = triggerName === "agenda_crear";
        const pushTitle = isAgenda ? "🗓️ Enlace de Agenda" : "⚠️ Alerta Biocognitiva";
        const pushBody = isAgenda 
          ? (triggerArgs.title || "Ajuste de Esfuerzo Fénix") 
          : (triggerArgs.body || "Alineamiento espinal requerido.");
          
        const chatPushMsg = {
          id: "push-chat-" + Date.now(),
          title: pushTitle,
          body: pushBody,
          type: isAgenda ? "agenda" as const : "alerta" as const,
          skill: triggerName,
          args: triggerArgs,
          reasoning: "Generada en caliente por inferencia proactiva del chat VPS.",
          timestamp: new Date().toLocaleTimeString("es-ES", { hour: "2-digit", minute: "2-digit" }),
          status: "received",
          capsuleId: activeCapsule.id
        };
        setActivePush(chatPushMsg);
        setPushHistory(prev => [chatPushMsg, ...prev]);
      }

      setVpsLogs(prev => [
        ...prev,
        ` -> Inferencia completada. Output tokens de Gemini mapeados a JSON Schema.`,
        ` -> Enrutados Triggers: ${data.trigger ? `Nativo [${data.trigger.skill_to_call}]` : "Ninguno"}`
      ]);

    } catch (err: any) {
      console.error(err);
      setMessages(prev => [
        ...prev,
        {
          id: "msg-err-" + Date.now(),
          role: "assistant",
          content: `FenixVpsException: No se pudo enlazar el cerebro con el VPS de Hostinger. Detalles: ${err.message || String(err)}. Comprueba si se ha inyectado correctamente la variable GEMINI_API_KEY en la configuración de la app.`,
          timestamp: new Date().toLocaleTimeString("es-ES", { hour: '2-digit', minute: '2-digit' })
        }
      ]);
    } finally {
      setIsProcessingChat(false);
    }
  };

  // --- COPY CODE FUNCTION ---
  const copyToClipboard = (text: string, index: number) => {
    navigator.clipboard.writeText(text);
    setCopiedFileIndex(index);
    setTimeout(() => {
      setCopiedFileIndex(null);
    }, 2000);
  };

  if (!isAuthenticated) {
    return (
      <div className="min-h-screen bg-[#0C0C0C] font-sans flex flex-col justify-center select-none selection:bg-[#C5A059]/30 selection:text-white relative overflow-hidden">
        {onboardingStep === 1 && (
          <div className="flex flex-col items-center justify-center p-8 max-w-lg mx-auto w-full z-10 animate-in fade-in zoom-in duration-500 relative">
            <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-64 h-64 bg-[#C5A059]/5 blur-[100px] rounded-full pointer-events-none" />
            <Shield className="w-20 h-20 text-[#C5A059] mb-8 relative" />
            <h1 className="text-white font-serif text-3xl font-bold tracking-[0.1em] mb-4 text-center">A.G.O.S. / FÉNIX</h1>
            <p className="text-white/60 text-center font-sans text-sm leading-relaxed mb-12 max-w-sm">
              Tu Agente de Inteligencia Soberana.<br/>
              100% Privado. Zero-Knowledge. Evolutivo.
            </p>
            <button
              onClick={() => setOnboardingStep(2)}
              className="bg-[#C5A059] hover:bg-[#B38F4B] text-black px-8 py-3.5 rounded-xl font-bold text-sm tracking-wide transition-all hover:scale-105 active:scale-95 shadow-[0_4px_20px_rgba(197,160,89,0.2)]"
            >
              Inicializar mi Asistente Soberano
            </button>
          </div>
        )}

        {onboardingStep === 2 && (
          <div className="flex justify-center p-4 z-10 sm:p-8 animate-in slide-in-from-right-4 fade-in duration-500 overflow-y-auto">
            <div className="w-full max-w-md">
              <h2 className="text-white font-serif text-2xl font-bold mb-2">Arquitectura de Identidad</h2>
              <p className="text-white/50 text-xs mb-8">
                Configura la matriz local. Estos datos no viajan de forma estática en la red, se inyectan en tiempo de ejecución al vuelo.
              </p>

              <div className="space-y-5">
                <div>
                  <label className="block text-white/70 text-xs font-semibold mb-2">Tu Nombre/Alias</label>
                  <input
                    type="text"
                    placeholder="Ej. Alex"
                    value={authForm.nombre}
                    onChange={e => setAuthForm(prev => ({ ...prev, nombre: e.target.value }))}
                    className="w-full bg-[#141414] border border-[#2A2A2A] rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-[#C5A059]/50 transition-colors"
                  />
                </div>

                <div>
                  <label className="block text-white/70 text-xs font-semibold mb-2">Profesión / Rol</label>
                  <input
                    type="text"
                    placeholder="Ej. Ingeniero DevOps, Estudiante"
                    value={authForm.profesion}
                    onChange={e => setAuthForm(prev => ({ ...prev, profesion: e.target.value }))}
                    className="w-full bg-[#141414] border border-[#2A2A2A] rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-[#C5A059]/50 transition-colors"
                  />
                </div>

                <div>
                  <label className="block text-white/70 text-xs font-semibold mb-2">Meta Principal con Fénix</label>
                  <input
                    type="text"
                    placeholder="Ej. Productividad, Fitness, Longevidad"
                    value={authForm.meta}
                    onChange={e => setAuthForm(prev => ({ ...prev, meta: e.target.value }))}
                    className="w-full bg-[#141414] border border-[#2A2A2A] rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-[#C5A059]/50 transition-colors"
                  />
                </div>

                <div className="my-6 border-t border-[#2A2A2A]" />

                <h3 className="text-white font-serif text-lg font-bold mb-2">Conexión VPS (Multiusuario)</h3>

                <div>
                  <label className="block text-white/70 text-xs font-semibold mb-2">URL Endpoint Fénix <span className="text-[#C5A059]">(Requerido)</span></label>
                  <input
                    type="url"
                    value={authForm.vpsUrl}
                    onChange={e => setAuthForm(prev => ({ ...prev, vpsUrl: e.target.value }))}
                    className="w-full bg-[#1A1814] border border-[#C5A059]/50 rounded-xl px-4 py-3 text-sm text-[#C5A059] font-mono focus:outline-none focus:border-[#C5A059] transition-colors shadow-[0_0_15px_rgba(197,160,89,0.05)_inset]"
                  />
                </div>

                <button
                  disabled={isInitializingVault}
                  onClick={() => {
                    if (!authForm.nombre.trim() || !authForm.vpsUrl.trim()) return;
                    setIsInitializingVault(true);
                    
                    // Simulación de generación AES-256 e instanciación local
                    setTimeout(() => {
                      setIdentity({
                        name: authForm.nombre,
                        profession: authForm.profesion || "Indefinido",
                        goals: authForm.meta ? [authForm.meta] : [],
                        trainingRythmn: "Pendiente de explorar",
                        focusGoal: authForm.meta || "Exploratorio",
                        healthConstraints: "Ninguna conocida",
                        physicalData: { injuries: [], diet: "No especificada" }
                      });
                      setIsInitializingVault(false);
                      setIsAuthenticated(true);
                    }, 2500);
                  }}
                  className="w-full mt-8 bg-[#C5A059] hover:bg-[#B38F4B] text-black px-8 py-4 rounded-xl font-bold text-sm transition-all shadow-[0_4px_20px_rgba(197,160,89,0.2)] disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
                >
                  {isInitializingVault ? (
                    <>
                      <RefreshCw className="w-5 h-5 animate-spin" />
                      Aislando Cápsula Local...
                    </>
                  ) : (
                    "Crear Compañero Personal"
                  )}
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-[#080808] text-[#E0D8D0] flex flex-col font-sans selection:bg-[#C5A059]/30 selection:text-white">
      
      {/* HEADER: SYSTEM STATUS & SOVEREIGNTY INDICATORS */}
      <header className="border-b border-[#2A2A2A] bg-[#0C0C0C] px-8 py-4 flex flex-col md:flex-row md:items-center justify-between gap-4 sticky top-0 z-50">
        <div className="flex items-center gap-4">
          {/* Rotate 45deg elegant gold frame with brand letter */}
          <div className="w-10 h-10 border border-[#C5A059] flex items-center justify-center rotate-45 shrink-0 transition-all duration-300 hover:rotate-135 bg-[#12110F]">
            <div className="-rotate-45 font-serif text-[#C5A059] font-bold text-lg select-none">F</div>
          </div>
          <div>
            <div className="flex items-center gap-2 mb-0.5">
              <span className="font-mono text-[9px] font-semibold tracking-[0.2em] text-[#C5A059] uppercase">Arquitectura Soberana</span>
              <span className="bg-[#141414] text-[#888] text-[9px] px-1.5 py-0.5 rounded border border-[#2A2A2A] font-mono">v2.0-Prod</span>
            </div>
            <h1 className="text-xl font-bold tracking-widest text-[#E0D8D0] uppercase font-sans">Fenix</h1>
            <p className="text-[10px] text-[#888] font-mono tracking-tighter uppercase">PERSONAL ASSISTANT</p>
          </div>
        </div>

        {/* METADATA BAR INTEGRACION REAL - SOPHISTICATED DARK */}
        <div className="flex items-center gap-6 overflow-x-auto py-1">
          <div className="flex flex-col items-end whitespace-nowrap">
            <span className="text-[9px] text-[#666] uppercase tracking-[0.15em] font-mono">Smartphone Memory</span>
            <span className={`text-xs font-mono flex items-center gap-1.5 ${memoryWarning ? 'text-red-500 animate-pulse' : 'text-[#A0A0A0]'}`}>
              <HardDrive className="w-3.5 h-3.5" /> 
              {memoryUsage.used} / {memoryUsage.total} MB
              {memoryWarning && <AlertTriangle className="w-3.5 h-3.5" />}
            </span>
          </div>
          <div className="flex flex-col items-end whitespace-nowrap">
            <span className="text-[9px] text-[#666] uppercase tracking-[0.15em] font-mono">Connection Status</span>
            <span className="text-xs font-mono text-[#4CAF50] flex items-center gap-1.5">
              <span className="w-2 h-2 rounded-full bg-[#4CAF50] animate-pulse"></span> STATELESS VPS : ACTIVE
            </span>
          </div>
          <div className="flex flex-col items-end whitespace-nowrap">
            <span className="text-[9px] text-[#666] uppercase tracking-[0.15em] font-mono">Encryption</span>
            <span className="text-xs font-mono text-[#C5A059] flex items-center gap-1.5">
              <Lock className="w-3.5 h-3.5 text-[#C5A059]" /> AES-256 LOCAL DUAL
            </span>
          </div>
          <div className="flex flex-col items-end whitespace-nowrap">
            <span className="text-[9px] text-[#666] uppercase tracking-[0.15em] font-mono">LLM Core</span>
            <span className="text-xs font-mono text-[#E0D8D0] flex items-center gap-1.5">
              <Cpu className="w-3.5 h-3.5 text-[#E0D8D0]" /> gemini-3.5-flash
            </span>
          </div>
        </div>
      </header>

      {/* DASHBOARD PRINCIPAL CON DIVISION DE PANTALLA */}
      <main className="flex-1 max-w-7xl w-full mx-auto p-4 md:p-6 grid grid-cols-1 lg:grid-cols-12 gap-6">
        
        {/* COLUMNA IZQUIERDA: EL SIMULADOR MÓVIL DEL FLUTTER NATIVO (45% o 5 Cols) */}
        <section className="col-span-1 lg:col-span-5 flex flex-col items-center justify-start xl:justify-center w-full">
          
          {/* CARCASA DEL TELÉFONO DE LUJO OBISDIAN */}
          <div className="w-full sm:max-w-[380px] bg-[#0A0A0A] rounded-[24px] md:rounded-[44px] p-0 sm:p-3.5 border sm:border-4 border-[#2A2A2A] shadow-2xl relative overflow-hidden ring-1 ring-[#C5A059]/10">
            
            {/* Notch superior del smartphone */}
            <div className="hidden sm:flex absolute top-0 left-1/2 -translate-x-1/2 h-6 w-32 bg-[#0C0C0C] rounded-b-2xl z-40 items-center justify-center border-x border-b border-[#2A2A2A]/40">
              <div className="w-2.5 h-2.5 rounded-full bg-[#1F1F1F] mr-2 border border-[#2A2A2A]"></div>
              <div className="w-12 h-1 bg-[#1F1F1F] rounded-full"></div>
            </div>

            {/* MARCO VIRTUAL DE CONTEXTO */}
            <div className="bg-[#0A0A0A] sm:bg-[#080808] sm:rounded-[32px] overflow-hidden sm:border border-[#2A2A2A] flex flex-col h-[680px] sm:h-[640px] relative">
              
              {/* NOTIFICACIÓN PUSH ACTIVA FLOTANTE (ESTILO MÓVIL SOBERANO) */}
              <AnimatePresence>
                {activePush && (
                  <motion.div
                    initial={{ opacity: 0, y: -80, scale: 0.9 }}
                    animate={{ opacity: 1, y: 0, scale: 1 }}
                    exit={{ opacity: 0, y: -40, scale: 0.9 }}
                    transition={{ type: "spring", stiffness: 120, damping: 15 }}
                    className="absolute top-11 left-3 right-3 bg-[#0C0B0A]/95 border border-[#C5A059]/50 rounded-2xl p-3 z-50 shadow-2xl backdrop-blur-md ring-1 ring-[#C5A059]/10"
                    style={{ borderTop: "3px solid #C5A059" }}
                  >
                    <div className="flex items-start gap-2.5">
                      <div className="w-8 h-8 rounded-lg bg-[#141311] border border-[#C5A059]/30 flex items-center justify-center text-lg shadow-inner shrink-0 leading-none">
                        {activeCapsule.avatar}
                      </div>
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center justify-between">
                          <span className="text-[10px] uppercase font-mono tracking-wider text-[#C5A059] font-bold">
                            {activePush.title}
                          </span>
                          <span className="text-[8px] text-[#666] font-mono">{activePush.timestamp}</span>
                        </div>
                        <p className="text-[11px] text-[#E0D8D0] leading-relaxed mt-0.5 font-sans break-words pr-1">
                          {activePush.body}
                        </p>
                        
                        {activePush.reasoning && (
                          <div className="text-[8px] text-[#888]/80 font-mono leading-tight mt-1 flex items-center gap-1">
                            <span className="text-[#C5A059]">RAG:</span>
                            <span className="truncate max-w-[180px]">{activePush.reasoning}</span>
                          </div>
                        )}

                        <div className="mt-2.5 pt-1.5 border-t border-[#1C1C1C] flex items-center justify-end gap-2 text-[9px] font-mono font-semibold">
                          {activePush.skill === "agenda_crear" ? (
                            <button
                              type="button"
                              onClick={() => handleExecutePushSkill(activePush)}
                              className="bg-[#C5A059] hover:bg-[#B38F4B] text-[#080808] px-2 py-0.5 rounded font-bold cursor-pointer transition-all flex items-center gap-1"
                            >
                              <Calendar className="w-2.5 h-2.5" />
                              AGENDAR EVENTO
                            </button>
                          ) : (
                            <button
                              type="button"
                              onClick={() => handleExecutePushSkill(activePush)}
                              className="bg-[#1C1C1C] hover:bg-[#2A2A2A] text-[#C5A059] px-2 py-0.5 rounded border border-[#C5A059]/20 font-semibold cursor-pointer transition-all"
                            >
                              MARCAR LEÍDO
                            </button>
                          )}
                          <button
                            type="button"
                            onClick={() => setActivePush(null)}
                            className="text-[#666] hover:text-[#888] px-1 py-0.5 font-sans cursor-pointer"
                          >
                            Desechar
                          </button>
                        </div>
                      </div>
                    </div>
                  </motion.div>
                )}
              </AnimatePresence>

              {/* Barra de estado del móvil */}
              <div className="h-9 bg-[#0C0C0C] px-5 pt-3.5 pb-1 flex justify-between items-center text-[10px] font-mono text-[#888] z-30 select-none">
                <span className="font-semibold text-[#E0D8D0]">17:48 UTC</span>
                <span className="bg-[#1A1009] text-[#C5A059] text-[9px] px-1.5 py-0.5 rounded border border-[#C5A059]/20 flex items-center gap-1 font-mono">
                  <span className="w-1 h-1 rounded-full bg-[#C5A059]"></span> ZERO-KNOWLEDGE
                </span>
                <div className="flex items-center gap-1.5 text-[#4CAF50]">
                  <Activity className="w-3 h-3 text-[#4CAF50]" />
                  <span className="text-[#888] text-[9px]">5G SOBERANO</span>
                </div>
              </div>

              {/* CABECERA DINÁMICA DE LA CÁPSULA (Animated Container Flutter styled for Sophisticated Dark) */}
              <motion.div 
                className="px-4 py-4 border-b border-[#2A2A2A] flex items-center justify-between bg-gradient-to-b from-[#12110F] to-[#0A0A0A]"
                animate={{ transition: { duration: 0.6 } }}
              >
                <div className="flex items-center gap-3">
                  <div className="w-11 h-11 rounded-xl bg-[#080808] border border-[#C5A059]/30 flex items-center justify-center text-2xl shadow-md">
                    {activeCapsule.avatar}
                  </div>
                  <div>
                    <h3 className="text-sm font-bold text-[#E0D8D0] tracking-wide font-sans">{activeCapsule.name}</h3>
                    <p className="text-[10px] text-[#888] font-mono tracking-wider flex items-center gap-1">
                      <span className="w-1.5 h-1.5 bg-[#4CAF50] rounded-full animate-ping"></span>
                      INTEGRADO E INSTALADO
                    </p>
                  </div>
                </div>
                
                {/* Indicador de Skills de esa Cápsula en Caliente */}
                <span className="text-[10px] px-2 py-0.5 rounded-full border border-[#2A2A2A] bg-[#141414] font-mono text-[#888]">
                  {activeCapsule.skills.length} Skills
                </span>
              </motion.div>

              {/* RAG Context Banner indicador */}
              <div className="px-3.5 py-1.5 bg-[#0C0C0C] border-b border-[#2A2A2A] text-[10px] font-mono text-[#888] flex items-center justify-between">
                <span className="flex items-center gap-1">
                  <Database className="w-3 h-3 text-[#C5A059]" />
                  RAG Híbrido:
                </span>
                <span className="text-[#C5A059] uppercase tracking-widest text-[9px] font-semibold">
                  Dual Obsidian Desencriptado
                </span>
              </div>

              {/* PANTALLA DE CHAT (LIST INTEGRADO) */}
              <div className="flex-1 overflow-y-auto px-3.5 py-3 space-y-4 bg-[#080808]/75 scrollbar-thin">
                <AnimatePresence initial={false}>
                  {messages.map((msg, index) => {
                    const isUser = msg.role === "user";
                    const isSystem = msg.role === "system";

                    if (isSystem) {
                      return (
                        <div key={msg.id} className="flex justify-center select-none py-1">
                          <span className="text-[9px] font-mono bg-[#141414] text-[#888] px-3 py-1 rounded-full border border-[#2A2A2A]">
                            {msg.content}
                          </span>
                        </div>
                      );
                    }

                    return (
                      <motion.div
                        key={msg.id}
                        initial={{ opacity: 0, y: 10 }}
                        animate={{ opacity: 1, y: 0 }}
                        exit={{ opacity: 0 }}
                        transition={{ duration: 0.3 }}
                        className={`flex flex-col ${isUser ? "items-end" : "items-start"}`}
                      >
                        {/* Remitente de la burbuja */}
                        <span className="text-[9px] text-[#666] font-mono mb-1 px-1 flex items-center gap-1">
                          {isUser ? identity?.name : activeCapsule.name} • {msg.timestamp}
                        </span>

                        {/* Burbuja propiamente dicha */}
                        <div
                          className={`max-w-[85%] rounded-2xl p-3 text-xs leading-relaxed border ${
                            isUser
                              ? `bg-[#12110F] text-[#E0D8D0] border-[#C5A059]/40 shadow-lg`
                              : "bg-[#141414] text-[#E0D8D0] border-[#2A2A2A] shadow-md"
                          }`}
                          style={isUser ? { borderLeft: `3px solid #C5A059`, borderRadius: "1rem 1rem 0 1rem" } : { borderLeft: `3px solid #888888`, borderRadius: "1rem 1rem 1rem 0" }}
                        >
                          <p className={`whitespace-pre-wrap ${!isUser ? 'font-serif text-[13px] leading-relaxed' : 'font-sans'}`}>{msg.content}</p>

                          {/* INFORMACIÓN SOBRE EL CONTEXTO INYECTADO (RAG) */}
                          {!isUser && msg.ragContextUsed && (
                            <div className="mt-2.5 pt-2 border-t border-[#2A2A2A] text-[10px] text-[#888] space-y-1 font-mono">
                              <span className="text-[#C5A059] text-[9px] font-semibold uppercase flex items-center gap-1">
                                <Shield className="w-3 h-3 text-[#C5A059]" /> Conocimiento Usado en RAM:
                              </span>
                              <div className="bg-[#080808] p-1.5 rounded text-[9px] leading-tight text-[#888] border border-[#2A2A2A]">
                                <div className="text-[#C5A059]/80 truncate">📓 Diarios: {msg.ragContextUsed.userNote}</div>
                                <div className="text-[#4CAF50]/80 truncate mt-0.5">🔬 Base Científica: {msg.ragContextUsed.expertArticle}</div>
                              </div>
                            </div>
                          )}

                          {/* MOTORES DE ACCIÓN NATIVO DISPARADOS DESDE VPS */}
                          {!isUser && msg.triggeredSkill && (
                            <div className="mt-2 pt-2 border-t border-[#2A2A2A] text-[9px] text-[#888]">
                              <div className="bg-[#0C120C] border border-[#1B321B] p-2 rounded flex items-start gap-1.5">
                                {msg.triggeredSkill.name === "agenda_crear" ? (
                                  <Calendar className="w-4 h-4 text-[#4CAF50] shrink-0 mt-0.5" />
                                ) : (
                                  <BellRing className="w-4 h-4 text-[#4CAF50] shrink-0 mt-0.5" />
                                )}
                                <div>
                                  <div className="font-semibold text-[#4CAF50] uppercase tracking-widest font-mono text-[8px]">
                                    Skill Ejecutada en Móvil
                                  </div>
                                  <div className="text-[#E0D8D0] mt-0.5 leading-tight">{msg.triggeredSkill.description}</div>
                                </div>
                              </div>
                            </div>
                          )}
                        </div>
                      </motion.div>
                    );
                  })}
                </AnimatePresence>

                {/* Loader de inferencia */}
                {isProcessingChat && (
                  <div className="flex flex-col items-start">
                    <span className="text-[9px] text-[#666] font-mono mb-1 px-1">
                      Fénix está procesando en el VPS...
                    </span>
                    <div className="bg-[#141414] border border-[#2A2A2A] text-[#888] rounded-2xl rounded-tl-none px-4 py-3 text-xs flex items-center gap-2">
                      <RefreshCw className="w-3.5 h-3.5 animate-spin text-[#C5A059]" />
                      <span>El cerebro ciego está estructurando la inferencia...</span>
                    </div>
                  </div>
                )}
                <div ref={messagesEndRef} />
              </div>

              {/* CAJA DE INPUT (SIMULADA FLUTTER NATIVO) */}
              <form onSubmit={handleSendMessage} className="p-3 bg-[#0C0C0C] border-t border-[#2A2A2A] flex gap-2 items-center">
                <button
                  type="button"
                  onClick={handleMicrophone}
                  disabled={isProcessingChat}
                  className={`p-2.5 rounded-xl transition-all flex items-center justify-center cursor-pointer border ${isRecording ? 'bg-red-500/20 text-red-500 border-red-500/50 animate-pulse' : 'bg-[#141414] text-[#888] border-[#2A2A2A] hover:text-[#C5A059] hover:bg-[#1C1C1C]'}`}
                >
                  {isRecording ? <MicOff className="w-4 h-4" /> : <Mic className="w-4 h-4" />}
                </button>
                <input
                  type="text"
                  value={inputMessage}
                  onChange={(e) => setInputMessage(e.target.value)}
                  placeholder="Pregunta o describe síntomas..."
                  disabled={isProcessingChat}
                  className="flex-1 bg-[#141414] placeholder:text-[#555] text-[#E0D8D0] rounded-xl px-3.5 py-2.5 text-xs border border-[#2A2A2A] focus:outline-none focus:border-[#C5A059]/40 disabled:opacity-50 font-sans"
                />
                <button
                  type="submit"
                  disabled={!inputMessage.trim() || isProcessingChat}
                  className="p-2.5 rounded-xl transition-all font-semibold flex items-center justify-center disabled:opacity-35 text-[#080808] cursor-pointer"
                  style={{
                    backgroundColor: "#C5A059",
                    boxShadow: `0 2px 10px rgba(197, 160, 89, 0.2)`
                  }}
                >
                  <Send className="w-4 h-4" />
                </button>
              </form>

            </div>
          </div>
          
          <div className="mt-4 text-center select-none font-mono text-[10px] text-[#666] max-w-[340px]">
             Escribe en el chat para probar la inferencia real de Gemini encapsulada simulando el VPS Stateless de Hostinger.
          </div>
        </section>

        {/* COLUMNA DERECHA: CONSOLA DE OPERACIÓN SOBERANA Y REPOSITORIO (75% o 7 Cols) */}
        <section className="lg:col-span-7 flex flex-col bg-[#0C0C0C]/80 border border-[#2A2A2A] rounded-3xl overflow-hidden shadow-2xl select-none">
          
          {/* TABS DE COFRE DE CONTROL */}
          <div className="border-b border-[#2A2A2A] bg-[#0A0A0A] p-2 flex flex-wrap gap-1">
            <button
              onClick={() => setActiveTab("operations")}
              className={`px-4 py-2 text-xs font-semibold rounded-xl flex items-center gap-2 transition-all cursor-pointer ${
                activeTab === "operations"
                  ? "bg-[#141414] text-[#C5A059] border border-[#2A2A2A] shadow-inner"
                  : "text-[#888] hover:text-[#E0D8D0] hover:bg-[#141414]/30"
              }`}
            >
              <Settings className="w-3.5 h-3.5 text-[#C5A059]" />
              1. Cápsulas e Identidad
            </button>
            <button
              onClick={() => setActiveTab("obsidian")}
              className={`px-4 py-2 text-xs font-semibold rounded-xl flex items-center gap-2 transition-all cursor-pointer ${
                activeTab === "obsidian"
                  ? "bg-[#141414] text-[#C5A059] border border-[#2A2A2A] shadow-inner"
                  : "text-[#888] hover:text-[#E0D8D0] hover:bg-[#141414]/30"
              }`}
            >
              <Folder className="w-3.5 h-3.5 text-[#C5A059]" />
              2. Nano-Obsidian Vault
            </button>
            <button
              onClick={() => setActiveTab("vps")}
              className={`px-4 py-2 text-xs font-semibold rounded-xl flex items-center gap-2 transition-all cursor-pointer ${
                activeTab === "vps"
                  ? "bg-[#141414] text-[#C5A059] border border-[#2A2A2A] shadow-inner"
                  : "text-[#888] hover:text-[#E0D8D0] hover:bg-[#141414]/30"
              }`}
            >
              <Terminal className="w-3.5 h-3.5 text-[#C5A059]" />
              3. VPS Payload & Logs
            </button>
            <button
              type="button"
              onClick={() => setActiveTab("code")}
              className={`px-4 py-2 text-xs font-semibold rounded-xl flex items-center gap-2 transition-all cursor-pointer ${
                activeTab === "code"
                  ? "bg-[#141414] text-[#C5A059] border border-[#2A2A2A] shadow-inner"
                  : "text-[#888] hover:text-[#E0D8D0] hover:bg-[#141414]/30"
              }`}
            >
              <CodeXml className="w-3.5 h-3.5 text-[#C5A059]" />
              4. Cofre de Código Fénix
            </button>
            <button
              type="button"
              onClick={() => setActiveTab("notifications")}
              className={`px-4 py-2 text-xs font-semibold rounded-xl flex items-center gap-2 transition-all cursor-pointer ${
                activeTab === "notifications"
                  ? "bg-[#141414] text-[#C5A059] border border-[#2A2A2A] shadow-inner"
                  : "text-[#888] hover:text-[#E0D8D0] hover:bg-[#141414]/30"
              }`}
            >
              <BellRing className="w-3.5 h-3.5 text-[#C5A059]" />
              5. Notificaciones Push
            </button>
            <button
              type="button"
              onClick={() => setActiveTab("skills")}
              className={`px-4 py-2 text-xs font-semibold rounded-xl flex items-center gap-2 transition-all cursor-pointer ${
                activeTab === "skills"
                  ? "bg-[#141414] text-[#C5A059] border border-[#2A2A2A] shadow-inner"
                  : "text-[#888] hover:text-[#E0D8D0] hover:bg-[#141414]/30"
              }`}
            >
              <Blocks className="w-3.5 h-3.5 text-[#C5A059]" />
              6. Skills Nativas
            </button>
          </div>

          {/* CONTENIDO DE TAB 1: CÁPSULAS E IDENTIDAD */}
          {activeTab === "operations" && (
            <div className="p-6 space-y-6 flex-1 overflow-y-auto">
              <div>
                <h2 className="text-base font-bold text-[#E0D8D0] flex items-center gap-2 mb-1.5 font-sans uppercase tracking-widest">
                  <Layers className="w-4 h-4 text-[#C5A059]" />
                  Instalación de Cápsulas de Personalidad y Conocimiento Experto
                </h2>
                <p className="text-xs text-[#888] font-sans">
                  Haz clic sobre una de las cápsulas modulares para inyectarla instantáneamente en caliente en el simulador móvil. 
                  Esto emula la descompresión local del archivo empaquetado en el teléfono.
                </p>
              </div>

              {/* LISTA DE CÁPSULAS */}
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                {capsules.map((capsule) => {
                  const isActive = activeCapsule.id === capsule.id;
                  return (
                    <button
                      key={capsule.id}
                      onClick={() => handleCapsuleChange(capsule)}
                      className={`text-left p-4 rounded-2xl border transition-all flex flex-col justify-between h-[160px] cursor-pointer ${
                        isActive
                          ? "bg-[#12110F] border-[#C5A059] ring-1 ring-[#C5A059]/10 shadow-lg"
                          : "bg-[#0A0A0A] border-[#2A2A2A] hover:border-[#444] opacity-60 hover:opacity-100"
                      }`}
                    >
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-xl bg-[#080808] border border-[#2A2A2A] flex items-center justify-center text-xl shadow-inner">
                          {capsule.avatar}
                        </div>
                        <div>
                          <div className="font-bold text-xs text-[#E0D8D0]">{capsule.name}</div>
                          <div className="text-[10px] font-mono font-medium text-[#C5A059]">{capsule.roleDescription}</div>
                        </div>
                      </div>

                      <p className="text-[11px] text-[#888] line-clamp-2 leading-relaxed my-2 font-sans">
                        {capsule.description}
                      </p>

                      <div className="flex items-center justify-between mt-1 pt-1.5 border-t border-[#2A2A2A] w-full">
                        <span className="text-[9px] text-[#555] font-mono">
                          {capsule.id}.zip
                        </span>
                        {isActive ? (
                          <span className="text-[9px] font-semibold text-[#C5A059] bg-[#12110F] border border-[#C5A059]/20 px-2 py-0.5 rounded-full">
                            Activa
                          </span>
                        ) : (
                          <span className="text-[9px] text-[#666] hover:text-[#888] flex items-center gap-1 font-mono">
                            Montar <ArrowRight className="w-3 h-3" />
                          </span>
                        )}
                      </div>
                    </button>
                  );
                })}
              </div>

              {/* PERFIL DE IDENTIDAD EVOLUTIVO */}
              <div className="border-t border-[#2A2A2A] pt-6">
                <div className="bg-[#0A0A0A] border border-[#2A2A2A] rounded-2xl p-5 space-y-4">
                  <h3 className="text-xs font-bold font-mono tracking-widest text-[#C5A059] flex items-center gap-2 uppercase">
                    <User className="w-3.5 h-3.5 text-[#C5A059]" />
                    Perfil Evolutivo del Usuario (Fénix SQLite Local)
                  </h3>
                  <p className="text-[11px] text-[#888] leading-relaxed font-sans">
                    Estos datos se guardan estrictamente en la base de datos del teléfono y se empaquetan en cada POST cifrado. 
                    Edita el contexto evolutivo para alterar las respuestas de la inferencia:
                  </p>

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div className="space-y-1.5">
                      <label className="text-[10px] text-[#888] font-mono">Nombre del Usuario:</label>
                      <input
                        type="text"
                        value={identity?.name}
                        onChange={(e) => setIdentity({ ...identity, name: e.target.value })}
                        className="w-full bg-[#141414] border border-[#2A2A2A] rounded-xl px-3 py-2 text-xs text-[#E0D8D0] focus:outline-none focus:border-[#C5A059]/50 font-sans"
                      />
                    </div>
                    <div className="space-y-1.5">
                      <label className="text-[10px] text-[#888] font-mono">Profesión / Rutina Diaria:</label>
                      <input
                        type="text"
                        value={identity?.profession}
                        onChange={(e) => setIdentity({ ...identity, profession: e.target.value })}
                        className="w-full bg-[#141414] border border-[#2A2A2A] rounded-xl px-3 py-2 text-xs text-[#E0D8D0] focus:outline-none focus:border-[#C5A059]/50 font-sans"
                      />
                    </div>
                    <div className="space-y-1.5">
                      <label className="text-[10px] text-[#888] font-mono">Frecuencia de Entrenamiento:</label>
                      <input
                        type="text"
                        value={identity?.trainingRythmn}
                        onChange={(e) => setIdentity({ ...identity, trainingRythmn: e.target.value })}
                        className="w-full bg-[#141414] border border-[#2A2A2A] rounded-xl px-3 py-2 text-xs text-[#E0D8D0] focus:outline-none focus:border-[#C5A059]/50 font-sans"
                      />
                    </div>
                    <div className="space-y-1.5">
                      <label className="text-[10px] text-[#888] font-mono">Meta Principal de Salud:</label>
                      <input
                        type="text"
                        value={identity?.focusGoal}
                        onChange={(e) => setIdentity({ ...identity, focusGoal: e.target.value })}
                        className="w-full bg-[#141414] border border-[#2A2A2A] rounded-xl px-3 py-2 text-xs text-[#E0D8D0] focus:outline-none focus:border-[#C5A059]/50 font-sans"
                      />
                    </div>
                    <div className="space-y-1.5 md:col-span-2">
                      <label className="text-[10px] text-[#888] font-mono">Restricción Biomecánica / Dolencias (Sacado por noche de Aprendizaje Diario):</label>
                      <textarea
                        rows={2}
                        value={identity?.healthConstraints}
                        onChange={(e) => setIdentity({ ...identity, healthConstraints: e.target.value })}
                        className="w-full bg-[#141414] border border-[#2A2A2A] rounded-xl px-3 py-2 text-xs text-[#E0D8D0] focus:outline-none focus:border-[#C5A059]/50 font-sans"
                      />
                    </div>
                  </div>

                  {/* CONSOLIDACIÓN NOCTURNA */}
                  <div className="mt-6 pt-4 border-t border-[#2A2A2A]">
                    <div className="flex items-center justify-between">
                      <div>
                        <h4 className="text-xs font-bold font-mono text-[#E0D8D0] flex items-center gap-2">
                          <Activity className="w-3.5 h-3.5 text-purple-400" />
                          Consolidación Nocturna (Aprendizaje)
                        </h4>
                        <p className="text-[10px] text-[#888] leading-tight font-sans mt-1">
                          Envía el historial de hoy al subconsciente para extraer patrones, actualizar el perfil e inyectar un nuevo diario.
                        </p>
                      </div>
                      <button 
                        onClick={triggerConsolidation} 
                        disabled={isConsolidating}
                        className="bg-[#141414] hover:bg-purple-900/20 text-[#E0D8D0] border border-[#2A2A2A] hover:border-purple-500/50 px-4 py-2 rounded-xl text-[11px] font-bold transition-all disabled:opacity-50"
                      >
                        {isConsolidating ? "Procesando..." : "Ejecutar Consolidación"}
                      </button>
                    </div>
                    {consolidationResult && (
                      <div className="mt-4 bg-[#0A0A0A] border border-purple-500/20 rounded-xl p-3 font-mono text-[10px]">
                        <h5 className="text-purple-400 font-bold mb-2">Resultado Empaquetado</h5>
                        <div className="space-y-2 text-[#E0D8D0]">
                          <div><strong className="text-[#888]">Nuevos Datos Perfil:</strong> {consolidationResult.changes?.length > 0 ? JSON.stringify(consolidationResult.changes) : "Ninguno"}</div>
                          <div><strong className="text-[#888]">Alerta Coach:</strong> {consolidationResult.alertas}</div>
                          <div className="mt-2 p-2 bg-[#141414] rounded border border-[#2A2A2A] text-[9px] max-h-32 overflow-y-auto whitespace-pre-wrap">
                            {consolidationResult.markdown}
                          </div>
                        </div>
                      </div>
                    )}
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* CONTENIDO DE TAB 2: NANO-OBSIDIAN DECRYPTION SIMULATOR */}
          {activeTab === "obsidian" && (
            <div className="p-6 flex-1 overflow-y-auto flex flex-col md:flex-row gap-6">
              
              {/* Navegador de Archivos Fénix (.md) */}
              <div className="w-full md:w-[240px] border-r border-[#2A2A2A] pr-4 space-y-4">
                <div className="flex justify-between items-start">
                  <div>
                    <h3 className="text-xs font-bold font-mono text-[#888] uppercase tracking-widest flex items-center gap-1.5">
                      <Database className="w-3.5 h-3.5 text-[#C5A059]" />
                      Obsidian Vault
                    </h3>
                    <p className="text-[10px] text-[#666] leading-tight font-sans">Segmentado en Diaries locales y Literatura modular.</p>
                  </div>
                  <button onClick={() => setShowAddDoc(!showAddDoc)} className="p-1.5 bg-[#C5A059]/10 text-[#C5A059] rounded hover:bg-[#C5A059]/20 transition-colors tooltip" title="Importar Conocimiento">
                    <Plus className="w-4 h-4" />
                  </button>
                </div>

                {showAddDoc && (
                  <form onSubmit={handleCreateDocument} className="bg-[#141414] p-3 rounded-xl border border-[#C5A059]/30 space-y-2">
                    <input 
                      required 
                      type="text" 
                      placeholder="Nombre del Doc" 
                      className="w-full bg-[#0A0A0A] border border-[#2A2A2A] rounded px-2 py-1.5 text-[10px] text-[#E0D8D0] font-mono outline-none focus:border-[#C5A059]/50"
                      value={newDocForm.filename}
                      onChange={e => setNewDocForm(f => ({...f, filename: e.target.value}))}
                    />
                    <select 
                      className="w-full bg-[#0A0A0A] border border-[#2A2A2A] rounded px-2 py-1.5 text-[10px] text-[#E0D8D0] font-mono outline-none focus:border-[#C5A059]/50"
                      value={newDocForm.category}
                      onChange={e => setNewDocForm(f => ({...f, category: e.target.value as "personal"|"expert"}))}
                    >
                      <option value="personal">Diario Personal</option>
                      <option value="expert">Conocimiento Experto</option>
                    </select>
                    <textarea 
                      required
                      placeholder="Contenido Markdown..."
                      className="w-full bg-[#0A0A0A] border border-[#2A2A2A] rounded px-2 py-1.5 text-[10px] text-[#E0D8D0] font-mono outline-none focus:border-[#C5A059]/50 h-20 resize-none"
                      value={newDocForm.content}
                      onChange={e => setNewDocForm(f => ({...f, content: e.target.value}))}
                    />
                    <div className="flex justify-end gap-2">
                      <button type="submit" className="text-[10px] bg-[#C5A059] text-black px-2 py-1 rounded font-bold">Importar</button>
                    </div>
                  </form>
                )}

                <div className="space-y-3">
                  {/* Carpeta Diarios */}
                  <div>
                    <div className="text-[10px] font-mono text-[#E0D8D0] font-bold mb-1.5 flex items-center gap-1">
                      <Folder className="w-3 h-3 text-[#C5A059]" />
                      /nano_obsidian/Diarios/
                    </div>
                    <div className="space-y-1 pl-3.5">
                      {localVaultFiles.filter(f => f.category === "personal").map((file) => (
                        <button
                          key={file.id}
                          onClick={() => setSelectedFile(file)}
                          className={`w-full text-left text-xs font-mono px-2 py-1.5 rounded truncate transition-all block cursor-pointer ${
                            selectedFile.id === file.id
                              ? "bg-[#12110F] text-[#C5A059] border-l-2 border-[#C5A059] pl-2.5"
                              : "text-[#888] hover:text-[#E0D8D0]"
                          }`}
                        >
                          {file.filename}
                        </button>
                      ))}
                    </div>
                  </div>

                  {/* Carpeta Conocimiento Científico */}
                  <div>
                    <div className="text-[10px] font-mono text-[#E0D8D0] font-bold mb-1.5 flex items-center gap-1">
                      <Folder className="w-3 h-3 text-[#4CAF50]" />
                      /nano_obsidian/Conocimiento_Experto/
                    </div>
                    <div className="space-y-1 pl-3.5 font-mono">
                      {localVaultFiles.filter(f => f.category === "expert").map((file) => (
                        <button
                          key={file.id}
                          onClick={() => setSelectedFile(file)}
                          className={`w-full text-left text-xs px-2 py-1.5 rounded truncate transition-all block cursor-pointer ${
                            selectedFile.id === file.id
                              ? "bg-[#12110F] text-[#C5A059] border-l-2 border-[#C5A059] pl-2.5"
                              : "text-[#888] hover:text-[#E0D8D0]"
                          }`}
                        >
                          {file.filename}
                        </button>
                      ))}
                    </div>
                  </div>
                </div>
              </div>

              {/* Panel de descifrado síncrono en RAM */}
              <div className="flex-1 space-y-4">
                <div className="bg-[#0C0C0C] border border-[#2A2A2A] rounded-2xl p-5 relative overflow-hidden">
                  <div className="flex justify-between items-start gap-4">
                    <div>
                      <span className="text-[9px] font-mono text-[#666] uppercase tracking-widest block">Ubicación local del archivo</span>
                      <div className="text-xs font-mono font-bold text-[#E0D8D0] mt-0.5">{selectedFile.chapter}/{selectedFile.filename}</div>
                    </div>
                    <div className="flex gap-1.5 select-none font-mono">
                      {decryptedFiles[selectedFile.id] ? (
                        <span className="text-[9px] bg-[#0C120C] text-[#4CAF50] px-2 py-0.5 rounded border border-[#1B321B] flex items-center gap-1">
                          <Unlock className="w-2.5 h-2.5" /> Descifrado en RAM
                        </span>
                      ) : (
                        <span className="text-[9px] bg-[#120F0C] text-[#C5A059] px-2 py-0.5 rounded border border-[#32201B] flex items-center gap-1">
                          <Lock className="w-2.5 h-2.5" /> Encriptado AES-256
                        </span>
                      )}
                    </div>
                  </div>

                  {/* VISOR DE CIFRADO */}
                  <div className="mt-4 bg-[#080808] p-4 rounded-xl border border-[#2A2A2A] min-h-[160px] font-mono text-[11px] leading-relaxed relative flex flex-col justify-between">
                    
                    {isDecrypting && (
                      <div className="absolute inset-0 bg-[#080808]/95 flex flex-col items-center justify-center gap-3 z-30">
                        <RefreshCw className="w-6 h-6 text-[#C5A059] animate-spin" />
                        <div className="text-[9px] uppercase tracking-widest text-[#C5A059] animate-pulse font-mono font-bold">
                          Descifrando síncronamente con AES-256...
                        </div>
                      </div>
                    )}

                    {!decryptedFiles[selectedFile.id] ? (
                      <>
                        <div className="text-[#C5A059]/60 max-w-[95%] break-words leading-normal select-all">
                          {selectedFile.encryptedContent}
                        </div>
                        <div className="mt-4 border-t border-[#2A2A2A] pt-3.5 flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                          <p className="text-[10px] text-[#666] font-sans">
                            🔒 Los datos persistidos se protegen en disco con vector de inicialización dinámico. No son leíbles externamente.
                          </p>
                          <button
                            onClick={() => handleDecryptFile(selectedFile.id)}
                            className="bg-[#C5A059] hover:bg-[#B38F4B] text-[#080808] font-bold text-xs px-4 py-1.5 rounded-lg shrink-0 flex items-center gap-1.5 transition-colors cursor-pointer"
                          >
                            <Unlock className="w-3.5 h-3.5" />
                            Descifrar en RAM
                          </button>
                        </div>
                      </>
                    ) : (
                      <>
                        <div className="text-[#E0D8D0] whitespace-pre-wrap leading-relaxed select-text prose prose-invert font-sans bg-[#141414] p-3 rounded-lg border border-[#2A2A2A]">
                          {selectedFile.decryptedContent}
                        </div>
                        <div className="mt-4 border-t border-[#2A2A2A] pt-3 flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                          <p className="text-[10px] text-[#4CAF50] flex items-center gap-1 font-sans">
                            <Unlock className="w-3 h-3" /> Descifrado con éxito en memoria de forma temporal y síncrona.
                          </p>
                          <button
                            onClick={() => {
                              setDecryptedFiles(prev => ({ ...prev, [selectedFile.id]: false }));
                            }}
                            className="bg-[#141414] hover:bg-[#222222] text-[#888] text-xs px-3 py-1 rounded-lg border border-[#2A2A2A] transition-colors cursor-pointer font-sans"
                          >
                            Cerrar Memoria (Borrar RAM)
                          </button>
                        </div>
                      </>
                    )}
                  </div>
                </div>
              </div>

            </div>
          )}

          {/* CONTENIDO DE TAB 3: VPS PAYLOAD & LOGS SIMULADOS */}
          {activeTab === "vps" && (
            <div className="p-6 flex-1 overflow-y-auto grid grid-cols-1 md:grid-cols-2 gap-6">
              
              {/* Payload Unificado HTTP Sent */}
              <div className="space-y-3">
                <div className="flex items-center justify-between">
                  <h3 className="text-xs font-bold font-mono text-[#888] uppercase tracking-widest flex items-center gap-1.5">
                    <Database className="w-3.5 h-3.5 text-[#C5A059]" />
                    RAG HTTP POST Schema (/api/v1/chat)
                  </h3>
                  <span className="text-[9px] font-mono bg-[#12110F] text-[#C5A059] px-2 rounded border border-[#C5A059]/20">
                    Stateless Payload
                  </span>
                </div>
                <p className="text-[11px] text-[#666] leading-tight font-sans">
                  Estructura unificada que la aplicación móvil envía en frío al VPS Hostinger. Modifica valores en las otras pestañas para verla alternar:
                </p>

                <div className="bg-[#0A0A0A] border border-[#2A2A2A] rounded-2xl p-4 font-mono text-[10px] leading-relaxed text-[#C5A059] overflow-x-auto max-h-[380px] scrollbar-thin">
                  <pre>{JSON.stringify(currentPayload, null, 2)}</pre>
                </div>
              </div>

              {/* Logs en tiempo real del VPS */}
              <div className="space-y-3">
                <div className="flex items-center justify-between">
                  <h3 className="text-xs font-bold font-mono text-[#888] uppercase tracking-widest flex items-center gap-1.5">
                    <Terminal className="w-3.5 h-3.5 text-[#4CAF50]" />
                    Consola del VPS de Hostinger (FastAPI Terminal)
                  </h3>
                  <button
                    onClick={() => setVpsLogs([vpsLogs[0], vpsLogs[1], vpsLogs[2]])}
                    className="text-[#666] hover:text-[#888] text-[10px] font-mono flex items-center gap-1 cursor-pointer"
                  >
                    Clear Logs
                  </button>
                </div>
                <p className="text-[11px] text-[#666] leading-tight font-sans">
                  Trazas de ejecución de procesamiento síncrono. El backend recibe, computa y se desentiende de logs permanentemente:
                </p>

                <div className="bg-[#0A0A0A] border border-[#2A2A2A] rounded-2xl p-4 font-mono text-[10px] text-[#4CAF50]/90 space-y-2 min-h-[380px] max-h-[380px] overflow-y-auto scrollbar-thin">
                  {vpsLogs.map((log, index) => (
                    <div key={index} className="leading-normal break-words">
                      {log}
                    </div>
                  ))}
                  <div className="w-2 h-3.5 bg-[#4CAF50] animate-pulse inline-block"></div>
                </div>
              </div>

            </div>
          )}

          {/* CONTENIDO DE TAB 4: COFRE DE CÓDIGO PRODUCTIVO */}
          {activeTab === "code" && (
            <div className="p-6 flex-1 overflow-y-auto flex flex-col md:flex-row gap-6">
              
              {/* Selector de códigos solicitados */}
              <div className="w-full md:w-[220px] border-r border-[#2A2A2A] pr-4 space-y-4">
                <div>
                  <h3 className="text-xs font-bold font-mono text-[#888] uppercase tracking-widest flex items-center gap-2">
                    <CodeXml className="w-3.5 h-3.5 text-[#C5A059]" />
                    Repositorio
                  </h3>
                  <p className="text-[10px] text-[#666] font-sans">Código de producción completo segmentado.</p>
                </div>

                <div className="space-y-2">
                  <div className="text-[9px] font-mono font-bold uppercase tracking-widest text-[#555] border-b border-[#2A2A2A] pb-1">
                    Frontend Flutter (Dart)
                  </div>
                  {productionFiles.filter(f => f.language === "dart").map((file) => {
                    const idx = productionFiles.findIndex(f => f.path === file.path);
                    const isActive = selectedCodeIdx === idx;
                    return (
                      <button
                        key={file.path}
                        onClick={() => setSelectedCodeIdx(idx)}
                        className={`w-full text-left font-mono text-xs px-2 py-1.5 rounded truncate block transition-all cursor-pointer ${
                          isActive
                            ? "bg-[#12110F] text-[#C5A059] border-l-2 border-[#C5A059] pl-2.5"
                            : "text-[#888] hover:text-[#E0D8D0]"
                        }`}
                      >
                        {file.name}
                        <span className="text-[9px] font-mono text-[#555] block truncate">{file.path}</span>
                      </button>
                    );
                  })}

                  <div className="text-[9px] font-mono font-bold uppercase tracking-widest text-[#555] border-b border-[#2A2A2A] pt-2 pb-1">
                    Backend FastAPI (Python)
                  </div>
                  {productionFiles.filter(f => f.language === "python").map((file) => {
                    const idx = productionFiles.findIndex(f => f.path === file.path);
                    const isActive = selectedCodeIdx === idx;
                    return (
                      <button
                        key={file.path}
                        onClick={() => setSelectedCodeIdx(idx)}
                        className={`w-full text-left font-mono text-xs px-2 py-1.5 rounded truncate block transition-all cursor-pointer ${
                          isActive
                            ? "bg-[#12110F] text-[#C5A059] border-l-2 border-[#C5A059] pl-2.5"
                            : "text-[#888] hover:text-[#E0D8D0]"
                        }`}
                      >
                        {file.name}
                        <span className="text-[9px] font-mono text-[#555] block truncate">{file.path}</span>
                      </button>
                    );
                  })}
                </div>
              </div>

              {/* Contenedor del Visor de Archivo seleccionado */}
              <div className="flex-1 space-y-4">
                <div className="bg-[#0C0C0C] border border-[#2A2A2A] rounded-2xl p-4 space-y-4 relative">
                  
                  {/* Header del archivo */}
                  <div className="flex flex-col sm:flex-row sm:items-center justify-between border-b border-[#2A2A2A] pb-3 gap-3">
                    <div>
                      <span className="text-[10px] font-mono text-[#666]">{productionFiles[selectedCodeIdx].path}</span>
                      <h4 className="text-sm font-bold text-[#E0D8D0] tracking-wide font-sans">{productionFiles[selectedCodeIdx].name}</h4>
                    </div>
                    <div className="flex items-center gap-3">
                      <span className="text-[9px] font-mono bg-[#141414] text-[#C5A059] border border-[#2A2A2A] px-2 py-0.5 rounded uppercase">
                        {productionFiles[selectedCodeIdx].language}
                      </span>
                      <button
                        onClick={() => copyToClipboard(productionFiles[selectedCodeIdx].content, selectedCodeIdx)}
                        className="bg-[#141414] hover:bg-[#222222] text-[#E0D8D0] border border-[#2A2A2A] text-xs px-3 py-1.5 rounded-lg flex items-center gap-1.5 transition-colors cursor-pointer font-sans"
                      >
                        {copiedFileIndex === selectedCodeIdx ? (
                          <>
                            <Check className="w-3.5 h-3.5 text-[#4CAF50] animate-bounce" />
                            <span className="text-[#4CAF50]">¡Copiado!</span>
                          </>
                        ) : (
                          <>
                            <Copy className="w-3.5 h-3.5" />
                            <span>Copiar Código</span>
                          </>
                        )}
                      </button>
                    </div>
                  </div>

                  {/* Resumen explicativo */}
                  <div className="text-xs text-[#888] leading-relaxed font-sans bg-[#0A0A0A] px-3.5 py-3 rounded-xl border border-[#2A2A2A]">
                    💡 <span className="font-semibold text-[#E0D8D0]">Explicación Técnica:</span> {productionFiles[selectedCodeIdx].description}
                  </div>

                  {/* Visor de código con colores adaptados */}
                  <div className="bg-[#0A0A0A] text-[#D0D0D0] font-mono text-[11px] leading-relaxed p-4 rounded-xl border border-[#2A2A2A] max-h-[460px] overflow-y-auto scrollbar-thin overflow-x-auto">
                    <pre className="whitespace-pre">{productionFiles[selectedCodeIdx].content}</pre>
                  </div>
                </div>
              </div>

            </div>
          )}

          {/* CONTENIDO DE TAB 6: SKILLS NATIVAS */}
          {activeTab === "skills" && (
            <div className="p-6 space-y-6 flex-1 overflow-y-auto w-full">
              <div>
                <h2 className="text-base font-bold text-[#E0D8D0] flex items-center gap-2 mb-1.5 font-sans uppercase tracking-widest">
                  <Blocks className="w-4 h-4 text-[#C5A059]" />
                  Hub de Skills e Integraciones Nativas
                </h2>
                <p className="text-xs text-[#888] font-sans">
                  Instala capacidades de hardware nativo y módulos adicionales para tu Fénix Sovereign.
                  Cada skill otorga al sistema acceso cifrado y local a una función del móvil.
                </p>
              </div>

              <div className="space-y-4">
                <div className="flex justify-between items-center border-b border-[#2A2A2A] pb-2">
                  <h3 className="text-xs font-bold font-mono text-[#E0D8D0]">Skills Disponibles (Mercado Local)</h3>
                  <button
                    onClick={() => setShowAddSkill(!showAddSkill)}
                    className="flex items-center gap-1.5 text-[#C5A059] hover:text-[#E0D8D0] transition-colors text-[10px] uppercase font-bold tracking-widest bg-[#C5A059]/10 px-2.5 py-1 rounded-lg"
                  >
                    <Plus className="w-3.5 h-3.5" /> Nueva Skill
                  </button>
                </div>

                {showAddSkill && (
                  <form onSubmit={handleCreateSkill} className="bg-[#141414] border border-[#C5A059]/30 rounded-2xl p-4 space-y-3 shadow-inner">
                    <p className="text-[10px] text-[#A8A8A8] font-mono mb-2 border-b border-[#2A2A2A] pb-2">Definición de Protocolo Customizado</p>
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                      <input 
                        type="text" 
                        required 
                        placeholder="Nombre de Skill (ej. Domótica Casa)" 
                        className="bg-[#0A0A0A] border border-[#2A2A2A] rounded-lg px-3 py-2 text-[11px] text-[#E0D8D0] focus:outline-none focus:border-[#C5A059]/50"
                        value={newSkillForm.name} 
                        onChange={e => setNewSkillForm(f => ({...f, name: e.target.value}))} 
                      />
                      <input 
                        type="text" 
                        required 
                        placeholder="ID Interno (ej. domotica_luces)" 
                        className="bg-[#0A0A0A] border border-[#2A2A2A] rounded-lg px-3 py-2 text-[11px] text-[#E0D8D0] focus:outline-none focus:border-[#C5A059]/50 font-mono"
                        value={newSkillForm.id} 
                        onChange={e => setNewSkillForm(f => ({...f, id: e.target.value}))} 
                      />
                    </div>
                    <textarea 
                      required 
                      placeholder="Descripción de la acción que realiza la skill y parámetros necesarios." 
                      className="bg-[#0A0A0A] border border-[#2A2A2A] rounded-lg px-3 py-2 text-[11px] text-[#E0D8D0] focus:outline-none focus:border-[#C5A059]/50 w-full resize-none min-h-[60px]"
                      value={newSkillForm.description} 
                      onChange={e => setNewSkillForm(f => ({...f, description: e.target.value}))} 
                    />
                    <div className="flex justify-end gap-2 pt-2">
                      <button 
                        type="button" 
                        onClick={() => setShowAddSkill(false)} 
                        className="px-3 py-1.5 text-xs text-[#888] hover:text-white transition-colors"
                      >
                        Cancelar
                      </button>
                      <button 
                        type="submit" 
                        className="bg-[#C5A059] text-black px-4 py-1.5 rounded-lg text-xs font-bold flex items-center gap-1.5 shadow-[0_2px_10px_rgba(197,160,89,0.2)] hover:bg-[#b08d4b]"
                      >
                        Compilar Skill
                      </button>
                    </div>
                  </form>
                )}
                
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  {availableSkills.map((skill) => (
                    <div key={skill.id} className="bg-[#0A0A0A] border border-[#2A2A2A] rounded-2xl p-4 flex flex-col justify-between">
                      <div className="flex items-start justify-between mb-3">
                        <div className="flex items-center gap-2">
                          <div className={`p-2 rounded-xl ${skill.installed ? 'bg-[#C5A059]/10 text-[#C5A059]' : 'bg-[#1C1C1C] text-[#888]'}`}>
                            {skill.icon === "Calendar" && <Calendar className="w-4 h-4" />}
                            {skill.icon === "BellRing" && <BellRing className="w-4 h-4" />}
                            {skill.icon === "Activity" && <Activity className="w-4 h-4" />}
                            {skill.icon === "Speaker" && <Speaker className="w-4 h-4" />}
                            {skill.icon === "Eye" && <Eye className="w-4 h-4" />}
                            {skill.icon === "Database" && <Database className="w-4 h-4" />}
                            {skill.icon === "Globe" && <Globe className="w-4 h-4" />}
                            {skill.icon === "Blocks" && <Blocks className="w-4 h-4" />}
                          </div>
                          <div>
                            <span className="text-[11px] font-bold text-[#E0D8D0] font-sans block">{skill.name}</span>
                            <span className="text-[9px] text-[#666] font-mono uppercase tracking-wider">{skill.category}</span>
                          </div>
                        </div>
                        {skill.installed && (
                          <span className="text-[9px] font-bold tracking-widest text-[#4CAF50] bg-[#4CAF50]/10 px-2 py-0.5 rounded uppercase flex items-center gap-1">
                            <Check className="w-3 h-3" /> Instalada
                          </span>
                        )}
                      </div>
                      <p className="text-[10px] text-[#888] font-sans leading-relaxed flex-1 mb-4">
                        {skill.description}
                      </p>
                      
                      <div className="flex justify-end gap-2">
                        {skill.installed ? (
                          <button
                            type="button"
                            onClick={() => handleUninstallSkill(skill.id)}
                            className="text-[#666] hover:text-red-500 hover:bg-red-500/10 px-3 py-1.5 rounded-lg text-xs font-semibold flex items-center gap-1.5 transition-all w-full justify-center"
                          >
                            <Trash2 className="w-3.5 h-3.5" /> Desinstalar
                          </button>
                        ) : (
                          <button
                            type="button"
                            onClick={() => handleInstallSkill(skill.id)}
                            className="bg-[#C5A059] text-black hover:bg-[#B38F4B] px-3 py-1.5 rounded-lg text-xs font-bold flex items-center gap-1.5 transition-all w-full justify-center shadow-[0_2px_10px_rgba(197,160,89,0.15)]"
                          >
                            <Plus className="w-3.5 h-3.5" /> Descargar/Activar
                          </button>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          )}

          {/* CONTENIDO DE TAB 5: NOTIFICACIONES PUSH */}
          {activeTab === "notifications" && (
            <div className="p-6 space-y-6 flex-1 overflow-y-auto">
              <div>
                <h2 className="text-base font-bold text-[#E0D8D0] flex items-center gap-2 mb-1.5 font-sans uppercase tracking-widest">
                  <BellRing className="w-4 h-4 text-[#C5A059]" />
                  Hub Global de Notificaciones Push & Alertas Proactivas
                </h2>
                <p className="text-xs text-[#888] font-sans">
                  Emula el envío y ruteo de notificaciones y recordatorios inteligentes generados por el RAG Híbrido en el VPS. Las habilidades <span className="font-mono text-[#C5A059]">[agenda_crear, notificacion_enviar]</span> se inyectan en caliente basándose en los perfiles SQLite locales y diarios descifrados.
                </p>
              </div>

              <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start text-[#D0D0D0]">
                {/* PANEL IZQUIERDO: ACCIONES Y CONFIGURACIÓN (7 Cols) */}
                <div className="lg:col-span-7 space-y-6">
                  
                  {/* GENERACIÓN PROACTIVA */}
                  <div className="bg-[#0A0A0A] border border-[#2A2A2A] rounded-2xl p-5 space-y-4">
                    <h3 className="text-xs font-bold font-mono tracking-widest text-[#C5A059] flex items-center gap-2 uppercase">
                      <Sparkles className="w-3.5 h-3.5 text-[#C5A059]" />
                      Generador de Inferencia de Alertas (Gemini + RAG Híbrido)
                    </h3>
                    <p className="text-[11px] text-[#888] leading-relaxed">
                      Lanza una consulta sintética desde el teléfono al VPS. Gemini procesará las restricciones biomecánicas y diarios Markdown de la cápsula <strong className="text-[#E0D8D0] font-bold">{activeCapsule.name}</strong> para generar una advertencia o recordatorio micro-estructurado:
                    </p>

                    <div className="grid grid-cols-1 sm:grid-cols-3 gap-3 pt-1">
                      {/* Generar Consejo */}
                      <button
                        type="button"
                        onClick={() => triggerLivePushNotification("consejo")}
                        disabled={isGeneratingPush}
                        className="bg-[#141414] hover:bg-[#1A1A1A] text-[#E0D8D0] border border-[#C5A059]/30 hover:border-[#C5A059]/60 p-3.5 rounded-xl flex flex-col items-center justify-between text-left gap-2 group transition-all duration-300 disabled:opacity-40 cursor-pointer h-[120px]"
                      >
                        <Shield className="w-5 h-5 text-[#C5A059] group-hover:scale-110 transition-transform" />
                        <div className="w-full">
                          <span className="text-[10px] font-bold font-mono text-[#C5A059] block">CONSEJO RAG</span>
                          <span className="text-[9px] text-[#888] leading-tight block mt-0.5 font-sans">Previene lesiones con Gemini.</span>
                        </div>
                      </button>

                      {/* Generar Agenda */}
                      <button
                        type="button"
                        onClick={() => triggerLivePushNotification("agenda")}
                        disabled={isGeneratingPush}
                        className="bg-[#141414] hover:bg-[#1A1A1A] text-[#E0D8D0] border border-[#2A2A2A] hover:border-[#C5A059]/40 p-3.5 rounded-xl flex flex-col items-center justify-between text-left gap-2 group transition-all duration-300 disabled:opacity-40 cursor-pointer h-[120px]"
                      >
                        <Calendar className="w-5 h-5 text-[#4CAF50] group-hover:scale-110 transition-transform" />
                        <div className="w-full">
                          <span className="text-[10px] font-bold font-mono text-[#4CAF50] block">REGISTRO AGENDA</span>
                          <span className="text-[9px] text-[#888] leading-tight block mt-0.5 font-sans">Sincroniza agendas biomecánicas.</span>
                        </div>
                      </button>

                      {/* Generar Alerta */}
                      <button
                        type="button"
                        onClick={() => triggerLivePushNotification("alerta")}
                        disabled={isGeneratingPush}
                        className="bg-[#141414] hover:bg-[#1A1A1A] text-[#E0D8D0] border border-[#2A2A2A] hover:border-red-500/30 p-3.5 rounded-xl flex flex-col items-center justify-between text-left gap-2 group transition-all duration-300 disabled:opacity-40 cursor-pointer h-[120px]"
                      >
                        <Activity className="w-5 h-5 text-red-500 group-hover:scale-110 transition-transform" />
                        <div className="w-full">
                          <span className="text-[10px] font-bold font-mono text-red-500 block">ALERTA SENSORIAL</span>
                          <span className="text-[9px] text-[#888] leading-tight block mt-0.5 font-sans">Simula avisos de fatiga muscular.</span>
                        </div>
                      </button>
                    </div>

                    {isGeneratingPush && (
                      <div className="bg-[#141414] border border-[#C5A059]/20 p-3 rounded-xl flex items-center gap-2.5 text-xs text-[#C5A059] font-mono animate-pulse">
                        <RefreshCw className="w-4 h-4 animate-spin text-[#C5A059]" />
                        <span>Fénix VPS está calculando el payload push con Gemini...</span>
                      </div>
                    )}
                  </div>

                  {/* CONFIGURACIÓN SOBERANA */}
                  <div className="bg-[#0A0A0A] border border-[#2A2A2A] rounded-2xl p-5 space-y-4">
                    <h3 className="text-xs font-bold font-mono tracking-widest text-[#C5A059] flex items-center gap-2 uppercase">
                      <Settings className="w-3.5 h-3.5 text-[#C5A059]" />
                      Configuración del Sistema Push Local (Soberano)
                    </h3>
                    
                    <div className="space-y-3.5 text-xs font-sans">
                      {/* Cifrado homomórfico */}
                      <div className="flex items-center justify-between p-3 bg-[#141414] rounded-xl border border-[#2A2A2A]">
                        <div>
                          <p className="font-bold text-[#E0D8D0]">Blindaje Cifrado de Mensajería Push</p>
                          <p className="text-[10px] text-[#888]">Cifra el contenido del push en RAM antes de renderizar (Inmunidad de sistema).</p>
                        </div>
                        <button
                          type="button"
                          onClick={() => setPushSettings(p => ({ ...p, homomorphicEncryption: !p.homomorphicEncryption }))}
                          className={`w-10 h-6 rounded-full transition-all relative ${pushSettings.homomorphicEncryption ? "bg-[#C5A059]" : "bg-[#222]"}`}
                        >
                          <span className={`w-4 h-4 rounded-full bg-[#080808] absolute top-1 transition-all ${pushSettings.homomorphicEncryption ? "right-1" : "left-1"}`}></span>
                        </button>
                      </div>

                      {/* Inferencia segundo plano */}
                      <div className="flex items-center justify-between p-3 bg-[#141414] rounded-xl border border-[#2A2A2A]">
                        <div>
                          <p className="font-bold text-[#E0D8D0]">Inferencia en Tránsito Síncrono (Background)</p>
                          <p className="text-[10px] text-[#888]">Monitorea las bitácoras lumbares por la noche de manera autónoma.</p>
                        </div>
                        <button
                          type="button"
                          onClick={() => setPushSettings(p => ({ ...p, backgroundInference: !p.backgroundInference }))}
                          className={`w-10 h-6 rounded-full transition-all relative ${pushSettings.backgroundInference ? "bg-[#C5A059]" : "bg-[#222]"}`}
                        >
                          <span className={`w-4 h-4 rounded-full bg-[#080808] absolute top-1 transition-all ${pushSettings.backgroundInference ? "right-1" : "left-1"}`}></span>
                        </button>
                      </div>

                      {/* Interval slider */}
                      <div className="space-y-1.5 p-3.5 bg-[#141414] rounded-xl border border-[#2A2A2A]">
                        <div className="flex justify-between text-[11px] font-mono">
                          <span className="text-[#888]">Frecuencia de Inferencia Activa:</span>
                          <span className="text-[#C5A059] font-bold">Cada {pushSettings.activeIntervalHours} horas</span>
                        </div>
                        <input
                          type="range"
                          min="1"
                          max="24"
                          value={pushSettings.activeIntervalHours}
                          onChange={(e) => setPushSettings(p => ({ ...p, activeIntervalHours: parseInt(e.target.value) }))}
                          className="w-full accent-[#C5A059] cursor-pointer"
                        />
                        <span className="text-[9px] text-[#666] font-mono block">Un intervalo más corto consume más CPU en el dispositivo móvil pero reacciona más rápido a reportes de fatiga.</span>
                      </div>
                    </div>
                  </div>

                </div>

                {/* PANEL DERECHO: SECURE PUSH LEDGER (5 Cols) */}
                <div className="lg:col-span-5 space-y-4">
                  <div className="flex justify-between items-center bg-[#0C0C0C]/50 border-b border-[#2A2A2A] pb-2">
                    <h3 className="text-xs font-bold font-mono text-[#888] uppercase tracking-widest flex items-center gap-1.5">
                      <Database className="w-3.5 h-3.5 text-[#C5A059]" />
                      Secure Push Ledger (Historial)
                    </h3>
                    <button
                      type="button"
                      onClick={() => setPushHistory([])}
                      className="text-[9px] font-mono text-[#666] hover:text-[#888] underline cursor-pointer"
                    >
                      Clear
                    </button>
                  </div>

                  <div className="space-y-3 max-h-[460px] overflow-y-auto pr-1.5 scrollbar-thin">
                    {pushHistory.length === 0 ? (
                      <div className="text-center py-10 border border-dashed border-[#2A2A2A] rounded-2xl text-[#666] text-xs font-mono">
                        Ninguna notificación registrada en este ciclo.
                      </div>
                    ) : (
                      pushHistory.map((push) => {
                        const isExecuted = push.status === "executed";
                        const isFitness = push.capsuleId === "fitness_expert";
                        const isNutri = push.capsuleId === "nutricion_expert";
                        const activeColor = isFitness ? "border-l-orange-500" : isNutri ? "border-l-emerald-500" : "border-l-stone-400";
                        const badgeColor = isFitness ? "text-orange-400 bg-orange-950/20" : isNutri ? "text-emerald-400 bg-emerald-950/20" : "text-stone-300 bg-stone-900/30";

                        return (
                          <div
                            key={push.id}
                            className={`p-3 bg-[#0A0A0A] border border-[#2A2A2A] rounded-xl flex flex-col gap-1.5 border-l-4 ${activeColor} relative`}
                          >
                            <div className="flex justify-between items-start gap-1">
                              <span className="text-[10px] font-bold text-[#E0D8D0] truncate max-w-[135px] font-mono">
                                {push.title}
                              </span>
                              <span className="text-[8px] font-mono text-[#555] whitespace-nowrap">
                                {push.timestamp}
                              </span>
                            </div>

                            <p className="text-[11px] text-[#A8A8A8] leading-normal font-sans">
                              {push.body}
                            </p>

                            {push.reasoning && (
                              <div className="text-[8px] text-[#777] font-mono bg-[#050505] p-1.5 rounded border border-[#1a1a1a] leading-tight">
                                <span className="text-[#C5A059] font-bold">Concepto RAG:</span> {push.reasoning}
                              </div>
                            )}

                            <div className="flex items-center justify-between pt-1 font-mono text-[9px]">
                              <span className={`px-1.5 py-0.5 rounded-[4px] text-[8px] uppercase font-bold tracking-widest ${badgeColor}`}>
                                {push.type}
                              </span>

                              {isExecuted ? (
                                <span className="text-[#4CAF50] flex items-center gap-1 font-medium select-none">
                                  <Check className="w-2.5 h-2.5" /> Aplicado
                                </span>
                              ) : (
                                <button
                                  type="button"
                                  onClick={() => {
                                    setActivePush(push);
                                    setVpsLogs(p => [...p, `[MÓVIL] Re-proyectando push flotante: ${push.title}`]);
                                  }}
                                  className="text-[#C5A059] hover:underline flex items-center gap-0.5 cursor-pointer"
                                >
                                  Re-lanzar
                                </button>
                              )}
                            </div>
                          </div>
                        );
                      })
                    )}
                  </div>
                </div>
              </div>
            </div>
          )}

        </section>

      </main>

      <footer className="border-t border-[#2A2A2A] bg-[#0C0C0C] p-6 text-center select-none mt-auto">
        <p className="text-xs text-[#666] leading-normal max-w-2xl mx-auto font-sans">
          Fenix Sovereign AI Agent Architecture. Diseñado bajo el paradigma de inmunidad de logs, privacidad absoluta zero-knowledge en local markdown (Nano-Obsidian) y procesamiento ciego asíncrono en VPS Hostinger con FastAPI.
        </p>
        <p className="text-[10px] text-[#555] font-mono mt-2">
          © 2026 Fenix · Clean Architecture Native Dart & Python. Todos los derechos reservados.
        </p>
      </footer>

    </div>
  );
}
