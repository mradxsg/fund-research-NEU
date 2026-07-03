import { http } from '@kit.NetworkKit'
import { AppCache } from './storage/AppCache'

export class HttpClient {
  private static _baseUrl: string = 'http://10.38.162.203:8080'

  static async initBaseUrl(): Promise<void> {
    HttpClient._baseUrl = await AppCache.getBaseUrl()
  }

  static async setBaseUrl(url: string): Promise<void> {
    HttpClient._baseUrl = url
    await AppCache.setBaseUrl(url)
  }

  static getBaseUrl(): string {
    return HttpClient._baseUrl
  }

  private static buildUrl(path: string, params?: Record<string, string>): string {
    let url: string = HttpClient._baseUrl + path
    if (params != null) {
      const parts: string[] = []
      const keys: string[] = Object.keys(params)
      for (let i = 0; i < keys.length; i++) {
        const k: string = keys[i]
        const v: Object | undefined = params[k]
        if (v != null && v !== '') {
          parts.push(k + '=' + encodeURIComponent(String(v)))
        }
      }
      if (parts.length > 0) {
        url = url + '?' + parts.join('&')
      }
    }
    return url
  }

  static async get<T>(path: string, params?: Record<string, string>): Promise<T | null> {
    return HttpClient.request<T>('GET', path, params, undefined)
  }

  static async post<T>(path: string, body?: Object): Promise<T | null> {
    return HttpClient.request<T>('POST', path, undefined, body)
  }

  static async put<T>(path: string, body?: Object): Promise<T | null> {
    return HttpClient.request<T>('PUT', path, undefined, body)
  }

  static async delete<T>(path: string): Promise<T | null> {
    return HttpClient.request<T>('DELETE', path, undefined, undefined)
  }

  private static async request<T>(
    method: string, path: string,
    params?: Record<string, string>,
    body?: Object
  ): Promise<T | null> {
    const url: string = HttpClient.buildUrl(path, params)
    const httpRequest: http.HttpRequest = http.createHttp()
    try {
      const option: http.HttpRequestOptions = {
        method: method as http.RequestMethod,
        header: { 'Content-Type': 'application/json' },
        connectTimeout: 10000,
        readTimeout: 15000
      }
      if (body != null) {
        option.extraData = JSON.stringify(body)
      }
      const resp: http.HttpResponse = await httpRequest.request(url, option)
      if (resp.responseCode >= 200 && resp.responseCode < 300) {
        const result: T = JSON.parse(resp.result as string) as T
        return result
      }
      // 即使出错也尝试解析响应体（后端返回了结构化的错误信息）
      try {
        const result: T = JSON.parse(resp.result as string) as T
        return result
      } catch (_) {
        console.error('HTTP ' + method + ' ' + url + ' -> ' + resp.responseCode)
        return null
      }
    } catch (e) {
      console.error('HTTP ' + method + ' ' + url + ' failed: ' + JSON.stringify(e))
      return null
    } finally {
      httpRequest.destroy()
    }
  }
}


