// 主页面 - 底部导航容器
import CommonConstants from '../common/Constants';
import HomePage from './HomePage';
import PersonalPage from './PersonalPage';
import NoticePage from './NoticePage';
import ProfilePage from './ProfilePage';
import TokenManager from '../utils/TokenManager';

@Entry
@Component
struct Index {
  // @State currentIndex: number = 0;
  @State isLoading: boolean = true;
  @State isLoggedIn: boolean = false;
  @State currentIndex: number = 0;

  private tabsController: TabsController = new TabsController();

  // 页面初始化时检查登录状态
  async aboutToAppear() {
    try {
      // 检查登录状态
      this.isLoggedIn = await TokenManager.checkLoginStatus();
      if (this.isLoggedIn) {
        // 已登录，初始化AppStorage
        await TokenManager.initAppStorage();
      }
    } catch (error) {
      console.error('初始化失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  @Builder
  TabBuilder(title: string, targetIndex: number, selectedImg: Resource, normalImg: Resource) {
    Column() {
      Image(this.currentIndex === targetIndex ? selectedImg : normalImg)
        .size({ width: 25, height: 25 })
      Text(title)
        .fontColor(this.currentIndex === targetIndex ? '#1698CE' : '#6B6B6B')
        .fontSize(10)
        .fontWeight(500)
        .lineHeight(14)
        .margin({ top: 2 })
    }
    .width('100%')
    .height(50)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.currentIndex = targetIndex;
      this.tabsController.changeIndex(this.currentIndex);
    })
  }

  build() {
    if (this.isLoading) {
      // 加载中界面
      Column() {
        // Logo区域
        Image($r('app.media.app_ic_logo'))
          .width(80)
          .height(80)
          .margin({ bottom: 32 })
        
        // 标题
        Text('班级信息中心云平台')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor('#182431')
          .margin({ bottom: 40 })
        
        // 加载指示器
        LoadingProgress()
          .width(32)
          .height(32)
          .color('#007DFF')
          .margin({ bottom: 16 })
        
        // 加载文字
        Text('正在加载...')
          .fontSize(14)
          .fontColor('#99182431')
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .backgroundColor('#F1F3F5')
    } else if (this.isLoggedIn) {
      // 已登录，显示主界面
      Tabs({ barPosition: BarPosition.End, controller: this.tabsController }) {
        TabContent() {
          HomePage()
        }
        .tabBar(this.TabBuilder('首页', 0, $r('app.media.home_selected'), $r('app.media.home_normal')))

        TabContent() {
          PersonalPage()
        }
        .tabBar(this.TabBuilder('个人荣誉', 1, $r('app.media.personal_selected'), $r('app.media.personal_normal')))

        TabContent() {
          NoticePage()
        }
        .tabBar(this.TabBuilder('公告', 2, $r('app.media.notice_selected'), $r('app.media.notice_normal')))

        TabContent() {
          ProfilePage()
        }
        .tabBar(this.TabBuilder('我的', 3, $r('app.media.profile_selected'), $r('app.media.profile_normal')))
      }
      .width('100%')
      .height('100%')
      .barHeight(56)
      .onChange((index: number) => {
        this.currentIndex = index;
      })
    }
  }
}