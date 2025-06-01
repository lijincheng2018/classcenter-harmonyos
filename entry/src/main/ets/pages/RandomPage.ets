import router from '@ohos.router';
import { ToastOptions, StudentVO, DrawResult } from '../models/dataModels';
import CommonConstants from '../common/Constants';
import TokenManager from '../utils/TokenManager';
import HttpService from '../services/HttpService';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct RandomPage {
  @State studentList: StudentVO[] = [];
  @State isLoading: boolean = true;
  @State isDrawing: boolean = false;
  @State randomTitle: string = '点击开始抽号';
  @State btnTitle: string = '开始抽号';
  @State showResetBtn: boolean = false;
  @State resultList: DrawResult[] = [];
  @State refreshing: boolean = false;
  @State loading: boolean = false;

  aboutToAppear() {
    this.loadStudentList();
  }

  async loadStudentList() {
    try {
      this.isLoading = true;
      const token = await TokenManager.getToken();

      // 设置token到HttpService
      const httpService = HttpService;
      httpService.setToken(token);

      // 使用HttpService发送获取学生列表请求
      httpService.get<StudentVO[]>(
        CommonConstants.API_RANDOM
      ).then(response => {
        if (response.code === 200 && response.data) {
          this.studentList = response.data;
        } else {
          const toastOptions: ToastOptions = { message: response.msg || '加载失败', duration: 2000 };
          promptAction.showToast(toastOptions);
        }
      }).catch((err: Error) => {
        console.log('student list err=>', err);
        console.error('加载数据失败:', err);
      }).finally(() => {
        this.isLoading = false;
      });
    } catch (error) {
      this.isLoading = false;
    }
  }

  async onRefresh() {
    this.refreshing = true;
    await this.loadStudentList();
    this.refreshing = false;
  }

  async startDraw() {
    if (this.studentList.length === 0) {
      const toastOptions: ToastOptions = { message: '暂无学生数据', duration: 2000 };
      promptAction.showToast(toastOptions);
      return;
    }

    try {
      this.isDrawing = true;
      this.btnTitle = '抽号中...';
      this.randomTitle = '抽号中...';
      
      // 模拟抽号过程
      await new Promise<void>(resolve => setTimeout(resolve, 1500));


      // 随机选择一个学生
      const randomIndex = Math.floor(Math.random() * this.studentList.length);
      const selectedStudent = this.studentList[randomIndex];
      
      // 添加到结果列表
      const result: DrawResult = {
        name: selectedStudent.name,
        timestamp: new Date().toLocaleString()
      };
      this.resultList.unshift(result);
      
      // 更新UI状态
      this.randomTitle = selectedStudent.name;
      this.btnTitle = '再次抽号';
      this.showResetBtn = true;
      
    } catch (error) {
      const toastOptions: ToastOptions = { message: '抽号失败，请重试', duration: 2000 };
      promptAction.showToast(toastOptions);
    } finally {
      this.isDrawing = false;
    }
  }

  resetDraw() {
    this.randomTitle = '点击开始抽号';
    this.btnTitle = '开始抽号';
    this.showResetBtn = false;
    this.resultList = [];
  }

  @Builder
  refreshBuilder() {
    Row() {
      LoadingProgress()
        .width(24)
        .height(24)
        .margin({ right: 8 })
      Text('正在刷新...')
        .fontSize(14)
        .fontColor('#666666')
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height(60)
  }

  @Builder
  GeneratorCard() {
    Column() {
      // 卡片标题
      Row() {
        Text('抽号区')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
      }
      .width('100%')
      .margin({ bottom: 20 })
      
      // 数字显示圆圈
      Stack() {
        // 外圈光晕效果
        Circle()
          .width(140)
          .height(140)
          .fill('#E3F2FD')
          .opacity(0.6)
        
        // 主圆圈
        Circle()
          .width(120)
          .height(120)
          .fill('#2196F3')
          .shadow({
            radius: 10,
            color: '#1A2196F3',
            offsetX: 0,
            offsetY: 4
          })
        
        // 显示文字
        Text(this.randomTitle)
          .fontSize(this.randomTitle.length > 6 ? 14 : 16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .textAlign(TextAlign.Center)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width(100)
      }
      .margin({ top: 30, bottom: 30 })
      
      // 控制按钮组
      Row({ space: 16 }) {
        Button(this.btnTitle)
          .width(120)
          .height(44)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(this.isDrawing ? '#CCCCCC' : '#2196F3')
          .fontColor('#FFFFFF')
          .borderRadius(22)
          .enabled(!this.isDrawing)
          .onClick(() => this.startDraw())
        
        if (this.showResetBtn) {
          Button('重置')
            .width(80)
            .height(44)
            .fontSize(14)
            .backgroundColor('#FF9800')
            .fontColor('#FFFFFF')
            .borderRadius(22)
            .onClick(() => this.resetDraw())
        }
      }
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .padding(24)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({
      radius: 12,
      color: '#1A000000',
      offsetX: 0,
      offsetY: 4
    })
    .margin({ top: 8, bottom: 8, left: 16, right: 16 })
  }

  @Builder
  ResultsCard() {
    Column() {
      // 卡片标题
      Row() {
        Text('结果区')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
      }
      .width('100%')
      .margin({ bottom: 16 })
      
      // 结果内容
      if (this.resultList.length === 0) {
        // 空状态
        Column() {
          Image($r('app.media.empty'))
            .width(80)
            .height(80)
            .margin({ bottom: 12 })
            .opacity(0.6)
          Text('暂无数据哦~')
            .fontSize(14)
            .fontColor('#999999')
        }
        .width('100%')
        .padding({ top: 40, bottom: 40 })
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        // 结果列表
        Column() {
          ForEach(this.resultList, (item: DrawResult, index: number) => {
            Row() {
              // 序号
              Text((index + 1).toString())
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
                .width(28)
                .height(28)
                .textAlign(TextAlign.Center)
                .backgroundColor('#2196F3')
                .borderRadius(14)
                .margin({ right: 16 })
              
              // 姓名和时间
              Column() {
                Text(item.name)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333333')
                  .margin({ bottom: 4 })
                Text(item.timestamp)
                  .fontSize(12)
                  .fontColor('#999999')
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
            }
            .width('100%')
            .padding({ top: 12, bottom: 12, left: 4, right: 4 })
            .borderRadius(8)
            .backgroundColor(index === 0 ? '#F3F8FF' : 'transparent')
            
            if (index < this.resultList.length - 1) {
              Divider()
                .color('#F0F0F0')
                .margin({ top: 8, bottom: 8 })
            }
          }, (item: DrawResult, index: number) => `${item.name}_${index}`)
        }
        .width('100%')
      }
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({
      radius: 12,
      color: '#1A000000',
      offsetX: 0,
      offsetY: 4
    })
    .margin({ bottom: 16 })
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Image($r('app.media.back'))
          .width(24)
          .height(24)
          .onClick(() => router.back())
        
        Text('随机抽号')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        // 占位，保持标题居中
        Row().width(24).height(24)
      }
      .width('100%')
      .height(56)
      .padding({ bottom: 16 })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .backgroundColor('#FFFFFF')
      .shadow({
        radius: 4,
        color: '#1A000000',
        offsetX: 0,
        offsetY: 2
      })
      
      // 主要内容区域
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(48)
            .height(48)
            .margin({ bottom: 16 })
          Text('加载中...')
            .fontSize(14)
            .fontColor('#666666')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        Refresh({ refreshing: this.refreshing, builder: this.refreshBuilder }) {
          Scroll() {
            Column() {
              // 抽号区域
              this.GeneratorCard()
              
              // 结果区域
              this.ResultsCard()
              
              // 底部说明
              Text('鸿蒙版仅提供基础抽号功能，更多功能请使用网页端')
                .fontSize(12)
                .fontColor('#999999')
                .textAlign(TextAlign.Center)
                .width('100%')
                .padding({ left: 16, right: 16, top: 20, bottom: 20 })
            }
            .width('100%')
            .padding({ top: 16, bottom: 20 })
          }
          .width('100%')
          .layoutWeight(1)
          .scrollable(ScrollDirection.Vertical)
          .scrollBar(BarState.Auto)
        }
        .onRefreshing(() => {
          this.onRefresh()
        })
        .width('100%')
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}