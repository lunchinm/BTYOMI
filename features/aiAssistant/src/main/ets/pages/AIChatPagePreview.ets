import { AIChatPage } from './AIChatPage';

@Entry
@Component
struct AIChatPagePreview {
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack();

  build() {
    Column() {
      AIChatPage();
    }
    .width('100%')
    .height('100%');
  }
}