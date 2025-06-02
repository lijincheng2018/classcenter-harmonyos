// 个人中心页面
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import preferences from '@ohos.data.preferences';
import HttpService from '../services/HttpService';
import CommonConstants from '../common/Constants';
import { RouterParams, ToastOptions } from '../models/dataModels';
import TokenManager from '../utils/TokenManager';
import { GlobalContext } from '../utils/GlobalContext';

@Component
export default struct ProfilePage {
  @State username: string = '';
  @State isLogin: boolean = false;

  aboutToAppear() {
    this.username = AppStorage.get<string>('username') || '未登录';
    this.isLogin = AppStorage.get<boolean>('isLogin') || false;
  }

  // 退出登录
  private async logout() {
    try {
      const token = AppStorage.get<string>('token') || '';
      
      // 设置token到HttpService
      const httpService = HttpService;
      httpService.setToken(token);
      
      // 发送退出登录请求
      httpService.post<Record<string, Object>>(
        CommonConstants.API_LOGOUT
      ).then(response => {
        console.log("logout response=>", JSON.stringify(response));
      }).catch((err : Error) => {
        console.log('logout err=>', err);
      }).finally(() => {
        // 无论请求成功与否，都清除本地存储
        this.clearLocalStorage();
      });
      
    } catch (error) {
      console.error('退出登录失败:', error);
      // 即使请求失败，也清除本地存储
      this.clearLocalStorage();
    }
  }
  
  // 清除本地存储
  private async clearLocalStorage() {
    try {
      // 使用TokenManager清除token
      await TokenManager.clearToken();
      
      // 清除记住密码
      const context = GlobalContext.getInstance().getContext();
      if (!context) {
        console.error('上下文未初始化');
        return;
      }

      let pref = await preferences.getPreferences(context, 'userPrefs');
      await pref.delete('username');
      await pref.delete('password');
      
      const toastOptions: ToastOptions = { message: '已退出登录', duration: 2000 };
      promptAction.showToast(toastOptions);
      
      // 跳转到登录页
      router.replaceUrl({
        url: 'pages/LoginPage'
      });
    } catch (error) {
      console.error('清除本地存储失败:', error);
      const toastOptions: ToastOptions = { message: '退出失败，请稍后重试', duration: 2000 };
      promptAction.showToast(toastOptions);
    }
  }

  // 菜单项构建器
  @Builder
  MenuItem(icon: Resource, title: string, showArrow: boolean = true, onClick?: () => void) {
    Row() {
      Image(icon)
        .width(24)
        .height(24)
        .fillColor('#666666')
      
      Text(title)
        .fontSize(16)
        .fontColor('#333333')
        .margin({ left: 12 })
        .layoutWeight(1)
      
      if (showArrow) {
        Image($r('app.media.arrow_right'))
          .width(16)
          .height(16)
          .fillColor('#CCCCCC')
      }
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
    .onClick(() => {
      if (onClick) {
        onClick();
      }
    })
  }

  build() {
    Column() {
      // 顶部用户信息区域
      Column({ space: 16 }) {
        Row() {
          Image($r('app.media.avatar_default'))
            .width(60)
            .height(60)
            .borderRadius(30)
          
          Column({ space: 4 }) {
            Text(this.username)
              .fontSize(18)
              .fontColor('#FFFFFF')
              .fontWeight(600)
            
            Text(this.isLogin ? '已登录' : '未登录')
              .fontSize(14)
              .fontColor('#E0E0E0')
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 16 })
          .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: 20, right: 20 })
      }
      .width('100%')
      .height(140)
      .padding({ top: 40, bottom: 20 })
      .backgroundColor('#1698CE')
      .justifyContent(FlexAlign.Center)

      Scroll() {
        Column({ space: 12 }) {
          // 个人信息管理
          Column() {
            Text('个人功能')
              .fontSize(14)
              .fontColor('#999999')
              .width('100%')
              .padding({ left: 16, top: 12, bottom: 8 })
            
            Column() {
              this.MenuItem($r('app.media.ic_exam'), '成绩查询', true, () => {
                router.pushUrl({ url: 'pages/ExamPage' });
              })
              
              Divider().height(1).color('#F0F0F0').margin({ left: 52 })
              
              this.MenuItem($r('app.media.resume'), '个人履历', true, () => {
                router.pushUrl({ url: 'pages/DocPage' });
              })
            }
            .borderRadius(12)
            .clip(true)
          }
          
          // 应用设置
          Column() {
            Text('应用设置')
              .fontSize(14)
              .fontColor('#999999')
              .width('100%')
              .padding({ left: 16, top: 12, bottom: 8 })
            
            Column() {
              this.MenuItem($r('app.media.setting'), '设置', true, () => {
                const toastOptions: ToastOptions = { message: '功能开发中', duration: 2000 };
                promptAction.showToast(toastOptions);
              })
              
              Divider().height(1).color('#F0F0F0').margin({ left: 52 })
              
              this.MenuItem($r('app.media.about'), '关于我们', true, () => {
                const toastOptions: ToastOptions = { message: '班级信息中心云平台鸿蒙版 v1.0.0\n开发者：李锦成', duration: 2000 };
                promptAction.showToast(toastOptions);
              })
              
              Divider().height(1).color('#F0F0F0').margin({ left: 52 })
              
              this.MenuItem($r('app.media.help'), '帮助与反馈', true, () => {
                AlertDialog.show({
                  title: '帮助与反馈',
                  message: '您可以发送邮件至：\nsupport@classcloud.com.cn\n来获取帮助',
                  confirm: {
                    value: '关闭',
                    action: () => {}
                  }
                });
              })

              this.MenuItem($r('app.media.web'), '产品网站', true, () => {
                router.pushUrl({ url: 'pages/ProductWeb' });
              })
            }
            .borderRadius(12)
            .clip(true)
          }
          
          // 退出登录按钮
          if (this.isLogin) {
            Button('退出登录')
              .width('100%')
              .height(48)
              .backgroundColor('#FF4444')
              .fontColor('#FFFFFF')
              .fontSize(16)
              .borderRadius(12)
              .margin({ top: 20 })
              .onClick(() => {
                AlertDialog.show({
                  title: '确认退出',
                  message: '确定要退出登录吗？',
                  primaryButton: {
                    value: '取消',
                    action: () => {}
                  },
                  secondaryButton: {
                    value: '退出',
                    fontColor: '#FF4444',
                    action: () => this.logout()
                  }
                });
              })
          } else {
            Button('立即登录')
              .width('100%')
              .height(48)
              .backgroundColor('#1698CE')
              .fontColor('#FFFFFF')
              .fontSize(16)
              .borderRadius(12)
              .margin({ top: 20 })
              .onClick(() => {
                const routerParams: RouterParams = { url: 'pages/LoginPage' };
                router.replaceUrl(routerParams);
              })
          }
        }
        .padding(20)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }
}