// 个人履历页面
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import HttpService from '../services/HttpService';
import CommonConstants from '../common/Constants';
import { DocVO, DocDTO, ToastOptions, Result } from '../models/dataModels';
import TokenManager from '../utils/TokenManager';


@Entry
@Component
struct DocPage {
  @State docList: DocVO[] = [];
  @State loading: boolean = false;
  @State showAddDialog: boolean = false;
  @State showEditDialog: boolean = false;
  @State currentDoc: DocVO | null = null;

  @State dialogType: 'add' | 'edit' | null = null;
  @State isDialogVisible: boolean = false;
  
  // 表单数据
  @State formTitle: string = '';
  @State formLeixing: string = '';
  @State formTime: string = '';
  @State formDescribe: string = '';
  @State startDate: Date = new Date();
  @State endDate: Date = new Date();
  @State refreshing: boolean = false;

  aboutToAppear() {
    this.loadDocList();
  }

  // 下拉刷新
  private async onRefresh() {
    this.refreshing = true;
    await this.loadDocList();
    this.refreshing = false;
  }

  // 加载个人履历列表
  private async loadDocList() {
    this.loading = true;
    try {
      const token = await TokenManager.getToken();
      
      // 设置token到HttpService
      const httpService = HttpService;
      httpService.setToken(token);
      
      // 使用HttpService发送获取个人履历列表请求
      httpService.get<DocVO[]>(
        CommonConstants.API_DOC
      ).then(response => {
        console.log("doc list response=>", JSON.stringify(response));
        if (response.code === 200 && response.data) {
          this.docList = response.data;
        } else {
          const toastOptions: ToastOptions = { message: response.msg || '加载失败', duration: 2000 };
          promptAction.showToast(toastOptions);
        }
      }).catch((err : Error) => {
        console.log('doc list err=>', err);
        console.error('加载个人履历失败:', err);
        const toastOptions: ToastOptions = { message: '网络错误，请稍后重试', duration: 2000 };
        promptAction.showToast(toastOptions);
      }).finally(() => {
        this.loading = false;
      });
      
    } catch (error) {
      console.error('加载个人履历失败:', error);
      const toastOptions: ToastOptions = { message: '网络错误，请稍后重试', duration: 2000 };
      promptAction.showToast(toastOptions);
      this.loading = false;
    }
  }

  // 重置表单
  private resetForm() {
    this.formTitle = '';
    this.formLeixing = '';
    this.formTime = '';
    this.formDescribe = '';
    this.startDate = new Date();
    this.endDate = new Date();
  }

  // 显示添加对话框
  private showAddDocDialog() {
    this.resetForm();
    this.showAddDialog = true;
    this.isDialogVisible = true;
    this.dialogType = 'add';
  }

  // 显示编辑对话框
  private showEditDocDialog(doc: DocVO) {
    this.showAddDialog = false;
    this.isDialogVisible = true;
    this.dialogType = 'edit';

    this.currentDoc = doc;
    this.formTitle = doc.title;
    this.formLeixing = doc.leixing;
    this.formTime = doc.time;
    this.formDescribe = doc.describe;
    this.formLeixing = this.convertNumberToLeixing(doc.leixing);
    
    // 解析时间范围
    this.parseTimeRange(doc.time);
    
    this.showEditDialog = true;
  }

  // 添加个人履历
  private async addDoc() {
    if (!this.validateForm()) return;
    
    try {
      const docData: DocDTO = {
        title: this.formTitle,
        leixing: this.convertLeixingToNumber(this.formLeixing),
        time: this.formatTimeRange(),
        describe: this.formDescribe
      };
      
      const token = await TokenManager.getToken();
      
      // 设置token到HttpService
      const httpService = HttpService;
      httpService.setToken(token);
      
      // 使用HttpService发送添加个人履历请求
      httpService.post<DocVO>(
        CommonConstants.API_DOC,
        docData
      ).then(response => {
        console.log("add doc response=>", JSON.stringify(response));
        if (response.code === 200) {
          const toastOptions: ToastOptions = { message: '添加成功', duration: 2000 };
          promptAction.showToast(toastOptions);
          this.isDialogVisible = false;
          this.loadDocList();
        } else {
          const toastOptions: ToastOptions = { message: response.msg || '添加失败', duration: 2000 };
          promptAction.showToast(toastOptions);
        }
      }).catch((err : Error) => {
        console.log('add doc err=>', err);
        console.error('添加个人履历失败:', err);
        const toastOptions: ToastOptions = { message: '网络错误，请稍后重试', duration: 2000 };
        promptAction.showToast(toastOptions);
      });
      
    } catch (error) {
      console.error('添加个人履历失败:', error);
      const toastOptions: ToastOptions = { message: '网络错误，请稍后重试', duration: 2000 };
      promptAction.showToast(toastOptions);
    }
  }

  // 编辑个人履历
  private async editDoc() {
    if (!this.validateForm() || !this.currentDoc) return;
    
    try {
      const docData: DocDTO = {
        title: this.formTitle,
        leixing: this.convertLeixingToNumber(this.formLeixing),
        time: this.formatTimeRange(),
        describe: this.formDescribe
      };
      
      const token = await TokenManager.getToken();
      
      // 设置token到HttpService
      const httpService = HttpService;
      httpService.setToken(token);
      
      // 使用HttpService发送编辑个人履历请求
      httpService.put<DocVO>(
        `${CommonConstants.API_DOC}/${this.currentDoc.unid}`,
        docData
      ).then(response => {
        console.log("edit doc response=>", JSON.stringify(response));
        if (response.code === 200) {
          const toastOptions: ToastOptions = { message: '修改成功', duration: 2000 };
          promptAction.showToast(toastOptions);
          this.isDialogVisible = false;
          this.loadDocList();
        } else {
          const toastOptions: ToastOptions = { message: response.msg || '修改失败', duration: 2000 };
          promptAction.showToast(toastOptions);
        }
      }).catch((err : Error) => {
        console.log('edit doc err=>', err);
        console.error('编辑个人履历失败:', err);
        const toastOptions: ToastOptions = { message: '网络错误，请稍后重试', duration: 2000 };
        promptAction.showToast(toastOptions);
      });
      
    } catch (error) {
      console.error('编辑个人履历失败:', error);
      const toastOptions: ToastOptions = { message: '网络错误，请稍后重试', duration: 2000 };
      promptAction.showToast(toastOptions);
    }
  }

  // 删除个人履历
  private async deleteDoc(doc: DocVO) {
    try {
      const token = await TokenManager.getToken();
      
      // 设置token到HttpService
      const httpService = HttpService;
      httpService.setToken(token);
      
      // 使用HttpService发送删除个人履历请求
      httpService.delete<Record<string, Object>>(
        `${CommonConstants.API_DOC}/${doc.unid}`
      ).then(response => {
        console.log("delete doc response=>", JSON.stringify(response));
        if (response.code === 200) {
          const toastOptions: ToastOptions = { message: '删除成功', duration: 2000 };
          promptAction.showToast(toastOptions);
          this.loadDocList();
        } else {
          const toastOptions: ToastOptions = { message: response.msg || '删除失败', duration: 2000 };
          promptAction.showToast(toastOptions);
        }
      }).catch((err : Error) => {
        console.log('delete doc err=>', err);
        console.error('删除个人履历失败:', err);
        const toastOptions: ToastOptions = { message: '网络错误，请稍后重试', duration: 2000 };
        promptAction.showToast(toastOptions);
      });
      
    } catch (error) {
      console.error('删除个人履历失败:', error);
      const toastOptions: ToastOptions = { message: '网络错误，请稍后重试', duration: 2000 };
      promptAction.showToast(toastOptions);
    }
  }

  // 格式化日期（精确到月份）
  private formatDate(date: Date): string {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    return `${year}-${month}`;
  }

  // 格式化时间范围
  private formatTimeRange(): string {
    const startStr = this.formatDate(this.startDate);
    const endStr = this.formatDate(this.endDate);
    return `${startStr}至${endStr}`;
  }

  // 解析时间范围
  private parseTimeRange(timeRange: string) {
    if (timeRange && timeRange.includes('至')) {
      const parts = timeRange.split('至');
      if (parts.length === 2) {
        // 解析YYYY-MM格式的日期
        const startPart = parts[0].trim();
        const endPart = parts[1].trim();
        this.startDate = new Date(startPart + '-01'); // 添加日期部分
        this.endDate = new Date(endPart + '-01'); // 添加日期部分
      }
    }
  }

  // 获取选中的索引
  private getSelectedIndex(): number {
    if (!this.formLeixing) return -1;
    const typeMap = ['项目经历', '实习经历', '校园经历'];
    return typeMap.indexOf(this.formLeixing);
  }

  // 将文本值转换为数字值用于提交
  private convertLeixingToNumber(leixing: string): string {
    const typeMap = ['项目经历', '实习经历', '校园经历'];
    const index = typeMap.indexOf(leixing);
    return index >= 0 ? (index + 1).toString() : leixing;
  }

  // 将数字值转换为文本值用于显示
  private convertNumberToLeixing(leixing: string): string {
    const typeMap = ['项目经历', '实习经历', '校园经历'];
    const index = parseInt(leixing) - 1;
    return index >= 0 && index < typeMap.length ? typeMap[index] : leixing;
  }

  // 表单验证
  private validateForm(): boolean {
    if (!this.formTitle.trim()) {
      const toastOptions: ToastOptions = { message: '请输入履历标题', duration: 2000 };
      promptAction.showToast(toastOptions);
      return false;
    }
    if (!this.formLeixing.trim()) {
      const toastOptions: ToastOptions = { message: '请输入履历类型', duration: 2000 };
      promptAction.showToast(toastOptions);
      return false;
    }
    if (!this.startDate || !this.endDate) {
      const toastOptions: ToastOptions = { message: '请选择开始时间和结束时间', duration: 2000 };
      promptAction.showToast(toastOptions);
      return false;
    }
    if (this.startDate > this.endDate) {
      const toastOptions: ToastOptions = { message: '开始时间不能晚于结束时间', duration: 2000 };
      promptAction.showToast(toastOptions);
      return false;
    }
    if (!this.formDescribe.trim()) {
      const toastOptions: ToastOptions = { message: '请输入履历描述', duration: 2000 };
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

  // 个人履历卡片构建器
  @Builder
  DocCard(doc: DocVO) {
    Column({ space: 12 }) {
      Row() {
        Text(doc.title)
          .fontSize(16)
          .fontColor('#333333')
          .fontWeight(600)
          .layoutWeight(1)
        
        Row({ space: 8 }) {
          Text('编辑')
            .fontSize(14)
            .fontColor('#1698CE')
            .onClick(() => this.showEditDocDialog(doc))
          
          Text('删除')
            .fontSize(14)
            .fontColor('#FF4444')
            .onClick(() => {
              AlertDialog.show({
                title: '确认删除',
                message: '确定要删除这个履历吗？',
                primaryButton: {
                  value: '取消',
                  action: () => {}
                },
                secondaryButton: {
                  value: '删除',
                  fontColor: '#FF4444',
                  action: () => this.deleteDoc(doc)
                }
              });
            })
        }
      }
      .width('100%')
      
      Row({ space: 16 }) {
        Column({ space: 4 }) {
          Text('类型')
            .fontSize(12)
            .fontColor('#999999')
          Text(this.convertNumberToLeixing(doc.leixing))
            .fontSize(14)
            .fontColor('#666666')
        }
        .alignItems(HorizontalAlign.Start)
        
        Column({ space: 4 }) {
          Text('时间')
            .fontSize(12)
            .fontColor('#999999')
          Text(doc.time)
            .fontSize(14)
            .fontColor('#666666')
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
      
      Column({ space: 4 }) {
        Text('描述')
          .fontSize(12)
          .fontColor('#999999')
          .width('100%')
        Text(doc.describe)
          .fontSize(14)
          .fontColor('#666666')
          .width('100%')
          .maxLines(3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
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
      Text(isEdit ? '编辑个人履历' : '添加个人履历')
        .fontSize(18)
        .fontColor('#333333')
        .fontWeight(600)
      
      Column({ space: 16 }) {
        TextInput({ placeholder: '请输入履历标题', text: this.formTitle })
          .onChange((value: string) => this.formTitle = value)
          .height(44)
        
        Select([{ value: '项目经历' },
          { value: '实习经历' },
          { value: '校园经历' }])
          .selected(this.getSelectedIndex())
          .value(this.formLeixing || '请选择履历类型')
          .onSelect((index: number, value: string) => {
            this.formLeixing = value;
          })
          .width('100%')
          .height(44)
          .borderRadius(8)
          .backgroundColor('#F8F9FA')
          .fontColor('#333333')
        
        Column({ space: 8 }) {
          Text('开始时间')
            .fontSize(14)
            .fontColor('#666666')
            .alignSelf(ItemAlign.Start)
          
          DatePicker({
            start: new Date('2000-1-1'),
            end: new Date('2030-12-31'),
            selected: this.startDate
          })
            .onDateChange((value: Date) => {
              this.startDate = value;
            })
            .height(44)
            .backgroundColor('#F8F9FA')
            .borderRadius(8)
            .disappearTextStyle({ color: '#CCCCCC', font: { size: 14 } })
            .textStyle({ color: '#333333', font: { size: 16 } })
            .selectedTextStyle({ color: '#1698CE', font: { size: 16, weight: FontWeight.Bold } })
        }
        .alignItems(HorizontalAlign.Start)
        
        Column({ space: 8 }) {
          Text('结束时间')
            .fontSize(14)
            .fontColor('#666666')
            .alignSelf(ItemAlign.Start)
          
          DatePicker({
            start: new Date('2000-1-1'),
            end: new Date('2030-12-31'),
            selected: this.endDate
          })
            .onDateChange((value: Date) => {
              this.endDate = value;
            })
            .height(44)
            .backgroundColor('#F8F9FA')
            .borderRadius(8)
            .disappearTextStyle({ color: '#CCCCCC', font: { size: 14 } })
            .textStyle({ color: '#333333', font: { size: 16 } })
            .selectedTextStyle({ color: '#1698CE', font: { size: 16, weight: FontWeight.Bold } })
        }
        .alignItems(HorizontalAlign.Start)
        
        TextArea({ placeholder: '请输入履历描述', text: this.formDescribe })
          .onChange((value: string) => this.formDescribe = value)
          .height(80)
      }
      
      Row({ space: 12 }) {
        Button('取消')
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#F5F5F5')
          .fontColor('#666666')
          .onClick(() => {
            if (isEdit) {
              this.showEditDialog = false;
            } else {
              this.showAddDialog = false;
            }
          })
        
        Button(isEdit ? '保存' : '添加')
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#1698CE')
          .fontColor('#FFFFFF')
          .onClick(() => {
            if (isEdit) {
              this.editDoc();
            } else {
              this.addDoc();
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
        Image($r('app.media.back'))
          .width(24)
          .height(24)
          .onClick(() => router.back())


        Text('个人履历')
          .fontSize(18)
          .fontColor('#333333')
          .fontWeight(600)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Button('添加')
          .height(36)
          .backgroundColor('#1698CE')
          .fontColor('#FFFFFF')
          .borderRadius(18)
          .onClick(() => this.showAddDocDialog())
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
      } else if (this.docList.length > 0) {
        Refresh({ refreshing: $$this.refreshing, builder: this.refreshBuilder }) {
          Scroll() {
            Column({ space: 12 }) {
              ForEach(this.docList, (doc: DocVO) => {
                this.DocCard(doc)
              }, (doc: DocVO) => doc.id.toString())
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
            Text('暂无个人履历')
              .fontSize(16)
              .fontColor('#999999')
              .margin({ top: 16 })
            Text('点击右上角添加按钮开始记录您的履历')
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
      { height: 550, dragBar: false }
    )
    // .bindSheet($$this.showAddDialog, this.FormDialog(false), {
    //   height: 500,
    //   dragBar: false
    // })
    // .bindSheet($$this.showEditDialog, this.FormDialog(true), {
    //   height: 500,
    //   dragBar: false
    // })
  }
}