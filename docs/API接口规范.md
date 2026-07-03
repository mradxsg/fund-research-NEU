# 基金研究子系统 API 接口规范

## 通用说明
- 基础地址：`http://localhost:8080`
- 所有返回数据格式为 JSON
- 统一返回结构：
```json
{
  "code": 200,
  "message": "success",
  "data": { ... }
}
```
- code 值含义：200=成功，400=参数错误，401=未登录，404=不存在，500=服务器错误
- 需要登录的接口需在请求参数中携带 `userId`

---

## 1. 用户模块

### 1.1 用户注册
- **接口**：POST `/api/user/register`
- **请求体**：
```json
{
  "username": "testuser",
  "password": "123456"
}
```
- **成功返回**：
```json
{
  "code": 200,
  "message": "注册成功",
  "data": null
}
```

### 1.2 用户登录
- **接口**：POST `/api/user/login`
- **请求体**：
```json
{
  "username": "test01",
  "password": "999999"
}
```
- **成功返回**：
```json
{
  "code": 200,
  "data": {
    "userId": 1,
    "username": "test01"
  }
}
```

---

## 2. 标签模块

### 2.1 获取标签树
- **接口**：GET `/api/tags?dimension=fund`
- **参数**：dimension 取值 fund / company / manager
- **成功返回**：
```json
{
  "code": 200,
  "data": [
    {
      "id": 1,
      "name": "基金类型",
      "parentId": null,
      "children": [
        { "id": 4, "name": "股票型", "parentId": 1, "children": [] }
      ]
    }
  ]
}
```

---

## 3. 基金查询模块

### 3.1 基金列表查询
- **接口**：GET `/api/funds`
- **参数**：
  - keyword：基金代码或名称关键字
  - tagIds：标签ID，多个用逗号分隔，如 `4,12`
  - page：页码，默认 0
- **成功返回**：参考文档其余部分

### 3.2 基金画像
- **接口**：GET `/api/funds/{id}`
- **返回**：包含基本信息、净值走势、行业配置、持仓、公告等完整数据

### 3.3 鸿蒙净值查询
- **接口**：GET `/api/funds/code/{code}`
- **返回**：基金代码、名称、单位净值、日涨跌幅

---

## 4. 基金公司模块

### 4.1 公司列表
- **接口**：GET `/api/companies?keyword=&page=0`

### 4.2 公司旗下基金
- **接口**：GET `/api/companies/{id}/funds`

---

## 5. 基金经理模块

### 5.1 经理列表
- **接口**：GET `/api/managers?keyword=&page=0`

### 5.2 经理管理的基金
- **接口**：GET `/api/managers/{id}/funds`

---

## 6. 组合管理模块（需登录）

### 6.1 创建组合
- **接口**：POST `/api/portfolios`
- **请求体**：`{ "userId": 1, "name": "我的组合", "fundIds": [1,2,3] }`

### 6.2 组合列表
- **接口**：GET `/api/portfolios?userId=1`

### 6.3 组合详情
- **接口**：GET `/api/portfolios/{id}`

### 6.4 删除组合
- **接口**：DELETE `/api/portfolios/{id}`

---

## 7. AI 对话模块

### 7.1 提问
- **接口**：POST `/api/ai/chat`
- **请求体**：`{ "message": "什么是夏普比率？" }`
- **成功返回**：
```json
{
  "code": 200,
  "data": {
    "reply": "夏普比率是衡量基金风险调整后收益的指标……"
  }
}
```
