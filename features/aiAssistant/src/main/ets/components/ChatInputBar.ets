@Component
export struct ChatInputBar {
  @Prop inputText: string = '';
  @Prop isLoading: boolean = false;

  onInputChange: (text: string) => void = () => {};
  onSend: (content: string) => void = () => {};
  onInputFocus: () => void = () => {};

  build() {
    Row() {
      TextInput({ placeholder: '输入你的需求...', text: this.inputText })
        .width('70%')
        .height(48)
        .backgroundColor('#F5F5F5')
        .borderRadius(24)
        .padding({ left: 20 })
        .onChange((value: string) => {
          this.onInputChange(value);
        })
        .onFocus(() => {
          this.onInputFocus();
        });

      Button(this.isLoading ? '发送中...' : '发送')
        .width(80)
        .height(48)
        .backgroundColor('#007DFF')
        .fontColor('#FFFFFF')
        .borderRadius(24)
        .enabled(!this.isLoading && this.inputText.trim().length > 0)
        .onClick(() => {
          this.onSend(this.inputText);
        });
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 8, bottom: 16 })
    .backgroundColor('#FFFFFF');
  }
}