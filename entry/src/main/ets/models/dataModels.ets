// 数据模型定义

// 通用响应结果
export interface Result<T = Record<string, Object>> {
  code: number;
  msg: string;
  data: T;
}

export interface tokenValidateDTO {
  token: string;
}

export interface UserInfo {
  token: string;
  username: string;
  isLogin: boolean;
}

// 登录相关
export interface LoginDTO {
  username: string;
  password: string;
  captcha?: string;
  captchaId?: string;
}

export interface LoginResponse {
  token: string;
  username: string;
  userId: number;
}

// Token验证
export interface TokenValidateDTO {
  token: string;
}

// 个人荣誉相关
export interface PersonalDTO {
  title: string;
  leixing: string;
  rank: string;
  time: string;
}

export interface PersonalVO {
  id: number;
  unid: number;
  title: string;
  leixing: string;
  rank: string;
  time: string;
}

// 公告相关
export interface NoticeDTO {
  title: string;
  content: string;
}

export interface NoticeVO {
  id: number;
  unid: number;
  title: string;
  content: string;
  time: string;
  poster: string;
}

// 个人履历相关
export interface DocDTO {
  title: string;
  leixing: string;
  time: string;
  describe: string;
}

export interface DocVO {
  id: number;
  unid: number;
  title: string;
  leixing: string;
  time: string;
  describe: string;
}

// 分页查询参数
export interface PageParams {
  page: number;
  size: number;
}

// 分页响应结果
export interface PageResult<T> {
  notices: T[];
  totalElements: number;
  totalPages: number;
  size: number;
  number: number;
  first: boolean;
  last: boolean;
}

export interface NoticePageResult {
  notices: NoticeVO[];
  totalElements: number;
  totalPages: number;
}

export interface NoticeParams {
  notice: NoticeVO;
}

// Router related interfaces
export interface RouterParams {
  url: string;
  params?: string;
}

// HTTP请求专用VO接口
export interface LoginRequestVO {
  username: string;
  password: string;
  captcha?: string;
  captchaId?: string;
}

export interface TokenValidateRequestVO {
  token: string;
}

export interface PersonalCreateRequestVO {
  title: string;
  leixing: string;
  rank: string;
  time: string;
}

export interface PersonalUpdateRequestVO {
  title: string;
  leixing: string;
  rank: string;
  time: string;
}

export interface NoticeListRequestVO {
  page: number;
  size: number;
}

export interface DocCreateRequestVO {
  title: string;
  leixing: string;
  time: string;
  describe: string;
}

export interface DocUpdateRequestVO {
  title: string;
  leixing: string;
  time: string;
  describe: string;
}

export interface ToastOptions {
  message: string;
  duration: number;
}

// 成绩管理相关
export interface ExamVO {
  examID: number;
  bindClass: string;
  examName: string;
  examDate: string;
  createTime: string;
  subjects: string;
  examLeixing: string;
  isOpen: string;
}

export interface ExamReportVO {
  class_rank: string;
  isOpen: string;
  subject_output: SubjectScoreVO[];
  examDate: string;
  zonghe: string;
  examName: string;
  zhuanye_rank: string;
  examType: string;
}

export interface SubjectScoreVO {
  id: number;
  examID: number;
  studentID: string;
  subjectName: string;
  score: string;
}

// 学生信息接口
export interface StudentVO {
  id: string;
  name: string;
}

// 抽号结果接口
export interface DrawResult {
  name: string;
  timestamp: string;
}


// 任务统计相关
export interface TaskCountVO {
  finishCount: number;
  totalCount: number;
}

export interface TaskCountResult {
  finishCount: number;
  totalCount: number;
}