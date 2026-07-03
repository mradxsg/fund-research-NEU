package com.example.fundresearch.controller;

import com.example.fundresearch.common.Result;
import com.example.fundresearch.entity.User;
import com.example.fundresearch.mapper.UserMapper;
import com.example.fundresearch.service.FundService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/user")
public class UserController {

    @Autowired
    private FundService fundService;

    @Autowired
    private UserMapper userMapper;

    // 注册
    @PostMapping("/register")
    public Result<?> register(@RequestBody Map<String, String> body) {
        String username = body.get("username");
        String password = body.get("password");
        if (username == null || password == null || username.isEmpty() || password.isEmpty()) {
            return Result.error(400, "用户名和密码不能为空");
        }
        try {
            fundService.register(username, password);
            return Result.success("注册成功", null);
        } catch (RuntimeException e) {
            return Result.error(400, e.getMessage());
        }
    }

    // 登录
    @PostMapping("/login")
    public Result<?> login(@RequestBody Map<String, String> body) {
        String username = body.get("username");
        String password = body.get("password");
        try {
            User user = fundService.login(username, password);
            Map<String, Object> data = new HashMap<>();
            data.put("userId", user.getId());
            data.put("username", user.getUsername());
            return Result.success("登录成功", data);
        } catch (RuntimeException e) {
            return Result.error(400, e.getMessage());
        }
    }

    // 获取个人信息
    @GetMapping("/profile")
    public Result<?> getProfile(@RequestParam Long userId) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            return Result.error(404, "用户不存在");
        }
        Map<String, Object> data = new HashMap<>();
        data.put("id", user.getId());
        data.put("username", user.getUsername());
        data.put("nickname", user.getNickname() != null ? user.getNickname() : user.getUsername());
        return Result.success(data);
    }
}

