import { ChatMessage, MessageType } from '../model/ChatModel';
import { preferencesUtil } from '@ohos/common';

const CHAT_HISTORY_KEY: string = 'chat_history_messages';
const MAX_HISTORY_COUNT: number = 100;

export class ChatHistoryManager {
  private static instance: ChatHistoryManager;

  private constructor() {}

  public static getInstance(): ChatHistoryManager {
    if (!ChatHistoryManager.instance) {
      ChatHistoryManager.instance = new ChatHistoryManager();
    }
    return ChatHistoryManager.instance;
  }

  public saveSession(messages: ChatMessage[]): void {
    const savable: ChatMessage[] = [];
    for (let i = 0; i < messages.length; i++) {
      const msg: ChatMessage = messages[i];
      if (msg.type === MessageType.LOADING || msg.type === MessageType.ERROR) {
        continue;
      }
      if (msg.id === 'welcome') {
        continue;
      }
      const trimmed: ChatMessage = {
        id: msg.id,
        role: msg.role,
        type: msg.type,
        content: msg.content.length > 500 ? msg.content.substring(0, 500) : msg.content,
        options: msg.options,
        timestamp: msg.timestamp
      };
      savable.push(trimmed);
      if (savable.length >= MAX_HISTORY_COUNT) {
        break;
      }
    }
    try {
      const json: string = JSON.stringify(savable);
      if (json.length > 8100) {
        const reduced: ChatMessage[] = [];
        for (let i = savable.length - 1; i >= 0; i--) {
          reduced.unshift(savable[i]);
          const testJson: string = JSON.stringify(reduced);
          if (testJson.length > 8000) {
            reduced.shift();
            break;
          }
        }
        preferencesUtil.pref?.putSync(CHAT_HISTORY_KEY, JSON.stringify(reduced));
        preferencesUtil.pref?.flush();
        return;
      }
      preferencesUtil.pref?.putSync(CHAT_HISTORY_KEY, json);
      preferencesUtil.pref?.flush();
    } catch (e) {
      // ignore
    }
  }

  public loadSession(): ChatMessage[] {
    try {
      const json: string = preferencesUtil.pref?.getSync(CHAT_HISTORY_KEY, '') as string;
      if (!json || json.length === 0) {
        return [];
      }
      const parsed: ChatMessage[] = JSON.parse(json) as ChatMessage[];
      if (parsed && parsed.length > 0) {
        return parsed;
      }
    } catch (e) {
      // ignore
    }
    return [];
  }

  public clearSession(): void {
    try {
      preferencesUtil.pref?.deleteSync(CHAT_HISTORY_KEY);
      preferencesUtil.pref?.flush();
    } catch (e) {
      // ignore
    }
  }
}
