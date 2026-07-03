package com.example.fundresearch.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.example.fundresearch.entity.User;
import com.example.fundresearch.mapper.UserMapper;
import com.example.fundresearch.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
public class UserServiceImpl implements UserService {

    @Autowired
    private UserMapper userMapper;

    @Override
    public User register(String username, String password) {
        if (userMapper.selectCount(new LambdaQueryWrapper<User>().eq(User::getUsername, username)) > 0) {
            throw new RuntimeException("用户名已存在");
        }
        User user = new User();
        user.setUsername(username);
        user.setPassword(password);
        user.setNickname(username); // 默认昵称 = 用户名
        user.setCreateTime(LocalDateTime.now());
        userMapper.insert(user);
        return user;
    }

    @Override
    public User login(String username, String password) {
        User user = userMapper.selectOne(new LambdaQueryWrapper<User>().eq(User::getUsername, username));
        if (user == null || !user.getPassword().equals(password)) {
            throw new RuntimeException("用户名或密码错误");
        }
        return user;
    }

    @Override
    public User findByUsername(String username) {
        return userMapper.selectOne(new LambdaQueryWrapper<User>().eq(User::getUsername, username));
    }

    @Override
    public User getUserById(Long userId) {
        return userMapper.selectById(userId);
    }

    @Override
    public void updateNickname(Long userId, String nickname) {
        User user = userMapper.selectById(userId);
        if (user == null) throw new RuntimeException("用户不存在");
        user.setNickname(nickname);
        userMapper.updateById(user);
    }

    @Override
    public void changePassword(Long userId, String oldPassword, String newPassword) {
        User user = userMapper.selectById(userId);
        if (user == null || !user.getPassword().equals(oldPassword)) {
            throw new RuntimeException("原密码错误");
        }
        user.setPassword(newPassword);
        userMapper.updateById(user);
    }
}