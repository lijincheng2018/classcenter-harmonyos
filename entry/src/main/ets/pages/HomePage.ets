// 首页
import router from '@ohos.router';
import HttpService from '../services/HttpService';
import CommonConstants from '../common/Constants';
import { NoticeVO, PageParams, NoticePageResult, TaskCountVO } from '../models/dataModels';
import TokenManager from '../utils/TokenManager';

@Preview
@Component
export default struct HomePage {
  @State username: string = '';
  @State notices: NoticeVO[] = [];
  @State loading: boolean = false;
  @State taskCount: TaskCountVO | null = null;
  @State taskLoading: boolean = false;

  async aboutToAppear() {
    this.username = AppStorage.get<string>('name') || '用户';
    await Promise.all([
      this.loadNotices(),
      this.loadTaskCount()
    ]);
  }

  // 加载任务统计
  private async loadTaskCount() {
    this.taskLoading = true;
    try {
      const token = await TokenManager.getToken();
      const httpService = HttpService;
      httpService.setToken(token);

      httpService.get<TaskCountVO>(
        CommonConstants.API_TASK_COUNT
      ).then(response => {
        console.log("task count response=>", JSON.stringify(response));
        if (response.code === 200 && response.data) {
          this.taskCount = response.data;
        }
      }).catch((err: Error) => {
        console.error('加载任务统计失败:', err);
      }).finally(() => {
        this.taskLoading = false;
      });
    } catch (error) {
      console.error('加载任务统计失败:', error);
      this.taskLoading = false;
    }
  }

  // 加载公告列表
  private async loadNotices() {
    this.loading = true;
    try {
      const params: PageParams = { page: 0, size: 5 };
      const token = await TokenManager.getToken();
      
      // 设置token到HttpService
      const httpService = HttpService;
      httpService.setToken(token);

      // 使用HttpService发送获取公告列表请求
      httpService.get<NoticePageResult>(
        CommonConstants.API_NOTICES,
        params
      ).then(response => {
        console.log("notices response=>", JSON.stringify(response));
        console.log("notices-data =>", response.data);
        console.log("notices-code =>", response.code);

        if (response.code === 200 && response.data) {
          this.notices = response.data?.notices ?? []; // 空数组兜底

          //          console.log("notices =>", this.notices);
          console.log("notices-data =>",response.data.notices);

        }
      }).catch((err : Error) => {
        console.log('notices err=>', err);
        console.error('加载公告失败:', err);
      }).finally(() => {
        this.loading = false;
      });
      
    } catch (error) {
      console.error('加载公告失败:', error);
      this.loading = false;
    }
  }

  // 功能卡片构建器
  @Builder
  FunctionCard(title: string, icon: Resource, iconBgColor: string, iconColor: string, onClick: () => void, borderRadiusValue: number | BorderRadiuses = 12) {
    Row() {
      // 图标区域
      Stack() {
        Circle({ width: 48, height: 48 })
          .fill(iconBgColor)
        Image(icon)
          .width(24)
          .height(24)
          .fillColor(iconColor)
      }
      .margin({ right: 16 })

      // 文字区域
      Column() {
        Text(title)
          .fontSize(16)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)
          .lineHeight(22)

        Text('点击进入功能')
          .fontSize(12)
          .fontColor('#999999')
          .margin({ top: 2 })
          .lineHeight(18)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 箭头图标
      Image($r('app.media.ic_public_arrow_right'))
        .width(18)
        .height(18)
        .fillColor('#CCCCCC')
    }
    .width('100%')
    .height(72)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
    .borderRadius(borderRadiusValue)
    .shadow({ radius: 8, color: '#0D000000', offsetX: 0, offsetY: 2 })
    .onClick(() => {
      onClick();
    })
  }

  // 敬请期待卡片
  @Builder
  ComingSoonCard(borderRadiusValue: number | BorderRadiuses = 12) {
    Row() {
      // 图标区域
      Stack() {
        Circle({ width: 48, height: 48 })
          .fill('#F0F0F0') // 浅灰色背景
        Image($r('app.media.ic_public_coming_soon')) // 假设这是一个合适的“更多”图标
          .width(24)
          .height(24)
          .fillColor('#B0B0B0') // 中灰色图标
      }
      .margin({ right: 16 })

      // 文字区域
      Column() {
        Text('更多功能')
          .fontSize(16)
          .fontColor('#666666') // 深灰色文字
          .fontWeight(FontWeight.Medium)
          .lineHeight(22)

        Text('敬请期待后续更新')
          .fontSize(12)
          .fontColor('#AAAAAA') // 浅灰色辅助文字
          .margin({ top: 2 })
          .lineHeight(18)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 装饰性元素 (可选，例如一个小的加载指示器或省略号)
      Row(){
        Text('. . .')
          .fontSize(20)
          .fontColor('#D0D0D0')
      }

    }
    .width('100%')
    .height(72)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FAFAFA') // 非常浅的灰色背景，与普通卡片区分
    .borderRadius(borderRadiusValue)
    .border({width:1, color:'#EAEAEA', style: BorderStyle.Dashed})
    .opacity(0.8) // 整体略微透明，表示“未激活”或“未来”状态
  }

  // 公告卡片构建器
  @Builder
  NoticeCard(notice: NoticeVO) {
    Column({ space: 12 }) {
      Row() {
        // 公告标识
        Row() {
          Circle({ width: 6, height: 6 })
            .fill('#3B82F6')
            .margin({ right: 6 })
          Text('公告')
            .fontSize(11)
            .fontColor('#3B82F6')
            .fontWeight(500)
        }
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .backgroundColor('#EFF6FF')
        .borderRadius(12)
        
        Blank()
        
        Text(notice.time.split(' ')[0])
          .fontSize(12)
          .fontColor('#9CA3AF')
          .fontWeight(400)
      }
      .width('100%')
      
      Text(notice.title)
        .fontSize(16)
        .fontColor('#111827')
        .fontWeight(600)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
        .lineHeight(24)
      
      Text(notice.content)
        .fontSize(14)
        .fontColor('#6B7280')
        .fontWeight(400)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
        .lineHeight(20)
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .border({ width: 1, color: '#F3F4F6' })
    .shadow({ 
      radius: 12, 
      color: '#0A000000', 
      offsetX: 0, 
      offsetY: 4,
      fill: true
    })
    .onClick(() => {
      // 跳转到公告详情
      router.pushUrl({
        url: 'pages/NoticeDetailPage',
        params: { notice: notice}
      });
    })
  }

  // 任务统计卡片构建器
  @Builder
  TaskStatCard() {
    Column({ space: 16 }) {
      Row() {
        Text('任务完成情况')
          .fontSize(18)
          .fontColor('#333333')
          .fontWeight(600)
      }
      .width('100%')
      .padding({ left: 20, right: 20 })
      
      if (this.taskLoading) {
        Row() {
          LoadingProgress()
            .width(24)
            .height(24)
            .color('#1698CE')
          Text('加载中...')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ left: 8 })
        }
        .width('100%')
        .height(80)
        .justifyContent(FlexAlign.Center)
      } else if (this.taskCount) {
        Row() {
          // 总任务数卡片
          Column({ space: 8 }) {
            Text(this.taskCount.totalCount.toString())
              .fontSize(28)
              .fontColor('#3B82F6')
              .fontWeight(700)
            Text('总任务数')
              .fontSize(14)
              .fontColor('#6B7280')
              .fontWeight(500)
          }
          .layoutWeight(1)
          .padding(20)
          .backgroundColor('#F8FAFC')
          .borderRadius(12)
          .border({ width: 1, color: '#E2E8F0' })
          
          Blank().width(16)
          
          // 已完成任务数卡片
          Column({ space: 8 }) {
            Text(this.taskCount.finishCount.toString())
              .fontSize(28)
              .fontColor('#10B981')
              .fontWeight(700)
            Text('已完成')
              .fontSize(14)
              .fontColor('#6B7280')
              .fontWeight(500)
          }
          .layoutWeight(1)
          .padding(20)
          .backgroundColor('#F0FDF4')
          .borderRadius(12)
          .border({ width: 1, color: '#BBF7D0' })
          
          Blank().width(16)
          
          // 完成率卡片
          Column({ space: 8 }) {
            Row({ space: 2 }) {
              Text(`${this.taskCount.totalCount > 0 ? Math.round((this.taskCount.finishCount / this.taskCount.totalCount) * 100) : 0}`)
                .fontSize(28)
                .fontColor('#F59E0B')
                .fontWeight(700)
              Text('%')
                .fontSize(20)
                .fontColor('#F59E0B')
                .fontWeight(700)
            }
            .justifyContent(FlexAlign.Center)
            Text('完成率')
              .fontSize(14)
              .fontColor('#6B7280')
              .fontWeight(500)
          }
          .layoutWeight(1)
          .padding(20)
          .backgroundColor('#FFFBEB')
          .borderRadius(12)
          .border({ width: 1, color: '#FDE68A' })
        }
        .width('100%')
        .padding({ left: 20, right: 20 })
      } else {
        Column() {
          Text('暂无任务数据')
            .fontSize(14)
            .fontColor('#999999')
        }
        .width('100%')
        .height(80)
        .justifyContent(FlexAlign.Center)
      }
    }
  }

  build() {
    Column() {
      // 顶部欢迎区域
      Row() {
        Column({ space: 4 }) {
          Text(`欢迎回来，${this.username}！`)
            .fontSize(20)
            .fontColor('#333333')
            .fontWeight(600)
          Text('班级信息中心云平台')
            .fontSize(14)
            .fontColor('#666666')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        
        Image($r('app.media.avatar_default'))
          .width(50)
          .height(50)
          .borderRadius(25)
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 20, bottom: 16 })
      .backgroundColor('#FFFFFF')

      Scroll() {
        Column({ space: 32 }) {
          // 横向功能区域
          Column({ space: 12 }) {
            Row() {
              Text('快捷功能')
                .fontSize(18)
                .fontColor('#333333')
                .fontWeight(600)
            }
            .width('100%')
            .padding({ left: 20, right: 20 })
            
            // 功能卡片区域
            Column() {
              this.FunctionCard('个人履历', $r('app.media.resume'), '#E6F2FF', '#007DFF', () => {
                router.pushUrl({ url: 'pages/DocPage' });
              }, { topLeft: 12, topRight: 12, bottomLeft: 0, bottomRight: 0 })
              this.FunctionCard('成绩查询', $r('app.media.ic_exam'), '#FFF0F0', '#FF5A5A', () => {
                router.pushUrl({ url: 'pages/ExamPage' });
              }, 0)
              this.FunctionCard('随机抽号', $r('app.media.ic_random'), '#E9F7EA', '#4CAF50', () => {
                router.pushUrl({ url: 'pages/RandomPage' });
              }, 0)
              this.ComingSoonCard({ topLeft: 0, topRight: 0, bottomLeft: 12, bottomRight: 12 })
            }
            .padding({ left: 20, right: 20 })
          }

          // 任务完成情况区域
          this.TaskStatCard()

          // 最新公告区域
          Column({ space: 16 }) {
            Row() {
              Text('最新公告')
                .fontSize(20)
                .fontColor('#111827')
                .fontWeight(700)
                .lineHeight(28)
              
              Blank()
              
              Row() {
                Text('查看更多')
                  .fontSize(14)
                  .fontColor('#3B82F6')
                  .fontWeight(500)
                Image($r('sys.media.ohos_ic_public_arrow_right'))
                  .width(16)
                  .height(16)
                  .fillColor('#3B82F6')
                  .margin({ left: 4 })
              }
              .onClick(() => {
                router.pushUrl({ url: 'pages/NoticePage' });
              })
            }
            .width('100%')
            .padding({ left: 24, right: 24 })
            
            if (this.loading) {
              Row() {
                LoadingProgress()
                  .width(30)
                  .height(30)
                  .color('#1698CE')
                Text('加载中...')
                  .fontSize(14)
                  .fontColor('#666666')
                  .margin({ left: 8 })
              }
              .width('100%')
              .height(80)
              .justifyContent(FlexAlign.Center)
            } else if (this.notices.length > 0) {
              Column({ space: 12 }) {
                ForEach(this.notices, (notice: NoticeVO) => {
                  this.NoticeCard(notice)
                }, (notice: NoticeVO) => notice.id.toString())
              }
              .padding({ left: 24, right: 24 })
            } else {
              Column() {
                Image($r('app.media.empty'))
                  .width(80)
                  .height(80)
                  .opacity(0.5)
                Text('暂无公告')
                  .fontSize(14)
                  .fontColor('#999999')
                  .margin({ top: 8 })
              }
              .width('100%')
              .height(120)
              .justifyContent(FlexAlign.Center)
            }
          }

          Text('最新公告仅展示最新5条，全部公告请前往公告中心查看')
            .fontSize(12)
            .fontColor('#999999')
            .textAlign(TextAlign.Center)
            .width('100%')
            .padding({ left: 16, right: 16, bottom: 20 })
        }
        .margin({ top: 20, bottom: 20})
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FAFBFC')
  }
}