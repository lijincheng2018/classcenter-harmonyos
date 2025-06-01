// 首页
import router from '@ohos.router';
import HttpService from '../services/HttpService';
import CommonConstants from '../common/Constants';
import { NoticeVO, PageParams, NoticePageResult } from '../models/dataModels';
import TokenManager from '../utils/TokenManager';

@Preview
@Component
export default struct HomePage {
  @State username: string = '';
  @State notices: NoticeVO[] = [];
  @State loading: boolean = false;

  async aboutToAppear() {
    this.username = AppStorage.get<string>('username') || '用户';
    await this.loadNotices();
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
  FunctionCard(title: string, icon: Resource, color: string, onClick: () => void) {
    Column() {
      Image(icon)
        .width(40)
        .height(40)
        .fillColor(color)
      Text(title)
        .fontSize(14)
        .fontColor('#333333')
        .margin({ top: 8 })
    }
    .width('100%')
    .height(80)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 4, color: '#1F000000', offsetX: 0, offsetY: 2 })
    .onClick(onClick)
  }

  // 敬请期待卡片构建器
  @Builder
  ComingSoonCard() {
    Column() {
      Row() {
        Circle({ width: 6, height: 6 })
          .fill('#FFB84D')
          .margin({ right: 4 })
        Circle({ width: 8, height: 8 })
          .fill('#FFB84D')
          .opacity(0.7)
          .margin({ right: 4 })
        Circle({ width: 6, height: 6 })
          .fill('#FFB84D')
          .opacity(0.5)
      }
      .margin({ bottom: 8 })
      
      Text('更多功能')
        .fontSize(14)
        .fontColor('#333333')
        .fontWeight(500)
        .margin({ bottom: 2 })
      
      Text('接入中...')
        .fontSize(12)
        .fontColor('#FFB84D')
        .fontWeight(400)
    }
    .width('100%')
    .height(80)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .border({ width: 1, color: '#FFE4B5', style: BorderStyle.Dashed })
    .shadow({ radius: 2, color: '#1A000000', offsetX: 0, offsetY: 1 })
  }

  // 公告卡片构建器
  @Builder
  NoticeCard(notice: NoticeVO) {
    Column({ space: 8 }) {
      Row() {
        Text(notice.title)
          .fontSize(16)
          .fontColor('#333333')
          .fontWeight(500)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
        
        Text(notice.time.split(' ')[0])
          .fontSize(12)
          .fontColor('#999999')
      }
      .width('100%')
      
      Text(notice.content)
        .fontSize(14)
        .fontColor('#666666')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 4, color: '#1F000000', offsetX: 0, offsetY: 2 })
    .onClick(() => {
      // 跳转到公告详情

      router.pushUrl({
        url: 'pages/NoticeDetailPage',
        params: { notice: notice}
      });
    })
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
      .backgroundColor('#F8F9FA')

      Scroll() {
        Column({ space: 20 }) {
          // 功能区域
          Column({ space: 12 }) {
            Row() {
              Text('快捷功能')
                .fontSize(18)
                .fontColor('#333333')
                .fontWeight(600)
            }
            .width('100%')
            .padding({ left: 20, right: 20 })
            
            Grid() {
              GridItem() {
                this.FunctionCard('个人履历', $r('app.media.resume'), '#4ECDC4', () => {
                  router.pushUrl({ url: CommonConstants.DOC_PAGE });
                })
              }
              
              GridItem() {
                this.FunctionCard('成绩查询', $r('app.media.ic_exam'), '#FF6B6B', () => {
                  router.pushUrl({ url: CommonConstants.EXAM_PAGE });
                })
              }
              
              GridItem() {
                this.FunctionCard('随机抽号', $r('app.media.ic_random'), '#FFB74D', () => {
                  router.pushUrl({ url: CommonConstants.RANDOM_PAGE });
                })
              }
              
              GridItem() {
                this.ComingSoonCard()
              }
            }
            .columnsTemplate('1fr 1fr')
            .rowsTemplate('1fr 1fr')
            .columnsGap(12)
            .height(180)
            .padding({ left: 20, right: 20 })
          }

          // 最新公告区域
          Column({ space: 12 }) {
            Row() {
              Text('最新公告')
                .fontSize(18)
                .fontColor('#333333')
                .fontWeight(600)
              
              Blank()
              
              Text('查看更多')
                .fontSize(14)
                .fontColor('#1698CE')
                .onClick(() => {
                  router.pushUrl({ url: 'pages/NoticePage' });
                })
            }
            .width('100%')
            .padding({ left: 20, right: 20 })
            
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
              .padding({ left: 20, right: 20 })
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
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }
}