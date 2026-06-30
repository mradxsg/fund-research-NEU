package com.example.fundresearch.common;

import com.fasterxml.jackson.annotation.JsonInclude;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class Result<T> {

    private int code;
    private String message;
    private T data;
    private long timestamp;

    public Result() {}

    public Result(int code, String message, T data) {
        this.code = code;
        this.message = message;
        this.data = data;
        this.timestamp = System.currentTimeMillis();
    }

    // ---------- 成功 ----------
    public static <T> Result<T> success(T data) {
        return new Result<>(200, "success", data);
    }

    public static <T> Result<T> success(String message, T data) {
        return new Result<>(200, message, data);
    }

    public static <T> Result<T> ok() {
        return new Result<>(200, "success", null);
    }

    // ---------- 客户端错误 ----------
    public static <T> Result<T> badRequest(String message) {
        return new Result<>(400, message, null);
    }

    public static <T> Result<T> unauthorized(String message) {
        return new Result<>(401, message, null);
    }

    public static <T> Result<T> notFound(String message) {
        return new Result<>(404, message, null);
    }

    public static <T> Result<T> conflict(String message) {
        return new Result<>(409, message, null);
    }

    // ---------- 服务器错误 ----------
    public static <T> Result<T> error(String message) {
        return new Result<>(500, message, null);
    }

    // ★ 新增：支持自定义错误码（用于 BusinessException）
    public static <T> Result<T> error(int code, String message) {
        return new Result<>(code, message, null);
    }

    // ---------- getters / setters ----------
    public int getCode() { return code; }
    public void setCode(int code) { this.code = code; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public T getData() { return data; }
    public void setData(T data) { this.data = data; }

    public long getTimestamp() { return timestamp; }
    public void setTimestamp(long timestamp) { this.timestamp = timestamp; }
}




