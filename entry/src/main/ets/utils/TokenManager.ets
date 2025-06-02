// TokenManager.ets - Token持久化管理工具类
import preferences from '@ohos.data.preferences';
import router from '@ohos.router';
import CommonConstants from '../common/Constants';
import { UserInfo, Result, tokenValidateDTO } from '../models/dataModels';
import { GlobalContext } from '../utils/GlobalContext';
import HttpService from '../services/HttpService';

export class TokenManager {
  private static readonly PREF_NAME = 'userPrefs';
  private static readonly TOKEN_KEY = 'token';
  private static readonly USERNAME_KEY = 'username';
  private static readonly IS_LOGIN_KEY = 'isLogin';

  /**
   * 保存token到持久化存储
   * @param token 用户token
   * @param username 用户名
   */
  static async saveToken(token: string, username: string): Promise<void> {
    try {
      const context = GlobalContext.getInstance().getContext();
      if (!context) {
        throw new Error("上下文未初始化");
      }

      // 使用同步方法获取实例
      const pref = preferences.getPreferencesSync(context, {
        name: TokenManager.PREF_NAME
      });

      // 同步写入
      pref.putSync(TokenManager.TOKEN_KEY, token);
      pref.putSync(TokenManager.USERNAME_KEY, username);
      pref.putSync(TokenManager.IS_LOGIN_KEY, true);

      // 异步刷盘
      await pref.flush();

      AppStorage.setOrCreate('token', token);
      AppStorage.setOrCreate('username', username);
      AppStorage.setOrCreate('isLogin', true);
    } catch (error) {
      throw new Error(`保存Token失败: ${error.message}`);
    }
  }

  /**
   * 从持久化存储获取token
   * @returns token字符串，如果不存在返回空字符串
   */
  static async getToken(): Promise<string> {
    try {
      const context = GlobalContext.getInstance().getContext();
      if (!context) {
        throw new Error("上下文未初始化");
      }

      const pref = preferences.getPreferencesSync(context, {
        name: TokenManager.PREF_NAME
      });

      return pref.getSync(TokenManager.TOKEN_KEY, '').toString();
    } catch (error) {
      return '';
    }
  }

  /**
   * 获取用户信息
   * @returns 用户信息对象
   */
  static async getUserInfo(): Promise<UserInfo> {
    try {
      const context = GlobalContext.getInstance().getContext();
      if (!context) {
        throw new Error("上下文未初始化");
      }

      // 使用同步API获取preferences实例
      const pref = preferences.getPreferencesSync(context, {
        name: TokenManager.PREF_NAME
      });

      // 同步获取数据
      const token = pref.getSync(TokenManager.TOKEN_KEY, '');
      const username = pref.getSync(TokenManager.USERNAME_KEY, '');
      const isLogin = pref.getSync(TokenManager.IS_LOGIN_KEY, false);

      return {
        token: token.toString(),
        username: username.toString(),
        isLogin: Boolean(isLogin)
      };
    } catch (error) {
      console.error('获取用户信息失败:', error);
      return { token: '', username: '', isLogin: false };
    }
  }

  /**
   * 初始化AppStorage，从持久化存储恢复数据
   */
  static async initAppStorage(): Promise<void> {
    try {
      // 修复：调用getUserInfo而不是自身
      const userInfo = await TokenManager.getUserInfo();

      AppStorage.setOrCreate('token', userInfo.token);
      AppStorage.setOrCreate('username', userInfo.username);
      AppStorage.setOrCreate('isLogin', userInfo.isLogin);
      console.log('AppStorage初始化完成');
    } catch (error) {
      console.error('初始化AppStorage失败:', error);
    }
  }

  /**
   * 清除token和用户信息
   */
  static async clearToken(): Promise<void> {
    try {
      const context = GlobalContext.getInstance().getContext();
      if (!context) {
        throw new Error("上下文未初始化");
      }

      // 使用同步方法获取实例
      const pref = preferences.getPreferencesSync(context, {
        name: TokenManager.PREF_NAME
      });

      // 同步删除
      pref.deleteSync(TokenManager.TOKEN_KEY);
      pref.deleteSync(TokenManager.USERNAME_KEY);
      pref.deleteSync(TokenManager.IS_LOGIN_KEY);

      // 异步刷盘
      await pref.flush();

      // 清除AppStorage
      AppStorage.setOrCreate('token', '');
      AppStorage.setOrCreate('username', '');
      AppStorage.setOrCreate('isLogin', false);

      console.log('Token清除成功');
    } catch (error) {
      console.error('清除Token失败:', error);
      throw new Error(`清除Token失败: ${error.message}`);
    }
  }

  /**
   * 检查是否已登录
   * @returns 是否已登录
   */
  static async isLoggedIn(): Promise<boolean> {
    try {
      const token = await TokenManager.getToken();
      if (token === '') {
        return false;
      }

      // 发送网络请求验证token状态
      const httpService = HttpService;
      httpService.setToken(token);

      const postToken = { token: token } as tokenValidateDTO;

      const response = await httpService.post<tokenValidateDTO>(
        CommonConstants.API_VALIDATE_TOKEN,
        postToken
      );

      return response.code === 200;
    } catch (error) {
      console.error('检查登录状态失败:', error);
      return false;
    }
  }

  /**
   * 登录拦截器 - 检查登录状态，未登录则跳转到登录页
   * @returns 是否已登录
   */
  static async checkLoginStatus(): Promise<boolean> {
    try {
      // 初始化AppStorage
      await TokenManager.initAppStorage();

      const isLoggedIn = await TokenManager.isLoggedIn();
      if (!isLoggedIn) {
        console.log('用户未登录，跳转到登录页');
        router.replaceUrl({
          url: CommonConstants.LOGIN_PAGE
        });
        return false;
      }
      return true;
    } catch (error) {
      console.error('检查登录状态失败:', error);
      // 出错时跳转到登录页
      router.replaceUrl({
        url: CommonConstants.LOGIN_PAGE
      });
      return false;
    }
  }
}

export default TokenManager;