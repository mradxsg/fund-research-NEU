package com.example.fundresearch.service;

import com.example.fundresearch.entity.User;

public interface UserService {
    User register(String username, String password);
    User login(String username, String password);
    User findByUsername(String username);

    // ---- 新方法 ----
    User getUserById(Long userId);
    void updateNickname(Long userId, String nickname);
    void changePassword(Long userId, String oldPassword, String newPassword);
}