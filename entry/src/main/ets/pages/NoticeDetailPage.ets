// 公告详情页面
import router from '@ohos.router';
import { NoticeVO } from '../models/dataModels';

@Entry
@Component
struct NoticeDetailPage {
  @State notice: NoticeVO | null = null;
  @State isLoading: boolean = true;

  aboutToAppear() {
    if (router.getParams() !== undefined && router.getParams() !== null) {
      let record = router.getParams() as Record<string, NoticeVO>;
      if (record !== undefined && record !== null) {
        this.notice = record['notice'];
      }
    }
    // 模拟加载延迟
    setTimeout(() => {
      this.isLoading = false;
    }, 300);
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Row() {
          Image($r('app.media.back'))
            .width(20)
            .height(20)
            .fillColor('#333333')
        }
        .width(40)
        .height(40)
        .borderRadius(20)
        // .backgroundColor('rgba(255, 255, 255, 0.2)')
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          router.back();
        })
        .transition({ type: TransitionType.All, scale: { x: 0.9, y: 0.9 } })

        Text('公告详情')
          .fontSize(20)
          .fontColor('#333333')
          .fontWeight(700)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        // 占位，保持标题居中
        Row().width(40).height(40)
      }
      .width('100%')
      .height(60) // 调整导航栏高度
      .padding({
        left: 16,
        right: 16,
        top: 10,
        bottom: 10
      }) // 调整内边距
      .backgroundColor('#FFFFFF')
      .border({ width: { bottom: 1 }, color: '#E0E0E0' })

      if (this.notice && !this.isLoading) {
        Scroll() {
          Column({ space: 0 }) {
            // 主要内容卡片
            Column({ space: 24 }) {
              // 公告标题区域
              Column({ space: 12 }) {
                Text(this.notice.title)
                  .fontSize(24)
                  .fontColor('#1a1a1a')
                  .fontWeight(700)
                  .width('100%')
                  .textAlign(TextAlign.Start)
                  .lineHeight(32)

                // 发布时间标签
                Row({ space: 8 }) {
                  Row() {
                    Image($r('app.media.ic_time'))
                      .width(16)
                      .height(16)
                      .fillColor('#667eea')
                      .margin({ right: 4 })
                    Text('发布时间')
                      .fontSize(12)
                      .fontColor('#667eea')
                      .fontWeight(500)
                  }
                  .padding({
                    left: 12,
                    right: 12,
                    top: 6,
                    bottom: 6
                  })
                  .backgroundColor('#f0f4ff')
                  .borderRadius(12)

                  Text(this.notice.time)
                    .fontSize(14)
                    .fontColor('#666666')
                    .fontWeight(500)
                }
                .width('100%')
                .justifyContent(FlexAlign.Start)

                // 发布者
                Row({ space: 8 }) {
                  Row() {
                    Text('发布者')
                      .fontSize(12)
                      .fontColor('#667eea')
                      .fontWeight(500)
                  }
                  .padding({
                    left: 12,
                    right: 12,
                    top: 6,
                    bottom: 6
                  })
                  .backgroundColor('#f0f4ff')
                  .borderRadius(12)

                  Text(this.notice.poster)
                    .fontSize(14)
                    .fontColor('#666666')
                    .fontWeight(500)
                }
                .width('100%')
                .justifyContent(FlexAlign.Start)
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)

              // 优雅的分割线
              Row()
                .width('100%')
                .height(1)
                .backgroundColor('#E0E0E0') // 修改分割线为纯色

              // 公告内容
              Text(this.notice.content)
                .fontSize(16)
                .fontColor('#333333')
                .lineHeight(28)
                .width('100%')
                .textAlign(TextAlign.Start)
                .fontWeight(400)
            }
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.Start)
            .width('100%')
            .padding(24)
            .backgroundColor('#FFFFFF')
            .borderRadius(20)
            .shadow({
              radius: 15,
              color: 'rgba(0, 0, 0, 0.08)',
              offsetX: 0,
              offsetY: 4
            })
          }
          .padding({ top: 0, left: 20, right: 20 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      } else if (this.isLoading) {
        // 加载状态
        Column() {
          LoadingProgress()
            .width(60)
            .height(60)
            .color('#4A90E2')
            .margin({ top: 40 })

          Text('加载中...')
            .fontSize(16)
            .fontColor('#4A90E2')
            .margin({ top: 20 })
            .fontWeight(500)
        }
        .width('100%')
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Start)
      } else {
        // 错误状态 - 美化设计
        Column() {
          Column() {
            Image($r('app.media.error'))
              .width(100)
              .height(100)
              .fillColor('#D9534F')// 修改错误图标颜色
              .opacity(1)

            Text('公告不存在')
              .fontSize(18)
              .fontColor('#333333')
              .fontWeight(600)
              .margin({ top: 24 })

            Text('抱歉，您要查看的公告可能已被删除或不存在')
              .fontSize(14)
              .fontColor('#999999')
              .textAlign(TextAlign.Center)
              .margin({ top: 8 })
              .lineHeight(20)

            Button('返回')
              .width(120)
              .height(44)
              .backgroundColor('#4A90E2')// 修改按钮背景色
              .fontColor('#FFFFFF')
              .borderRadius(22)
              .margin({ top: 32 })
              .fontSize(16)
              .fontWeight(500)
              .onClick(() => {
                router.back();
              })
              .shadow({
                radius: 12,
                color: 'rgba(102, 126, 234, 0.3)',
                offsetX: 0,
                offsetY: 4
              })
          }
          .padding(40)
          .backgroundColor('#FFFFFF')
          .borderRadius(20)
          .shadow({
            radius: 20,
            color: 'rgba(0, 0, 0, 0.08)',
            offsetX: 0,
            offsetY: 4
          })
          .margin({ left: 20, right: 20 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Start)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5') // 修改页面背景为浅灰色
  }
}