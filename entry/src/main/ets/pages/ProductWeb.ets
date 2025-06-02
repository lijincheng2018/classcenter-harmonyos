import router from '@ohos.router';

@Entry
@Component
struct ProductWeb {

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Image($r('app.media.back'))
          .width(24)
          .height(24)
          .margin({ left: 16, right: 8 })
          .onClick(() => {
            router.back();
          })
        Text('产品文档')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
        Blank()
      }
      .width('100%')
      .height(56)
      .backgroundColor('#FFFFFF')
      .padding({ right: 16 })
      .border({ width: { bottom: 1 }, color: '#F0F0F0' })

      Web({
        src: 'https://docs.classcloud.com.cn',
        controller: new WebController()
      })
      .layoutWeight(1)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }
}