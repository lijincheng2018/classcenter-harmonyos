// src/main/ets/common/Constants.ets
export default class CommonConstants {
  static readonly BASE_URL: string = 'https://class-gateway.ljcljc.cn/api'; // 替换为实际API地址
  
  // 页面路由
  static readonly LOGIN_PAGE: string = 'pages/LoginPage';
  static readonly INDEX_PAGE: string = 'pages/Index';
  static readonly HOME_PAGE: string = 'pages/HomePage';
  static readonly PERSONAL_PAGE: string = 'pages/PersonalPage';
  static readonly NOTICE_PAGE: string = 'pages/NoticePage';
  static readonly NOTICE_DETAIL_PAGE: string = 'pages/NoticeDetailPage';
  static readonly DOC_PAGE: string = 'pages/DocPage';
  static readonly PROFILE_PAGE: string = 'pages/ProfilePage';
  static readonly EXAM_PAGE: string = 'pages/ExamPage';
  static readonly EXAM_REPORT_PAGE: string = 'pages/ExamReportPage';
  static readonly RANDOM_PAGE: string = 'pages/RandomPage';
  
  // API端点
  static readonly API_LOGIN: string = '/doLogin';
  static readonly API_LOGOUT: string = '/logout';
  static readonly API_VALIDATE_TOKEN: string = '/validateStatus';
  
  // 个人荣誉相关API
  static readonly API_PERSONAL: string = '/personal';
  
  // 公告管理相关API
  static readonly API_NOTICES: string = '/notices';
  
  // 个人履历相关API
  static readonly API_DOC: string = '/doc';
  
  // 班级相关API
  static readonly API_CLASS: string = '/class';
  
  // 登记表相关API
  static readonly API_REGISTER: string = '/register';
  static readonly API_REGISTER_ADMIN: string = '/register/admin';
  
  // 收集表相关API
  static readonly API_COLLECT: string = '/collect';
  static readonly API_COLLECT_ADMIN: string = '/collect/admin';
  
  // 任务管理相关API
  static readonly API_TASK: string = '/task';
  static readonly API_TASK_COUNT: string = '/task/count';
  
  // 抽号相关API
  static readonly API_RANDOM: string = '/users/getRandomList';
  
  // 成绩管理相关API
  static readonly API_EXAMS: string = '/exams';
  static readonly API_EXAMS_ADMIN: string = '/exams/admin';
  
  // 简历分析相关API
  static readonly API_RESUME: string = '/resume';


  // 相关常量
  /**
   * The width or height of the component is spread across the parent component.
   */
  static readonly FULL_PARENT: string = '100%';

  /**
   * Left padding of the input box.
   */
  static readonly INPUT_PADDING_LEFT: number = 0;
}