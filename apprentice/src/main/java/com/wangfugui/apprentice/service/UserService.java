package com.wangfugui.apprentice.service;

import com.wangfugui.apprentice.common.util.ResultUtils;
import com.wangfugui.apprentice.dao.domain.User;

/**
 * @author MaSiyi
 * @version 1.0.0 2021/10/23
 * @since JDK 1.8.0
 */
public interface UserService {
    ResultUtils listUser();

    User getUserInfo(String username);

    ResultUtils insertUser(User userInfo);

    ResultUtils updatePwd(String oldPwd, String newPwd);
}
