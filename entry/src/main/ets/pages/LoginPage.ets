// LoginPage.ets
import CommonConstants from '../common/Constants';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import preferences from '@ohos.data.preferences';
import md5 from 'js-md5';
import HttpService, { HttpServiceClass } from '../services/HttpService';
import { LoginResponse, LoginDTO } from '../models/dataModels';
import { Result } from '../models/dataModels';
import httpServiceInstance from '../services/HttpService';
import TokenManager from '../utils/TokenManager';
import { GlobalContext } from '../utils/GlobalContext';


@Entry
@Component
struct LoginPage {
  @State username: string = '';
  @State password: string = '';
  @State rememberpwd: boolean = false;
  @State logining: boolean = false;
  private httpService: HttpServiceClass = httpServiceInstance;

  // 初始化记住密码
  aboutToAppear() {
    this.getStoredCredentials();
  }

  // 获取存储的凭证
  private async getStoredCredentials() {
    try {
      const context = GlobalContext.getInstance().getContext();
      if (!context) {
        console.error('上下文未初始化');
        return;
      }

      let pref = await preferences.getPreferences(context, 'userPrefs');

      let storedUser = await pref.get('username', '');
      let storedPwd = await pref.get('password', '');
      if (storedUser && storedPwd) {
        this.username = storedUser.toString();
        this.password = storedPwd.toString();
        this.rememberpwd = true;
      }
    } catch (err) {
      console.error('获取凭证失败: ' + err);
    }
  }

  // 提交登录表单
  private async submitForm() {
    if (!this.validateForm()) return;
    this.logining = true;
    let encryptedPwd: string = md5(md5(this.password) + '_ljcsys');

    try {
      const loginData: LoginDTO = {
        username: this.username,
        password: encryptedPwd
      };

      const result : Result<LoginResponse> = await this.httpService.post<LoginResponse>(CommonConstants.API_LOGIN, loginData);

      if (result.code === 200) {
        await this.handleLoginSuccess(result.data);
      } else {
        promptAction.showToast({ message: result.msg || '登录失败，请检查账号密码', duration: 2000 });
      }
    } catch (err) {
      this.handleLoginError(err);
    } finally {
      this.logining = false;
    }
  }

  // 处理登录成功
  private async handleLoginSuccess(data: LoginResponse) {
    await this.storeCredentials();

    // 使用TokenManager存储token和用户信息
    await TokenManager.saveToken(data.token, data.username);
    this.httpService.setToken(data.token);

    promptAction.showToast({ message: '登录成功！欢迎您！', duration: 2000 });

    // 跳转到首页
    router.pushUrl({
      url: CommonConstants.INDEX_PAGE
    });
  }

  // 处理登录错误
  private handleLoginError(error: Error) {
    console.error('登录错误:', error);
    promptAction.showToast({ message: '登录失败，请稍后再试', duration: 2000 });
  }

  // 存储凭证
  private async storeCredentials() {
    try {
      const context = GlobalContext.getInstance().getContext();
      if (!context) {
        console.error('上下文未初始化');
        return;
      }

      let pref = await preferences.getPreferences(context, 'userPrefs');

      if (this.rememberpwd) {
        await pref.put('username', this.username);
        await pref.put('password', this.password);
      } else {
        await pref.delete('username');
        await pref.delete('password');
      }
      await pref.flush();
    } catch (err) {
      console.error('存储凭证失败:', err);
    }
  }

  // 表单验证
  private validateForm(): boolean {
    if (!this.username.trim()) {
      promptAction.showToast({ message: '请输入账号', duration: 2000 });
      return false;
    }
    if (!this.password.trim()) {
      promptAction.showToast({ message: '请输入密码', duration: 2000 });
      return false;
    }
    return true;
  }

  build() {
    Stack() {
      // 背景渐变
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 135,
          colors: [['#667eea', 0.0], ['#764ba2', 1.0]]
        })

      // 主要内容
      Column() {
        // Logo区域
        Column() {
          // 装饰性图标
          Text('🎓')
            .fontSize(60)
            .margin({ bottom: 16 })
          
          // 标题
          Text('班级信息中心云平台')
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .textShadow({ radius: 2, color: 'rgba(0,0,0,0.3)', offsetX: 1, offsetY: 1 })
            .margin({ bottom: 8 })
          
          // 副标题
          Text('智慧教育，连接未来')
            .fontSize(16)
            .fontColor('rgba(255,255,255,0.8)')
            .margin({ bottom: 50 })
        }
        .alignItems(HorizontalAlign.Center)

        // 登录卡片
        Column() {
          // 用户名输入框
          Row() {
            Text('👤')
              .fontSize(20)
              .fontColor('#666')
              .margin({ right: 12 })
            
            TextInput({ placeholder: '请输入账号', text: this.username })
              .layoutWeight(1)
              .height(50)
              .backgroundColor('transparent')
              .border({ width: 0 })
              .fontSize(16)
              .placeholderColor('#999')
              .onChange(value => this.username = value)
          }
          .width('100%')
          .height(50)
          .backgroundColor('#F8F9FA')
          .borderRadius(25)
          .padding({ left: 20, right: 20 })
          .margin({ bottom: 16 })
          .shadow({
            radius: 8,
            color: 'rgba(0,0,0,0.1)',
            offsetX: 0,
            offsetY: 2
          })

          // 密码输入框
          Row() {
            Text('🔒')
              .fontSize(20)
              .fontColor('#666')
              .margin({ right: 12 })
            
            TextInput({ placeholder: '请输入密码', text: this.password })
              .layoutWeight(1)
              .height(50)
              .backgroundColor('transparent')
              .border({ width: 0 })
              .fontSize(16)
              .type(InputType.Password)
              .placeholderColor('#999')
              .onChange(value => this.password = value)
          }
          .width('100%')
          .height(50)
          .backgroundColor('#F8F9FA')
          .borderRadius(25)
          .padding({ left: 20, right: 20 })
          .margin({ bottom: 20 })
          .shadow({
            radius: 8,
            color: 'rgba(0,0,0,0.1)',
            offsetX: 0,
            offsetY: 2
          })

          // 记住密码
          Row() {
            Checkbox()
              .select(this.rememberpwd)
              .selectedColor('#667eea')
              .unselectedColor('#DDD')
              .onChange(value => this.rememberpwd = value)
            
            Text('记住密码')
              .fontSize(14)
              .fontColor('#666')
              .margin({ left: 8 })
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .margin({ bottom: 30 })

          // 登录按钮
          Button(this.logining ? '登录中...' : '登录')
            .width('100%')
            .height(50)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .backgroundColor(this.logining ? '#CCC' : '#667eea')
            .borderRadius(25)
            .shadow({
              radius: 12,
              color: this.logining ? 'rgba(0,0,0,0.1)' : 'rgba(102,126,234,0.4)',
              offsetX: 0,
              offsetY: 4
            })
            .onClick(() => this.submitForm())
            .enabled(!this.logining)
            .animation({
              duration: 200,
              curve: Curve.EaseInOut
            })
        }
        .width('85%')
        .padding({ top: 40, bottom: 40, left: 30, right: 30 })
        .backgroundColor('#FFFFFF')
        .borderRadius(20)
        .shadow({
          radius: 20,
          color: 'rgba(0,0,0,0.15)',
          offsetX: 0,
          offsetY: 8
        })
        .margin({ top: 20 })

        // 底部装饰
        Text('© 2024 班级信息中心云平台')
          .fontSize(12)
          .fontColor('rgba(255,255,255,0.6)')
          .margin({ top: 40 })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .padding({ left: 20, right: 20 })
    }
    .width('100%')
    .height('100%')
  }
}