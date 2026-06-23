package com.example.fundresearch.common;

/**
 * 业务异常，用于主动抛出可预知的错误
 */
public class BusinessException extends RuntimeException {
    private int code;

    public BusinessException(int code, String message) {
        super(message);
        this.code = code;
    }
    public int getCode() {
        return code;
    }
}


