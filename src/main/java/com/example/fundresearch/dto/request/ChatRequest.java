package com.example.fundresearch.dto.request;

import jakarta.validation.constraints.NotBlank;

/**
 * AI 聊天请求
 */
public class ChatRequest {

    @NotBlank(message = "消息不能为空")
    private String message;

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
}
