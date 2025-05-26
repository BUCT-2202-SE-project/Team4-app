import preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';

/**
 * 用户信息服务类
 * 负责管理用户状态和持久化存储
 */
export class UserService {
  private static instance: UserService;
  private readonly PREFERENCES_NAME: string = 'user_preferences';
  private readonly USER_ID_KEY: string = 'current_user_id';
  private readonly DEFAULT_USER_ID: number = 2; // 默认用户ID为2
  private currentUserId: number = this.DEFAULT_USER_ID;
  private preferences: preferences.Preferences | null = null;
  private context: common.UIAbilityContext | null = null;

  /**
   * 私有构造函数，初始化组件
   */
  private constructor() {
    try {
      // 获取上下文
      this.context = getContext(this) as common.UIAbilityContext;

      // 从本地存储初始化
      this.initPreferences();
    } catch (error) {
      console.error(`UserService 构造函数错误: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 获取单例实例
   */
  public static getInstance(): UserService {
    if (!UserService.instance) {
      UserService.instance = new UserService();
    }
    return UserService.instance;
  }

  /**
   * 初始化首选项存储
   */
  private async initPreferences(): Promise<void> {
    try {
      if (this.context) {
        this.preferences = await preferences.getPreferences(this.context, this.PREFERENCES_NAME);
        // 从首选项中获取存储的用户ID
        const storedUserId = await this.preferences.get(this.USER_ID_KEY, this.DEFAULT_USER_ID) as number;
        this.currentUserId = storedUserId;

        console.info(`UserService 初始化完成，当前用户ID: ${this.currentUserId}`);
      } else {
        console.error('UserService 初始化失败: 上下文为空');
      }
    } catch (error) {
      console.error(`UserService 初始化失败: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 获取当前用户ID
   */
  public getCurrentUserId(): number {
    return this.currentUserId;
  }

  /**
   * 设置当前用户ID并持久化保存
   * @param userId 用户ID
   */
  public async setCurrentUserId(userId: number): Promise<boolean> {
    this.currentUserId = userId;

    // 持久化保存到首选项
    try {
      if (this.preferences) {
        await this.preferences.put(this.USER_ID_KEY, userId);
        await this.preferences.flush();
        console.info(`已保存用户ID: ${userId}`);
        return true;
      }
    } catch (error) {
      console.error(`保存用户ID失败: ${JSON.stringify(error)}`);
    }
    return false;
  }

  /**
   * 重置用户ID为默认值
   */
  public async resetUserId(): Promise<boolean> {
    return await this.setCurrentUserId(this.DEFAULT_USER_ID);
  }
}