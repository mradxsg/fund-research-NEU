/*
 Navicat Premium Data Transfer

 Source Server         : NEU
 Source Server Type    : MySQL
 Source Server Version : 80045 (8.0.45)
 Source Host           : localhost:3306
 Source Schema         : fund_db

 Target Server Type    : MySQL
 Target Server Version : 80045 (8.0.45)
 File Encoding         : 65001

 Date: 23/06/2026 19:12:22
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for fund_announcement
-- ----------------------------
DROP TABLE IF EXISTS `fund_announcement`;
CREATE TABLE `fund_announcement`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `fund_id` bigint NOT NULL,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '公告标题',
  `publish_date` date NULL DEFAULT NULL COMMENT '公告日期',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_announcement_fund`(`fund_id` ASC) USING BTREE,
  CONSTRAINT `fund_announcement_ibfk_1` FOREIGN KEY (`fund_id`) REFERENCES `fund_info` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '基金公告表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of fund_announcement
-- ----------------------------

-- ----------------------------
-- Table structure for fund_company
-- ----------------------------
DROP TABLE IF EXISTS `fund_company`;
CREATE TABLE `fund_company`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '基金公司表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of fund_company
-- ----------------------------

-- ----------------------------
-- Table structure for fund_info
-- ----------------------------
DROP TABLE IF EXISTS `fund_info`;
CREATE TABLE `fund_info`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '基金类型：股票型/混合型/债券型/货币型/指数型',
  `scale` decimal(15, 2) NULL DEFAULT NULL COMMENT '规模（亿元）',
  `establish_date` date NULL DEFAULT NULL COMMENT '成立日期',
  `company_id` bigint NULL DEFAULT NULL COMMENT '所属公司ID',
  `manager_id` bigint NULL DEFAULT NULL COMMENT '基金经理ID',
  `risk_level` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '风险等级',
  `benchmark` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '跟踪指数',
  `attribution_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '业绩归因文本（静态）',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `code`(`code` ASC) USING BTREE,
  INDEX `idx_fund_info_company`(`company_id` ASC) USING BTREE,
  INDEX `idx_fund_info_manager`(`manager_id` ASC) USING BTREE,
  INDEX `idx_fund_info_type`(`type` ASC) USING BTREE,
  CONSTRAINT `fund_info_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `fund_company` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `fund_info_ibfk_2` FOREIGN KEY (`manager_id`) REFERENCES `fund_manager` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '基金基本信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of fund_info
-- ----------------------------

-- ----------------------------
-- Table structure for fund_manager
-- ----------------------------
DROP TABLE IF EXISTS `fund_manager`;
CREATE TABLE `fund_manager`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `experience_years` int NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '基金经理表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of fund_manager
-- ----------------------------

-- ----------------------------
-- Table structure for fund_nav
-- ----------------------------
DROP TABLE IF EXISTS `fund_nav`;
CREATE TABLE `fund_nav`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `fund_id` bigint NOT NULL,
  `date` date NOT NULL,
  `unit_nav` decimal(8, 4) NULL DEFAULT NULL COMMENT '单位净值',
  `accum_nav` decimal(8, 4) NULL DEFAULT NULL COMMENT '累计净值',
  `daily_return` decimal(6, 2) NULL DEFAULT NULL COMMENT '日涨跌幅(%)',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_fund_nav_fund`(`fund_id` ASC) USING BTREE,
  INDEX `idx_fund_nav_date`(`date` ASC) USING BTREE,
  CONSTRAINT `fund_nav_ibfk_1` FOREIGN KEY (`fund_id`) REFERENCES `fund_info` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '基金净值历史表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of fund_nav
-- ----------------------------

-- ----------------------------
-- Table structure for fund_sector
-- ----------------------------
DROP TABLE IF EXISTS `fund_sector`;
CREATE TABLE `fund_sector`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `fund_id` bigint NOT NULL,
  `sector_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '行业名称',
  `ratio` decimal(5, 2) NULL DEFAULT NULL COMMENT '占比(%)',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_fund_sector_fund`(`fund_id` ASC) USING BTREE,
  CONSTRAINT `fund_sector_ibfk_1` FOREIGN KEY (`fund_id`) REFERENCES `fund_info` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '基金行业配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of fund_sector
-- ----------------------------

-- ----------------------------
-- Table structure for fund_stock
-- ----------------------------
DROP TABLE IF EXISTS `fund_stock`;
CREATE TABLE `fund_stock`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `fund_id` bigint NOT NULL,
  `stock_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '股票名称',
  `ratio` decimal(5, 2) NULL DEFAULT NULL COMMENT '占比(%)',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_fund_stock_fund`(`fund_id` ASC) USING BTREE,
  CONSTRAINT `fund_stock_ibfk_1` FOREIGN KEY (`fund_id`) REFERENCES `fund_info` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '基金前十大重仓股表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of fund_stock
-- ----------------------------

-- ----------------------------
-- Table structure for fund_tag
-- ----------------------------
DROP TABLE IF EXISTS `fund_tag`;
CREATE TABLE `fund_tag`  (
  `fund_id` bigint NOT NULL,
  `tag_id` bigint NOT NULL,
  PRIMARY KEY (`fund_id`, `tag_id`) USING BTREE,
  INDEX `idx_fund_tag_fund`(`fund_id` ASC) USING BTREE,
  INDEX `idx_fund_tag_tag`(`tag_id` ASC) USING BTREE,
  CONSTRAINT `fund_tag_ibfk_1` FOREIGN KEY (`fund_id`) REFERENCES `fund_info` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fund_tag_ibfk_2` FOREIGN KEY (`tag_id`) REFERENCES `tag` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '基金-标签关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of fund_tag
-- ----------------------------

-- ----------------------------
-- Table structure for portfolio
-- ----------------------------
DROP TABLE IF EXISTS `portfolio`;
CREATE TABLE `portfolio`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `created_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_portfolio_user`(`user_id` ASC) USING BTREE,
  CONSTRAINT `portfolio_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '基金组合表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of portfolio
-- ----------------------------

-- ----------------------------
-- Table structure for portfolio_item
-- ----------------------------
DROP TABLE IF EXISTS `portfolio_item`;
CREATE TABLE `portfolio_item`  (
  `portfolio_id` bigint NOT NULL,
  `fund_id` bigint NOT NULL,
  PRIMARY KEY (`portfolio_id`, `fund_id`) USING BTREE,
  INDEX `idx_portfolio_item_fund`(`fund_id` ASC) USING BTREE,
  CONSTRAINT `portfolio_item_ibfk_1` FOREIGN KEY (`portfolio_id`) REFERENCES `portfolio` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `portfolio_item_ibfk_2` FOREIGN KEY (`fund_id`) REFERENCES `fund_info` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '组合持仓明细表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of portfolio_item
-- ----------------------------

-- ----------------------------
-- Table structure for tag
-- ----------------------------
DROP TABLE IF EXISTS `tag`;
CREATE TABLE `tag`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `dimension` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '适用维度：fund/company/manager',
  `parent_id` bigint NULL DEFAULT NULL COMMENT '父标签ID，可空',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `parent_id`(`parent_id` ASC) USING BTREE,
  CONSTRAINT `tag_ibfk_1` FOREIGN KEY (`parent_id`) REFERENCES `tag` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '标签主表（支持多级层级）' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of tag
-- ----------------------------

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户表（简化版）' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user
-- ----------------------------

SET FOREIGN_KEY_CHECKS = 1;
