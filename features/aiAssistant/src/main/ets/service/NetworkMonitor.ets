import connection from '@ohos.net.connection';

export class NetworkMonitor {
  private static instance: NetworkMonitor;
  private netConnection: connection.NetConnection | null = null;
  private _isOnline: boolean = true;
  private recoveryTimer: number = 0;
  private onOnlineCallback: (() => void) | null = null;
  private onOfflineCallback: (() => void) | null = null;

  private constructor() {}

  public static getInstance(): NetworkMonitor {
    if (!NetworkMonitor.instance) {
      NetworkMonitor.instance = new NetworkMonitor();
    }
    return NetworkMonitor.instance;
  }

  public get isOnline(): boolean {
    return this._isOnline;
  }

  public setCallbacks(onOnline: () => void, onOffline: () => void): void {
    this.onOnlineCallback = onOnline;
    this.onOfflineCallback = onOffline;
  }

  public register(): void {
    if (this.netConnection) {
      return;
    }
    this.netConnection = connection.createNetConnection();
    this.netConnection.register(() => {});

    this.netConnection.on('netAvailable', () => {
      this._isOnline = true;
      if (this.onOnlineCallback) {
        this.onOnlineCallback();
      }
    });

    this.netConnection.on('netLost', () => {
      this._isOnline = false;
      if (this.onOfflineCallback) {
        this.onOfflineCallback();
      }
    });

    this.netConnection.on('netUnavailable', () => {
      this._isOnline = false;
    });

    try {
      const netHandle: connection.NetHandle = connection.getDefaultNetSync();
      if (netHandle && netHandle.netId > 0) {
        this._isOnline = true;
      } else {
        this._isOnline = false;
      }
    } catch (e) {
      this._isOnline = false;
    }
  }

  public unregister(): void {
    if (this.netConnection) {
      this.netConnection.unregister(() => {});
      this.netConnection = null;
    }
    if (this.recoveryTimer) {
      clearTimeout(this.recoveryTimer);
      this.recoveryTimer = 0;
    }
  }

  public scheduleRecoveryCheck(callback: () => void, delayMs: number): void {
    if (this.recoveryTimer) {
      clearTimeout(this.recoveryTimer);
    }
    this.recoveryTimer = setTimeout(() => {
      this.recoveryTimer = 0;
      if (this._isOnline) {
        callback();
      }
    }, delayMs);
  }
}
