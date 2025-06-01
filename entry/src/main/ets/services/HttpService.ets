// HttpService.ets
import http from '@ohos.net.http';
import CommonConstants from '../common/Constants';
import { Result } from '../models/dataModels';

/**
 * HTTP服务类 - 单例模式
 * 提供统一的网络请求接口
 */
export class HttpService {
  private static instance: HttpService;
  private token: string = '';
  private baseUrl: string = CommonConstants.BASE_URL;

  private constructor() {}

  /**
   * 获取HttpService单例实例
   */
  public static getInstance(): HttpService {
    if (!HttpService.instance) {
      HttpService.instance = new HttpService();
    }
    return HttpService.instance;
  }

  /**
   * 设置认证token
   * @param token 认证令牌
   */
  public setToken(token: string): void {
    this.token = token;
  }

  /**
   * 获取当前token
   */
  public getToken(): string {
    return this.token;
  }

  /**
   * 清除token
   */
  public clearToken(): void {
    this.token = '';
  }

  /**
   * 构建请求头
   */
  private buildHeaders(): Record<string, string> {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    };
    
    if (this.token) {
      headers['X-Token'] = `${this.token}`;
    }
    
    return headers;
  }

  /**
   * 发送HTTP请求的通用方法
   */
  private async request<T>(
    method: http.RequestMethod,
    url: string,
    data?: Object | string | number | boolean
  ): Promise<Result<T>> {
    return new Promise((resolve, reject) => {
      const httpRequest = http.createHttp();
      const fullUrl = url.startsWith('http') ? url : `${this.baseUrl}${url}`;
      
      const options: http.HttpRequestOptions = {
        method: method,
        header: this.buildHeaders(),
        expectDataType: http.HttpDataType.STRING
      };

      // 如果有数据且不是GET请求，添加到请求体
      if (data && method !== http.RequestMethod.GET) {
        options.extraData = JSON.stringify(data);
      }

      // 如果是GET请求且有参数，添加到URL
      let requestUrl = fullUrl;
      if (data && method === http.RequestMethod.GET && typeof data === 'object') {
        const paramPairs: string[] = [];
        const keys = Object.keys(data);
        for (let i = 0; i < keys.length; i++) {
          const key = keys[i];
          const value = (data as Record<string, string | number | boolean>)[key]; // 使用Record显式声明类型
          if (value !== undefined && value !== null) {
            paramPairs.push(`${encodeURIComponent(key)}=${encodeURIComponent(value.toString())}`);
          }
        }
        if (paramPairs.length > 0) {
          const queryString = paramPairs.join('&');
          const separator = requestUrl.includes('?') ? '&' : '?';
          requestUrl = `${requestUrl}${separator}${queryString}`;
        }
      }

      httpRequest.request(requestUrl, options, (err, data) => {
        if (err) {
          console.error('HTTP请求错误:', err);
          reject(new Error(`网络请求失败: ${err.message}`));
          return;
        }

        try {
          const response = JSON.parse(data.result.toString()) as Result<T>;
          resolve(response);
        } catch (parseError) {
          console.error('响应解析错误:', parseError);
          reject(new Error('响应数据格式错误'));
        } finally {
          httpRequest.destroy();
        }
      });
    });
  }

  /**
   * GET请求
   * @param url 请求地址
   * @param params 查询参数
   */
  public async get<T>(url: string, params?: Object): Promise<Result<T>> {
    return this.request<T>(http.RequestMethod.GET, url, params);
  }

  /**
   * POST请求
   * @param url 请求地址
   * @param data 请求数据
   */
  public async post<T>(url: string, data?: Object): Promise<Result<T>> {
    return this.request<T>(http.RequestMethod.POST, url, data);
  }

  /**
   * PUT请求
   * @param url 请求地址
   * @param data 请求数据
   */
  public async put<T>(url: string, data?: Object): Promise<Result<T>> {
    return this.request<T>(http.RequestMethod.PUT, url, data);
  }

  /**
   * DELETE请求
   * @param url 请求地址
   * @param params 查询参数
   */
  public async delete<T>(url: string, params?: Object): Promise<Result<T>> {
    return this.request<T>(http.RequestMethod.DELETE, url, params);
  }
}

// 导出单例实例
const httpServiceInstance = HttpService.getInstance();
export default httpServiceInstance;
export { HttpService as HttpServiceClass };