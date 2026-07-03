package com.example.fundresearch.controller;

import com.example.fundresearch.common.Result;
import com.example.fundresearch.dto.request.ChatRequest;
import com.example.fundresearch.service.FundService;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.Map;

/**
 * AI 智能问答控制器
 *
 * 提供接口：
 * - POST /api/ai/chat  用户提问，AI 回答
 *
 * 当前为模拟实现（返回固定话术），
 * 正式接入 Dify + DeepSeek 时修改 FundServiceImpl.chat() 方法即可。
 */
@RestController
@RequestMapping("/api/ai")
public class AiChatController {

    private final FundService fundService;

    public AiChatController(FundService fundService) {
        this.fundService = fundService;
    }

    /**
     * AI 对话
     *
     * POST /api/ai/chat
     * 请求体：{ "message": "沪深300指数近一年表现如何？" }
     * 返回：{ "code": 200, "data": { "reply": "..." } }
     */
    @PostMapping("/chat")
    public Result<Map<String, String>> chat(@RequestBody @Valid ChatRequest request) {
        String reply = fundService.chat(request.getMessage());
        Map<String, String> result = new java.util.HashMap<>();
        result.put("reply", reply);
        return Result.success(result);
    }
}
