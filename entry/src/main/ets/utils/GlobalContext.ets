export class GlobalContext {
  private constructor() {}
  private static instance: GlobalContext = new GlobalContext();
  private _context: Context | null = null;

  public static getInstance(): GlobalContext {
    return GlobalContext.instance;
  }

  getContext(): Context {
    if (!this._context) {
      throw new Error("GlobalContext 未初始化！请在 EntryAbility 中调用 setContext()");
    }
    return this._context;
  }

  setContext(context: Context): void {
    this._context = context;
  }
}