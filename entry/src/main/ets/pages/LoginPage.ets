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

@Extend(TextInput)
function inputStyle() {
  .placeholderColor($r('app.color.placeholder_color'))
  .height($r('app.float.login_input_height'))
  .fontSize($r('app.float.big_text_size'))
  .backgroundColor(Color.White)
  .width(CommonConstants.FULL_PARENT)
  .padding({ left: CommonConstants.INPUT_PADDING_LEFT })
  .margin({ top: $r('app.float.input_margin_top') })
}


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
    Column() {
      // Logo区域
      Image($r('app.media.app_ic_logo'))
        .width(80)
        .height(80)
        .margin({
          top: 60,
          bottom: 40
        })
      
      // 标题
      Text('班级信息中心云平台')
        .fontSize(24)
        .fontWeight(FontWeight.Medium)
        .fontColor('#182431')
        .margin({ bottom: 8 })
      
      // 副标题
      Text('智慧教育，连接未来')
        .fontSize(16)
        .fontColor('#99182431')
        .margin({ bottom: 40 })

      // 输入框区域
      Column() {
        TextInput({ placeholder: '请输入账号', text: this.username })
          .placeholderColor('#99182431')
          .height(48)
          .fontSize(16)
          .backgroundColor(Color.White)
          .width('100%')
          .inputStyle()
          .onChange((value: string) => {
            this.username = value;
          })

        Line()
          .width('100%')
          .height(1)
          .backgroundColor('#F1F3F5')

        TextInput({ placeholder: '请输入密码', text: this.password })
          .placeholderColor('#99182431')
          .height(48)
          .fontSize(16)
          .backgroundColor(Color.White)
          .width('100%')
          .inputStyle()
          .type(InputType.Password)
          .onChange((value: string) => {
            this.password = value;
          })
      }
      .padding({ top: 0,
        bottom: 0,
        left: $r('app.float.input_padding_left'),
        right: $r('app.float.input_padding_left') })
      .backgroundColor(Color.White)
      .borderRadius(12)
      .margin({ bottom: 20 })

      // 记住密码和忘记密码
      Row() {
        Row() {
          Checkbox()
            .select(this.rememberpwd)
            .selectedColor('#007DFF')
            .unselectedColor('#CCCCCC')
            .onChange(value => this.rememberpwd = value)
          
          Text('记住密码')
            .fontColor('#007DFF')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .margin({ left: 8 })
        }
        
        Text('忘记密码')
          .fontColor('#007DFF')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            promptAction.showToast({ message: '请联系班级管理员重置密码', duration: 2000 });
          })
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .padding({
        left: 16,
        right: 16
      })
      .margin({ bottom: 40 })

      // 登录按钮
      Button(this.logining ? '登录中...' : '登录', { type: ButtonType.Capsule })
        .width('100%')
        .height(48)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .backgroundColor(this.logining ? '#CCCCCC' : '#007DFF')
        .enabled(!this.logining)
        .onClick(() => this.submitForm())

      Blank()

      // 底部版权信息
      Text('© 2022-2025 班级信息中心云平台')
        .fontSize(12)
        .fontColor('#99182431')
        .margin({ bottom: 40 })
    }
    .backgroundColor('#F1F3F5')
    .height('100%')
    .width('100%')
    .padding({
      left: 24,
      right: 24
    })
  }
}