// 个人荣誉页面
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import HttpService from '../services/HttpService';
import CommonConstants from '../common/Constants';
import { PersonalVO, PersonalDTO, ToastOptions } from '../models/dataModels';
import TokenManager from '../utils/TokenManager';

@Component
export default struct PersonalPage {
  @State personalList: PersonalVO[] = [];
  @State loading: boolean = false;
  @State refreshing: boolean = false;
  @State showAddDialog: boolean = false;
  @State showEditDialog: boolean = false;
  @State currentPersonal: PersonalVO | null = null;

  @State dialogType: 'add' | 'edit' | null = null;
  @State isDialogVisible: boolean = false;
  
  // 表单数据
  @State formTitle: string = '';
  @State formLeixing: string = '';
  @State formRank: string = '';
  @State formTime: string = '';
  @State selectedDate: Date = new Date();

  aboutToAppear() {
    this.loadPersonalList();
  }

  // 下拉刷新
  private async onRefresh() {
    this.refreshing = true;
    await this.loadPersonalList();
    this.refreshing = false;
  }

  // 加载个人荣誉列表
  private async loadPersonalList() {
    if (!this.refreshing) {
      this.loading = true;
    }
    try {
      const token = await TokenManager.getToken();
      
      // 设置token到HttpService
      const httpService = HttpService;
      httpService.setToken(token);
      
      // 使用HttpService发送获取个人荣誉列表请求
      httpService.get<PersonalVO[]>(
        CommonConstants.API_PERSONAL
      ).then(response => {
        if (response.code === 200 && response.data) {
          this.personalList = response.data;
        } else {
          const toastOptions: ToastOptions = { message: response.msg || '加载失败', duration: 2000 };
          promptAction.showToast(toastOptions);
        }
      }).catch((err : Error) => {
        console.log('personal list err=>', err);
        console.error('加载个人荣誉失败:', err);
        const toastOptions: ToastOptions = { message: '网络错误，请稍后重试', duration: 2000 };
        promptAction.showToast(toastOptions);
      }).finally(() => {
        this.loading = false;
      });
      
    } catch (error) {
      console.error('加载个人荣誉失败:', error);
      const toastOptions: ToastOptions = { message: '网络错误，请稍后重试', duration: 2000 };
      promptAction.showToast(toastOptions);
      this.loading = false;
    }
  }

  // 重置表单
  private resetForm() {
    this.formTitle = '';
    this.formLeixing = '';
    this.formRank = '';
    this.formTime = '';
    this.selectedDate = new Date();
  }

  // 格式化日期
  private formatDate(date: Date): string {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  // 显示添加对话框
  private showAddPersonalDialog() {
    // 确保编辑对话框已关闭
    this.showEditDialog = false;
    this.dialogType = 'add';
    this.isDialogVisible = true;

    this.resetForm();
    this.showAddDialog = true;
  }

  // 显示编辑对话框
  private showEditPersonalDialog(personal: PersonalVO) {
    // 确保添加对话框已关闭
    this.showAddDialog = false;
    this.isDialogVisible = true;
    this.dialogType = 'edit';
    this.currentPersonal = personal;
    this.formTitle = personal.title;
    this.formLeixing = this.convertNumberToLeixing(personal.leixing);
    this.formRank = personal.rank;
    this.formTime = personal.time;
    // 解析日期字符串为Date对象
    this.selectedDate = new Date(personal.time);
    this.showEditDialog = true;
  }

  // 添加个人荣誉
  private async addPersonal() {
    if (!this.validateForm()) return;

    try {
      const personalData: PersonalDTO = {
        title: this.formTitle,
        leixing: this.convertLeixingToNumber(this.formLeixing),
        rank: this.formRank,
        time: this.formatDate(this.selectedDate)
      };
      
      const token = await TokenManager.getToken();
      
      // 设置token到HttpService
      const httpService = HttpService;
      httpService.setToken(token);
      
      // 使用HttpService发送添加个人荣誉请求
      httpService.post<PersonalVO>(
        CommonConstants.API_PERSONAL,
        personalData
      ).then(response => {
        console.log("add personal response=>", JSON.stringify(response));
        if (response.code === 200) {
          const toastOptions: ToastOptions = { message: '添加成功', duration: 2000 };
          promptAction.showToast(toastOptions);
          this.showAddDialog = false;
          this.isDialogVisible = false;
          this.resetForm();
          this.loadPersonalList();
        } else {
          const toastOptions: ToastOptions = { message: response.msg || '添加失败', duration: 2000 };
          promptAction.showToast(toastOptions);
        }
      }).catch((err : Error) => {
        console.log('add personal err=>', err);
        console.error('添加个人荣誉失败:', err);
        const toastOptions: ToastOptions = { message: '网络错误，请稍后重试', duration: 2000 };
        promptAction.showToast(toastOptions);
      });
      
    } catch (error) {
      console.error('添加个人荣誉失败:', error);
      const toastOptions: ToastOptions = { message: '网络错误，请稍后重试', duration: 2000 };
      promptAction.showToast(toastOptions);
    }
  }

  // 编辑个人荣誉
  private async editPersonal() {
    if (!this.validateForm() || !this.currentPersonal) return;
    
    try {
      const personalData: PersonalDTO = {
        title: this.formTitle,
        leixing: this.convertLeixingToNumber(this.formLeixing),
        rank: this.formRank,
        time: this.formatDate(this.selectedDate)
      };
      
      const token = await TokenManager.getToken();
      
      // 设置token到HttpService
      const httpService = HttpService;
      httpService.setToken(token);
      
      // 使用HttpService发送编辑个人荣誉请求
      httpService.put<PersonalVO>(
        `${CommonConstants.API_PERSONAL}/${this.currentPersonal.unid}`,
        personalData
      ).then(response => {
        console.log("edit personal response=>", JSON.stringify(response));
        if (response.code === 200) {
          const toastOptions: ToastOptions = { message: '修改成功', duration: 2000 };
          promptAction.showToast(toastOptions);
          this.showEditDialog = false;
          this.isDialogVisible = false;

          this.currentPersonal = null;
          this.resetForm();
          this.loadPersonalList();
        } else {
          const toastOptions: ToastOptions = { message: response.msg || '修改失败', duration: 2000 };
          promptAction.showToast(toastOptions);
        }
      }).catch((err : Error) => {
        console.log('edit personal err=>', err);
        console.error('编辑个人荣誉失败:', err);
        const toastOptions: ToastOptions = { message: '网络错误，请稍后重试', duration: 2000 };
        promptAction.showToast(toastOptions);
      });
      
    } catch (error) {
      console.error('编辑个人荣誉失败:', error);
      const toastOptions: ToastOptions = { message: '网络错误，请稍后重试', duration: 2000 };
      promptAction.showToast(toastOptions);
    }
  }

  // 删除个人荣誉
  private async deletePersonal(personal: PersonalVO) {
    try {
      const token = await TokenManager.getToken();
      
      // 设置token到HttpService
      const httpService = HttpService;
      httpService.setToken(token);
      
      // 使用HttpService发送删除个人荣誉请求
      httpService.delete<Record<string, Object>>(
        `${CommonConstants.API_PERSONAL}/${personal.unid}`
      ).then(response => {
        console.log("delete personal response=>", JSON.stringify(response));
        if (response.code === 200) {
          const toastOptions: ToastOptions = { message: '删除成功', duration: 2000 };
          promptAction.showToast(toastOptions);
          this.loadPersonalList();
        } else {
          const toastOptions: ToastOptions = { message: response.msg || '删除失败', duration: 2000 };
          promptAction.showToast(toastOptions);
        }
      }).catch((err : Error) => {
        console.log('delete personal err=>', err);
        console.error('删除个人荣誉失败:', err);
        const toastOptions: ToastOptions = { message: '网络错误，请稍后重试', duration: 2000 };
        promptAction.showToast(toastOptions);
      });
      
    } catch (error) {
      console.error('删除个人荣誉失败:', error);
      const toastOptions: ToastOptions = { message: '网络错误，请稍后重试', duration: 2000 };
      promptAction.showToast(toastOptions);
    }
  }

  // 获取选中的索引
  private getSelectedIndex(): number {
    if (!this.formLeixing) return -1;
    const typeMap = ['班级', '院级', '校级', '镇级', '县级', '市级', '省级', '国家级'];
    return typeMap.indexOf(this.formLeixing);
  }

  // 将文本值转换为数字值用于提交
  private convertLeixingToNumber(leixing: string): string {
    const typeMap = ['班级', '院级', '校级', '镇级', '县级', '市级', '省级', '国家级'];
    const index = typeMap.indexOf(leixing);
    return index >= 0 ? (index + 1).toString() : leixing;
  }

  // 将数字值转换为文本值用于显示
  private convertNumberToLeixing(leixing: string): string {
    const typeMap = ['班级', '院级', '校级', '镇级', '县级', '市级', '省级', '国家级'];
    const index = parseInt(leixing) - 1;
    return index >= 0 && index < typeMap.length ? typeMap[index] : leixing;
  }

  // 表单验证
  private validateForm(): boolean {
    if (!this.formTitle.trim()) {
      const toastOptions: ToastOptions = { message: '请输入荣誉标题', duration: 2000 };
      promptAction.showToast(toastOptions);
      return false;
    }
    if (!this.formLeixing.trim()) {
      const toastOptions: ToastOptions = { message: '请输入荣誉类型', duration: 2000 };
      promptAction.showToast(toastOptions);
      return false;
    }
    if (!this.formRank.trim()) {
      const toastOptions: ToastOptions = { message: '请输入荣誉等级', duration: 2000 };
      promptAction.showToast(toastOptions);
      return false;
    }
    if (!this.formTime.trim() && !this.selectedDate) {
      const toastOptions: ToastOptions = { message: '请选择获得时间', duration: 2000 };
      promptAction.showToast(toastOptions);
      return false;
    }
    return true;
  }

  // 下拉刷新构建器
  @Builder
  refreshBuilder() {
    Row() {
      LoadingProgress()
        .width(24)
        .height(24)
        .color('#1698CE')
      Text('正在刷新...')
        .fontSize(14)
        .fontColor('#666666')
        .margin({ left: 8 })
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height(60)
  }

  // 个人荣誉卡片构建器
  @Builder
  PersonalCard(personal: PersonalVO) {
    Column({ space: 12 }) {
      Row() {
        Text(personal.title)
          .fontSize(16)
          .fontColor('#333333')
          .fontWeight(600)
          .layoutWeight(1)
        
        Row({ space: 8 }) {
          Text('编辑')
            .fontSize(14)
            .fontColor('#1698CE')
            .onClick(() => this.showEditPersonalDialog(personal))
          
          Text('删除')
            .fontSize(14)
            .fontColor('#FF4444')
            .onClick(() => {
              AlertDialog.show({
                title: '确认删除',
                message: '确定要删除这个荣誉吗？',
                primaryButton: {
                  value: '取消',
                  action: () => {}
                },
                secondaryButton: {
                  value: '删除',
                  fontColor: '#FF4444',
                  action: () => this.deletePersonal(personal)
                }
              });
            })
        }
      }
      .width('100%')
      
      Row({ space: 16 }) {
        Column({ space: 4 }) {
          Text('等级')
            .fontSize(12)
            .fontColor('#999999')
          Text(this.convertNumberToLeixing(personal.leixing))
            .fontSize(14)
            .fontColor('#666666')
        }
        .alignItems(HorizontalAlign.Start)
        
        Column({ space: 4 }) {
          Text('名词')
            .fontSize(12)
            .fontColor('#999999')
          Text(personal.rank)
            .fontSize(14)
            .fontColor('#666666')
        }
        .alignItems(HorizontalAlign.Start)
        
        Column({ space: 4 }) {
          Text('时间')
            .fontSize(12)
            .fontColor('#999999')
          Text(personal.time)
            .fontSize(14)
            .fontColor('#666666')
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 4, color: '#1F000000', offsetX: 0, offsetY: 2 })
  }

  // 表单对话框构建器
  @Builder
  FormDialog(isEdit: boolean) {
    Column({ space: 20 }) {
      Text(isEdit ? '编辑个人荣誉' : '添加个人荣誉')
        .fontSize(18)
        .fontColor('#333333')
        .fontWeight(600)
      
      Column({ space: 16 }) {
        TextInput({ placeholder: '请输入荣誉标题', text: this.formTitle })
          .onChange((value: string) => this.formTitle = value)
          .height(44)
        
        Select([{ value: '班级' },
                { value: '院级' },
                { value: '校级' },
                { value: '镇级' },
                { value: '县级' },
                { value: '市级' },
                { value: '省级' },
                { value: '国家级' }])
          .selected(this.getSelectedIndex())
          .value(this.formLeixing || '请选择荣誉类型')
          .onSelect((index: number, value: string) => {
            this.formLeixing = value;
          })
          .width('100%')
          .height(44)
          .borderRadius(8)
          .backgroundColor('#F8F9FA')
          .fontColor('#333333')
        
        TextInput({ placeholder: '请输入荣誉等级', text: this.formRank })
          .onChange((value: string) => this.formRank = value)
          .height(44)
        
        Column({ space: 8 }) {
          Text('获得时间')
            .fontSize(14)
            .fontColor('#666666')
            .alignSelf(ItemAlign.Start)
          
          DatePicker({
            start: new Date('2000-1-1'),
            end: new Date('2099-12-31'),
            selected: this.selectedDate
          })
            .onDateChange((value: Date) => {
              this.selectedDate = value;
              this.formTime = this.formatDate(value);
            })
            .height(44)
            .backgroundColor('#F8F9FA')
            .borderRadius(8)
        }
        .alignItems(HorizontalAlign.Start)
      }
      
      Row({ space: 12 }) {
        Button('取消')
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#F5F5F5')
          .fontColor('#666666')
          .onClick(() => {
            if (isEdit) {
              this.isDialogVisible = false;
              this.currentPersonal = null;
            } else {
              this.isDialogVisible = false;
            }
            this.resetForm();
          })
        
        Button(isEdit ? '保存' : '添加')
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#1698CE')
          .fontColor('#FFFFFF')
          .onClick(() => {
            if (isEdit) {
              this.editPersonal();
            } else {
              this.addPersonal();
            }
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(20)
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('个人荣誉')
          .fontSize(20)
          .fontColor('#333333')
          .fontWeight(600)
          .layoutWeight(1)
        
        Button('添加')
          .height(36)
          .backgroundColor('#1698CE')
          .fontColor('#FFFFFF')
          .borderRadius(18)
          .onClick(() => this.showAddPersonalDialog())
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 16 })
      .backgroundColor('#FFFFFF')
      .shadow({ radius: 2, color: '#1F000000', offsetX: 0, offsetY: 1 })

      if (this.loading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color('#1698CE')
          Text('加载中...')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 12 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.personalList.length > 0) {
        Refresh({ refreshing: $$this.refreshing, builder: this.refreshBuilder }) {
          Scroll() {
            Column({ space: 12 }) {
              ForEach(this.personalList, (personal: PersonalVO) => {
                this.PersonalCard(personal)
              }, (personal: PersonalVO) => personal.id.toString())
            }
            .padding(20)
          }
          .scrollBar(BarState.Off)
        }
        .onRefreshing(() => {
          this.onRefresh();
        })
        .layoutWeight(1)
      } else {
        Refresh({ refreshing: $$this.refreshing, builder: this.refreshBuilder }) {
          Column() {
            Image($r('app.media.empty'))
              .width(100)
              .height(100)
              .opacity(0.5)
            Text('暂无个人荣誉')
              .fontSize(16)
              .fontColor('#999999')
              .margin({ top: 16 })
            Text('点击右上角添加按钮开始记录您的荣誉')
              .fontSize(14)
              .fontColor('#CCCCCC')
              .margin({ top: 8 })
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
        }
        .onRefreshing(() => {
          this.onRefresh();
        })
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
    .bindSheet(
      $$this.isDialogVisible,
      this.FormDialog(this.dialogType === 'edit'),
      { height: 400, dragBar: false }
    )
    // .bindSheet($$this.showAddDialog, this.FormDialog(false), {
    //   height: 400,
    //   dragBar: false
    // })
    // .bindSheet($$this.showEditDialog, this.FormDialog(true), {
    //   height: 400,
    //   dragBar: false
    // })
  }
}