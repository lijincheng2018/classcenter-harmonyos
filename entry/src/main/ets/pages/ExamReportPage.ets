import router from '@ohos.router';
import { ExamReportVO, SubjectScoreVO, ToastOptions } from '../models/dataModels';
import CommonConstants from '../common/Constants';
import HttpService from '../services/HttpService';
import promptAction from '@ohos.promptAction';
import TokenManager from '../utils/TokenManager';

interface GeneratedTypeLiteralInterface_1 {
  bgColor: string;
  textColor: string;
}

@Entry
@Component
struct ExamReportPage {
  @State examReport: ExamReportVO | null = null;
  @State isLoading: boolean = true;
  private examId: number = 0;
  private examName: string = '';

  aboutToAppear() {
    const params = router.getParams() as Record<string, Object>;
    this.examId = params['examId'] as number;
    this.examName = params['examName'] as string || '考试报告';
    this.loadExamReport();
  }

  async loadExamReport() {
    try {
      this.isLoading = true;
      const token = await TokenManager.getToken();


      // 设置token到HttpService
      const httpService = HttpService;
      httpService.setToken(token);

      httpService.get<ExamReportVO>(
        CommonConstants.API_EXAMS + "/" + this.examId
      ).then(response => {
        if (response.code === 200 && response.data) {
          this.examReport = response.data;
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

  getScoreColor(score: number): string {
    if (score >= 90) return '#4CAF50';
    if (score >= 80) return '#8BC34A';
    if (score >= 60) return '#FF9800';
    return '#F44336';
  }

  getGradeLevel(score: number): string {
    if (score >= 90) return '优秀';
    if (score >= 80) return '良好';
    if (score >= 60) return '及格';
    return '不及格';
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

  getGradeBadgeStyle(score: number): GeneratedTypeLiteralInterface_1 {
    if (score >= 90) return { bgColor: '#E8F5E8', textColor: '#2E7D32' };
    if (score >= 80) return { bgColor: '#F3E5F5', textColor: '#7B1FA2' };
    if (score >= 60) return { bgColor: '#FFF8E1', textColor: '#F57C00' };
    return { bgColor: '#FFEBEE', textColor: '#C62828' };
  }

  @Builder
  ScoreOverview() {
    if (this.examReport) {
      Column() {
        // 综合分数展示
        Row() {
          Column() {
            Text(this.examReport.zonghe)
              .fontSize(48)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.getScoreColor(parseFloat(this.examReport.zonghe)))
            Text('综合分数')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ top: 4 })
          }
          .alignItems(HorizontalAlign.Center)
          
          Column() {
            Row() {
              Text('班级排名: ')
                .fontSize(14)
                .fontColor('#666666')
              Text(this.examReport.class_rank)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
            }
            .margin({ bottom: 8 })
            
            Row() {
              Text('专业排名: ')
                .fontSize(14)
                .fontColor('#666666')
              Text(this.examReport.zhuanye_rank)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
            }
            .margin({ bottom: 8 })
            
            Row() {
              Text('等级: ')
                .fontSize(14)
                .fontColor('#666666')
              Text(this.getGradeLevel(parseFloat(this.examReport.zonghe)))
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.getScoreColor(parseFloat(this.examReport.zonghe)))
            }
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          .margin({ left: 32 })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
        
        Divider()
          .color('#E0E0E0')
          .margin({ top: 16, bottom: 16 })
        
        // 考试信息
        Column() {
          Row() {
            Text('考试名称:')
              .fontSize(14)
              .fontColor('#666666')
              .width(80)
            Text(this.examReport.examName)
              .fontSize(14)
              .fontColor('#333333')
              .layoutWeight(1)
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .width('100%')
          .margin({ bottom: 8 })
          
          Row() {
            Text('考试时间:')
              .fontSize(14)
              .fontColor('#666666')
              .width(80)
            Text(this.examReport.examDate)
              .fontSize(14)
              .fontColor('#333333')
              .layoutWeight(1)
          }
          .width('100%')
          .margin({ bottom: 8 })
          
          Row() {
            Text('考试类型:')
              .fontSize(14)
              .fontColor('#666666')
              .width(80)
            Text(this.getExamTypeText(this.examReport.examType))
              .fontSize(14)
              .fontColor('#333333')
              .layoutWeight(1)
          }
          .width('100%')
        }
      }
      .width('100%')
      .padding(20)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .shadow({
        radius: 8,
        color: '#1A000000',
        offsetX: 0,
        offsetY: 2
      })
      .margin({ left: 16, right: 16, top: 16, bottom: 8 })
    }
  }

  @Builder
  SubjectCard(subject: SubjectScoreVO) {
    Column() {
      Row() {
        Text(subject.subjectName)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .layoutWeight(1)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        
        Text(subject.score)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getScoreColor(parseFloat(subject.score)))
      }
      .width('100%')
      .margin({ bottom: 12 })
      
      Row() {
        Text('等级:')
          .fontSize(14)
          .fontColor('#666666')
          .margin({ right: 8 })
        
        Text(this.getGradeLevel(parseFloat(subject.score)))
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getGradeBadgeStyle(parseFloat(subject.score)).textColor)
          .backgroundColor(this.getGradeBadgeStyle(parseFloat(subject.score)).bgColor)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .borderRadius(16)
          .border({
            width: 1,
            color: this.getGradeBadgeStyle(parseFloat(subject.score)).textColor + '40'
          })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({
      radius: 6,
      color: '#1A000000',
      offsetX: 0,
      offsetY: 1
    })
    .margin({ left: 16, right: 16, top: 8, bottom: 8 })
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Image($r('app.media.back'))
          .width(24)
          .height(24)
          .onClick(() => router.back())
        
        Text(this.examName)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        
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
      } else if (this.examReport) {
        Scroll() {
          Column() {
            // 成绩概览
            this.ScoreOverview()
            
            // 科目成绩标题
            Row() {
              Text('科目成绩')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 16, bottom: 8 })
            
            // 科目成绩列表
            if (this.examReport.subject_output && this.examReport.subject_output.length > 0) {
              ForEach(this.examReport.subject_output, (subject: SubjectScoreVO, index: number) => {
                this.SubjectCard(subject)
              }, (subject: SubjectScoreVO, index: number) => subject.id.toString())
            } else {
              Column() {
                Text('暂无科目成绩数据')
                  .fontSize(14)
                  .fontColor('#999999')
              }
              .width('100%')
              .padding(32)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
            }
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
          Text('获取成绩报告失败')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ bottom: 8 })
          Text('请稍后重试')
            .fontSize(14)
            .fontColor('#CCCCCC')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}