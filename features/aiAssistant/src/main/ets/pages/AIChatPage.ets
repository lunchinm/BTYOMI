import { ChatService } from '../service/ChatService';
import { BehaviorTracker, UserBehaviorProfile, ProfileCompletenessResult, BehaviorEvent } from '@ohos/common';
import { ChatMessage, MessageType, CarInfo } from '../model/ChatModel';
import { ChatMessageBubble } from '../components/ChatMessageBubble';
import { ChatInputBar } from '../components/ChatInputBar';
import { QuickQuestions } from '../components/QuickQuestions';

interface RenderItem {
  id: string;
  type: string;
  timeLabel: string;
  message: ChatMessage | null;
}

@Component
export struct AIChatPage {
  @Consume('pageInfos') pageInfos: NavPathStack = new NavPathStack();

  @State messages: ChatMessage[] = [];
  @State isLoading: boolean = false;
  @State inputText: string = '';

  private chatService: ChatService = ChatService.getInstance();
  private behaviorTracker: BehaviorTracker = BehaviorTracker.getInstance();
  private listScroller: Scroller = new Scroller();
  private hasWelcome: boolean = false;

  private getRenderItems(): RenderItem[] {
    const items: RenderItem[] = [];
    for (let i = 0; i < this.messages.length; i++) {
      const msg: ChatMessage = this.messages[i];
      if (i > 0) {
        const prevTimestamp: number = this.messages[i - 1].timestamp;
        const label: string = this.formatTimeDivider(prevTimestamp, msg.timestamp);
        if (label.length > 0) {
          const timeItem: RenderItem = {
            id: `time_${msg.id}`,
            type: 'time',
            timeLabel: label,
            message: null
          };
          items.push(timeItem);
        }
      }
      const msgItem: RenderItem = {
        id: msg.id,
        type: 'message',
        timeLabel: '',
        message: msg
      };
      items.push(msgItem);
    }
    return items;
  }

  aboutToAppear(): void {
    this.behaviorTracker.init();
    this.chatService.initNetworkMonitor();
    this.chatService.loadHistory();
    this.syncState();
    if (this.messages.length === 0) {
      this.initWelcomeMessage();
    }
  }

  private syncState(): void {
    const state = this.chatService.getState();
    this.messages = state.messages;
    this.isLoading = state.isLoading;
  }

  private handleInputFocus(): void {
    this.scrollToBottom();
  }

  private initWelcomeMessage(): void {
    if (this.hasWelcome) {
      return;
    }
    this.hasWelcome = true;
    const welcomeMessage: ChatMessage = {
      id: 'welcome',
      role: 'assistant',
      type: MessageType.TEXT,
      content: '你好！我是你的AI选车顾问，告诉我你的需求，我来帮你找到最适合的车型 🚗',
      timestamp: Date.now()
    };
    this.messages = [welcomeMessage];
  }

  private async handleSendMessage(content: string): Promise<void> {
    if (!content.trim()) {
      return;
    }

    this.inputText = '';
    this.messages = this.chatService.sendUserMessage(content, 'AIChatPage');
    this.isLoading = true;
    this.scrollToBottom();

    const profile: UserBehaviorProfile = this.behaviorTracker.getProfile();
    const completeness: ProfileCompletenessResult = this.behaviorTracker.calculateCompleteness();
    this.messages = await this.chatService.getAIResponse(profile, completeness);
    this.isLoading = this.chatService.getIsLoading();
    this.scrollToBottom();
  }

  private scrollToBottom(): void {
    setTimeout(() => {
      this.listScroller.scrollEdge(Edge.Bottom);
    }, 50);
  }

  private handleQuickQuestion(question: string): void {
    this.handleSendMessage(question);
  }

  private handleRetry(_errorMessage: ChatMessage): void {
    const lastUserMessage = this.messages.find((m: ChatMessage) => m.role === 'user');
    if (lastUserMessage) {
      this.handleSendMessage(lastUserMessage.content);
    }
  }

  private handleOptionClick(option: string): void {
    this.handleSendMessage(option);
  }

  private handleFavoriteCar(car: CarInfo, isFavorited: boolean): void {
    const extra: Record<string, string> = {};
    extra['carId'] = car.id.toString();
    extra['brand'] = car.brand;
    extra['model'] = car.model;
    const event: BehaviorEvent = {
      eventType: isFavorited ? 'favorite_add' : 'favorite_remove',
      targetId: car.id.toString(),
      targetType: 'car',
      timestamp: Date.now(),
      pageName: 'AIChatPage',
      extra: extra
    };
    this.behaviorTracker.track(event);
  }

  private handleNewConversation(): void {
    this.chatService.clearConversation();
    this.hasWelcome = false;
    this.syncState();
    this.initWelcomeMessage();
    this.isLoading = false;
  }

  private formatTimeDivider(prevTimestamp: number, currTimestamp: number): string {
    const diff: number = currTimestamp - prevTimestamp;
    const diffMinutes: number = Math.floor(diff / 60000);
    if (diffMinutes < 5) {
      return '';
    }
    if (diffMinutes < 60) {
      return `${diffMinutes}分钟前`;
    }
    const diffHours: number = Math.floor(diffMinutes / 60);
    if (diffHours < 24) {
      return `${diffHours}小时前`;
    }
    const diffDays: number = Math.floor(diffHours / 24);
    if (diffDays === 1) {
      return '昨天';
    }
    if (diffDays < 30) {
      return `${diffDays}天前`;
    }
    const date: Date = new Date(currTimestamp);
    const month: number = date.getMonth() + 1;
    const day: number = date.getDate();
    return `${month}月${day}日`;
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          Text('AI 选车顾问')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1);

          Text('📊')
            .fontSize(20)
            .padding({ left: 8, right: 8 })
            .onClick(() => {
              this.pageInfos.pushPath({ name: 'ProfileReportPage' });
            });

          Text('+ 新对话')
            .fontSize(13)
            .fontColor('#007DFF')
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .borderRadius(16)
            .backgroundColor('#F0F5FF')
            .margin({ left: 8 })
            .onClick(() => {
              this.handleNewConversation();
            });
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 20, bottom: 10 });

        List({ space: 0, scroller: this.listScroller }) {
          ListItem() {
            QuickQuestions({ onQuestionClick: this.handleQuickQuestion.bind(this) });
          }

          ForEach(this.getRenderItems(), (item: RenderItem) => {
            ListItem() {
              if (item.type === 'time') {
                Text(item.timeLabel)
                  .fontSize(12)
                  .fontColor('#999999')
                  .width('100%')
                  .textAlign(TextAlign.Center)
                  .padding({ top: 8, bottom: 8 });
              } else if (item.message) {
                ChatMessageBubble({
                  message: item.message,
                  onRetry: this.handleRetry.bind(this),
                  onOptionClick: this.handleOptionClick.bind(this),
                  onFavoriteCar: this.handleFavoriteCar.bind(this)
                });
              }
            }
          }, (item: RenderItem) => item.id);
        }
        .layoutWeight(1)
        .width('100%')
        .edgeEffect(EdgeEffect.Spring)
        .onClick(() => {});

        ChatInputBar({
          inputText: this.inputText,
          onInputChange: (text: string) => {
            this.inputText = text;
          },
          onSend: this.handleSendMessage.bind(this),
          isLoading: this.isLoading,
          onInputFocus: this.handleInputFocus.bind(this)
        });
      }
      .width('100%')
      .height('100%');
    }
    .hideTitleBar(true);
  }
}
