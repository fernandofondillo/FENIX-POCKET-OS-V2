// Types for Fenix Sandbox Architecture

export interface Capsule {
  id: string;
  name: string;
  avatar: string;
  description: string;
  roleDescription: string;
  systemPrompt: string;
  skills: string[];
  themeColor: string; // Tailwind class color
  accentHex: string;  // Hex for direct styling
  bgGradient: string; // Gradient color profile
  badgeColor: string; // Tailwind badge style
}

export interface ObsidianFile {
  id: string;
  filename: string;
  category: "personal" | "expert";
  chapter: string;
  encryptedContent: string;
  decryptedContent: string;
}

export interface IdentityProfile {
  name: string;
  profession: string;
  trainingRythmn: string;
  focusGoal: string;
  healthConstraints: string;
}

export interface ChatMessage {
  id: string;
  role: "user" | "assistant" | "system";
  content: string;
  timestamp: string;
  ragContextUsed?: {
    userNote?: string;
    expertArticle?: string;
  };
  triggeredSkill?: {
    name: string;
    description: string;
    args: any;
  } | null;
}
