// 公告页面
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import HttpService from '../services/HttpService';
import CommonConstants from '../common/Constants';
import { NoticeVO, PageParams, RouterParams, ToastOptions, PageResult, Result } from '../models/dataModels';
import TokenManager from '../utils/TokenManager';

@Component
export default struct NoticePage {
  @State noticeList: NoticeVO[] = [];
  @State loading: boolean = false;
  @State refreshing: boolean = false;
  @State hasMore: boolean = true;
  @State currentPage: number = 0;
  @State pageSize: number = 10;

  aboutToAppear() {
    this.loadNoticeList(true);
  }

  // 加载公告列表
  private async loadNoticeList(isRefresh: boolean = false) {
    if (isRefresh) {
      this.currentPage = 0;
      this.hasMore = true;
      this.refreshing = true;
    } else {
      this.loading = true;
    }
    
    try {
      const params: PageParams = {
        page: this.currentPage,
        size: this.pageSize
      };
      
      const token = await TokenManager.getToken();
      
      // 设置token到HttpService
      const httpService = HttpService;
      if (token) {
        httpService.setToken(token);
      }
      
      // 使用HttpService发送获取公告列表请求
      httpService.get<PageResult<NoticeVO>>(
        CommonConstants.API_NOTICES,
        params
      ).then(response => {
        console.log("notice list response=>", JSON.stringify(response));
        if (response.code === 200 && response.data) {
          const pageResult: PageResult<NoticeVO> = response.data;
          
          if (isRefresh) {
            this.noticeList = pageResult.notices || [];
          } else {
            this.noticeList = this.noticeList.concat(pageResult.notices || []);
          }
          
          this.hasMore = !pageResult.last;
          this.currentPage++;
        } else {
          const toastOptions: ToastOptions = { message: response.msg || '加载失败', duration: 2000 };
          promptAction.showToast(toastOptions);
        }
      }).catch((err : Error) => {
        console.log('notice list err=>', err);
        console.error('加载公告失败:', err);
        const toastOptions: ToastOptions = { message: '网络错误，请稍后重试', duration: 2000 };
        promptAction.showToast(toastOptions);
      }).finally(() => {
        this.loading = false;
        this.refreshing = false;
      });
      
    } catch (error) {
      console.error('加载公告失败:', error);
      const toastOptions: ToastOptions = { message: '网络错误，请稍后重试', duration: 2000 };
      promptAction.showToast(toastOptions);
      this.loading = false;
      this.refreshing = false;
    }
  }

  // 加载更多
  private loadMore() {
    if (!this.loading && this.hasMore) {
      this.loadNoticeList(false);
    }
  }

  // 下拉刷新
  private onRefresh() {
    this.loadNoticeList(true);
  }

  // 公告卡片构建器
  @Builder
  NoticeCard(notice: NoticeVO) {
    Column({ space: 12 }) {
      Row() {
        Text(notice.title)
          .fontSize(16)
          .fontColor('#333333')
          .fontWeight(600)
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
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
        .lineHeight(20)
      
      Row() {
        Text('查看详情')
          .fontSize(12)
          .fontColor('#1698CE')
        Image($r('app.media.arrow_right'))
          .width(12)
          .height(12)
          .fillColor('#1698CE')
          .margin({ left: 4 })
      }
      .justifyContent(FlexAlign.End)
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 4, color: '#1F000000', offsetX: 0, offsetY: 2 })
    .onClick(() => {
      router.pushUrl({
        url: 'pages/NoticeDetailPage',
        params: { notice: notice}
      });
    })
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('公告通知')
          .fontSize(20)
          .fontColor('#333333')
          .fontWeight(600)
      }
      .width('100%')
      .height(56)
      .padding({ left: 20, right: 20 })
      .backgroundColor('#FFFFFF')
      .justifyContent(FlexAlign.Center)
      .shadow({ radius: 2, color: '#1F000000', offsetX: 0, offsetY: 1 })

      if (this.noticeList.length === 0 && !this.loading && !this.refreshing) {
        Column() {
          Image($r('app.media.empty'))
            .width(100)
            .height(100)
            .opacity(0.5)
          Text('暂无公告')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ top: 16 })
          Text('下拉刷新试试')
            .fontSize(14)
            .fontColor('#CCCCCC')
            .margin({ top: 8 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Refresh({ refreshing: $$this.refreshing, offset: 64, friction: 100 }) {
          List({ space: 12 }) {
            ForEach(this.noticeList, (notice: NoticeVO) => {
              ListItem() {
                this.NoticeCard(notice)
              }
            }, (notice: NoticeVO) => notice.id.toString())
            
            // 加载更多指示器
            if (this.hasMore) {
              ListItem() {
                Row() {
                  if (this.loading) {
                    LoadingProgress()
                      .width(20)
                      .height(20)
                      .color('#1698CE')
                    Text('加载中...')
                      .fontSize(14)
                      .fontColor('#666666')
                      .margin({ left: 8 })
                  } else {
                    Text('上拉加载更多')
                      .fontSize(14)
                      .fontColor('#999999')
                  }
                }
                .width('100%')
                .height(50)
                .justifyContent(FlexAlign.Center)
              }
              .onClick(() => this.loadMore())
            } else if (this.noticeList.length > 0) {
              ListItem() {
                Text('没有更多了')
                  .fontSize(14)
                  .fontColor('#CCCCCC')
                  .width('100%')
                  .height(50)
                  .textAlign(TextAlign.Center)
              }
            }
          }
          .width('100%')
          .layoutWeight(1)
          .padding({ left: 20, right: 20, top: 16, bottom: 16 })
          .scrollBar(BarState.Off)
          .onReachEnd(() => {
            this.loadMore();
          })
        }
        .onStateChange((refreshStatus: RefreshStatus) => {
          if (refreshStatus === RefreshStatus.Refresh) {
            this.onRefresh();
          }
        })
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }
}