import router from '@ohos.router';
import { ExamVO, ToastOptions } from '../models/dataModels';
import CommonConstants from '../common/Constants';
import HttpService from '../services/HttpService';
import promptAction from '@ohos.promptAction';
import TokenManager from '../utils/TokenManager';

@Entry
@Component
struct ExamPage {
  @State exams: ExamVO[] = [];
  @State isLoading: boolean = true;
  @State refreshing: boolean = false;

  aboutToAppear() {
    this.loadExams();
  }

  async loadExams() {
    try {
      this.isLoading = true;

      const token = await TokenManager.getToken();


      // 设置token到HttpService
      const httpService = HttpService;
      httpService.setToken(token);


      httpService.get<ExamVO[]>(
        CommonConstants.API_EXAMS
      ).then(response => {
        if (response.code === 200 && response.data) {
          this.exams = response.data || [];
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

    } finally {
      this.isLoading = false;
    }
  }

  async onRefresh() {
    this.refreshing = true;
    await this.loadExams();
    this.refreshing = false;
  }

  getExamTypeText(examType: string): string {
    switch (examType) {
      case '1': return '周考';
      case '2': return '月考';
      case '3': return '期中考';
      case '4': return '期末考';
      default: return '学年结业';
    }
  }

  onExamClick(exam: ExamVO) {
    if (exam.isOpen === '1') {
      router.pushUrl({
        url: CommonConstants.EXAM_REPORT_PAGE,
        params: { examId: exam.examID, examName: exam.examName }
      });
    } else {
      const toastOptions: ToastOptions = { message: '考试尚未开放', duration: 2000 };
      promptAction.showToast(toastOptions);
    }
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
  ExamCard(exam: ExamVO) {
    Column() {
      Row() {
        Column() {
          Text(exam.examName)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ bottom: 4 })
          
          Text(`考试时间: ${exam.examDate}`)
            .fontSize(12)
            .fontColor('#999999')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        
        Column() {
          Text(exam.isOpen === '1' ? '已开放' : '未开放')
            .fontSize(12)
            .fontColor(exam.isOpen === '1' ? '#4CAF50' : '#FF9800')
            .backgroundColor(exam.isOpen === '1' ? '#E8F5E8' : '#FFF3E0')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .borderRadius(12)
            .margin({ bottom: 8 })
          
          Text(`类型: ${this.getExamTypeText(exam.examLeixing)}`)
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      
      Divider()
        .color('#F0F0F0')
        .margin({ top: 12, bottom: 12 })
      
      Row() {
        Text(`创建时间: ${exam.createTime}`)
          .fontSize(12)
          .fontColor('#666666')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({
      radius: 8,
      color: '#1A000000',
      offsetX: 0,
      offsetY: 2
    })
    .margin({ left: 16, right: 16, top: 8, bottom: 8 })
    .onClick(() => this.onExamClick(exam))
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Image($r('app.media.back'))
          .width(24)
          .height(24)
          .onClick(() => router.back())
        
        Text('成绩查询')
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
      .padding({ left: 16, right: 16 })
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
          if (this.exams.length > 0) {
            Scroll() {
              Column() {
                ForEach(this.exams, (exam: ExamVO) => {
                  this.ExamCard(exam)
                }, (exam: ExamVO) => exam.examID.toString())
              }
              .width('100%')
              .padding({ top: 16, bottom: 20 })
            }
            .width('100%')
            .layoutWeight(1)
            .scrollable(ScrollDirection.Vertical)
            .scrollBar(BarState.Auto)
          } else {
            Column() {
              Image($r('app.media.empty'))
                .width(120)
                .height(120)
                .margin({ bottom: 16 })
              Text('暂无考试记录')
                .fontSize(16)
                .fontColor('#999999')
                .margin({ bottom: 8 })
              Text('考试信息将在这里显示')
                .fontSize(14)
                .fontColor('#CCCCCC')
            }
            .width('100%')
            .layoutWeight(1)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
          }
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