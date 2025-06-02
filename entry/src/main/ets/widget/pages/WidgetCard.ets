@Entry
@Component
struct WidgetCard {
  /*
   * 任务统计数据
   */
  @LocalStorageProp('totalCount') totalCount: number = 0;
  @LocalStorageProp('finishCount') finishCount: number = 0;
  @LocalStorageProp('title') title: string = "待办事项";
  @LocalStorageProp('lastUpdate') lastUpdate: string = "";
  
  /*
   * The action type.
   */
  readonly actionType: string = 'router';
  /*
   * The ability name.
   */
  readonly abilityName: string = 'EntryAbility';
  /*
   * The message.
   */
  readonly message: string = 'openTaskPage';
  /*
   * The width percentage setting.
   */
  readonly fullWidthPercent: string = '100%';
  /*
   * The height percentage setting.
   */
  readonly fullHeightPercent: string = '100%';

  // 计算完成率
  private getCompletionRate(): number {
    return this.totalCount > 0 ? Math.round((this.finishCount / this.totalCount) * 100) : 0;
  }

  build() {
    Column({ space: 8 }) {
      // 标题区域
      Row() {
        Text(this.title)
          .fontSize(14)
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)
        
        Blank()
        
        // 刷新时间
        if (this.lastUpdate) {
          Text(this.lastUpdate)
            .fontSize(10)
            .fontColor('#999999')
        }
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 8 })
      
      // 数据展示区域
      Row({ space: 8 }) {
        // 总任务数
        Column({ space: 4 }) {
          Text(this.totalCount.toString())
            .fontSize(20)
            .fontColor('#3B82F6')
            .fontWeight(FontWeight.Bold)
          Text('总任务')
            .fontSize(10)
            .fontColor('#666666')
        }
        .layoutWeight(1)
        .padding(8)
        .backgroundColor('#F8FAFC')
        .borderRadius(8)
        
        // 已完成数
        Column({ space: 4 }) {
          Text(this.finishCount.toString())
            .fontSize(20)
            .fontColor('#10B981')
            .fontWeight(FontWeight.Bold)
          Text('已完成')
            .fontSize(10)
            .fontColor('#666666')
        }
        .layoutWeight(1)
        .padding(8)
        .backgroundColor('#F0FDF4')
        .borderRadius(8)
        
        // 完成率
        Column({ space: 4 }) {
          Row({ space: 1 }) {
            Text(this.getCompletionRate().toString())
              .fontSize(20)
              .fontColor('#F59E0B')
              .fontWeight(FontWeight.Bold)
            Text('%')
              .fontSize(14)
              .fontColor('#F59E0B')
              .fontWeight(FontWeight.Bold)
          }
          .justifyContent(FlexAlign.Center)
          
          Text('完成率')
            .fontSize(10)
            .fontColor('#666666')
        }
        .layoutWeight(1)
        .padding(8)
        .backgroundColor('#FFFBEB')
        .borderRadius(8)
      }
      .width('100%')
      .padding({ left: 12, right: 12 })
      
      // 底部提示
      Text('点击查看详情')
        .fontSize(10)
        .fontColor('#999999')
        .textAlign(TextAlign.Center)
        .width('100%')
        .padding({ bottom: 8 })
    }
    .width(this.fullWidthPercent)
    .height(this.fullHeightPercent)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 4, color: '#1F000000', offsetX: 0, offsetY: 2 })
    .onClick(() => {
      postCardAction(this, {
        action: this.actionType,
        abilityName: this.abilityName,
        params: {
          message: this.message
        }
      });
    })
  }
}