/*
 Navicat Premium Data Transfer

 Source Server         : localhost_3306
 Source Server Type    : MySQL
 Source Server Version : 50718
 Source Host           : localhost:3306
 Source Schema         : apprentice

 Target Server Type    : MySQL
 Target Server Version : 50718
 File Encoding         : 65001

 Date: 25/10/2021 10:45:17
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `email` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '邮箱',
  `user_name` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '用户名',
  `password` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '密码',
  `role_id` int(11) NULL DEFAULT NULL COMMENT '用户角色',
  `photo` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '用户头像地址',
  `status` int(11) NULL DEFAULT 1 COMMENT '用户状态 1 启用 2 停止',
  `register_date` datetime(0) NULL DEFAULT NULL COMMENT '用户注册时间',
  `contact_no` varchar(11) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '联系方式',
  `del_flag` int(11) NULL DEFAULT 0 COMMENT '0 存在，1 删除',
  `create_time` datetime(0) NULL DEFAULT NULL,
  `update_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP(0),
  `nickname` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '昵称',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES (1, NULL, 'fugui', '123', 2, NULL, 1, NULL, NULL, 0, NULL, '2021-10-25 10:44:35', NULL);
INSERT INTO `user` VALUES (2, NULL, 'admin', '123', 1, NULL, 1, NULL, NULL, 0, NULL, '2021-10-23 15:53:43', NULL);
INSERT INTO `user` VALUES (4, NULL, 'wangfugui', '$2a$10$gpq7aq5CM0JijheXM7M53.SaM/5t6JZFa9oTH3HfMIJ3fgT4BWTYO', 1, NULL, 1, NULL, NULL, 0, NULL, '2021-10-25 10:44:40', NULL);

SET FOREIGN_KEY_CHECKS = 1;
