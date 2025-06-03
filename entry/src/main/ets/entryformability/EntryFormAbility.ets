import { preferences } from '@kit.ArkData';
import { formBindingData, FormExtensionAbility, formProvider } from '@kit.FormKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import HttpService from '../services/HttpService';
import CommonConstants from '../common/Constants';
import TokenManager from '../utils/TokenManager';
import { TaskCountResult, UserBasicInfo } from '../models/dataModels';
import { Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { GlobalContext } from '../utils/GlobalContext';

const TAG: string = 'EntryFormAbility';
const DOMAIN_NUMBER: number = 0xFF00;

interface DataVO {
  totalCount: number;
  finishCount: number;
  title: string;
  userName: string;
  userRole: string;
  userGroup: string;
  lastUpdate: string;
}

interface messageObjectParams {
  method: string;
  action: string;
}

interface messageObject {
  method: string;
  params: messageObjectParams;
}

export default class EntryFormAbility extends FormExtensionAbility {

  onCreate(want: Want): void {
    hilog.info(DOMAIN_NUMBER, TAG, 'FormExtensionAbility onCreate');
    // 初始化GlobalContext，确保FormExtensionAbility能访问context
    GlobalContext.getInstance().setContext(this.context);
    hilog.info(DOMAIN_NUMBER, TAG, 'GlobalContext initialized in FormExtensionAbility');
  }

  // 卡片创建时调用
  onAddForm(want: Want): formBindingData.FormBindingData {
    hilog.info(DOMAIN_NUMBER, TAG, 'FormAbility onAddForm');
    
    // 确保GlobalContext已初始化
    try {
      GlobalContext.getInstance().setContext(this.context);
      hilog.info(DOMAIN_NUMBER, TAG, 'GlobalContext initialized in onAddForm');
    } catch (error) {
      hilog.error(DOMAIN_NUMBER, TAG, `GlobalContext init failed: ${error}`);
    }

    // 获取formId
    const formId = want.parameters?.['ohos.extra.param.key.form_identity'] as string;
    hilog.info(DOMAIN_NUMBER, TAG, `FormId: ${formId}`);

    // 初始化数据（添加测试数据）
    let formData: DataVO = {
      totalCount: 0,
      finishCount: 0,
      title: '任务完成情况',
      userName: 'N/A',
      userRole: 'N/A',
      userGroup: '3',
      lastUpdate: this.getCurrentTime()
    };

    // 初始化LocalStorage数据
    AppStorage.setOrCreate('totalCount', formData.totalCount);
    AppStorage.setOrCreate('finishCount', formData.finishCount);
    AppStorage.setOrCreate('title', formData.title);
    AppStorage.setOrCreate('lastUpdate', formData.lastUpdate);
    AppStorage.setOrCreate('userName', formData.userName);
    AppStorage.setOrCreate('userRole', formData.userRole);
    AppStorage.setOrCreate('userGroup', formData.userGroup);

    hilog.info(DOMAIN_NUMBER, TAG, `Initial form data: ${JSON.stringify(formData)}`);
    hilog.info(DOMAIN_NUMBER, TAG, `totalCount: ${formData.totalCount}, finishCount: ${formData.finishCount}`);

    // 异步获取任务数据
    if (formId) {
      this.loadTaskData(formId);
    }

    let bindingData = formBindingData.createFormBindingData(formData);
    hilog.info(DOMAIN_NUMBER, TAG, `Binding data created: ${JSON.stringify(bindingData)}`);

    return bindingData;
  }
  
  // 卡片更新时调用
  onUpdateForm(formId: string): void {
    hilog.info(DOMAIN_NUMBER, TAG, 'FormAbility onUpdateForm');
    
    // 确保GlobalContext已初始化
    try {
      GlobalContext.getInstance().setContext(this.context);
      hilog.info(DOMAIN_NUMBER, TAG, 'GlobalContext initialized in onUpdateForm');
    } catch (error) {
      hilog.error(DOMAIN_NUMBER, TAG, `GlobalContext init failed: ${error}`);
    }
    
    this.loadTaskData(formId);
  }
  
  // 获取任务数据
  private async loadTaskData(formId: string): Promise<void> {
    try {
      hilog.info(DOMAIN_NUMBER, TAG, `Loading task data for formId: ${formId}`);
      
      const token = await TokenManager.getToken();
      hilog.info(DOMAIN_NUMBER, TAG, `Token retrieved: ${token ? 'Found' : 'Not found'}`);
      if (!token) {
        hilog.error(DOMAIN_NUMBER, TAG, 'No token available - user may not be logged in');
        // 即使没有token，也更新卡片显示默认数据
         const formData : DataVO = {
           totalCount: 0,
           finishCount: 0,
           title: '任务完成情况',
           userName: 'N/A',
           userRole: 'N/A',
           userGroup: '3',
           lastUpdate: this.getCurrentTime()
         };
        
        // 更新LocalStorage数据
        AppStorage.setOrCreate('totalCount', formData.totalCount);
        AppStorage.setOrCreate('finishCount', formData.finishCount);
        AppStorage.setOrCreate('title', formData.title);
        AppStorage.setOrCreate('lastUpdate', formData.lastUpdate);
        AppStorage.setOrCreate('userName', formData.userName);
        AppStorage.setOrCreate('userRole', formData.userRole);
        AppStorage.setOrCreate('userGroup', formData.userGroup);

        let formInfo: formBindingData.FormBindingData = formBindingData.createFormBindingData(formData);
        formProvider.updateForm(formId, formInfo);
        return;
      }
      
      hilog.info(DOMAIN_NUMBER, TAG, `Token available: ${token.substring(0, 10)}...`);
      
      const httpService = HttpService;
      httpService.setToken(token);
      
      hilog.info(DOMAIN_NUMBER, TAG, `Calling API: ${CommonConstants.API_TASK_COUNT}`);
      const response = await httpService.get<TaskCountResult>(CommonConstants.API_TASK_COUNT);
      const response_basic_info = await httpService.get<UserBasicInfo>(CommonConstants.API_GET_USER_BASIC_INFO);

      if (response.code === 200 && response.data && response_basic_info.code === 200 && response_basic_info.data) {
        const formData : DataVO = {
          totalCount: response.data.totalCount || 0,
          finishCount: response.data.finishCount || 0,
          title: '任务完成情况',
          userName: response_basic_info.data.name,
          userRole: response_basic_info.data.zhiwu,
          userGroup: response_basic_info.data.usergroup,
          lastUpdate: this.getCurrentTime()
        };
        
        hilog.info(DOMAIN_NUMBER, TAG, `Form data: ${JSON.stringify(formData)}`);
        hilog.info(DOMAIN_NUMBER, TAG, `API totalCount: ${formData.totalCount}, finishCount: ${formData.finishCount}`);
        
        // 更新LocalStorage数据
        AppStorage.setOrCreate('totalCount', formData.totalCount);
        AppStorage.setOrCreate('finishCount', formData.finishCount);
        AppStorage.setOrCreate('title', formData.title);
        AppStorage.setOrCreate('lastUpdate', formData.lastUpdate);
        AppStorage.setOrCreate('userName', formData.userName);
        AppStorage.setOrCreate('userRole', formData.userRole);
        AppStorage.setOrCreate('userGroup', formData.userGroup);

        let formInfo: formBindingData.FormBindingData = formBindingData.createFormBindingData(formData);
        
        formProvider.updateForm(formId, formInfo).then(() => {
          hilog.info(DOMAIN_NUMBER, TAG, 'FormAbility updateForm success.');
        }).catch((error: BusinessError) => {
          hilog.error(DOMAIN_NUMBER, TAG, `Operation updateForm failed. Cause: ${JSON.stringify(error)}`);
        });
      } else {
        hilog.error(DOMAIN_NUMBER, TAG, `API call failed or no data. Response: ${JSON.stringify(response)}`);
         // API调用失败时也要更新卡片
         const formData : DataVO = {
           totalCount: 0,
           finishCount: 0,
           title: '任务完成情况',
           userName: 'N/A',
           userRole: 'N/A',
           userGroup: '3',
           lastUpdate: this.getCurrentTime()
         };
        
        // 更新LocalStorage数据
        AppStorage.setOrCreate('totalCount', formData.totalCount);
        AppStorage.setOrCreate('finishCount', formData.finishCount);
        AppStorage.setOrCreate('title', formData.title);
        AppStorage.setOrCreate('lastUpdate', formData.lastUpdate);
        AppStorage.setOrCreate('userName', formData.userName);
        AppStorage.setOrCreate('userRole', formData.userRole);
        AppStorage.setOrCreate('userGroup', formData.userGroup);

        let formInfo: formBindingData.FormBindingData = formBindingData.createFormBindingData(formData);
        formProvider.updateForm(formId, formInfo);
      }
    } catch (error) {
      hilog.error(DOMAIN_NUMBER, TAG, `Load task data failed: ${JSON.stringify(error)}`);
       // 出现异常时也要更新卡片
       const formData : DataVO = {
         totalCount: 0,
         finishCount: 0,
         title: '任务完成情况',
         userName: 'N/A',
         userRole: 'N/A',
         userGroup: '3',
         lastUpdate: this.getCurrentTime()
       };
      
      // 更新LocalStorage数据
      AppStorage.setOrCreate('totalCount', formData.totalCount);
      AppStorage.setOrCreate('finishCount', formData.finishCount);
      AppStorage.setOrCreate('title', formData.title);
      AppStorage.setOrCreate('lastUpdate', formData.lastUpdate);
      AppStorage.setOrCreate('userName', formData.userName);
      AppStorage.setOrCreate('userRole', formData.userRole);
      AppStorage.setOrCreate('userGroup', formData.userGroup);
      
      let formInfo: formBindingData.FormBindingData = formBindingData.createFormBindingData(formData);
      formProvider.updateForm(formId, formInfo);
    }
  }
  
  // 获取当前时间
  private getCurrentTime(): string {
    const now = new Date();
    return `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`;
  }

  // 卡片删除时调用
  onRemoveForm(formId: string): void {
    hilog.info(DOMAIN_NUMBER, TAG, 'FormAbility onRemoveForm');
  }
  
  // 卡片事件处理
  onFormEvent(formId: string, message: string): void {
    hilog.info(DOMAIN_NUMBER, TAG, `FormAbility onFormEvent, formId = ${formId}, message: ${JSON.stringify(message)}`);

    this.onUpdateForm(formId);
    
    // try {
    //   // 解析消息
    //   const messageObj : messageObject = JSON.parse(message);
    //   hilog.info(DOMAIN_NUMBER, TAG, `Parsed message: ${JSON.stringify(messageObj)}`);
    //
    //   // 处理刷新数据请求
    //   if (messageObj.method === 'refreshWidgetData') {
    //     hilog.info(DOMAIN_NUMBER, TAG, 'Refreshing widget data...');
    //     this.loadTaskData(formId);
    //   }
    // } catch (error) {
    //   hilog.error(DOMAIN_NUMBER, TAG, `Failed to parse message: ${error}`);
    //   // 如果解析失败，尝试直接处理字符串消息
    //   if (message === 'refresh') {
    //     this.loadTaskData(formId);
    //   }
    // }
  }
}