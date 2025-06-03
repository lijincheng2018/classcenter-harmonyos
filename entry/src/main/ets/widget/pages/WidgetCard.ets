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
  @LocalStorageProp('userName') userName: string = "N/A";
  @LocalStorageProp('userRole') userRole: string = "N/A";
  @LocalStorageProp('userGroup') userGroup: string = "3";

  /*
   * 刷新数据方法
   */
  private refreshData(): void {
    // 触发数据刷新的逻辑
    postCardAction(this, {
      action: 'message',
      params: {
        method: 'refreshWidgetData'
      }
    });
  }

  private getPermissionLabel(permision : string): string {
    if (permision === '1') {
      return '超级管理员';
    } else if (permision === '2') {
      return '管理员';
    } else if (permision === '3') {
      return '学生';
    } else {
      return '课代表';
    }
  }
  
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
    Column({ space: 6 }) {
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
        
        // 刷新按钮
        Button({ type: ButtonType.Circle }) {
          Image($r('app.media.refresh'))
            .width(20)
            .height(20)
            .fillColor('#666666')
        }
        .width(24)
        .height(24)
        .backgroundColor('#F5F5F5')
        .margin({ left: 8 })
        .onClick(() => {
          this.refreshData();
        })
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 8 })
      
      // 个人信息区域
      Row({ space: 8 }) {
        // 用户信息
        Column({ space: 2 }) {
          Text(this.userName)
            .fontSize(13)
            .fontColor('#333333')
            .fontWeight(FontWeight.Medium)
          Text(this.getPermissionLabel(this.userGroup))
            .fontSize(11)
            .fontColor('#666666')
        }
        .alignItems(HorizontalAlign.Start)
        
        Blank()
        
        // 状态标签
        Text(this.userRole)
          .fontSize(10)
          .fontColor('#10B981')
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .backgroundColor('#F0FDF4')
          .borderRadius(10)
          .border({ width: 1, color: '#10B981' })
      }
      .width('100%')
      .padding({ left: 12, right: 12 })
      .backgroundColor('#FAFAFA')
      .borderRadius(8)
      .margin({ left: 12, right: 12 })
      
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
        .padding({ bottom: 6 })
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