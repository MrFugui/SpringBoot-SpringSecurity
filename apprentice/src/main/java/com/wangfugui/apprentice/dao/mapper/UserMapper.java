package com.wangfugui.apprentice.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.UpdateWrapper;
import com.wangfugui.apprentice.common.util.ResultUtils;
import com.wangfugui.apprentice.dao.domain.User;
import com.wangfugui.apprentice.dao.mapper.UserMapper;
import com.wangfugui.apprentice.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * @author MaSiyi
 * @version 1.0.0 2021/10/23
 * @since JDK 1.8.0
 */
@Service
public class UserServiceImpl implements UserService{

    @Autowired
    private UserMapper userMapper;
    @Autowired
    private PasswordEncoder passwordEncoder;

    @Override
    public ResultUtils listUser() {
        List<User> users = userMapper.selectList(null);
        return ResultUtils.success(users);
    }

    @Override
    public User getUserInfo(String username){
        QueryWrapper<User> objectQueryWrapper = new QueryWrapper<>();
        objectQueryWrapper.eq("user_name",username);
        return userMapper.selectOne(objectQueryWrapper);
    }

    @Override
    public ResultUtils insertUser(User userInfo){
        // 加密密码
        userInfo.setPassword(passwordEncoder.encode(userInfo.getPassword()));
        return ResultUtils.success(userMapper.insert(userInfo));
    }

    @Override
    public ResultUtils updatePwd(String oldPwd, String newPwd) {
        // 获取当前登录用户信息(注意：没有密码的)
        UserDetails principal = (UserDetails) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        String username = principal.getUsername();

        // 通过用户名获取到用户信息（获取密码）
        User userInfo = this.getUserInfo(username);

        // 判断输入的旧密码是正确
        if (passwordEncoder.matches(oldPwd, userInfo.getPassword())) {
            UpdateWrapper<User> wrapper = new UpdateWrapper<>();
            wrapper.lambda().eq(User::getUserName, username);
            //加密新密码
            String encode = passwordEncoder.encode(newPwd);
            userInfo.setPassword(encode);
            userMapper.update(userInfo, wrapper);
        }
        return ResultUtils.success();
    }

}
