package com.example.fundresearch.controller;

import com.example.fundresearch.common.BusinessException;
import com.example.fundresearch.common.Result;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class TestController {

    @GetMapping("/test-success")
    public Result<String> testSuccess() {
        return Result.success("Hello, this is a success response!");
    }

    @GetMapping("/test-error")
    public Result<?> testError() {
        // 模拟业务异常
        throw new BusinessException(400, "参数错误演示");
    }

    @GetMapping("/test-system-error")
    public Result<?> testSystemError() {
        // 模拟系统异常
        int a = 1 / 0;   // 抛出 ArithmeticException
        return Result.success("ok");
    }
}


