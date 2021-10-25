## **写在前面：**

最近有一个想法，做一个程序员师徒管理系统。因为在大学期间的我在学习java的时候非常地迷茫，找不到自己的方向，也没有一个社会上有经验的前辈去指导，所以走了很多的弯路。后来工作了，想把自己的避坑经验分享给别人，但是发现身边都是有经验的开发者，也没有机会去分享自己的想法，所以富贵同学就想做一个程序员专属的师徒系统，秉承着徒弟能够有人指教少走弯路，师傅能桃李满天下的目的，所以开始做这个师徒系统，也会同步更新该系统所用到的技术，并且作为教程分享给大家，希望大家能够关注一波。
![请添加图片描述](https://img-blog.csdnimg.cn/93ce07a15e6c4ed2a125e4bd2d194e52.jpg)
好的，接下来给大家讲一讲改系统中安全模块用到的技术：SpringSecurity，用SpringBoot整合SpringSecurity。

## 1.首先我们需要创建一个用户表和角色表：

```sql
CREATE TABLE `user` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `email` varchar(100) DEFAULT NULL COMMENT '邮箱',
  `user_name` varchar(20) DEFAULT NULL COMMENT '用户名',
  `password` varchar(255) DEFAULT NULL COMMENT '密码',
  `role_id` int(11) DEFAULT NULL COMMENT '用户角色',
  `photo` varchar(100) DEFAULT NULL COMMENT '用户头像地址',
  `status` int(11) DEFAULT '1' COMMENT '用户状态 1 启用 2 停止',
  `register_date` datetime DEFAULT NULL COMMENT '用户注册时间',
  `contact_no` varchar(11) DEFAULT NULL COMMENT '联系方式',
  `del_flag` int(11) DEFAULT '0' COMMENT '0 存在，1 删除',
  `create_time` datetime DEFAULT NULL,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `nickname` varchar(255) DEFAULT NULL COMMENT '昵称',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
```

```sql
CREATE TABLE `role` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `role_name` varchar(50) DEFAULT NULL COMMENT '角色名称',
  `sort` int(11) DEFAULT NULL,
  `role_desc` varchar(50) DEFAULT NULL COMMENT '角色描述',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COMMENT='平台角色表';
```

## 2.导入pml依赖：

**SpringSecurity+web**
```xml
 	    <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
```
**同时我们需要用到MybatisPlus：**

```xml
        <!--Mybatis-Plus-->
        <dependency>
            <groupId>com.baomidou</groupId>
            <artifactId>mybatis-plus-boot-starter</artifactId>
            <version>3.4.2</version>
        </dependency>
        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <version>1.18.22</version>
            <scope>provided</scope>
        </dependency>
```
还有yml文件的配置：

```xml
server:
  port: 8080
# DataSource Config
spring:
  datasource:
    driver-class-name: com.mysql.cj.jdbc.Driver
    url: jdbc:mysql://127.0.0.1:3306/apprentice?serverTimezone=PRC
    username: root
    password: 123456
mybatis-plus:
  configuration:
    log-impl: org.apache.ibatis.logging.stdout.StdOutImpl
```

基本的配置已经好了，做这个时候我们启动服务访问`localhost:8080`就会跳转到springsecurity自带的登录界面，用户默认为`user`,密码会从控制台输出一串`随机字符串`。

## 3.那么问题来了，我该怎么样从我们的数据库中读取用户的username和password呢？
*第一步：首先编写domain类：*
**用户：**

```java
@Data
public class User {

    @TableId(type = IdType.AUTO)
    private Integer id;
    private String email;
    private String userName;
    private String password;
    private String photo;
    private Integer status;
    private Date registerDate;
    private String contactNo;
    private Integer delFlag;
    private Date createTime;
    private Date updateTime;
    private String nickname;
    private Integer roleId;

}
```
**角色：**
```java
@Data
public class Role {
    private Long id;
    private String roleName;
    private Integer sort;
    private String roleDesc;
}
```
*第二步，在springsecurity中有一个类会在登录的时候获取用户的username和password，这个时候我们需要重写这个类：*

```java

@Component
public class CustomUserDetailsService implements UserDetailsService {
    @Autowired
    private UserService userInfoService;
    @Autowired
    private RoleService roleService;

    /**
     * 需新建配置类注册一个指定的加密方式Bean，或在下一步Security配置类中注册指定
     */
    @Autowired
    private PasswordEncoder passwordEncoder;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        // 通过用户名从数据库获取用户信息
        User userInfo = userInfoService.getUserInfo(username);
        if (userInfo == null) {
            throw new UsernameNotFoundException("用户不存在");
        }

        // 得到用户角色
        Integer roleId = userInfo.getRoleId();
        String role = roleService.getUserRole(roleId);


        // 角色集合
        List<GrantedAuthority> authorities = new ArrayList<>();
        // 角色必须以`ROLE_`开头，数据库中没有，则在这里加
        authorities.add(new SimpleGrantedAuthority("ROLE_" + role));

        return new org.springframework.security.core.userdetails.User(
                userInfo.getUserName(),
                userInfo.getPassword(),
                authorities
        );
    }
}
```
这里有一个特别细的点：
![请添加图片描述](https://img-blog.csdnimg.cn/129cfdda5aa943ccafa2d5bc387e6283.jpg)

```java
  return new org.springframework.security.core.userdetails.User(
                userInfo.getUserName(),
                userInfo.getPassword(),
                authorities
        );
```
**这块**：   `userInfo.getPassword()` ，现在我们没有注册用户的功能，所以数据库存储的是明文字段，这个时候我们需要把这句替换为`    passwordEncoder.encode(userInfo.getPassword()),`！！

*第三步：随后我们新增一个配置类：WebSecurityConfig* 

```java
@EnableWebSecurity
public class WebSecurityConfig extends WebSecurityConfigurerAdapter {

    @Autowired
    private CustomUserDetailsService userDatailService;

    /**
     * 指定加密方式
     */
    @Bean
    public PasswordEncoder passwordEncoder() {
        // 使用BCrypt加密密码
        return new BCryptPasswordEncoder();
    }

    @Override
    protected void configure(AuthenticationManagerBuilder auth) throws Exception {
        auth
                // 从数据库读取的用户进行身份认证
                .userDetailsService(userDatailService)
                .passwordEncoder(passwordEncoder());
    }
}
```

好了，接下来就可以使用我们user表里面的username和password登录系统了。

## 哦对了！`userInfoService，roleService`这些基础的代码就在我的gitee仓库里面了。
![请添加图片描述](https://img-blog.csdnimg.cn/79898e1e809244afa483122b0211a448.jpg)
仓库地址：[这呢这呢](https://gitee.com/WangFuGui-Ma/spring-security-spring-boot)

## 到了这步了还不简单？？？
登录解决了，看看注册：

```java
  public ResultUtils insertUser(User userInfo){
        // 加密密码
        userInfo.setPassword(passwordEncoder.encode(userInfo.getPassword()));
        return ResultUtils.success(userMapper.insert(userInfo));
    }
```
富贵同学：这个很简单哈，添加用户的时候加密密码就好了啊！！！
注册解决了，更新密码还会远吗？

```java
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
```

## 4.好了，我们来讲最后一步，权限模块：

```java
   @PreAuthorize("hasAnyRole('test')") // 只能test角色才能访问该方法
    @GetMapping("/test")
    public String test(){
        return "test角色访问";
    }

    @PreAuthorize("hasAnyRole('admin')") // 只能admin角色才能访问该方法
    @GetMapping("/admin")
    public String admin(){
        return "admin角色访问";
    }
```
这个controller里面的两个接口。
我们需要  `@PreAuthorize("hasAnyRole('test')")` 来定义该接口的权限。
这个时候我们只需要在user表里面的`role_id`字段添加用户角色id就行了。

## 哦！对了！！
![请添加图片描述](https://img-blog.csdnimg.cn/2e1ec6d7f07c4a8fa9844f4e0d8d2724.jpg)
这里是数据表的数据！！！大家可以测试一下

```java
INSERT INTO `role` VALUES (1, 'admin', NULL, NULL);
INSERT INTO `role` VALUES (2, 'test', NULL, NULL);

INSERT INTO `user` VALUES (1, NULL, 'fugui', '123', 2, NULL, 1, NULL, NULL, 0, NULL, '2021-10-25 10:44:35', NULL);
INSERT INTO `user` VALUES (2, NULL, 'admin', '123', 1, NULL, 1, NULL, NULL, 0, NULL, '2021-10-23 15:53:43', NULL);
INSERT INTO `user` VALUES (4, NULL, 'wangfugui', '$2a$10$gpq7aq5CM0JijheXM7M53.SaM/5t6JZFa9oTH3HfMIJ3fgT4BWTYO', 1, NULL, 1, NULL, NULL, 0, NULL, '2021-10-25 10:44:40', NULL);
```

## 说在之后
师徒系统我会一直更新，因为是开源的项目，所以我也希望又更多的小伙伴加入进来！！
这是程序员师徒管理系统的地址：
[程序员师徒管理系统](https://gitee.com/WangFuGui-Ma/Programmer-Apprentice)
![在这里插入图片描述](https://img-blog.csdnimg.cn/23eefccf438f4aaeb5a143f1db1f0fa7.png?x-oss-process=image/watermark,type_ZHJvaWRzYW5zZmFsbGJhY2s,shadow_50,text_Q1NETiBAY3NkbmVyTQ==,size_16,color_FFFFFF,t_70,g_se,x_16)