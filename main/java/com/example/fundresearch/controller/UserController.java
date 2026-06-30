package com.example.fundresearch.controller;

import com.example.fundresearch.common.Result;
import com.example.fundresearch.dto.request.AuthRequest;
import com.example.fundresearch.entity.User;
import com.example.fundresearch.service.FundService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * 用户控制器
 *
 * 提供接口：
 * - POST /api/user/register  用户注册
 * - POST /api/user/login     用户登录
 */
@RestController
@RequestMapping("/api/user")
public class UserController {

    private final FundService fundService;

    public UserController(FundService fundService) {
        this.fundService = fundService;
    }

    /**
     * 用户注册
     *
     * POST /api/user/register
     * 请求体：{ "username": "test", "password": "123456" }
     *
     * 注册成功后自动跳转登录页（前端实现）
     */
    @PostMapping("/register")
    public Result<User> register(@Valid @RequestBody AuthRequest request) {
        User user = fundService.register(request.getUsername(), request.getPassword());
        user.setPassword(null);
        return Result.success("注册成功", user);
    }

    /**
     * 用户登录
     *
     * POST /api/user/login
     * 请求体：{ "username": "test", "password": "123456" }
     *
     * 返回：{ userId, username }
     * 前端保存 userId 到 localStorage，后续组合接口通过参数传递
     */
    @PostMapping("/login")
    public Result<Map<String, Object>> login(@Valid @RequestBody AuthRequest request) {
        User user = fundService.login(request.getUsername(), request.getPassword());
        Map<String, Object> result = new HashMap<>();
        result.put("userId", user.getId());
        result.put("username", user.getUsername());
        return Result.success("登录成功", result);
    }
}
