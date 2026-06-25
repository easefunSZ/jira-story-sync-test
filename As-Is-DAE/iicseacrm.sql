-- MySQL dump 10.13  Distrib 8.0.45, for Win64 (x86_64)
--
-- Host: ominteg-mysql.ctevlbtoyoz8.eu-west-1.rds.amazonaws.com    Database: iicseacrm
-- ------------------------------------------------------
-- Server version	8.4.7

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `iic_crm_agent_customer_statistical`
--

DROP TABLE IF EXISTS `iic_crm_agent_customer_statistical`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_agent_customer_statistical` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint DEFAULT NULL COMMENT '租户id',
  `agent_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '代理人id',
  `customer_sum` bigint DEFAULT NULL COMMENT '客户总数',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` varchar(50) NOT NULL DEFAULT 'SYSTEM',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by` varchar(50) NOT NULL DEFAULT 'SYSTEM',
  `record_date` date DEFAULT NULL COMMENT '统计日期',
  `dae_country_code` varchar(20) DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `attended` bigint DEFAULT '0' COMMENT 'category=attended的客户总数',
  `un_attended` bigint DEFAULT '0' COMMENT 'category=unattended的客户总数',
  `created_by_login_user` varchar(50) DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `customer_statistical_agent_record_date_index` (`agent_id`,`record_date`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=11690651 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='代理人所属客户统计表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_app_deploy_management`
--

DROP TABLE IF EXISTS `iic_crm_app_deploy_management`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_app_deploy_management` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `app_version` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '版本号',
  `build_version` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'build版本号',
  `min_compatible_version` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '兼容的app最低版本',
  `platform_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '表示android 和ios',
  `release_notes` varchar(5000) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '更新提示语',
  `file_key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'iobs的fileKey',
  `package_size` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '安装包大小',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `download_url` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '下载链接',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=49 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='版本更新记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_attach_info`
--

DROP TABLE IF EXISTS `iic_crm_attach_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_attach_info` (
  `id` bigint unsigned NOT NULL,
  `file_type` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `file_key` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `file_name` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `file_size` bigint unsigned NOT NULL,
  `status` varchar(2) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '0(草稿) 1(提交)',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT 'SYSTEM',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT 'SYSTEM',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `dae_country_code` varchar(20) DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='附件表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_b2b_base_dict`
--

DROP TABLE IF EXISTS `iic_crm_b2b_base_dict`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_b2b_base_dict` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `name` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '字典名称',
  `type` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '类型: 1 Industry, 2 Sector, 3 Telephone Number Type,4 Email Type,5 Role',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户id',
  `is_delete` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '是否删除1是0否',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=85 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='b2b基础字典表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_b2b_brm_branch_details`
--

DROP TABLE IF EXISTS `iic_crm_b2b_brm_branch_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_b2b_brm_branch_details` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `prospect_id` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '公司信息主表主键',
  `branch_company_name` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '分行公司名称',
  `branch_contact_person` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '联系人',
  `street_address_line_1` varchar(250) DEFAULT NULL COMMENT '街道地址1',
  `street_address_line_2` varchar(250) DEFAULT NULL COMMENT '街道地址2',
  `street_address_line_3` varchar(250) DEFAULT NULL COMMENT '街道地址3',
  `street_address_line_4` varchar(250) DEFAULT NULL COMMENT '街道地址4',
  `postal_code` varchar(50) DEFAULT NULL COMMENT '邮政编码',
  `country_code` varchar(50) DEFAULT NULL COMMENT '国家代码',
  `branch_same_address` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '居住地址与邮寄地址是否相同 1-勾选 0-不勾选',
  `postal_address_line_1` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '邮寄地址1',
  `postal_address_line_2` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '邮寄地址2',
  `postal_address_line_3` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '邮寄地址3',
  `postal_address_line_4` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '邮寄地址4',
  `postal_postal_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '邮寄邮政编码',
  `postal_country_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '邮寄国家代码',
  `branch_email_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '电子邮件类型',
  `branch_email_address` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '电子邮件地址',
  `branch_worksite_name` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '工作地点名称',
  `branch_telephone_number_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '电话号码类型',
  `branch_country_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '国家代码',
  `branch_telephone_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '电话号码',
  `branch_employees_male` int DEFAULT NULL COMMENT '男性员工数量',
  `branch_employees_female` int DEFAULT NULL COMMENT '女性员工数量',
  `branch_employees_total` int DEFAULT NULL COMMENT '员工总数',
  `tenant_id` varchar(10) DEFAULT NULL COMMENT '租户id',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '修改人',
  `branch_name` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '分行名称',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_b2b_branch_prospect_id` (`prospect_id`),
  KEY `idx_b2b_brm_created_by` (`created_by`)
) ENGINE=InnoDB AUTO_INCREMENT=82 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='b2b官方收购分行信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_b2b_brm_income_details`
--

DROP TABLE IF EXISTS `iic_crm_b2b_brm_income_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_b2b_brm_income_details` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `prospect_id` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '公司信息主表主键',
  `occupation` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '职业',
  `income_potential_unit` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '收入潜力单位 1-Number, 2-Percentage',
  `range1` varchar(250) DEFAULT NULL,
  `range2` varchar(250) DEFAULT NULL,
  `range3` varchar(250) DEFAULT NULL,
  `range4` varchar(250) DEFAULT NULL,
  `range5` varchar(250) DEFAULT NULL,
  `range6` varchar(250) DEFAULT NULL,
  `tenant_id` varchar(10) DEFAULT NULL COMMENT '租户id',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '修改人',
  `range_total` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'income range总和',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_b2b_income_prospect_id` (`prospect_id`),
  KEY `idx_b2b_brm_created_by` (`created_by`)
) ENGINE=InnoDB AUTO_INCREMENT=97 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='b2b官方收购收入信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_b2b_brm_official_acquisition`
--

DROP TABLE IF EXISTS `iic_crm_b2b_brm_official_acquisition`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_b2b_brm_official_acquisition` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `prospect_id` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '公司信息主表主键',
  `negotiator_name` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '交易人姓名',
  `negotiator_branch` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '交易人分行',
  `negotiator_telephone_number_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '交易人电话号码类型',
  `negotiator_country_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '交易人国家代码',
  `negotiator_contract_number` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '交易人手机号码',
  `manager_name` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '经理姓名',
  `province` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '省份 1-Eastern Cape, 2-Free State, 3-Gauteng, 4-Kwazulu Natal, 5-Limpopo, 6-Mpumalanga, 7-North West, 8-Northern Cape, 9-Western Cape',
  `manager_telephone_number_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '经理电话号码类型',
  `manager_country_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '经理国家代码',
  `manager_contract_number` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '经理电话号码',
  `consultant_name` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '顾问姓名',
  `consultant_telephone_number_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '顾问电话号码类型',
  `consultant_country_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '顾问国家代码',
  `consultant_contract_number` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '顾问合同号码',
  `market_introduced_by` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '市场引入者 1-RMM Tied, 2-RMM Alternate, 3-RMM FRM, 4-Market Management, 5-Other',
  `market_introduced_by_other` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '市场引入者选5-Other时输入值',
  `employees_male` int DEFAULT NULL COMMENT '男性员工数量',
  `employees_female` int DEFAULT NULL COMMENT '女性员工数量',
  `employees_total` int DEFAULT NULL COMMENT '员工总数',
  `normal_retirement_age` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '选择项 1-Male NRA/Female NRA, 2-Combined NRA',
  `normal_retirement_age_male` int DEFAULT NULL COMMENT '男性正常退休年龄',
  `normal_retirement_age_female` int DEFAULT NULL COMMENT '女性正常退休年龄',
  `normal_retirement_age_combined` int DEFAULT NULL COMMENT '综合正常退休年龄',
  `same_address` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '居住地址与邮寄地址是否相同 1-勾选 0-不勾选',
  `postal_address_line_1` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '邮寄地址1',
  `postal_address_line_2` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '邮寄地址2',
  `postal_address_line_3` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '邮寄地址3',
  `postal_address_line_4` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '邮寄地址4',
  `postal_postal_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '邮寄邮政编码',
  `postal_country_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '邮寄国家代码',
  `geographical_spread` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '地理分布 1-National, 2-Provincial, 3-Local',
  `total_potential` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '总潜力',
  `province_potential_unit` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '省潜力单位 1-Number, 2-Percentage',
  `breakdown_province` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '省份细分',
  `employees_paid_permanent` int DEFAULT NULL COMMENT '正式员工数量',
  `employees_paid_temporary` int DEFAULT NULL COMMENT '临时员工数量',
  `payment_method` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '支付方式 1-Cash, 2-EFT, 3-Other',
  `payment_method_other` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '支付方式选3-Other时输入值',
  `payment_frequency` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '支付频率 1-Weekly, 2-Bi-Weekly, 3-Monthly',
  `branch_debit_or_stop_order` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '借记或停止订单 1-Debit Order, 2-Stop Order',
  `access_protocols` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '访问协议 1-Industry safety standards to be adhered to, 2-Access by appoINTment only, 3-Access only between specified hours, 4-Access only certain times of the week, 5-Engagement in specified locations only, 6-Specific union affiliation to apply, 7-None',
  `product_protocols` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '产品协议 1-Only Risk to be sold, 2-Only Savings/Investment, 3-Sell only % of disposal income, 4-Premiums via stop order only, 5-Sell only number of products as disposable income, 6-None',
  `other_requirements` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '其他要求',
  `full_name` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '全名',
  `designation` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '职位',
  `tenant_id` varchar(10) DEFAULT NULL COMMENT '租户id',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '修改人',
  `is_read_declaration` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'employer‘s special requirements 1-勾选 0-不勾选',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_b2b_acquisition_prospect_id` (`prospect_id`),
  KEY `idx_b2b_brm_created_by` (`created_by`)
) ENGINE=InnoDB AUTO_INCREMENT=62 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='b2b官方收购从表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_b2b_brm_payroll_details`
--

DROP TABLE IF EXISTS `iic_crm_b2b_brm_payroll_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_b2b_brm_payroll_details` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `prospect_id` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '公司信息主表主键',
  `payroll_registered_company_name` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '注册公司名称',
  `payroll_registered_date` datetime DEFAULT NULL COMMENT '注册日期',
  `street_address_line_1` varchar(250) DEFAULT NULL COMMENT '街道地址1',
  `street_address_line_2` varchar(250) DEFAULT NULL COMMENT '街道地址2',
  `street_address_line_3` varchar(250) DEFAULT NULL COMMENT '街道地址3',
  `street_address_line_4` varchar(250) DEFAULT NULL COMMENT '街道地址4',
  `postal_code` varchar(50) DEFAULT NULL COMMENT '邮政编码',
  `country_code` varchar(50) DEFAULT NULL COMMENT '国家代码',
  `payroll_same_address` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '居住地址与邮寄地址是否相同 1-勾选 0-不勾选',
  `postal_address_line_1` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '邮寄地址1',
  `postal_address_line_2` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '邮寄地址2',
  `postal_address_line_3` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '邮寄地址3',
  `postal_address_line_4` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '邮寄地址4',
  `postal_postal_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '邮寄邮政编码',
  `postal_country_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '邮寄国家代码',
  `payroll_contact_person` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '联系人',
  `payroll_job_title` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '职位 1-HR Manger, 2-Payroll Manger, 3-Operations Manger, 4-Account Manager, 5-Other',
  `payroll_job_title_other` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '职位选择5-Other时输入值',
  `payroll_telephone_number_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '国家代码',
  `payroll_country_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '国家代码',
  `payroll_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '薪资编号',
  `payroll_email_address` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '电子邮件地址',
  `payroll_central` varchar(2) DEFAULT NULL COMMENT '是否中央化 1-Yes, 2-No',
  `payroll_Soft_and_version` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '工资单软件 1-SAP, 2-VIP, 3-Paywell, 4-Manual, 5-Other',
  `payroll_central_other` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '选择5-Other时输入值',
  `payroll_deductions` varchar(2) DEFAULT NULL COMMENT '扣除额 1-Yes, 2-No',
  `payroll_required` varchar(2) DEFAULT NULL COMMENT '是否需要 1-Yes, 2-No',
  `payroll_lodgements` varchar(2) DEFAULT NULL COMMENT '存款细节 1-Street address, 2-Postal address',
  `payroll_method` varchar(2) DEFAULT NULL COMMENT '存款细节 1-Stop Orders, 2-Payroll Administration, 3-EFT',
  `payroll_send_email` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '是否发送电子邮件',
  `payroll_prefer_send` varchar(2) DEFAULT NULL COMMENT '首选发送方式 1-Text, 2-LOA, 3-Excel, 4-Other',
  `payroll_prefer_send_other` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '选择4-Other时输入值',
  `payroll_format_requirements` varchar(2) DEFAULT NULL COMMENT '格式要求 1-Salay Reference, 2-Name, 3-Policy Number, 4-Other',
  `payroll_format_requirements_other` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '选择4-Other时输入值',
  `payroll_schedule_requirements` varchar(2) DEFAULT NULL COMMENT '时间表要求 1-Full schedule, 2-Movements only',
  `payroll_schedule_requirements_choose` varchar(2) DEFAULT NULL COMMENT '时间表要求选项 1-Same Month(1Y), 2-Previous Month(2Y), 3-Both, 4-Other',
  `payroll_schedule_requirements_other` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '选择4-Other时输入值',
  `payroll_require_date` datetime DEFAULT NULL COMMENT '要求日期',
  `payroll_use_aims` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '是否使用AIMS',
  `payroll_deposit_date` datetime DEFAULT NULL COMMENT '存款日期',
  `payroll_annual_leave` varchar(2) DEFAULT NULL COMMENT '年假天数 1-Yes, 2-No',
  `payroll_sick_leave` varchar(2) DEFAULT NULL COMMENT '病假天数 1-Yes, 2-No',
  `payroll_deducted_leave` varchar(2) DEFAULT NULL COMMENT '扣除的假期天数 1-Yes, 2-No ',
  `tenant_id` varchar(10) DEFAULT NULL COMMENT '租户id',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '修改人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_b2b_payroll_prospect_id` (`prospect_id`),
  KEY `idx_b2b_brm_created_by` (`created_by`)
) ENGINE=InnoDB AUTO_INCREMENT=54 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='b2b官方收购薪资详细信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_b2b_brm_prospect`
--

DROP TABLE IF EXISTS `iic_crm_b2b_brm_prospect`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_b2b_brm_prospect` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `business_name` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '母公司名称',
  `head_office_location` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '母公司地址',
  `subsidiary_name` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '子公司名称',
  `subsidiary_location` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '子公司地址',
  `industry` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'industry',
  `sector` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'sector',
  `total_potential` varchar(100) DEFAULT NULL COMMENT 'total_potential',
  `node_description` varchar(250) DEFAULT NULL COMMENT '备注',
  `status` varchar(2) DEFAULT NULL COMMENT '状态: 1 Draft, 2 Approval Pending, 3 Completed, 4 Accepted, 5 Declined, 9 Cancelled',
  `type` varchar(2) DEFAULT NULL COMMENT '类型: 1 Prospect, 2 Acquisitions, 3 Active Business Partners',
  `tenant_id` varchar(10) DEFAULT NULL COMMENT '租户id',
  `is_delete` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '是否删除1是0否',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '修改人',
  `segment` varchar(16) DEFAULT NULL COMMENT '用户组织类别 SA-PF/SA-MFC/NAM-PF/NAM-MFC',
  `sector_of_sub_category` varchar(50) DEFAULT NULL COMMENT '部门分类',
  `number_of_national_employees` varchar(250) DEFAULT NULL COMMENT '国籍人数',
  `head_office_region_of_organization` varchar(250) DEFAULT NULL COMMENT '总部区域组织',
  `head_office_area_of_organization` varchar(50) DEFAULT NULL COMMENT '总部单位组织',
  `street_address_line_1` varchar(250) DEFAULT NULL COMMENT '街道地址1',
  `street_address_line_2` varchar(250) DEFAULT NULL COMMENT '街道地址2',
  `street_address_line_3` varchar(250) DEFAULT NULL COMMENT '街道地址3',
  `street_address_line_4` varchar(250) DEFAULT NULL COMMENT '街道地址4',
  `postal_code` varchar(50) DEFAULT NULL COMMENT '邮政编码',
  `country_code` varchar(50) DEFAULT NULL COMMENT '国家代码',
  `is_same` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'business and worksite是否一致1是0否',
  `total_amount_of_individuals_worksite` int DEFAULT NULL COMMENT 'worksite总数',
  `range1` int DEFAULT NULL,
  `range2` int DEFAULT NULL,
  `range3` int DEFAULT NULL,
  `range4` int DEFAULT NULL,
  `range5` int DEFAULT NULL,
  `range6` int DEFAULT NULL,
  `scheme_code_and_name` varchar(250) DEFAULT NULL,
  `payment_method` varchar(50) DEFAULT NULL COMMENT '1:Debit order 2:Stop order',
  `is_official` varchar(2) DEFAULT '0' COMMENT '0-non-official, 1-official',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_b2b_brm_created_by` (`created_by`)
) ENGINE=InnoDB AUTO_INCREMENT=217 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='b2bProspect信息主表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_b2b_brm_prospect_approve_info`
--

DROP TABLE IF EXISTS `iic_crm_b2b_brm_prospect_approve_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_b2b_brm_prospect_approve_info` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `tenant_id` varchar(10) DEFAULT NULL COMMENT '租户id',
  `prospect_id` bigint NOT NULL COMMENT 'prospect id',
  `description` varchar(500) DEFAULT NULL COMMENT '描述',
  `prospect_status` char(2) DEFAULT NULL COMMENT '状态: 见prospect - status',
  `is_delete` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '是否删除1是0否',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '修改人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_b2b_brm_prospect_id` (`prospect_id`)
) ENGINE=InnoDB AUTO_INCREMENT=73 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='b2bProspect审批信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_b2b_brm_prospect_contact`
--

DROP TABLE IF EXISTS `iic_crm_b2b_brm_prospect_contact`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_b2b_brm_prospect_contact` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `business_id` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '公司信息主键 iic_crm_b2b_brm主键',
  `name` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '联系人名',
  `cellphone_number_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '手机号码类型',
  `country_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '所属国家',
  `cellphone_number` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '手机号码',
  `email_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'industry',
  `email` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'sector',
  `role` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'role',
  `role_desc` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'role_desc',
  `type` varchar(2) NOT NULL COMMENT '类型: 1 主要联系人, 2 非主要联系人',
  `tenant_id` varchar(10) NOT NULL COMMENT '租户id',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '修改人',
  `payroll_id` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'b2b官方收购薪资详细信息表 iic_crm_b2b_brm_payroll_details主键',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_b2b_contact_business_id` (`business_id`)
) ENGINE=InnoDB AUTO_INCREMENT=627 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='b2bProspect信息联系人表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_b2b_brm_scheme_details`
--

DROP TABLE IF EXISTS `iic_crm_b2b_brm_scheme_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_b2b_brm_scheme_details` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `prospect_id` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '公司信息主表主键',
  `scheme_code_or_name` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '方案编码或名称',
  `number_of_members` int DEFAULT NULL COMMENT '成员人数',
  `percentage_of_employees` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '受雇人员百分比',
  `consulted` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '是否可以咨询 1-Yes, 2-No',
  `organizing_rights` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '组织权利 1-Yes, 2-No',
  `tenant_id` varchar(10) DEFAULT NULL COMMENT '租户id',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '修改人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_b2b_scheme_prospect_id` (`prospect_id`),
  KEY `idx_b2b_brm_created_by` (`created_by`)
) ENGINE=InnoDB AUTO_INCREMENT=85 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='b2b官方收购细节计划表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_b2b_brm_search_history`
--

DROP TABLE IF EXISTS `iic_crm_b2b_brm_search_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_b2b_brm_search_history` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `prospect_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'prospectid',
  `user_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '用户id',
  `organisation_name` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '联系人名',
  `business_name` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '公司名称',
  `process_stage` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `location` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '地点',
  `segment` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'segment',
  `status` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '状态',
  `is_official` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `is_worksite` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `tenant_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '租户id',
  `is_delete` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '是否删除1是0否',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '修改人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_b2b_search_history_userId` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=97 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='查看searchEntities历史记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_b2b_reference_desc`
--

DROP TABLE IF EXISTS `iic_crm_b2b_reference_desc`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_b2b_reference_desc` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `table_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'table name',
  `field_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'field name',
  `value` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'field value',
  `description` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'field description',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT 'created by',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'created date',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT 'updated by',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'updated date',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='B2B reference table for the description';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_base_country_code`
--

DROP TABLE IF EXISTS `iic_crm_base_country_code`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_base_country_code` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `dict_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '编码',
  `language` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '语种',
  `describe` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '描述',
  `sort` int NOT NULL COMMENT '排序',
  `status` int NOT NULL COMMENT '状态(1-有效；2-无效)',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `segment_type` varchar(2) COLLATE utf8mb4_bin DEFAULT '1' COMMENT '1=PF; 2=MFC',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=247 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='国家区号基表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_base_data`
--

DROP TABLE IF EXISTS `iic_crm_base_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_base_data` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `type_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '类型',
  `dict_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '编码',
  `language` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '语种',
  `describe` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '描述',
  `sort` int NOT NULL COMMENT '排序',
  `status` int NOT NULL COMMENT '状态(1-有效；2-无效)',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `type_name` (`type_name`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2003 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='基表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_base_label`
--

DROP TABLE IF EXISTS `iic_crm_base_label`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_base_label` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `label_type` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '标签类型(1-手动，2-系统，3-产品大类)',
  `label_attribute` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '标签属性',
  `label_value` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '标签值',
  `is_delete` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT ' 0:未删除 1:已删除 ',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=100006 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='标签基表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_calendar`
--

DROP TABLE IF EXISTS `iic_crm_calendar`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_calendar` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT 'id',
  `user_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '用戶id',
  `timeline_Id` int DEFAULT '0' COMMENT 'timeline的主键id',
  `notes` varchar(3000) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `activity_type` char(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT ' 活动类型；根据动态表单变化',
  `start_date` datetime DEFAULT NULL COMMENT '开始时间',
  `end_date` datetime DEFAULT NULL COMMENT '结束时间',
  `tenant_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '租户id',
  `is_delete` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT ' 0:未删除 1:已删除 ',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `source` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT '1:线索;2:客户',
  `address` varchar(3000) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `calendar_type` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT '0 个人;1团队;2视频',
  `source_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '来源id（团队长时，来源于那个活动id）',
  `sub_type` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '子类型:1成员l;2团队长',
  `entire_day` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT '是否一整天：0 否;1是',
  `lead_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '线索id/客户id',
  `reminder_time` datetime DEFAULT NULL COMMENT '提醒时间',
  `alert` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT '提醒:0:None;1: At time of event; 2:15 minutes before 3:30 minutes before; 4:1 hour before;',
  `video_conference_url` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '视频链接地址',
  `org_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Worksite code',
  `org_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Worksite Name',
  `customer_name` varchar(128) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '客户全名',
  `is_tip` char(1) COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '不同组织前提下，是否有需要提示的日历，1是，0否',
  `is_overlap` char(1) COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '不同组织前提下，是否有重叠的日历，1是，0否，默认0',
  `overlap_batch` varchar(100) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '新增时，自己与其它记录有冲突，记一个batch,雪花id',
  `batch_array` varchar(3000) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '与自己冲突的记录数组,batch1,batch2,batch3,batch4,......,',
  `phone_number` varchar(32) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '电话号码',
  `appointment_status` varchar(2) COLLATE utf8mb4_bin NOT NULL DEFAULT 'SC' COMMENT '会议状态，SC:Scheduled、RE: Re-scheduled、CA: Cancelled、AT: Attended',
  `original_status` varchar(2) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '原会议状态，SC:Scheduled、RE: Re-scheduled、CA: Cancelled、AT: Attended',
  `sat_required` char(1) COLLATE utf8mb4_bin DEFAULT '-' COMMENT '日历是否需要参与s&t报销标识 1-Yes 0-No,默认-',
  `tenant_org_code` varchar(100) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '机构组织代码',
  `meeting_link` varchar(3000) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '会议室',
  `event_id` varchar(300) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'outlook返回的操作id,唯一key',
  `transaction_id` varchar(60) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'dae给om同步的操作id,唯一key',
  `data_from` varchar(10) COLLATE utf8mb4_bin NOT NULL DEFAULT 'dae' COMMENT '数据来源，dae/outlook',
  `recurrence_type` char(1) COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '重复事件类型 0-Does not repeat/1-daily/2-weekly/3-monthly/4-yearly/5-custom',
  `recurrence_rule_no` varchar(32) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '规则编号',
  `recurrence_unique` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '一个日程一个，等同于主键id',
  `task_category` char(1) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '任务类型，0：日历; 1：JFW; 2：Coaching Session',
  `task_id` varchar(50) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '任务id',
  `recipient_id` varchar(50) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '接收人id',
  `task_name` varchar(300) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '任务名称',
  `recurring_tips` varchar(200) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '重复事件规则描述提示文案',
  `recurring_outlook_id` varchar(300) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '重复事件序列每一个元素都有一个唯一的id,由outlook返回',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `event_type` char(1) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '0-Customer Meeting, 1-Branch Meetings，2-Training，3-Exams，4-Convention，5-OM - Area/Provincial Meetings，6-Other',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  `outlook_id` varchar(300) COLLATE utf8mb4_bin DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `iic_crm_calendar_outlook_id_IDX` (`outlook_id`) USING BTREE,
  KEY `user_id_idx` (`user_id`),
  KEY `idx_start_date` (`start_date`),
  KEY `idx_created_date` (`created_date`),
  KEY `idx_task_id` (`task_id`),
  KEY `idx_source_id` (`source_id`),
  KEY `idx_calendar_timeline_Id` (`timeline_Id`),
  KEY `idx_event_id` (`event_id`),
  KEY `idx_recurrence_unique` (`recurrence_unique`),
  KEY `iic_crm_calendar_reminder_time_IDX` (`reminder_time`) USING BTREE,
  KEY `iic_crm_calendar_recurrence_rule_no_IDX` (`recurrence_rule_no`) USING BTREE,
  KEY `iic_crm_calendar_recipient_id_IDX` (`recipient_id`),
  KEY `iic_crm_calendar_transaction_id_IDX` (`transaction_id`)
) ENGINE=InnoDB AUTO_INCREMENT=158009 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='日历活动表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_calendar_0813`
--

DROP TABLE IF EXISTS `iic_crm_calendar_0813`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_calendar_0813` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT 'id',
  `user_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '用戶id',
  `timeline_Id` int DEFAULT '0' COMMENT 'timeline的主键id',
  `notes` varchar(3000) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `activity_type` char(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT ' 活动类型；根据动态表单变化',
  `start_date` datetime DEFAULT NULL COMMENT '开始时间',
  `end_date` datetime DEFAULT NULL COMMENT '结束时间',
  `tenant_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '租户id',
  `is_delete` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT ' 0:未删除 1:已删除 ',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `source` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT '1:线索;2:客户',
  `address` varchar(3000) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `calendar_type` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT '0 个人;1团队;2视频',
  `source_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '来源id（团队长时，来源于那个活动id）',
  `sub_type` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '子类型:1成员l;2团队长',
  `entire_day` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT '是否一整天：0 否;1是',
  `lead_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '线索id/客户id',
  `reminder_time` datetime DEFAULT NULL COMMENT '提醒时间',
  `alert` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT '提醒:0:None;1: At time of event; 2:15 minutes before 3:30 minutes before; 4:1 hour before;',
  `video_conference_url` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '视频链接地址',
  `org_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Worksite code',
  `org_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Worksite Name',
  `customer_name` varchar(128) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '客户全名',
  `is_tip` char(1) COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '不同组织前提下，是否有需要提示的日历，1是，0否',
  `is_overlap` char(1) COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '不同组织前提下，是否有重叠的日历，1是，0否，默认0',
  `overlap_batch` varchar(100) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '新增时，自己与其它记录有冲突，记一个batch,雪花id',
  `batch_array` varchar(3000) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '与自己冲突的记录数组,batch1,batch2,batch3,batch4,......,',
  `phone_number` varchar(32) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '电话号码',
  `appointment_status` varchar(2) COLLATE utf8mb4_bin NOT NULL DEFAULT 'SC' COMMENT '会议状态，SC:Scheduled、RE: Re-scheduled、CA: Cancelled、AT: Attended',
  `original_status` varchar(2) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '原会议状态，SC:Scheduled、RE: Re-scheduled、CA: Cancelled、AT: Attended',
  `sat_required` char(1) COLLATE utf8mb4_bin DEFAULT '-' COMMENT '日历是否需要参与s&t报销标识 1-Yes 0-No,默认-',
  `tenant_org_code` varchar(100) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '机构组织代码',
  `meeting_link` varchar(3000) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '会议室',
  `event_id` varchar(300) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'outlook返回的操作id,唯一key',
  `transaction_id` varchar(60) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'dae给om同步的操作id,唯一key',
  `data_from` varchar(10) COLLATE utf8mb4_bin NOT NULL DEFAULT 'dae' COMMENT '数据来源，dae/outlook',
  `recurrence_type` char(1) COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '重复事件类型 0-Does not repeat/1-daily/2-weekly/3-monthly/4-yearly/5-custom',
  `recurrence_rule_no` varchar(32) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '规则编号',
  `recurrence_unique` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '一个日程一个，等同于主键id',
  `task_category` char(1) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '任务类型，0：日历; 1：JFW; 2：Coaching Session',
  `task_id` varchar(50) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '任务id',
  `recipient_id` varchar(50) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '接收人id',
  `task_name` varchar(300) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '任务名称',
  `recurring_tips` varchar(200) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '重复事件规则描述提示文案',
  `recurring_outlook_id` varchar(300) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '重复事件序列每一个元素都有一个唯一的id,由outlook返回',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `event_type` char(1) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '0-Customer Meeting, 1-Branch Meetings，2-Training，3-Exams，4-Convention，5-OM - Area/Provincial Meetings，6-Other',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `user_id_idx` (`user_id`),
  KEY `idx_is_delete` (`is_delete`),
  KEY `idx_start_date` (`start_date`),
  KEY `idx_created_date` (`created_date`),
  KEY `idx_task_id` (`task_id`),
  KEY `idx_source_id` (`source_id`),
  KEY `idx_calendar_timeline_Id` (`timeline_Id`),
  KEY `idx_event_id` (`event_id`),
  KEY `idx_recurrence_unique` (`recurrence_unique`),
  KEY `iic_crm_calendar_reminder_time_IDX` (`reminder_time`) USING BTREE,
  KEY `iic_crm_calendar_recurrence_rule_no_IDX` (`recurrence_rule_no`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=58966 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='日历活动表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_calendar_recurring`
--

DROP TABLE IF EXISTS `iic_crm_calendar_recurring`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_calendar_recurring` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `tenant_id` bigint NOT NULL COMMENT '租户id',
  `user_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '用户ID',
  `recurring_rule_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '规则编号',
  `recurring_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '1-daily/2-weekly/3-monthly/4-yearly',
  `start_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '重复事件开始日期',
  `frequency` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '频率 1~99,12个月英文缩写',
  `day_of_week` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday, 豆号隔开保存和返回给前端',
  `pattern` varchar(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'absolute/relative',
  `day_of_month` tinyint DEFAULT '0' COMMENT '月内天数1~31，monthly和yearly用',
  `on_type` varchar(6) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'on的类型,First（默认）/Second/Third/Fourth/Last',
  `on_day` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'on day 的类型，Sunday/Monday/Tuesday/Wednesday/Thursday/Friday/Saturday/Day（默认）/Weekday/WeekendDay',
  `end_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '1-on this day,2-after,3-no end date',
  `end_date` datetime DEFAULT NULL COMMENT '重复事件结束日期',
  `recurring_times` smallint DEFAULT '1' COMMENT '次数，代表重复多少次后结束，仅支持输入1-999整数数字',
  `generated_status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT '生成日程状态 1-true 0-false，默认未生成-0',
  `valid` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '1' COMMENT '有效状态 1-true 0-false，默认有效-1',
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `last_no_end_day` datetime DEFAULT NULL COMMENT '规则首次生成的最后下标',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  `outlook_master_id` varchar(300) COLLATE utf8mb4_bin DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `iic_crm_calendar_recurring_outlook_master_id_IDX` (`outlook_master_id`) USING BTREE,
  KEY `iic_crm_calendar_recurring_recurring_rule_no_IDX` (`recurring_rule_no`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=4277 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='日程重复事件表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_calendar_recurring_0813`
--

DROP TABLE IF EXISTS `iic_crm_calendar_recurring_0813`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_calendar_recurring_0813` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `tenant_id` bigint NOT NULL COMMENT '租户id',
  `user_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '用户ID',
  `recurring_rule_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '规则编号',
  `recurring_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '1-daily/2-weekly/3-monthly/4-yearly',
  `start_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '重复事件开始日期',
  `frequency` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '频率 1~99,12个月英文缩写',
  `day_of_week` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday, 豆号隔开保存和返回给前端',
  `pattern` varchar(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'absolute/relative',
  `day_of_month` tinyint DEFAULT '0' COMMENT '月内天数1~31，monthly和yearly用',
  `on_type` varchar(6) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'on的类型,First（默认）/Second/Third/Fourth/Last',
  `on_day` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'on day 的类型，Sunday/Monday/Tuesday/Wednesday/Thursday/Friday/Saturday/Day（默认）/Weekday/WeekendDay',
  `end_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '1-on this day,2-after,3-no end date',
  `end_date` datetime DEFAULT NULL COMMENT '重复事件结束日期',
  `recurring_times` smallint DEFAULT '1' COMMENT '次数，代表重复多少次后结束，仅支持输入1-999整数数字',
  `generated_status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT '生成日程状态 1-true 0-false，默认未生成-0',
  `valid` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '1' COMMENT '有效状态 1-true 0-false，默认有效-1',
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `last_no_end_day` datetime DEFAULT NULL COMMENT '规则首次生成的最后下标',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`),
  KEY `iic_crm_calendar_recurring_recurring_rule_no_IDX` (`recurring_rule_no`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3811 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='日程重复事件表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_calendar_switch`
--

DROP TABLE IF EXISTS `iic_crm_calendar_switch`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_calendar_switch` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `org_type` char(1) COLLATE utf8mb4_bin NOT NULL COMMENT '组织类型 0-segment/1-channel',
  `org_code` varchar(100) COLLATE utf8mb4_bin NOT NULL COMMENT '配开关的组织编码',
  `switch_on` char(1) COLLATE utf8mb4_bin NOT NULL COMMENT '开关打开，1-yes/0-no',
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `switch_un_org_code` (`org_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='日程同步开关表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_calendar_switch_record`
--

DROP TABLE IF EXISTS `iic_crm_calendar_switch_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_calendar_switch_record` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `switch_id` bigint NOT NULL COMMENT '日历开关表的主键',
  `status_in_time` datetime NOT NULL COMMENT '进入当前状态的时间',
  `pre_status_in_time` datetime NOT NULL COMMENT '进入上一个状态的时间',
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='开关操作记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_call_note`
--

DROP TABLE IF EXISTS `iic_crm_call_note`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_call_note` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '自增id',
  `tenant_id` bigint NOT NULL COMMENT '租户id',
  `leads_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '线索id',
  `call_log_note` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '记录文本',
  `start_time` datetime NOT NULL COMMENT '呼叫开始时间',
  `call_duration` int DEFAULT NULL COMMENT '通话时长',
  `status` int DEFAULT NULL COMMENT '逻辑删除（0：未删除，1：已删除）',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1740 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='通话线索日志记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_campaign`
--

DROP TABLE IF EXISTS `iic_crm_campaign`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_campaign` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `campaign_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '营销活动编码',
  `campaign_name` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '营销活动名称',
  `campaign_desc` varchar(2048) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '营销活动描述',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户id',
  `created_agent_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '活动创建人',
  `source` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '来源-Vendor/Social/Data Warehouse/Other',
  `category` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '类别，单选-OMP Life/OMIN',
  `sub_category` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '子类别，单选-Cross sell/Up sell',
  `start_time` datetime DEFAULT NULL COMMENT '开始时间',
  `end_time` datetime DEFAULT NULL COMMENT '结束时间',
  `launched_sms_notice` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '创建时短信消息提醒',
  `launched_msg_notice` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '创建时站内信消息提醒',
  `leads_allocated_sms_notice` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '新线索创建时短信提醒',
  `leads_allocated_msg_notice` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '新线索创建时站内信提醒',
  `lead_target` int DEFAULT NULL COMMENT '线索目标数量',
  `policy_target` bigint DEFAULT NULL COMMENT '投保保单目标数量',
  `assets_target` decimal(12,0) DEFAULT NULL COMMENT '投保金额目标数量',
  `conversation_rate_target` int DEFAULT NULL COMMENT '线索转客户转换率目标数量（1-100）',
  `is_confirm` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '是否确认，1是0否',
  `is_delete` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '是否删除，1是0否',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `template_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '活动模板id',
  `priority` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '优先级(D-HotC-HighB-Midium A-Low)',
  `customer_criteria` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '客户筛选类型(0-all;1-conditions)',
  `status` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '活动状态(1-Active;2-Expired;3-Pending;4-Closed)',
  `leads_count` int DEFAULT NULL COMMENT '线索总数量',
  `email_content` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'email营销信息',
  `sms_content` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '短信营销信息',
  `status_start_time` datetime DEFAULT NULL COMMENT '状态起始时间',
  `created_agent_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '' COMMENT '活动创建人姓名',
  `send_email_status` char(1) COLLATE utf8mb4_bin DEFAULT '0' COMMENT '是否勾选发送邮件 0:未勾选 1:已勾选',
  `role_code` varchar(100) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '业务角色代码',
  `role_type` int DEFAULT NULL COMMENT '角色类型(1: Adviser 2: Sales Manager 3: Campaign Admin 4: Campaign Manager)',
  `mandatory` char(1) COLLATE utf8mb4_bin DEFAULT '0' COMMENT '0:非强制性参加 1:强制性参加 2:无需展示',
  `engagement_type` varchar(2) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '0：Face to Face，1：Virtual，2：Telephonically',
  `re_allocation` char(1) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '是否重分配：0:no, 1:yes',
  `re_org_code` varchar(50) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '重分配的channel code',
  `org_code_path` varchar(200) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '创建人的组织机构path',
  `allocation_group_version` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'allocation group版本号',
  `type` tinyint NOT NULL DEFAULT '0' COMMENT '类型 0：已有主表数据  1：外部MFC数据 2：外部PF数据',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `segment` varchar(50) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'segment',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `unique_campaign_code` (`campaign_code`) USING BTREE,
  KEY `campaign_idx_tenant_id` (`tenant_id`),
  KEY `campaign_idx_created_by` (`created_by`),
  KEY `idx_created_agent_id` (`created_agent_id`),
  KEY `idx_tenantId_campaignCode` (`tenant_id`,`campaign_code`),
  KEY `idx_campaign_type` (`type`),
  KEY `idx_campaign_status_country` (`status`,`tenant_id`,`is_delete`,`dae_country_code`),
  KEY `idx_campaign_date_time` (`created_date`,`end_time`,`id`),
  KEY `idx_org_code_path` (`campaign_code`,`org_code_path`)
) ENGINE=InnoDB AUTO_INCREMENT=4723 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='营销活动主表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_campaign_allocation_group`
--

DROP TABLE IF EXISTS `iic_crm_campaign_allocation_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_campaign_allocation_group` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint DEFAULT NULL COMMENT '租户id',
  `unique_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '唯一标识',
  `segment_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'segment_code',
  `channel_code` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT 'channel_code',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '名称',
  `adviser_select_all` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '是否选择所有adviser',
  `creator` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `is_delete` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '是否删除，1是0否',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `unique_unique_code` (`unique_code`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=72 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='campaign_allocation_group表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_campaign_allocation_group_rel_adviser`
--

DROP TABLE IF EXISTS `iic_crm_campaign_allocation_group_rel_adviser`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_campaign_allocation_group_rel_adviser` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint DEFAULT NULL COMMENT '租户id',
  `allocation_group_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'allocation_group_code',
  `adviser_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'user id',
  `is_delete` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '是否删除，1是0否',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `org_codes` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '组织编码;多个逗号隔开',
  `org_name_paths` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '组织机构编码，多个值时用,号分割',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_allocation_group_code` (`allocation_group_code`)
) ENGINE=InnoDB AUTO_INCREMENT=17512 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='campaign_allocation_group关联adviser表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_campaign_criteria_condition`
--

DROP TABLE IF EXISTS `iic_crm_campaign_criteria_condition`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_campaign_criteria_condition` (
  `id` bigint unsigned NOT NULL COMMENT '主键',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `campaign_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '营销活动编码',
  `tree_data` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '存储前端回显的信息',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `org_tree_data` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT 'org回显信息',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='campaign决策树条件表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_campaign_criteria_setting`
--

DROP TABLE IF EXISTS `iic_crm_campaign_criteria_setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_campaign_criteria_setting` (
  `id` bigint unsigned NOT NULL COMMENT '主键',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `campaign_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '营销活动编码',
  `object` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '一级对象',
  `category_code` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '分类',
  `sub_object` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '子对象',
  `condition_value` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '条件',
  `match_value` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '匹配值',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='营销活动客户规则决策树配置表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_campaign_draft`
--

DROP TABLE IF EXISTS `iic_crm_campaign_draft`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_campaign_draft` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `campaign_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '营销活动编码',
  `campaign_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '营销活动名称',
  `campaign_desc` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '营销活动描述',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户id',
  `created_agent_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '活动创建人',
  `source` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '来源-Vendor/Social/Data Warehouse/Other',
  `category` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '类别，单选-OMP Life/OMIN',
  `sub_category` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '子类别，单选-Cross sell/Up sell',
  `start_time` datetime DEFAULT NULL COMMENT '开始时间',
  `end_time` datetime DEFAULT NULL COMMENT '结束时间',
  `launched_sms_notice` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '创建时短信消息提醒',
  `launched_msg_notice` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '创建时站内信消息提醒',
  `leads_allocated_sms_notice` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '新线索创建时短信提醒',
  `leads_allocated_msg_notice` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '新线索创建时站内信提醒',
  `lead_target` int DEFAULT NULL COMMENT '线索目标数量',
  `policy_target` bigint DEFAULT NULL COMMENT '投保保单目标数量',
  `assets_target` decimal(12,0) DEFAULT NULL COMMENT '投保金额目标数量',
  `conversation_rate_target` int DEFAULT NULL COMMENT '线索转客户转换率目标数量（1-100）',
  `is_confirm` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '是否确认，1是0否',
  `is_delete` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '是否删除，1是0否',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `template_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '活动模板id',
  `priority` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '优先级(1-Hot2-High3-Middle4-Low)',
  `customer_criteria` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '客户筛选类型(0-all;1-conditions)',
  `status` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '活动状态(1-Active;2-Expired;3-Pending;4-Closed)',
  `leads_count` int DEFAULT NULL COMMENT '线索总数量',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `unique_campaign_code` (`campaign_code`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=275 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='营销活动草稿表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_campaign_email_tracking`
--

DROP TABLE IF EXISTS `iic_crm_campaign_email_tracking`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_campaign_email_tracking` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `campaign_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'campaignCode',
  `message_email_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'msgId',
  `is_newmessage` varchar(1) COLLATE utf8mb4_bin NOT NULL DEFAULT '1' COMMENT '邮件模版是否为新建  0:否，1:是',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '邮件标题',
  `email_code` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'emailCode',
  `email_content` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '邮件内容',
  `file_keys` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '附件fileKeys以逗号分隔',
  `file_info_str` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '附件fileInfos对象转字符串',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_campaign_code` (`campaign_code`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=524 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='campaign email关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_campaign_message_record`
--

DROP TABLE IF EXISTS `iic_crm_campaign_message_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_campaign_message_record` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `campaign_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '营销活动编码',
  `type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '0: lead消息 1：lead邮件 2:确认客户通知',
  `lead_id` bigint DEFAULT NULL COMMENT 'leadId',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户id',
  `agent_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '收到信息的advisorId',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `batch_no` bigint DEFAULT NULL COMMENT '所属上传批号',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `idx_campaign_message_record_agent_id_campaign_code_type_batch_no` (`agent_id`,`type`,`campaign_code`,`batch_no`) USING BTREE,
  KEY `idx_campaign_message_record_campaign_code` (`campaign_code`) USING BTREE,
  KEY `idx_campaign_message_record_agent_id` (`agent_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3792 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='campaign邮件或消息发送记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_campaign_name`
--

DROP TABLE IF EXISTS `iic_crm_campaign_name`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_campaign_name` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户id',
  `campaign_name` char(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '活动名字',
  `user_id` char(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '用户id',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '修改人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改时间',
  `is_advisor_create` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '是否为advisor创建的',
  `is_mfc` char(1) COLLATE utf8mb4_bin DEFAULT '0' COMMENT '0 非mfc;1 是mfc',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=907 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='活动名字';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_campaign_om`
--

DROP TABLE IF EXISTS `iic_crm_campaign_om`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_campaign_om` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `campaign_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `campaign_active_state` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `start_time` datetime DEFAULT NULL COMMENT '开始时间',
  `end_time` datetime DEFAULT NULL COMMENT '结束时间',
  `campaign_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `type_description` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `category` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `source_product` varchar(256) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'source_product',
  `source_id` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'source_id',
  `channel_id` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'channel_id',
  `form_id` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'form_id',
  `lead_type_id` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'lead_type_id',
  `producer` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'producer',
  `status_id` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'status_id',
  `target_system` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'target_system',
  `worksite_code` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'worksite_code',
  `is_error_data` tinyint NOT NULL DEFAULT '0' COMMENT '是否既为PF又为MFC脏数据: 是：1 否：0(默认值)',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `unique_campaign_code` (`tenant_id`,`campaign_code`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=544 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='om campaign表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_campaign_om_0809`
--

DROP TABLE IF EXISTS `iic_crm_campaign_om_0809`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_campaign_om_0809` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `campaign_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `campaign_active_state` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `start_time` datetime DEFAULT NULL COMMENT '开始时间',
  `end_time` datetime DEFAULT NULL COMMENT '结束时间',
  `campaign_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `type_description` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `category` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `source_product` varchar(256) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'source_product',
  `source_id` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'source_id',
  `channel_id` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'channel_id',
  `form_id` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'form_id',
  `lead_type_id` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'lead_type_id',
  `producer` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'producer',
  `status_id` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'status_id',
  `target_system` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'target_system',
  `worksite_code` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'worksite_code',
  `is_error_data` tinyint NOT NULL DEFAULT '0' COMMENT '是否既为PF又为MFC脏数据: 是：1 否：0(默认值)',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `unique_campaign_code` (`tenant_id`,`campaign_code`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=533 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='om campaign表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_campaign_om_bak`
--

DROP TABLE IF EXISTS `iic_crm_campaign_om_bak`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_campaign_om_bak` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `campaign_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `campaign_active_state` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `start_time` datetime DEFAULT NULL COMMENT '开始时间',
  `end_time` datetime DEFAULT NULL COMMENT '结束时间',
  `campaign_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `type_description` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `category` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `unique_campaign_code` (`tenant_id`,`campaign_code`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=886 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='om campaign表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_campaign_om_sp33_bak`
--

DROP TABLE IF EXISTS `iic_crm_campaign_om_sp33_bak`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_campaign_om_sp33_bak` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `campaign_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `campaign_active_state` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `start_time` datetime DEFAULT NULL COMMENT '开始时间',
  `end_time` datetime DEFAULT NULL COMMENT '结束时间',
  `campaign_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `type_description` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `category` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `source_product` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'source_product',
  `source_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'source_id',
  `channel_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'channel_id',
  `form_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'form_id',
  `lead_type_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'lead_type_id',
  `producer` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'producer',
  `status_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'status_id',
  `target_system` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'target_system',
  `worksite_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'worksite_code',
  `is_error_data` tinyint NOT NULL DEFAULT '0' COMMENT '是否既为PF又为MFC脏数据: 是：1 否：0(默认值)',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `unique_campaign_code` (`tenant_id`,`campaign_code`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=906 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='om campaign备份表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_campaign_product_temp`
--

DROP TABLE IF EXISTS `iic_crm_campaign_product_temp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_campaign_product_temp` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `product_provider` char(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '产品提供商',
  `product_name` char(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '产品名称',
  `product_code` char(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '产品编码',
  `investment_type` char(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '类型',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `segment` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '0:pf的产品 1:mfc的产品',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=655 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='活动全量sprint2产品枚举';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_campaign_promotion`
--

DROP TABLE IF EXISTS `iic_crm_campaign_promotion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_campaign_promotion` (
  `id` bigint unsigned NOT NULL COMMENT '主键id（宣传页id）',
  `campaign_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '营销活动编码',
  `tenant_id` bigint NOT NULL COMMENT '租户id',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '宣传页名称',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '宣传页内容',
  `form_params` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '表单参数',
  `is_offline` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '是否下线（0：未下线，1：已下线）默认0',
  `is_release` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '是否发布（0：未发布，1：已发布）默认0',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_campaign_promotion_form`
--

DROP TABLE IF EXISTS `iic_crm_campaign_promotion_form`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_campaign_promotion_form` (
  `id` bigint unsigned NOT NULL COMMENT '主键id；自增',
  `promotion_id` bigint NOT NULL COMMENT '宣传页id',
  `form_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '表单id',
  `form_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '表单内容',
  `adviser_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '分享人id',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_campaign_rel_agent`
--

DROP TABLE IF EXISTS `iic_crm_campaign_rel_agent`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_campaign_rel_agent` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint DEFAULT NULL COMMENT '租户id',
  `campaign_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '营销活动编码',
  `org_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '组织节点',
  `agent_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '分配的代理人userid',
  `agent_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '代理人姓名',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=262 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='营销活动代理人子表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_campaign_rel_allocation_group`
--

DROP TABLE IF EXISTS `iic_crm_campaign_rel_allocation_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_campaign_rel_allocation_group` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint DEFAULT NULL COMMENT '租户id',
  `campaign_code` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL,
  `allocation_group_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'allocation_group_code',
  `is_delete` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '是否删除，1是0否',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_allocation_group_code` (`allocation_group_code`)
) ENGINE=InnoDB AUTO_INCREMENT=177 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='campaign关联allocation_group表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_campaign_rel_material`
--

DROP TABLE IF EXISTS `iic_crm_campaign_rel_material`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_campaign_rel_material` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint NOT NULL COMMENT '租户id',
  `campaign_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '营销活动编码',
  `material_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '附件名称',
  `material_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '附件文件上传id',
  `record_date` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '附件上传时间',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `material_type` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '类型：0普通，1邮件',
  `material_size` bigint DEFAULT NULL COMMENT '文件大小',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=849 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='营销活动附件子表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_campaign_rel_org`
--

DROP TABLE IF EXISTS `iic_crm_campaign_rel_org`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_campaign_rel_org` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint DEFAULT NULL COMMENT '租户id',
  `campaign_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '营销活动编码',
  `org_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '组织节点code',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `segment_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'segment节点code',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `campaign_rel_org_idx_org_code` (`org_code`),
  KEY `campaign_rel_org_idx_campaign_code` (`campaign_code`)
) ENGINE=InnoDB AUTO_INCREMENT=3052 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='营销活动组织节点子表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_campaign_rel_product`
--

DROP TABLE IF EXISTS `iic_crm_campaign_rel_product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_campaign_rel_product` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint DEFAULT NULL COMMENT '租户id',
  `campaign_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '营销活动编码',
  `insur_company_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '保险公司编码',
  `product_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '产品编码',
  `product_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '产品名称',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `product_path` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '产品路径',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_campaign_code` (`campaign_code`)
) ENGINE=InnoDB AUTO_INCREMENT=15269 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='营销活动产品子表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_campaign_rel_role`
--

DROP TABLE IF EXISTS `iic_crm_campaign_rel_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_campaign_rel_role` (
  `id` bigint unsigned NOT NULL COMMENT '主键',
  `tenant_id` bigint NOT NULL COMMENT '租户id',
  `campaign_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '模板编号',
  `role_code` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '角色编码',
  `role_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '角色名称',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='活动角色关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_campaign_target_customer`
--

DROP TABLE IF EXISTS `iic_crm_campaign_target_customer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_campaign_target_customer` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `campaign_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '活动编码',
  `customer_id` varchar(50) NOT NULL COMMENT '客户ID',
  `is_transform` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT '是否已转换为线索，0：未转换 1：已转换',
  `campaign_leads_type` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'campaign leads来源类型',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` varchar(50) NOT NULL DEFAULT 'SYSTEM',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by` varchar(50) NOT NULL DEFAULT 'SYSTEM',
  `batch_no` bigint DEFAULT NULL COMMENT '批次号',
  `status` char(1) DEFAULT '0' COMMENT '状态',
  `top_label` char(1) DEFAULT '0' COMMENT '顶top_label',
  `psi_id` varchar(50) DEFAULT NULL COMMENT '组织psid',
  `email_status` char(1) DEFAULT '0' COMMENT '是否发送邮件 0:未发送 1:已发送',
  `sales_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '首选代理人编码',
  `dae_country_code` varchar(20) DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `resource` varchar(2) NOT NULL DEFAULT '1' COMMENT '客户来源：1.客户，2线索',
  `resource_id` varchar(32) DEFAULT NULL COMMENT '来源id',
  `created_by_login_user` varchar(50) DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `index_campaign_code_customer_id` (`campaign_code`,`customer_id`),
  KEY `psi_id_idx` (`psi_id`)
) ENGINE=InnoDB AUTO_INCREMENT=36570 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='活动目标客户表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_campaign_template`
--

DROP TABLE IF EXISTS `iic_crm_campaign_template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_campaign_template` (
  `id` bigint unsigned NOT NULL COMMENT '主键',
  `tenant_id` bigint NOT NULL COMMENT '租户id',
  `template_code` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '模板编号',
  `template_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '模板名称',
  `template_desc` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '模板描述',
  `source` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '来源',
  `category` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '分类',
  `type` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '类型',
  `sub_type` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '子类型',
  `start_time` date NOT NULL COMMENT '开始时间',
  `end_time` date DEFAULT NULL COMMENT '结束时间',
  `open_end` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '开放标识;0:有结束时间；1:无结束时间',
  `status` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '状态，1-Active;2-Expired;3-Pending;4-Closed',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='活动模板表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_campaign_template_material`
--

DROP TABLE IF EXISTS `iic_crm_campaign_template_material`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_campaign_template_material` (
  `id` bigint unsigned NOT NULL COMMENT '主键',
  `tenant_id` bigint NOT NULL COMMENT '租户id',
  `template_code` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '模板编号',
  `material_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '材料名称',
  `material_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '材料id',
  `record_date` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '上传时间',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='活动模板关联材料表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_campaign_template_org`
--

DROP TABLE IF EXISTS `iic_crm_campaign_template_org`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_campaign_template_org` (
  `id` bigint unsigned NOT NULL COMMENT '主键',
  `tenant_id` bigint NOT NULL COMMENT '租户id',
  `template_code` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '模板编号',
  `org_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '组织编码',
  `org_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '组织名称',
  `org_json` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '前端回显使用',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='活动模板关联组织表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_campaign_template_org_json`
--

DROP TABLE IF EXISTS `iic_crm_campaign_template_org_json`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_campaign_template_org_json` (
  `id` bigint unsigned NOT NULL COMMENT '主键',
  `tenant_id` bigint NOT NULL COMMENT '租户id',
  `template_code` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '模板编码',
  `org_json` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '选择的组织回显字段',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='活动模板组织选择json保存表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_campaign_template_role`
--

DROP TABLE IF EXISTS `iic_crm_campaign_template_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_campaign_template_role` (
  `id` bigint unsigned NOT NULL COMMENT '主键',
  `tenant_id` bigint NOT NULL COMMENT '租户id',
  `template_code` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '模板编号',
  `role_code` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '角色编码',
  `role_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '角色名称',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='活动模板关联角色表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_campaign_upload_record`
--

DROP TABLE IF EXISTS `iic_crm_campaign_upload_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_campaign_upload_record` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `campaign_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '营销活动编码',
  `batch_no` bigint NOT NULL COMMENT '批次号',
  `file_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '文件名称',
  `upload_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '上传时间',
  `customer_num` int DEFAULT NULL COMMENT '数据条数',
  `is_submit` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '是否提交（0：未提交，1：已提交）默认0',
  `submit_time` datetime DEFAULT NULL COMMENT '提交时间',
  `fileKey` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '文件key',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `file_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '类型,2:PF/3:MFC',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `check_status` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '0：校验中。1：校验不通过。2校验通过',
  `error_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '错误的sales行数等信息',
  `result_file_key` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '校验salesCode有误的文件key',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`),
  KEY `idx_campaign_code` (`campaign_code`)
) ENGINE=InnoDB AUTO_INCREMENT=1343 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_common_reference`
--

DROP TABLE IF EXISTS `iic_crm_common_reference`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_common_reference` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '数据类型',
  `display_value` json DEFAULT NULL,
  `created_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT 'SYSTEM',
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT 'SYSTEM',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=356 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='国家名称表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_consent_upload_record`
--

DROP TABLE IF EXISTS `iic_crm_consent_upload_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_consent_upload_record` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `tenant_id` bigint NOT NULL COMMENT '租户id',
  `record_unique_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '与consent表的code字段对应',
  `customer_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '客户id',
  `agent_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '代理人id',
  `adviser_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'adviserCode',
  `file_type` varchar(30) COLLATE utf8mb4_bin NOT NULL,
  `reference_number` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'fileKey/referenceNumber',
  `file_name` varchar(200) COLLATE utf8mb4_bin NOT NULL,
  `file_size` bigint unsigned NOT NULL,
  `type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '类型0=e-sign，1=LOC',
  `dae_country_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `document_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'dae生成16位纯数字唯一码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_created_by_created_date` (`created_by`,`updated_date`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=116 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='Consent文件上传记录表(LOC/E-sign)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_country_in_world`
--

DROP TABLE IF EXISTS `iic_crm_country_in_world`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_country_in_world` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `country_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '国家名称',
  `country_code` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '国家编码',
  `sort` int NOT NULL COMMENT '排序编号',
  `is_deleted` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '是否已删除 0-未删除 1-已删除',
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=254 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='OM 全球国家表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_country_info`
--

DROP TABLE IF EXISTS `iic_crm_country_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_country_info` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `country_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `country_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `state_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `state_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `city_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `city_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `suburb_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `suburb_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=315 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_customer_address`
--

DROP TABLE IF EXISTS `iic_crm_customer_address`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_customer_address` (
  `id` bigint unsigned NOT NULL COMMENT '主键',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `customer_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '客户账户',
  `type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '类型',
  `country` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '国家',
  `address` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '地址',
  `zip_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '邮编',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `province` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `city` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='客户地址表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_customer_agent_relation`
--

DROP TABLE IF EXISTS `iic_crm_customer_agent_relation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_customer_agent_relation` (
  `id` bigint unsigned NOT NULL COMMENT 'id',
  `customer_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '客户id',
  `agent_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '代理人id',
  `tenant_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '租户id',
  `org_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '组织节点',
  `following_status` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '关注状态(0:默认未关注，1：关注)',
  `CREATED_BY` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `CREATED_DATE` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `UPDATED_BY` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `UPDATED_DATE` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_vip` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT '0:否; 1:是',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `tenant_customer_agent` (`tenant_id`,`customer_id`,`agent_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='客户代理人关系表 ';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_customer_cap_approval_info`
--

DROP TABLE IF EXISTS `iic_crm_customer_cap_approval_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_customer_cap_approval_info` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `reference_number` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'reference_number',
  `file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '附件文件名',
  `signature_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '签名文件key',
  `sign_date` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '签字时间',
  `reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '拒绝理由',
  `tenant_id` bigint NOT NULL COMMENT '租户id',
  `is_delete` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '是否删除1是0否',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '修改人',
  `file_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '文件key',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=74 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='cap审批信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_customer_cap_record`
--

DROP TABLE IF EXISTS `iic_crm_customer_cap_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_customer_cap_record` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `user_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '用户id',
  `customer_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '客户id',
  `type` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '类型: 1 exchange, 2 detail',
  `data` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT 'json数据',
  `tenant_id` bigint NOT NULL COMMENT '租户id',
  `is_delete` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '是否删除1是0否',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '修改人',
  `status` tinyint NOT NULL DEFAULT '0' COMMENT '审批状态：Approved（2）, Rejected（1）, Pending（0）',
  `customer_first_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '客户名称',
  `reference_number` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Appointment Reference Number',
  `first_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '名字',
  `surname` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '姓',
  `customer_last_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=269 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='cap操作记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_customer_cap_send`
--

DROP TABLE IF EXISTS `iic_crm_customer_cap_send`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_customer_cap_send` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `reference_number` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'reference_number',
  `user_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '用户id（代理人id）',
  `customer_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '客户id',
  `content` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '发送内容',
  `type` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '发送类型：SMS(0)',
  `send_status` tinyint NOT NULL DEFAULT '1' COMMENT '状态，0：默认  1：发送成功  -1 发送失败',
  `tenant_id` bigint NOT NULL COMMENT '租户id',
  `is_delete` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '是否删除1是0否',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '修改人',
  `receive` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '接收人',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='cap发送记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_customer_consent`
--

DROP TABLE IF EXISTS `iic_crm_customer_consent`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_customer_consent` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT 'id',
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '标识码',
  `customer_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '客户id',
  `agent_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '代理id',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT '签名状态：0：unknown、1：not request、 2：pending、 3：approved、 4：decline、5：expired',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `sign_date` datetime DEFAULT NULL COMMENT '签署时间',
  `request_phone` varchar(100) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '发送号码',
  `request_date` datetime DEFAULT NULL COMMENT '请求时间',
  `adviser_code` varchar(32) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'adviserCode',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `consent_type` tinyint unsigned DEFAULT NULL COMMENT '发起consent的类型，0-ussd手机号，1-LOC，2-电子签名',
  `customer_name` varchar(50) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '客户名称',
  `identity` varchar(50) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '客户身份证号',
  `consent_type_desc` varchar(32) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'the description of consent_type.',
  `delegatee_adviser_code` varchar(32) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'delegatee_adviser_code',
  `delegatee_user_id` varchar(32) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'delegatee_user_id',
  `origin_phone` varchar(100) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'the customer origin phone, differ from the column request_phone which is the latest phone used to ussd.',
  `phone_edited` char(1) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'value 0 means that origin_phone is equal to request_phone, and 1 means not.',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  `identity_type` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '证件类型',
  `request_count` int DEFAULT NULL COMMENT '请求次数',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=993 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='客户签署信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_customer_consent_his`
--

DROP TABLE IF EXISTS `iic_crm_customer_consent_his`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_customer_consent_his` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT 'id',
  `consent_id` int DEFAULT NULL COMMENT '授权记录Id',
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '标识码',
  `customer_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '客户id',
  `agent_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '代理id',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT '签名状态：0：unknown、1：not request、 2：pending、 3：approved、 4：decline、5：expired',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `sign_date` datetime DEFAULT NULL COMMENT '签署时间',
  `request_phone` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '发送号码',
  `adviser_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'adviserCode',
  `request_date` datetime DEFAULT NULL COMMENT '请求时间',
  `dae_country_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `consent_type` tinyint unsigned DEFAULT NULL COMMENT '发起consent的类型，0-ussd手机号，1-LOC，2-电子签名',
  `customer_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '客户名称',
  `identity` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '客户身份证号',
  `consent_type_desc` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'the description of consent_type.',
  `delegatee_adviser_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'delegatee_adviser_code',
  `delegatee_user_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'delegatee_user_id',
  `origin_phone` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'the customer origin phone, differ from the column request_phone which is the latest phone used to ussd.',
  `phone_edited` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'value 0 means that origin_phone is equal to request_phone, and 1 means not.',
  `created_by_login_user` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  `identity_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '证件类型',
  `request_count` int DEFAULT NULL COMMENT '请求次数',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=130 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='客户授权信息历史表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_customer_displaying`
--

DROP TABLE IF EXISTS `iic_crm_customer_displaying`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_customer_displaying` (
  `id` bigint unsigned NOT NULL COMMENT 'id',
  `customer_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '客户id',
  `tenant_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '租户id',
  `status` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '客户状态0：Lost，1：Active）',
  `last_interaction_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '上次互动时间',
  `is_delete` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '逻辑删除（0：未删除，1：已删除）',
  `CREATED_BY` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `CREATED_DATE` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `UPDATED_BY` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `UPDATED_DATE` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `leads_id` bigint unsigned DEFAULT NULL COMMENT '线索id',
  `vip_level` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT 'vip等级，0-普通；1-vip1',
  `org_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '默认组织',
  `become_vip_date` datetime DEFAULT NULL COMMENT '成为vip时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `iic_crm_customer_displaying_un` (`customer_id`) USING BTREE,
  KEY `idx_customer_displaying_leads_id` (`leads_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='客户展示信息表 ';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_customer_displaying_20220420`
--

DROP TABLE IF EXISTS `iic_crm_customer_displaying_20220420`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_customer_displaying_20220420` (
  `id` bigint unsigned NOT NULL COMMENT 'id',
  `customer_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '客户id',
  `tenant_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '租户id',
  `org_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '组织节点',
  `agent_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '代理人id',
  `status` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '客户状态0：Lost，1：Active）',
  `last_interaction_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '上次互动时间',
  `following_status` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '关注状态(0:默认未关注，1：关注)',
  `is_delete` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '逻辑删除（0：未删除，1：已删除）',
  `CREATED_BY` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `CREATED_DATE` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `UPDATED_BY` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `UPDATED_DATE` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `leads_id` bigint unsigned DEFAULT NULL COMMENT '线索id',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `iic_crm_customer_displaying_un` (`customer_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='客户展示信息表 ';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_customer_email`
--

DROP TABLE IF EXISTS `iic_crm_customer_email`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_customer_email` (
  `id` bigint unsigned NOT NULL COMMENT '主键',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `customer_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '客户账户',
  `type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '类型',
  `email` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '邮箱',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='客户邮箱表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_customer_family`
--

DROP TABLE IF EXISTS `iic_crm_customer_family`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_customer_family` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `customer_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '客户id',
  `tenant_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '租户id',
  `marital_status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '婚姻状况',
  `number_of_children` int DEFAULT NULL COMMENT '孩子数量',
  `family_members` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '家庭成员',
  `family_annual_income` decimal(20,0) DEFAULT NULL COMMENT '家庭年收入',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `iic_crm_customer_family_un` (`customer_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=49258 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='家庭情况';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_customer_file`
--

DROP TABLE IF EXISTS `iic_crm_customer_file`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_customer_file` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `customer_id` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '客户id',
  `tenant_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '租户id',
  `file_type` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '文件类型 1-FNA,2-Proposal,3-Policy Contract,4-E-Signature,5-Sales conduct record retention,6-Other Docs',
  `file_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '文件名',
  `file_date` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '文件日期',
  `file_url` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '文件url',
  `file_key` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '文件key',
  `file_size` decimal(6,2) DEFAULT NULL COMMENT '文件大小',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=142 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='客户文件记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_customer_filter`
--

DROP TABLE IF EXISTS `iic_crm_customer_filter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_customer_filter` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `filter_name` varchar(64) COLLATE utf8mb4_bin NOT NULL COMMENT 'filter名称',
  `filter_name_lowercase` varchar(64) COLLATE utf8mb4_bin NOT NULL COMMENT '小写敏感filter',
  `worksite` varchar(1024) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'work site code码',
  `age_from` int DEFAULT NULL COMMENT '年龄范围起始',
  `age_to` int DEFAULT NULL COMMENT '年龄范围截止',
  `birthdays` varchar(16) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '生日参数值',
  `marital_status` varchar(16) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '婚姻参数值',
  `gender` varchar(8) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '性别参数值',
  `last_contacted` varchar(8) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '联系客户频率参数值',
  `ena_status` varchar(16) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'ENA状态参数值',
  `favourite` varchar(2) COLLATE utf8mb4_bin DEFAULT '0' COMMENT '0:未收藏/1：已收藏',
  `is_delete` varchar(2) COLLATE utf8mb4_bin DEFAULT '0' COMMENT '0:未删除/1：已删除',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` varchar(100) COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by` varchar(100) COLLATE utf8mb4_bin DEFAULT 'SYSTEM',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `income` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  `dependents` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  `benefits` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  `address` text COLLATE utf8mb4_bin,
  `living_status` varchar(16) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '生存状态 Living/Deceased',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  `smart_goal_sign` varchar(32) COLLATE utf8mb4_bin DEFAULT NULL,
  `active_goals` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL,
  `goal_status` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL,
  `engaged_with_goals` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL,
  `new_goals_set` varchar(32) COLLATE utf8mb4_bin DEFAULT NULL,
  `email_sent` varchar(32) COLLATE utf8mb4_bin DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_customer_filter_created_by` (`created_by`),
  KEY `idx_customer_filter_name_lowercase` (`filter_name_lowercase`)
) ENGINE=InnoDB AUTO_INCREMENT=308 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='Customer Filter表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_customer_identity`
--

DROP TABLE IF EXISTS `iic_crm_customer_identity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_customer_identity` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `customer_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '客户id',
  `tenant_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '租户id',
  `id_type` char(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '证件类型',
  `id_no` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '证件号',
  `id_validity` datetime DEFAULT NULL COMMENT '有效期',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1858272 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='客户证件信息';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_customer_info`
--

DROP TABLE IF EXISTS `iic_crm_customer_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_customer_info` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `customer_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '客户id',
  `first_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `last_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `tele_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '电话',
  `age` int unsigned DEFAULT NULL COMMENT '年龄',
  `email` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '邮箱',
  `engagement` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '婚姻',
  `birthdate` date DEFAULT NULL COMMENT '生日',
  `gender` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '性别',
  `income` decimal(32,1) DEFAULT NULL COMMENT '收入',
  `application_scope` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '组织节点',
  `segment_code` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '首选代理人segment',
  `channel_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '首选代理人channel',
  `sales_code_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '首选代理人类型',
  `sales_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '首选代理人编码',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` varchar(50) NOT NULL DEFAULT 'SYSTEM',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by` varchar(50) NOT NULL DEFAULT 'SYSTEM',
  `suburb` varchar(100) DEFAULT NULL COMMENT '区域',
  `test_cell` varchar(100) DEFAULT NULL COMMENT '销售code',
  `rewards_tier` varchar(100) DEFAULT NULL COMMENT '客户信息rewards_tier',
  `rewards_client` varchar(100) DEFAULT NULL COMMENT '客户信息rewards_client',
  `pf_cvp_segments` varchar(100) DEFAULT NULL COMMENT '客户信息pf_cvp_segments',
  `tel_type` varchar(10) DEFAULT NULL COMMENT '电话类型',
  `id_document_type` varchar(100) DEFAULT NULL COMMENT '身份证类型',
  `identity_number` varchar(100) DEFAULT NULL COMMENT '身份证号码',
  `comms_received` varchar(100) DEFAULT NULL COMMENT '备注',
  `campaign_name` varchar(100) DEFAULT NULL COMMENT 'campaign名称',
  `ds_campaign_month` varchar(100) DEFAULT NULL COMMENT 'campaign月份',
  `ind_type_desc` varchar(100) DEFAULT NULL COMMENT '客户信息ind_type_desc',
  `production_channel` varchar(100) DEFAULT NULL COMMENT '产品渠道',
  `correspond_lang` varchar(100) DEFAULT NULL COMMENT '客户信息correspond_lang',
  `email_address` varchar(100) DEFAULT NULL COMMENT '邮件地址',
  `home_number` varchar(100) DEFAULT NULL COMMENT '家庭号码',
  `work_number` varchar(100) DEFAULT NULL COMMENT '工作号码',
  `cell_number` varchar(100) DEFAULT NULL COMMENT '私人号码',
  `gcs_id` varchar(100) DEFAULT NULL COMMENT '客户信息gcs_id',
  `date_of_birth` varchar(100) DEFAULT NULL COMMENT '生日',
  `surname` varchar(100) DEFAULT NULL COMMENT '名称',
  `first_names` varchar(100) DEFAULT NULL COMMENT '姓',
  `initials` varchar(100) DEFAULT NULL COMMENT '客户信息initials',
  `title` varchar(100) DEFAULT NULL COMMENT '职称',
  `category` varchar(100) DEFAULT NULL COMMENT '客户category',
  `cell_phone_no` varchar(100) DEFAULT NULL COMMENT '手机号码',
  `home_telephone_no` varchar(100) DEFAULT NULL COMMENT '家庭电话',
  `staff_code` varchar(100) DEFAULT NULL COMMENT '员工编码',
  `worksite_code` varchar(100) DEFAULT NULL COMMENT '工作地编码',
  `worksite` varchar(100) DEFAULT NULL COMMENT '工作地',
  `service_id` varchar(100) DEFAULT NULL COMMENT '系统逻辑系统，上游系统输出。，后续需要给下游ONESTREAM',
  `office_cell` varchar(100) DEFAULT NULL COMMENT '办公电话',
  `agreement_number` varchar(100) DEFAULT NULL COMMENT '保单号码',
  `detailed_income_band` varchar(100) DEFAULT NULL COMMENT '收入区间',
  `recurring_invest` varchar(100) DEFAULT NULL COMMENT '产品参数-不确定',
  `policy_type` varchar(100) DEFAULT NULL COMMENT '保单类型',
  `comments` varchar(100) DEFAULT NULL COMMENT '其他备注',
  `list_id` varchar(100) DEFAULT NULL COMMENT '上游系统的逻辑字段，后续需要给下游ONESTREAM',
  `is_draft` char(1) DEFAULT '0' COMMENT '是否草稿',
  `dae_country_code` varchar(20) DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `postal_code` varchar(32) DEFAULT NULL COMMENT '邮编',
  `created_by_login_user` varchar(50) DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) DEFAULT 'SYSTEM' COMMENT '实际修改人',
  `branch_id` varchar(20) DEFAULT NULL COMMENT 'OM数据库的branch_id',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `index_customer_id` (`customer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=49274 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='客户池mock表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_customer_label`
--

DROP TABLE IF EXISTS `iic_crm_customer_label`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_customer_label` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '租户id',
  `label_id` int NOT NULL COMMENT '标签id',
  `label_content` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '标签内容',
  `customer_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '客户id',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=242 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='客户标签表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_customer_note`
--

DROP TABLE IF EXISTS `iic_crm_customer_note`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_customer_note` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '租户id',
  `note_content` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '备注内容',
  `first_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '名',
  `middle_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '中间名',
  `last_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '姓',
  `customer_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '客户id',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `agent_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '代理人id',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=82 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='客户备注表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_customer_occupation_income`
--

DROP TABLE IF EXISTS `iic_crm_customer_occupation_income`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_customer_occupation_income` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `customer_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '客户id',
  `tenant_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '租户id',
  `occupation` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '职业',
  `employer` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '雇主（公司）名',
  `job_title` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '岗位',
  `annual_income` decimal(32,0) DEFAULT NULL COMMENT '年收入',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `iic_crm_customer_occupation_income_un` (`customer_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=49257 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='客户职业收入信息';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_customer_payment`
--

DROP TABLE IF EXISTS `iic_crm_customer_payment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_customer_payment` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `customer_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '客户id',
  `tenant_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '租户id',
  `default_payment_method` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '是否默认支付方式',
  `card_holder` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '卡主姓名',
  `account_number` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '银行卡号',
  `card_type` char(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '银行卡类型',
  `bank_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '银行名',
  `branch_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '银行机构名',
  `expires_on` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '银行卡有效期',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1849257 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='客户支付信息';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_customer_personal`
--

DROP TABLE IF EXISTS `iic_crm_customer_personal`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_customer_personal` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `customer_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '客户id',
  `tenant_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '租户id',
  `agent_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '代理人id',
  `salutation` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '称谓',
  `first_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '名',
  `last_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '姓',
  `full_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '全名',
  `gender` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '性别',
  `date_of_birth` date DEFAULT NULL COMMENT '出生日期',
  `age` int DEFAULT NULL COMMENT '年龄',
  `profile_photo` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '照片（头像）',
  `education` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '学历（PhD/ Master/ Bachelor/ High School/ Elementary School/ Other）',
  `weight` decimal(5,2) DEFAULT NULL COMMENT '体重',
  `height` decimal(5,2) DEFAULT NULL COMMENT '身高',
  `occupation` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '职业',
  `employer` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '雇主（公司）名',
  `job_title` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '岗位',
  `annual_income` decimal(32,8) DEFAULT NULL COMMENT '年收入',
  `marital_status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '婚姻状况',
  `number_of_children` int DEFAULT NULL COMMENT '孩子数量',
  `family_annual_income` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '家庭年收入',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `needs` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `time_of_call` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `speak_way` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '0：Face to Face；1：Telephonic',
  `social_insurance` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '1:有/2:无',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `iic_crm_customer_personal_un` (`customer_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=63536 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='个人信息表 ';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_customer_phone`
--

DROP TABLE IF EXISTS `iic_crm_customer_phone`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_customer_phone` (
  `id` bigint unsigned NOT NULL COMMENT '主键',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户id',
  `customer_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '类型',
  `number` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '号码',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='客户联系方式表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_customer_portfolio_disclaimer_record`
--

DROP TABLE IF EXISTS `iic_crm_customer_portfolio_disclaimer_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_customer_portfolio_disclaimer_record` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '报销编码',
  `type` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '0：web，1：app ',
  `claimer_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '记录点击提醒的日期',
  `tenant_id` bigint NOT NULL COMMENT '租户ID',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1675 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='customer portfolio disclaimer 记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_customer_recommend_product`
--

DROP TABLE IF EXISTS `iic_crm_customer_recommend_product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_customer_recommend_product` (
  `id` bigint unsigned NOT NULL COMMENT '主键',
  `customer_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '客户id',
  `product_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '产品编码',
  `insur_company_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '保险公司编码',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='客户推荐产品表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_customer_rel_leads`
--

DROP TABLE IF EXISTS `iic_crm_customer_rel_leads`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_customer_rel_leads` (
  `id` bigint unsigned NOT NULL COMMENT '主键',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `customer_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '客户id',
  `leads_id` bigint unsigned NOT NULL COMMENT '线索id',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `customer_id` (`customer_id`,`leads_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='客户-线索关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_customer_update_vip`
--

DROP TABLE IF EXISTS `iic_crm_customer_update_vip`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_customer_update_vip` (
  `id` bigint unsigned NOT NULL COMMENT '主键',
  `customer_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '客户id',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='客户待更新vip等级表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_dae_om_outlook`
--

DROP TABLE IF EXISTS `iic_crm_dae_om_outlook`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_dae_om_outlook` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `transaction_id` varchar(60) COLLATE utf8mb4_bin NOT NULL COMMENT 'dae给om同步的操作id,唯一key',
  `event_id` varchar(300) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'outlook返回的操作id,唯一key',
  `user_id` char(50) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '用户id',
  `target_system` varchar(255) COLLATE utf8mb4_bin NOT NULL COMMENT '目标系统的名称或标识符,OM_OUTLOOK',
  `call_type` char(1) COLLATE utf8mb4_bin NOT NULL COMMENT '调用类型,1-create 2-update 3-delete 4-retrieve',
  `request_body` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '入参',
  `push_time` datetime DEFAULT NULL COMMENT '推送时间',
  `push_status` char(1) COLLATE utf8mb4_bin NOT NULL COMMENT '推送状态，0-待推送 1-已推送',
  `push_result` varchar(600) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '推送结果',
  `push_count` tinyint NOT NULL DEFAULT '0' COMMENT '推送次数，初始值为0',
  `last_push_time` datetime DEFAULT NULL COMMENT '上一次推送时间，初始值为null',
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `transaction_id` (`transaction_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3827 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='dae给om推送outlook状态记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_dae_om_outlook_exception`
--

DROP TABLE IF EXISTS `iic_crm_dae_om_outlook_exception`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_dae_om_outlook_exception` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `transaction_id` varchar(60) COLLATE utf8mb4_bin NOT NULL COMMENT 'dae给om同步的操作id,唯一key',
  `target_system` varchar(255) COLLATE utf8mb4_bin NOT NULL COMMENT '目标系统的名称或标识符,OM_OUTLOOK',
  `push_count` tinyint NOT NULL DEFAULT '0' COMMENT '推送次数，初始值为0',
  `exception_time` datetime NOT NULL COMMENT '异常发生时间',
  `exception_msg` varchar(3000) COLLATE utf8mb4_bin NOT NULL COMMENT '异常信息',
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=10806 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='dae给om推送outlook异常记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_dashboard_leads`
--

DROP TABLE IF EXISTS `iic_crm_dashboard_leads`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_dashboard_leads` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `lead_id` bigint NOT NULL,
  `org_code` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  `org_name` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  `user_id` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  `user_name` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  `leads_status` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  `priority` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  `source` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  `campaign_code` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  `campaign_name` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  `create_date` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  `downstream` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  `escalation_sales_manager` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  `escalation_team` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  `total_assign` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  `allocate_org_code` text COLLATE utf8mb4_bin COMMENT '分配组织code',
  `allocate_org_name` text COLLATE utf8mb4_bin COMMENT '分配组织名称',
  `allocate_direct_leader` text COLLATE utf8mb4_bin COMMENT '分配直系领导id',
  `allocate_direct_leader_name` text COLLATE utf8mb4_bin COMMENT '分配直系领导名称',
  `allocate_adviser` text COLLATE utf8mb4_bin COMMENT '分配代理人id',
  `allocate_adviser_name` text COLLATE utf8mb4_bin COMMENT '分配代理人名称',
  `close_date` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  `close_reason_theme` varchar(1024) COLLATE utf8mb4_bin DEFAULT NULL,
  `close_reason_sub_theme` varchar(1024) COLLATE utf8mb4_bin DEFAULT NULL,
  `close_reason_other_reason` varchar(1024) COLLATE utf8mb4_bin DEFAULT NULL,
  `role_name` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  `region_name` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  `area_name` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  `team_name` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  `channel_name` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  `sla_status` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  `segment` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  `created_by` varchar(100) COLLATE utf8mb4_bin NOT NULL COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(100) COLLATE utf8mb4_bin NOT NULL COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=148525013 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='iic_crm_dashboard_leads';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_delegation`
--

DROP TABLE IF EXISTS `iic_crm_delegation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_delegation` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `tenant_id` bigint NOT NULL COMMENT '租户id',
  `delegation_unique_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `scope` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '委派范围',
  `delegator` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '委派人id',
  `delegatee` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '被委派人id',
  `action_time` datetime DEFAULT NULL COMMENT '操作时间',
  `action_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '操作类型',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '1' COMMENT '"1:To be Accepted\r\n2:Accepted\r\n3: Declined\r\n4:Completed \r\n5:Overdue"\r\n',
  `start_time` datetime NOT NULL COMMENT '开始时间',
  `end_time` datetime NOT NULL COMMENT '结束时间',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT '逻辑删除（0：未删除，1：已删除）',
  `role_code` varchar(100) COLLATE utf8mb4_bin NOT NULL DEFAULT '' COMMENT 'delegator创建委派时的business_role_code',
  `delegatee_role_resource` text COLLATE utf8mb4_bin NOT NULL COMMENT '委派人委派出去的业务角色及对应的菜单',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  `delegation_type` char(1) COLLATE utf8mb4_bin NOT NULL DEFAULT '0',
  `connection_role` varchar(50) COLLATE utf8mb4_bin DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=542 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='委派表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_delegation_contract`
--

DROP TABLE IF EXISTS `iic_crm_delegation_contract`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_delegation_contract` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `tenant_id` bigint NOT NULL COMMENT '租户id',
  `delegation_unique_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `delegator` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '委派人id',
  `third_delegator` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '委派人id',
  `delegatee` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '被委派人id',
  `delegator_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '委派人名称',
  `third_delegator_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '委派人名称',
  `delegatee_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '被委派人名称',
  `delegator_time` datetime DEFAULT NULL COMMENT '委派人签约时间',
  `delegatee_time` datetime DEFAULT NULL COMMENT '被委派人签约时间',
  `org_code_path_tor` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '委派人所在组织',
  `org_code_path_tee` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '被委派人所在组织',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT '逻辑删除（0：未删除，1：已删除）',
  `dae_country_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `iic_crm_delegation_contract_delegator_IDX` (`delegator`) USING BTREE,
  KEY `iic_crm_delegation_contract_delegatee_IDX` (`delegatee`) USING BTREE,
  KEY `iic_crm_delegation_contract_delegation_unique_code_IDX` (`delegation_unique_code`) USING BTREE,
  KEY `iic_crm_delegation_contract_org_code_path_tor_IDX` (`org_code_path_tor`) USING BTREE,
  KEY `iic_crm_delegation_contract_org_code_path_tee_IDX` (`org_code_path_tee`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=5802 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='委派表签署协议表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_delegation_rel`
--

DROP TABLE IF EXISTS `iic_crm_delegation_rel`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_delegation_rel` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `tenant_id` bigint NOT NULL COMMENT '租户id',
  `delegation_rel_unique_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `delegation_id` bigint NOT NULL,
  `delegator_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '委派人id',
  `business_key` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `result` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '被委派人id',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT '逻辑删除（0：未删除，1：已删除）',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=839 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='委派关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_delegation_task`
--

DROP TABLE IF EXISTS `iic_crm_delegation_task`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_delegation_task` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `delegation_id` bigint NOT NULL COMMENT '委派id',
  `start_date` datetime DEFAULT NULL COMMENT '任务开始时间',
  `end_date` datetime DEFAULT NULL COMMENT '任务结束时间',
  `pause_date` datetime DEFAULT NULL COMMENT 'delegation暂停时间',
  `status` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '01' COMMENT '任务状态 01 In Progress, 02 To Be Acknowledged, 03 Cancelled, 04 Completed, 05 Overdue',
  `delegator` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '委派人id',
  `delegatee` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '被委派人id',
  `delegation_creator` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '委派创建人id',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户id',
  `is_delete` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '是否删除1是0否',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '修改人',
  `is_third_delegator` char(1) DEFAULT '0' COMMENT '是否第三方委派，0=否，1=是',
  `created_by_login_user` varchar(50) DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_delegation_id` (`delegation_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='委派任务表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_delegation_task_schedule_log`
--

DROP TABLE IF EXISTS `iic_crm_delegation_task_schedule_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_delegation_task_schedule_log` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `delegation_id` bigint NOT NULL COMMENT '委派id',
  `task_id` bigint DEFAULT NULL COMMENT '任务id',
  `type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '1' COMMENT '1=create, 2=overdue, 3=suspended',
  `schedule_status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '0=success, 1=fail',
  `fail_reason` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '失败原因',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户id',
  `is_delete` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '是否删除1是0否',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '修改人',
  `created_by_login_user` varchar(50) DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='委派任务自动执行记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_email_recurrence_setting`
--

DROP TABLE IF EXISTS `iic_crm_email_recurrence_setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_email_recurrence_setting` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `customer_id` varchar(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '客户id',
  `start_date_original` varchar(10) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '循环开始时间(页面)',
  `start_date` varchar(10) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '循环开始时间',
  `end_date` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '循环结束时间',
  `content_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '邮件类型',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '状态',
  `recurrence` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '频率：1-每年，2-月频率',
  `month` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '频率为每年时-指代具体月份，为月频率时，即为每隔几个月的当月第几日发送',
  `day` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '月份中的具体时间',
  `email` varchar(500) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'email，多个邮件以逗号分割',
  `next_date` datetime DEFAULT NULL COMMENT '下一次循环时间',
  `user_id` varchar(36) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '创建循环的代理人userid',
  `tenant_id` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '租户id',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_next_date` (`next_date`),
  KEY `idx_customer_id` (`customer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=141 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='循环邮件发送配置表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_email_recurrence_setting_ex_log`
--

DROP TABLE IF EXISTS `iic_crm_email_recurrence_setting_ex_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_email_recurrence_setting_ex_log` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `biz_id` varchar(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '业务id',
  `ex_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '错误日志状态，0=正常异常，1=非正常异常',
  `ex_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '错误日志状态码（参考代码）',
  `ex_msg` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '错误日志消息',
  `trigger_date` datetime DEFAULT NULL COMMENT '触发时间',
  `req_id` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'log的requestId',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=793 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='循环邮件发送配置错误日志';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_field_config_catalog`
--

DROP TABLE IF EXISTS `iic_crm_field_config_catalog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_field_config_catalog` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `tenant_id` bigint NOT NULL COMMENT '租户编码',
  `catalog_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '分类编码',
  `catalog_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '分类名称',
  `is_deleted` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT '0=未删除，1=已删除',
  `sortable` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '1' COMMENT '0=不可排序，1=可排序',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `tenant_catalog_code` (`tenant_id`,`catalog_code`) USING BTREE,
  KEY `idx_is_deleted` (`is_deleted`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='字段配置分类表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_field_config_detail`
--

DROP TABLE IF EXISTS `iic_crm_field_config_detail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_field_config_detail` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `tenant_id` bigint NOT NULL COMMENT '租户编码',
  `field_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '字段名',
  `field_code` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '字段编码',
  `catalog_id` bigint unsigned NOT NULL COMMENT '分类编码',
  `is_deleted` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT '0=未删除，1=已删除',
  `editable` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '1' COMMENT '0=不可修改，1=可修改',
  `deletable` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '1' COMMENT '0=不可删除，1=可删除',
  `sort` int NOT NULL COMMENT '顺序编号，从0开始',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `field_detail_tenant_catalog_id_index` (`tenant_id`,`catalog_id`) USING BTREE,
  KEY `idx_catalog_id` (`catalog_id`),
  KEY `idx_sort` (`sort`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='字段配置分类详细表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_fna_recommend_product`
--

DROP TABLE IF EXISTS `iic_crm_fna_recommend_product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_fna_recommend_product` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT 'id',
  `result_code` bigint NOT NULL COMMENT 'FNA编码',
  `contact_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '客户/线索id',
  `contact_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '0线索 1客户',
  `product_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '产品编码',
  `product_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '产品名',
  `product_category` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '产品类型',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=337 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='FNA推荐产品信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_form_meta`
--

DROP TABLE IF EXISTS `iic_crm_form_meta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_form_meta` (
  `ID` bigint NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `TENANT_ID` bigint NOT NULL DEFAULT '0' COMMENT '租户ID',
  `FORM_FIELD_META` json NOT NULL COMMENT '字段配置元信息',
  `INIT_FLAG` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT 'N' COMMENT '是否预设表单信息',
  `REVISION` int NOT NULL DEFAULT '0' COMMENT '乐观锁',
  `CREATED_BY` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `UPDATED_BY` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '' COMMENT '更新人',
  `UPDATED_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `user_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '表单拥有者',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT '表单状态：0:草稿,1:生效',
  `source_category` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '分类 1:客户/线索信息表单；2:Hierarchy Field Settings；3:Account Data Settings；',
  `source` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '来源\n1:客户/线索信息表单；\n2:跳号\n3:Personal Data\n4:Organization Info\n5:Role Info\n6:User Info',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`ID`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='表单配置元信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_form_meta_history`
--

DROP TABLE IF EXISTS `iic_crm_form_meta_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_form_meta_history` (
  `ID` bigint NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `TENANT_ID` bigint NOT NULL DEFAULT '0' COMMENT '租户ID',
  `FORM_FIELD_META` json NOT NULL COMMENT '字段配置元信息',
  `INIT_FLAG` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT 'N' COMMENT '是否预设表单信息',
  `REVISION` int NOT NULL DEFAULT '0' COMMENT '乐观锁',
  `CREATED_BY` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `UPDATED_BY` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '' COMMENT '更新人',
  `UPDATED_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `user_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '表单拥有者',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT '表单状态：0:草稿,1:生效',
  `source_category` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '分类 1:客户/线索信息表单；2:Hierarchy Field Settings；3:Account Data Settings；',
  `source` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '来源 \r\n1:客户/线索信息表单；\r\n2:跳号\r\n3:Personal Data\r\n4:Organization Info\r\n5:Role Info\r\n6:User Info',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`ID`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=438 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='表单配置元信息历史记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_form_meta_instance`
--

DROP TABLE IF EXISTS `iic_crm_form_meta_instance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_form_meta_instance` (
  `ID` bigint NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `SOURCE_ID` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '源头ID',
  `FORM_FIELD_META` json NOT NULL COMMENT '字段配置元信息表ID',
  `FORM_META_ID` bigint NOT NULL DEFAULT '0' COMMENT '表单配置元信息表ID',
  `REVISION` int NOT NULL DEFAULT '0' COMMENT '乐观锁',
  `CREATED_BY` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `UPDATED_BY` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '' COMMENT '更新人',
  `UPDATED_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `source` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '1:线索;2:客户',
  `is_delete` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0',
  `tenant_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '租户id',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`ID`) USING BTREE,
  KEY `idx_source_sourceId` (`source`,`SOURCE_ID`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=11888 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='表单配置元信息实例化表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_gdm_pdf_record`
--

DROP TABLE IF EXISTS `iic_crm_gdm_pdf_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_gdm_pdf_record` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `result_code` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '业务结果码，唯一标识，关联上游表（如问卷结果）',
  `customer_name` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '客户名称，用于展示与检索',
  `customer_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '客户/线索id',
  `storage_type` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'LOCAL' COMMENT '存储类型：LOCAL（本地临时） / S3 / OSS / MINIO',
  `pdf_file_path` varchar(512) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '本地临时文件路径（如：/tmp/pdf/abc123.pdf）',
  `pdf_s3_bucket` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'S3 Bucket名称（如：gdm-pdf-prod-2026）',
  `pdf_s3_key` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'S3中文件Key路径（如：pdf/2026/01/06/abc123.pdf）',
  `pdf_s3_url` varchar(512) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'S3文件公网访问URL（自动拼接）',
  `pdf_file_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '原始文件名（如：合同_张三_20260106.pdf）',
  `pdf_file_size` bigint NOT NULL COMMENT '文件大小（字节）',
  `pdf_md5` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '文件MD5哈希值，用于完整性校验',
  `status` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '状态：PENDING / GENERATED / FAILED / ARCHIVED / DELETED',
  `generate_time` datetime NOT NULL COMMENT 'PDF生成时间（精确到秒）',
  `created_by` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '创建人（如：system, advisor_123）',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
  `updated_by` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '最后更新人',
  `updated_date` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '最后更新时间',
  `remark` text COLLATE utf8mb4_unicode_ci COMMENT '备注信息（如：失败原因、S3上传日志、临时路径说明）',
  `created_by_login_user` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_result_code` (`result_code`),
  KEY `idx_customer_name` (`customer_id`),
  KEY `idx_s3_key` (`pdf_s3_key`)
) ENGINE=InnoDB AUTO_INCREMENT=106 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='PDF生成记录表（兼容本地临时文件与AWS S3）';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_gdm_survey_answer`
--

DROP TABLE IF EXISTS `iic_crm_gdm_survey_answer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_gdm_survey_answer` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_phone` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '客户手机号',
  `client_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '客户姓名',
  `agent_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '代理人编码',
  `id_topic` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '题目编码',
  `version_no` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '问卷版本',
  `answer` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '答案内容',
  `id_survey` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '题目类型 1=单选，2=多选，3=输入',
  `checked_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT '是否勾选：0-否，1-是',
  `module_id` int NOT NULL COMMENT '模块id',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `result_code` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'result表唯一code',
  `dae_country_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_five` (`id_survey`,`version_no`,`agent_code`,`client_name`,`client_phone`),
  KEY `iic_crm_gdm_survey_answer_result_code_idx` (`result_code`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=6117 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='GDM问卷答案表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_gdm_survey_result`
--

DROP TABLE IF EXISTS `iic_crm_gdm_survey_result`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_gdm_survey_result` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `result_code` bigint NOT NULL COMMENT '结果编码',
  `agent_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '代理人编号',
  `client_phone` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '电话',
  `client_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '客户名字',
  `id_survey` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '问卷编码',
  `version_no` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '问卷版本号',
  `product_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '产品编码',
  `product_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '产品名',
  `recommend_reason` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '推荐原因',
  `recommend_amount` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '推荐保额',
  `product_category` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '产品类型',
  `product_desc` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '产品描述',
  `product_picture` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '产品图片',
  `contact_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '客户/线索id',
  `contact_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '客户/线索id类型：1-线索，2-客户',
  `insur_company_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '保司编码',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `draft` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT '0=已完成，1=草稿',
  `cur_module_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '草稿状态下当前模块',
  `common_dependant` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '前端暂存字段',
  `currency_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'zar' COMMENT '默认值zar, zar代表南非货币 nad代表纳米比亚货币',
  `dae_country_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  `is_deleted` char(1) COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '0:否,1:是',
  `link_result_code` bigint DEFAULT NULL COMMENT '关联resultCode',
  PRIMARY KEY (`id`),
  KEY `index_result_code_created_date` (`result_code`,`created_date`),
  KEY `idx_created_date` (`created_date`),
  KEY `test_index2` (`result_code`,`contact_id`),
  KEY `test_index` (`contact_id`,`result_code`,`contact_type`,`draft`)
) ENGINE=InnoDB AUTO_INCREMENT=246 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='GDM问卷结果表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_greeting_card`
--

DROP TABLE IF EXISTS `iic_crm_greeting_card`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_greeting_card` (
  `id` bigint unsigned NOT NULL COMMENT '主键',
  `tenant_id` bigint NOT NULL COMMENT '租户ID',
  `source_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '来源id',
  `source` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '类型(1-线索 2-客户)',
  `card_id` bigint DEFAULT NULL COMMENT '贺卡Id',
  `file_key` varchar(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '贺卡文件key',
  `word_id` bigint DEFAULT NULL COMMENT '贺词Id',
  `content` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '贺词',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='贺卡贺词信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_label_detail`
--

DROP TABLE IF EXISTS `iic_crm_label_detail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_label_detail` (
  `label_id` int NOT NULL AUTO_INCREMENT COMMENT '标签id（主键）',
  `tenant_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '租户id',
  `agent_id` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '代理人id',
  `label_type` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '标签类型（0：预设，1：自定义标签）',
  `label_content` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '标签内容',
  `last_display_time` datetime DEFAULT NULL COMMENT '上次使用时间',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`label_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=135 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='标签详情表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads`
--

DROP TABLE IF EXISTS `iic_crm_leads`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `priority` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '线索优先级',
  `tenant_id` bigint DEFAULT NULL COMMENT '代理人',
  `agent_id` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '代理人',
  `application_scope` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '应用范围（一级机构编码）',
  `journey_id` bigint DEFAULT NULL COMMENT '线索旅程id',
  `current_stage_id` bigint DEFAULT NULL COMMENT '当前所在线索阶段id',
  `sub_status_id` bigint DEFAULT NULL COMMENT '阶段子状态id',
  `score` decimal(10,2) DEFAULT NULL COMMENT '线索打分',
  `salutation` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '称谓',
  `leads_category` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '线索类型',
  `first_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '名',
  `last_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '姓',
  `full_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '全名',
  `gender` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '性别',
  `date_of_birth` date DEFAULT NULL COMMENT '出生日期',
  `age` int DEFAULT NULL COMMENT '年龄',
  `education` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '学历（PhD/ Master/ Bachelor/ High School/ Elementary School/ Other）',
  `body_weight` decimal(5,2) DEFAULT NULL COMMENT '体重',
  `height` decimal(5,2) DEFAULT NULL COMMENT '身高',
  `occupation` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '职业',
  `employer` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '雇主（公司）名',
  `job_title` varchar(128) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '岗位',
  `annual_income` decimal(32,8) DEFAULT NULL COMMENT '年收入',
  `marital_status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '婚姻状况',
  `number_of_children` int DEFAULT NULL COMMENT '孩子数量',
  `family_annual_income` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '家庭年收入',
  `id_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '证件类型（0:ID Card/ 1:Passport/ 2:Drivers Licence/ Other)',
  `id_number` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '证件号',
  `id_validity` date DEFAULT NULL COMMENT '证件有效期',
  `phone_number` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '电话号码',
  `phone_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '号码类型（0: Mobile/1: Work/2: Home/3: School/4: Fax/5: Other）',
  `email_address` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '邮箱地址',
  `email_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '邮箱类型（0: Work/1: Home/2: School/3: Other）',
  `address` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '详细地址',
  `address_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '地址类型（0: Work/1: Home/2: School/3: Other）',
  `postal_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '邮编',
  `source` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '选项暂为： Friend/Relative/Referral/Social media',
  `creation_time` datetime DEFAULT NULL COMMENT '线索阶段更新时间或重复线索合并完成时间',
  `is_existing` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '0: 未存在 1: 已存在',
  `is_active` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '0: 沉默 1：活跃',
  `is_overtime` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT '0：未超时 1：已超时',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '状态 0-待分配,1-待重新分配,2-已分配',
  `pool_source` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '平台来源 0=Customer portal,1=Social media,2=Manually created,3=Offical website,4=Third party ',
  `is_follow` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT '是否关注（0:未关注/1：已关注）',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT '0=未删除，1=已删除',
  `follow_date` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '最新跟进时间',
  `profile_photo` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `policy_no` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '保单号',
  `product_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `email` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '邮箱',
  `origin_id` bigint DEFAULT NULL COMMENT '原leads_id',
  `prem_sum` decimal(10,2) DEFAULT NULL COMMENT '保费',
  `campaign_id` varchar(100) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '活动id',
  `policy_created_date` datetime DEFAULT NULL COMMENT '保单创建时间',
  `conversion_date` datetime DEFAULT NULL COMMENT '线索转化成功时间',
  `leads_status` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '见crm模块LeadsStatusEnum',
  `close_type` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '关闭类型',
  `close_reason` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '关闭原因',
  `needs` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `time_of_call` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `speak_way` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '0：Face to Face；1：Telephonic',
  `available_call_time` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '可响应拨打电话时间范围',
  `prospector_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '线索客服id',
  `prospector_note` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '线索客服获取的notes',
  `call_start_time` datetime DEFAULT NULL COMMENT '通话开始时间',
  `call_end_time` datetime DEFAULT NULL COMMENT '通话结束时间',
  `out_come` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '通话记录',
  `allot_time` datetime DEFAULT NULL COMMENT '分配时间',
  `pre_allocation_stage` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '预分配阶段;0new 1:tel-prospector call 2:1st Assignment 3:2nd Assigment',
  `application_role` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '关联角色',
  `accept_within_limit` int DEFAULT NULL COMMENT '超时时间（分钟）',
  `social_insurance` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '1:有/2:无',
  `lead_feed` json DEFAULT NULL COMMENT 'ILMS原始数据',
  `feature` json DEFAULT NULL COMMENT 'OM原始数据',
  `is_workflow` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '是否需要工作流:0否；1是',
  `sla_status` varchar(10) COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT 'sla结果:0倒计时中；1:within sla;2:met sla;2-tmp:met sla(SAT);3:overdue;4:missed sla;4-tmp:missed sla(SAT);',
  `customer_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '客户ID',
  `assign_time` datetime DEFAULT NULL COMMENT '(重新)分配时间',
  `language` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '语言',
  `engagement_preference` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '枚举值,01:F2F/02:telehonic/03:virtual',
  `prefered_contact_time_start` time DEFAULT NULL COMMENT '联系开始时间',
  `prefered_contact_time_end` time DEFAULT NULL COMMENT '联系结束时间',
  `customer_need` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `agent_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '' COMMENT '代理人姓名',
  `sla_end_time` datetime DEFAULT NULL COMMENT 'sla结束时间',
  `accepted_time` datetime DEFAULT NULL COMMENT '建立联系时间',
  `issued_time` datetime DEFAULT NULL COMMENT 'issued时间',
  `is_last_year_left` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'tag：是否去年遗留，0:不是：1是',
  `x_plan` char(1) COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '0:否; 1:是',
  `assign_count` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '分配次数',
  `issued_close_flag` char(1) COLLATE utf8mb4_bin DEFAULT '0' COMMENT '1:issued转为关闭的线索',
  `declaration` char(1) COLLATE utf8mb4_bin DEFAULT '0' COMMENT '是否勾选declaration 0:未勾选 1:已勾选',
  `source_name` varchar(100) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'OM线索来源名称',
  `workflow_compensate` char(1) COLLATE utf8mb4_bin DEFAULT '0' COMMENT '工作流补偿标记; 0:否；1：是',
  `title` varchar(50) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Mr对应Male，Mrs/Ms/Miss对应Female',
  `is_update_title` varchar(50) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Y表示可以修改 N表示不可以修改',
  `send_to_rpp` char(1) COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '是否已同步至rpp系统，0:否；1:是',
  `send_to_rpp_status` char(1) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '同步至rpp系统的状态,见leads_status字段',
  `workflow_current_version` varchar(100) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '当前工作流版本',
  `workflow_history_version` text COLLATE utf8mb4_bin COMMENT '工作流所有历史版本，逗号隔开',
  `workflow_restart` char(1) COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '是否完成重新启动工作流',
  `is_product_associated` char(1) COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '是否关联产品 0-未关联 1-已关联',
  `re_allocation_time` datetime DEFAULT NULL COMMENT '重分配时间',
  `prefered_contact_time` varchar(100) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'prefered time',
  `re_allocation_no_psi_flag` char(1) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '重分配时，no psi标志，0=no psi，1=psi',
  `sub_status_count` smallint NOT NULL DEFAULT '0' COMMENT '关联的产品子状态个数',
  `is_multiple` char(1) COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '多个产品子状态标识，1是，0否',
  `leads_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '线索编号',
  `campaign_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '活动code',
  `org_code_path` varchar(200) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '组织机构path',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `edited_json` varchar(100) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'json key value, a status 4 both of personal、address、contact、identity',
  `segment` varchar(50) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'segment',
  `mfc_worksite_code` varchar(32) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'mfc worksite code',
  `om_lead_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'om同步的MFCLeadID',
  `om_compcl_key` varchar(18) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'om同步的Colpcl_k',
  `is_deceased` tinyint(1) DEFAULT NULL COMMENT '是否身故：1是，0否',
  `proposed_number` varchar(50) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'proposed_number电话，来源于客户信息',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  `original_worksite_code` varchar(32) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '记录线索初始携带的worksite code，目前只有mfc用',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `un_leads_code` (`leads_code`,`tenant_id`) USING BTREE,
  KEY `agent_id_index` (`agent_id`),
  KEY `current_stage_id_application_scope` (`current_stage_id`,`application_scope`),
  KEY `leads_tenant_stage_status_scope_index` (`tenant_id`,`current_stage_id`,`leads_status`,`application_scope`) USING BTREE,
  KEY `idx_campaign_code` (`campaign_code`),
  KEY `idx_created_date` (`created_date`) USING BTREE,
  KEY `idx_customer_id` (`customer_id`),
  KEY `idx_priority` (`priority`),
  KEY `idx_tenantId_isDelete_appScope` (`tenant_id`,`is_delete`,`application_scope`),
  KEY `idx_tenantId_appScope` (`tenant_id`,`application_scope`),
  KEY `idx_leadsStatus` (`leads_status`),
  KEY `idx_application_scope_index` (`application_scope`),
  KEY `idx_iic_crm_leads_group_tsa` (`tenant_id`,`leads_status`,`application_scope`),
  KEY `idx_om_lead_id` (`om_lead_id`),
  KEY `idx_leadStatus_tenantId_isDelete` (`leads_status`,`tenant_id`,`is_delete`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=738186 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='线索表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_20230328_bak`
--

DROP TABLE IF EXISTS `iic_crm_leads_20230328_bak`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_20230328_bak` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `priority` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '线索优先级',
  `tenant_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '租户id',
  `agent_id` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '代理人',
  `application_scope` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '应用范围（一级机构编码）',
  `journey_id` bigint DEFAULT NULL COMMENT '线索旅程id',
  `current_stage_id` bigint DEFAULT NULL COMMENT '当前所在线索阶段id',
  `sub_status_id` bigint DEFAULT NULL COMMENT '阶段子状态id',
  `score` decimal(10,2) DEFAULT NULL COMMENT '线索打分',
  `salutation` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '称谓',
  `leads_category` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '线索类型',
  `first_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '名',
  `last_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '姓',
  `full_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '全名',
  `gender` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '性别',
  `date_of_birth` date DEFAULT NULL COMMENT '出生日期',
  `age` int DEFAULT NULL COMMENT '年龄',
  `education` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '学历（PhD/ Master/ Bachelor/ High School/ Elementary School/ Other）',
  `body_weight` decimal(5,2) DEFAULT NULL COMMENT '体重',
  `height` decimal(5,2) DEFAULT NULL COMMENT '身高',
  `occupation` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '职业',
  `employer` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '雇主（公司）名',
  `job_title` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '岗位',
  `annual_income` decimal(32,8) DEFAULT NULL COMMENT '年收入',
  `marital_status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '婚姻状况',
  `number_of_children` int DEFAULT NULL COMMENT '孩子数量',
  `family_annual_income` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '家庭年收入',
  `id_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '证件类型（0:ID Card/ 1:Passport/ 2:Drivers Licence/ Other)',
  `id_number` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '证件号',
  `id_validity` date DEFAULT NULL COMMENT '证件有效期',
  `phone_number` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '电话号码',
  `phone_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '号码类型（0: Mobile/1: Work/2: Home/3: School/4: Fax/5: Other）',
  `email_address` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '邮箱地址',
  `email_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '邮箱类型（0: Work/1: Home/2: School/3: Other）',
  `address` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '详细地址',
  `address_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '地址类型（0: Work/1: Home/2: School/3: Other）',
  `postal_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '邮编',
  `source` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '选项暂为： Friend/Relative/Referral/Social media',
  `creation_time` datetime DEFAULT NULL COMMENT '线索阶段更新时间或重复线索合并完成时间',
  `is_existing` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '0: 未存在 1: 已存在',
  `is_active` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '0: 沉默 1：活跃',
  `is_overtime` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT '0：未超时 1：已超时',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '状态 0-待分配,1-待重新分配,2-已分配',
  `pool_source` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '平台来源 0=Customer portal,1=Social media,2=Manually created,3=Offical website,4=Third party ',
  `is_follow` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT '是否关注（0:未关注/1：已关注）',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT '0=未删除，1=已删除',
  `follow_date` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '最新跟进时间',
  `profile_photo` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `policy_no` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '保单号',
  `product_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `email` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '邮箱',
  `origin_id` bigint DEFAULT NULL COMMENT '原leads_id',
  `prem_sum` decimal(10,2) DEFAULT NULL COMMENT '保费',
  `campaign_id` varchar(100) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '活动id',
  `policy_created_date` datetime DEFAULT NULL COMMENT '保单创建时间',
  `conversion_date` datetime DEFAULT NULL COMMENT '线索转化成功时间',
  `leads_status` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '1' COMMENT '线索状态：1：旅程中，2：投保完成，3：取消选择',
  `close_type` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '关闭类型',
  `close_reason` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '关闭原因',
  `needs` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `time_of_call` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `speak_way` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '0：Face to Face；1：Telephonic',
  `available_call_time` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '可响应拨打电话时间范围',
  `prospector_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '线索客服id',
  `prospector_note` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '线索客服获取的notes',
  `call_start_time` datetime DEFAULT NULL COMMENT '通话开始时间',
  `call_end_time` datetime DEFAULT NULL COMMENT '通话结束时间',
  `out_come` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '通话记录',
  `allot_time` datetime DEFAULT NULL COMMENT '分配时间',
  `pre_allocation_stage` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '预分配阶段;0new 1:tel-prospector call 2:1st Assignment 3:2nd Assigment',
  `application_role` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '关联角色',
  `accept_within_limit` int DEFAULT NULL COMMENT '超时时间（分钟）',
  `social_insurance` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '1:有/2:无',
  `lead_feed` json DEFAULT NULL COMMENT 'ILMS原始数据',
  `feature` json DEFAULT NULL COMMENT 'OM原始数据',
  `is_workflow` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '是否需要工作流:0否；1是',
  `sla_status` varchar(10) COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT 'sla结果:0倒计时中；1:within sla;2:met sla;2-tmp:met sla(SAT);3:overdue;4:missed sla;4-tmp:missed sla(SAT);',
  `customer_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '客户ID',
  `assign_time` datetime DEFAULT NULL COMMENT '(重新)分配时间',
  `language` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '语言',
  `engagement_preference` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '枚举值,01:F2F/02:telehonic/03:virtual',
  `prefered_contact_time_start` time DEFAULT NULL COMMENT '联系开始时间',
  `prefered_contact_time_end` time DEFAULT NULL COMMENT '联系结束时间',
  `customer_need` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `agent_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '' COMMENT '代理人姓名',
  `sla_end_time` datetime DEFAULT NULL COMMENT 'sla结束时间',
  `accepted_time` datetime DEFAULT NULL COMMENT '建立联系时间',
  `issued_time` datetime DEFAULT NULL COMMENT 'issued时间',
  `is_last_year_left` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'tag：是否去年遗留，0:不是：1是',
  `x_plan` char(1) COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '0:否; 1:是',
  `assign_count` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '分配次数',
  `issued_close_flag` char(1) COLLATE utf8mb4_bin DEFAULT '0' COMMENT '1:issued转为关闭的线索',
  `declaration` char(1) COLLATE utf8mb4_bin DEFAULT '0' COMMENT '是否勾选declaration 0:未勾选 1:已勾选',
  `source_name` varchar(100) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'OM线索来源名称',
  `workflow_compensate` char(1) COLLATE utf8mb4_bin DEFAULT '0' COMMENT '工作流补偿标记; 0:否；1：是',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `agent_id_index` (`agent_id`),
  KEY `current_stage_id_application_scope` (`current_stage_id`,`application_scope`),
  KEY `leads_tenant_stage_status_scope_index` (`tenant_id`,`current_stage_id`,`leads_status`,`application_scope`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=17022 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='线索表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_address`
--

DROP TABLE IF EXISTS `iic_crm_leads_address`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_address` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `leads_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '线索id',
  `type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '类型',
  `country` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '国家',
  `province` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `city` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `address` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '地址',
  `zip_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '邮编',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `address2` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '地址2',
  `address3` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '地址3',
  `address4` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '地址4',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`),
  KEY `leads_id_idx` (`leads_id`)
) ENGINE=InnoDB AUTO_INCREMENT=28466 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='线索地址表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_assignment_history`
--

DROP TABLE IF EXISTS `iic_crm_leads_assignment_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_assignment_history` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `leads_id` bigint NOT NULL COMMENT '线索ID',
  `assignment_time` datetime NOT NULL COMMENT '分配时间',
  `assignment_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '分配类型',
  `assigned_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '分配线索的对象，用户或System',
  `assigned_by_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '分配线索的对象、用户或System的code',
  `assigned_to` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '接受线索的对象、用户、组织、角色',
  `assigned_to_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '接受线索的对象、用户、组织、角色的code',
  `assignment_to_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '接受线索的类型',
  `lead_location` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '线索当前位置',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `segment` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'segment',
  `dae_country_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `status` tinyint DEFAULT NULL COMMENT 'init:0,valid:1',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `leads_id_idx` (`leads_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1240 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='线索分配历史记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_assignment_status_history`
--

DROP TABLE IF EXISTS `iic_crm_leads_assignment_status_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_assignment_status_history` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `assignment_hi_id` bigint NOT NULL COMMENT '线索ID',
  `leads_id` bigint NOT NULL COMMENT '线索ID',
  `leads_status` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '见leads主表状态',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `leads_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'leads code参见leads主表',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `leads_id_idx` (`leads_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1879 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='线索分配历史状态记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_bak20250228`
--

DROP TABLE IF EXISTS `iic_crm_leads_bak20250228`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_bak20250228` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `priority` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '线索优先级',
  `tenant_id` bigint DEFAULT NULL COMMENT '代理人',
  `agent_id` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '代理人',
  `application_scope` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '应用范围（一级机构编码）',
  `journey_id` bigint DEFAULT NULL COMMENT '线索旅程id',
  `current_stage_id` bigint DEFAULT NULL COMMENT '当前所在线索阶段id',
  `sub_status_id` bigint DEFAULT NULL COMMENT '阶段子状态id',
  `score` decimal(10,2) DEFAULT NULL COMMENT '线索打分',
  `salutation` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '称谓',
  `leads_category` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '线索类型',
  `first_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '名',
  `last_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '姓',
  `full_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '全名',
  `gender` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '性别',
  `date_of_birth` date DEFAULT NULL COMMENT '出生日期',
  `age` int DEFAULT NULL COMMENT '年龄',
  `education` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '学历（PhD/ Master/ Bachelor/ High School/ Elementary School/ Other）',
  `body_weight` decimal(5,2) DEFAULT NULL COMMENT '体重',
  `height` decimal(5,2) DEFAULT NULL COMMENT '身高',
  `occupation` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '职业',
  `employer` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '雇主（公司）名',
  `job_title` varchar(128) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '岗位',
  `annual_income` decimal(32,8) DEFAULT NULL COMMENT '年收入',
  `marital_status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '婚姻状况',
  `number_of_children` int DEFAULT NULL COMMENT '孩子数量',
  `family_annual_income` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '家庭年收入',
  `id_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '证件类型（0:ID Card/ 1:Passport/ 2:Drivers Licence/ Other)',
  `id_number` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '证件号',
  `id_validity` date DEFAULT NULL COMMENT '证件有效期',
  `phone_number` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '电话号码',
  `phone_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '号码类型（0: Mobile/1: Work/2: Home/3: School/4: Fax/5: Other）',
  `email_address` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '邮箱地址',
  `email_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '邮箱类型（0: Work/1: Home/2: School/3: Other）',
  `address` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '详细地址',
  `address_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '地址类型（0: Work/1: Home/2: School/3: Other）',
  `postal_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '邮编',
  `source` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '选项暂为： Friend/Relative/Referral/Social media',
  `creation_time` datetime DEFAULT NULL COMMENT '线索阶段更新时间或重复线索合并完成时间',
  `is_existing` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '0: 未存在 1: 已存在',
  `is_active` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '0: 沉默 1：活跃',
  `is_overtime` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT '0：未超时 1：已超时',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '状态 0-待分配,1-待重新分配,2-已分配',
  `pool_source` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '平台来源 0=Customer portal,1=Social media,2=Manually created,3=Offical website,4=Third party ',
  `is_follow` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT '是否关注（0:未关注/1：已关注）',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT '0=未删除，1=已删除',
  `follow_date` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '最新跟进时间',
  `profile_photo` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `policy_no` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '保单号',
  `product_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `email` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '邮箱',
  `origin_id` bigint DEFAULT NULL COMMENT '原leads_id',
  `prem_sum` decimal(10,2) DEFAULT NULL COMMENT '保费',
  `campaign_id` varchar(100) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '活动id',
  `policy_created_date` datetime DEFAULT NULL COMMENT '保单创建时间',
  `conversion_date` datetime DEFAULT NULL COMMENT '线索转化成功时间',
  `leads_status` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '1' COMMENT '线索状态：1：旅程中，2：投保完成，3：取消选择',
  `close_type` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '关闭类型',
  `close_reason` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '关闭原因',
  `needs` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `time_of_call` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `speak_way` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '0：Face to Face；1：Telephonic',
  `available_call_time` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '可响应拨打电话时间范围',
  `prospector_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '线索客服id',
  `prospector_note` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '线索客服获取的notes',
  `call_start_time` datetime DEFAULT NULL COMMENT '通话开始时间',
  `call_end_time` datetime DEFAULT NULL COMMENT '通话结束时间',
  `out_come` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '通话记录',
  `allot_time` datetime DEFAULT NULL COMMENT '分配时间',
  `pre_allocation_stage` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '预分配阶段;0new 1:tel-prospector call 2:1st Assignment 3:2nd Assigment',
  `application_role` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '关联角色',
  `accept_within_limit` int DEFAULT NULL COMMENT '超时时间（分钟）',
  `social_insurance` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '1:有/2:无',
  `lead_feed` json DEFAULT NULL COMMENT 'ILMS原始数据',
  `feature` json DEFAULT NULL COMMENT 'OM原始数据',
  `is_workflow` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '是否需要工作流:0否；1是',
  `sla_status` varchar(10) COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT 'sla结果:0倒计时中；1:within sla;2:met sla;2-tmp:met sla(SAT);3:overdue;4:missed sla;4-tmp:missed sla(SAT);',
  `customer_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '客户ID',
  `assign_time` datetime DEFAULT NULL COMMENT '(重新)分配时间',
  `language` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '语言',
  `engagement_preference` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '枚举值,01:F2F/02:telehonic/03:virtual',
  `prefered_contact_time_start` time DEFAULT NULL COMMENT '联系开始时间',
  `prefered_contact_time_end` time DEFAULT NULL COMMENT '联系结束时间',
  `customer_need` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `agent_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '' COMMENT '代理人姓名',
  `sla_end_time` datetime DEFAULT NULL COMMENT 'sla结束时间',
  `accepted_time` datetime DEFAULT NULL COMMENT '建立联系时间',
  `issued_time` datetime DEFAULT NULL COMMENT 'issued时间',
  `is_last_year_left` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'tag：是否去年遗留，0:不是：1是',
  `x_plan` char(1) COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '0:否; 1:是',
  `assign_count` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '分配次数',
  `issued_close_flag` char(1) COLLATE utf8mb4_bin DEFAULT '0' COMMENT '1:issued转为关闭的线索',
  `declaration` char(1) COLLATE utf8mb4_bin DEFAULT '0' COMMENT '是否勾选declaration 0:未勾选 1:已勾选',
  `source_name` varchar(100) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'OM线索来源名称',
  `workflow_compensate` char(1) COLLATE utf8mb4_bin DEFAULT '0' COMMENT '工作流补偿标记; 0:否；1：是',
  `title` varchar(50) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Mr对应Male，Mrs/Ms/Miss对应Female',
  `is_update_title` varchar(50) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Y表示可以修改 N表示不可以修改',
  `send_to_rpp` char(1) COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '是否已同步至rpp系统，0:否；1:是',
  `send_to_rpp_status` char(1) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '同步至rpp系统的状态,见leads_status字段',
  `workflow_current_version` varchar(100) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '当前工作流版本',
  `workflow_history_version` text COLLATE utf8mb4_bin COMMENT '工作流所有历史版本，逗号隔开',
  `workflow_restart` char(1) COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '是否完成重新启动工作流',
  `is_product_associated` char(1) COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '是否关联产品 0-未关联 1-已关联',
  `re_allocation_time` datetime DEFAULT NULL COMMENT '重分配时间',
  `prefered_contact_time` varchar(100) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'prefered time',
  `re_allocation_no_psi_flag` char(1) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '重分配时，no psi标志，0=no psi，1=psi',
  `sub_status_count` smallint NOT NULL DEFAULT '0' COMMENT '关联的产品子状态个数',
  `is_multiple` char(1) COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '多个产品子状态标识，1是，0否',
  `leads_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '线索编号',
  `campaign_code` varchar(32) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '活动code',
  `org_code_path` varchar(200) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '组织机构path',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `edited_json` varchar(100) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'json key value, a status 4 both of personal、address、contact、identity',
  `segment` varchar(50) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'segment',
  `mfc_worksite_code` varchar(32) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'mfc worksite code',
  `om_lead_id` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'om同步的MFCLeadID',
  `om_compcl_key` varchar(18) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'om同步的Colpcl_k',
  `is_deceased` tinyint(1) DEFAULT NULL COMMENT '是否身故：1是，0否',
  `proposed_number` varchar(50) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'proposed_number电话，来源于客户信息',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `un_leads_code` (`leads_code`,`tenant_id`) USING BTREE,
  KEY `agent_id_index` (`agent_id`),
  KEY `current_stage_id_application_scope` (`current_stage_id`,`application_scope`),
  KEY `leads_tenant_stage_status_scope_index` (`tenant_id`,`current_stage_id`,`leads_status`,`application_scope`) USING BTREE,
  KEY `idx_campaign_code` (`campaign_code`),
  KEY `idx_created_date` (`created_date`) USING BTREE,
  KEY `idx_customer_id` (`customer_id`),
  KEY `idx_priority` (`priority`),
  KEY `idx_tenantId_isDelete_appScope` (`tenant_id`,`is_delete`,`application_scope`),
  KEY `idx_tenantId_appScope` (`tenant_id`,`application_scope`),
  KEY `idx_leadsStatus` (`leads_status`),
  KEY `idx_application_scope_index` (`application_scope`),
  KEY `idx_iic_crm_leads_group_tsa` (`tenant_id`,`leads_status`,`application_scope`),
  KEY `idx_om_lead_id` (`om_lead_id`),
  KEY `idx_leadStatus_tenantId_isDelete` (`leads_status`,`tenant_id`,`is_delete`) USING BTREE,
  FULLTEXT KEY `idx_org_code_path` (`org_code_path`)
) ENGINE=InnoDB AUTO_INCREMENT=330043 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='线索表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_breeze_push`
--

DROP TABLE IF EXISTS `iic_crm_leads_breeze_push`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_breeze_push` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `leads_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '线索编号',
  `request_body` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '入参',
  `response_body` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '出参',
  `error_status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '推送状态，0 - 成功;1 - foam id空;2 - 调用成功，但返回结果不是成功;3- 调用error报错',
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=8517 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='leads breeze推送状态记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_close_reason_rel_segment`
--

DROP TABLE IF EXISTS `iic_crm_leads_close_reason_rel_segment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_close_reason_rel_segment` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '租户id',
  `close_reason_code` varchar(32) COLLATE utf8mb4_bin NOT NULL COMMENT '唯一code',
  `segment` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'PF/MFC',
  `order_no` tinyint NOT NULL COMMENT '序号',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `access_type` char(1) COLLATE utf8mb4_bin DEFAULT '0' COMMENT '0: my leads 1: team leads',
  `customized` char(1) COLLATE utf8mb4_bin DEFAULT '0' COMMENT '0: fix value 1: manual input',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `segment_close_reason_code` (`tenant_id`,`segment`,`close_reason_code`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=135 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='线索关闭原因关联';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_close_reason_template`
--

DROP TABLE IF EXISTS `iic_crm_leads_close_reason_template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_close_reason_template` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '租户id',
  `code` varchar(32) COLLATE utf8mb4_bin NOT NULL COMMENT '唯一code',
  `parent_code` varchar(32) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '父节点code',
  `type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '1-theme;2-sub_theme',
  `content` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '内容',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `code` (`tenant_id`,`code`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=63 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='线索关闭原因模板';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_comment`
--

DROP TABLE IF EXISTS `iic_crm_leads_comment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_comment` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `tenant_id` bigint NOT NULL COMMENT '租户id',
  `comment_unique_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `leads_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '线索编号',
  `creator_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '创建人名字',
  `initial` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '姓名缩写',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '留言内容',
  `is_read` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '是否已读（0：否，1：是）',
  `is_edited` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '是否被修改过（0：否，1：是）',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT '逻辑删除（0：未删除，1：已删除）',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `can_edited` char(1) COLLATE utf8mb4_bin NOT NULL DEFAULT '1' COMMENT '是否可编辑,0否、1是',
  `source` varchar(10) COLLATE utf8mb4_bin NOT NULL DEFAULT 'dae' COMMENT '来源，dae或om',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `un_comment_unique_code` (`comment_unique_code`) USING BTREE,
  KEY `index_leads_code` (`leads_code`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=144613 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='线索comment表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_csi_sync_log`
--

DROP TABLE IF EXISTS `iic_crm_leads_csi_sync_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_csi_sync_log` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `csi_sync_log_unique_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `tenant_id` bigint NOT NULL COMMENT '租户id',
  `leads_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '线索ID',
  `req_body` text COLLATE utf8mb4_bin NOT NULL COMMENT '入参',
  `retry_times` int DEFAULT '0' COMMENT '失败重试次数',
  `token` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '0：失败，1：成功；2：csi回调成功',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_iic_crm_leads_csi_sync_log_leads_id` (`leads_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=6915 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='csi同步接口调用记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_csi_sync_log_retry_result`
--

DROP TABLE IF EXISTS `iic_crm_leads_csi_sync_log_retry_result`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_csi_sync_log_retry_result` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `tenant_id` bigint NOT NULL COMMENT '租户id',
  `csi_sync_log_unique_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `rep_body` text COLLATE utf8mb4_bin NOT NULL COMMENT '接口调用结果',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=23882 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='csi信息同步接口调用记录结果表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_email`
--

DROP TABLE IF EXISTS `iic_crm_leads_email`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_email` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `leads_id` bigint DEFAULT NULL COMMENT '线索ID',
  `type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '类型',
  `email` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '邮箱',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`),
  KEY `leads_id_idx` (`leads_id`)
) ENGINE=InnoDB AUTO_INCREMENT=37452 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='线索邮箱表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_exception_report`
--

DROP TABLE IF EXISTS `iic_crm_leads_exception_report`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_exception_report` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `leads_id` bigint DEFAULT NULL COMMENT '线索ID',
  `segment` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'segment',
  `source` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '类型',
  `SOURCE_NAME` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'OM线索来源DIGITAL的子级来源分类名称',
  `reason` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '原因',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `leads_id_idx` (`leads_id`)
) ENGINE=InnoDB AUTO_INCREMENT=79397 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='线索exception_report';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_external_product_info`
--

DROP TABLE IF EXISTS `iic_crm_leads_external_product_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_external_product_info` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `tenant_id` bigint NOT NULL COMMENT '租户id',
  `leads_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '线索编号',
  `ext_leads_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '外部系统线索id',
  `system_name` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '子系统名称，XPlan、RPP',
  `policy_number` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '保单号',
  `product_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '产品名称',
  `sub_status` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '产品子状态',
  `leads_status` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'leads status',
  `product_expiry` date DEFAULT NULL COMMENT '产品过期日期',
  `is_deleted` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '是否已删除 0-未删除 1-已删除',
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `adviser_code` varchar(100) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '代理人代码',
  `adviser_name` varchar(100) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '代理人名称',
  `system_order` smallint DEFAULT '0' COMMENT '系统排序顺序',
  `stage_id` varchar(6) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '关联的线索旅程id',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`),
  KEY `iic_crm_leads_external_product_info_leads_code_IDX` (`leads_code`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=326 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='leads外部系统产品状态信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_family`
--

DROP TABLE IF EXISTS `iic_crm_leads_family`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_family` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `leads_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '线索id',
  `tenant_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '租户id',
  `marital_status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '婚姻状况',
  `number_of_children` int DEFAULT NULL COMMENT '孩子数量',
  `family_members` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '家庭成员',
  `family_annual_income` decimal(32,8) DEFAULT NULL COMMENT '家庭年收入',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `iic_crm_leads_family_un` (`leads_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=8339 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='家庭情况';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_file`
--

DROP TABLE IF EXISTS `iic_crm_leads_file`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_file` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `leads_id` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '线索id',
  `file_type` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '文件类型 1-FNA,2-Proposal,3-Policy Contract,4-E-Signature,5-Sales conduct record retention,6-Other Docs',
  `file_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '文件名',
  `file_date` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '文件日期',
  `file_url` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `file_key` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '文件key',
  `file_size` decimal(6,2) DEFAULT NULL COMMENT '文件大小',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `tenant_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '租户id',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=425 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='线索文件记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_identity`
--

DROP TABLE IF EXISTS `iic_crm_leads_identity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_identity` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `leads_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '线索id',
  `tenant_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '租户id',
  `id_type` char(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '证件类型',
  `id_no` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '证件号',
  `id_validity` datetime DEFAULT NULL COMMENT '有效期',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `rel_country` varchar(30) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '关联国家(出生国家)',
  `country_of_issue` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '发证国家',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`),
  KEY `idx_leads_id` (`leads_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=403846 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='线索证件信息';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_journey_condition`
--

DROP TABLE IF EXISTS `iic_crm_leads_journey_condition`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_journey_condition` (
  `id` bigint unsigned NOT NULL COMMENT '主键',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `stage_id` bigint NOT NULL COMMENT '阶段id',
  `convert_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '转换类型，0:自动1手动',
  `settings` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `return_stage` bigint DEFAULT NULL COMMENT '自动完成后转给的阶段',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='线索旅程阶段完成条件表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_journey_condition_setting`
--

DROP TABLE IF EXISTS `iic_crm_leads_journey_condition_setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_journey_condition_setting` (
  `id` bigint unsigned NOT NULL COMMENT '主键',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `condition_id` bigint NOT NULL COMMENT '完成条件表id',
  `object` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '对象',
  `category_code` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '分类',
  `sub_object` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '子对象',
  `condition_value` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '条件',
  `match_value` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '匹配值',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='线索旅程阶段完成条件决策树配置表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_journey_config`
--

DROP TABLE IF EXISTS `iic_crm_leads_journey_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_journey_config` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '线索旅程名称',
  `desc` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '线索旅程描述',
  `application_scope` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '适用范围',
  `timeout_setting` int DEFAULT NULL COMMENT '超时时间',
  `stages` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '线索阶段列表',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `tenant_id` (`tenant_id`,`application_scope`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=172 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='线索旅程配置表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_journey_stage`
--

DROP TABLE IF EXISTS `iic_crm_leads_journey_stage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_journey_stage` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '自增id',
  `tenant_id` bigint DEFAULT NULL,
  `leads_journey_id` bigint NOT NULL COMMENT '线索旅程id',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '阶段名称',
  `order_no` int DEFAULT NULL COMMENT '阶段顺序',
  `is_delete` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '逻辑删除（0：未删除，1：已删除）',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `stage_tmpl_id` bigint DEFAULT NULL COMMENT '关联的阶段模板id',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_order_no` (`order_no`)
) ENGINE=InnoDB AUTO_INCREMENT=1415 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='线索旅程阶段表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_journey_stage_tmpl`
--

DROP TABLE IF EXISTS `iic_crm_leads_journey_stage_tmpl`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_journey_stage_tmpl` (
  `id` bigint unsigned NOT NULL COMMENT '主键',
  `tenant_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '租户id',
  `name_` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL COMMENT '阶段名称',
  `is_default` int DEFAULT NULL COMMENT '是否预设(1-预设;0-非预设;)',
  `is_delete` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '逻辑删除（0：未删除，1：已删除）',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='线索旅程阶段预设表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_journey_sub_status`
--

DROP TABLE IF EXISTS `iic_crm_leads_journey_sub_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_journey_sub_status` (
  `id` bigint unsigned NOT NULL COMMENT '主键',
  `tenant_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '租户id',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '子状态名',
  `description` varchar(5000) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '子状态描述',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '2' COMMENT '子状态状态 1-启用，2-未启用',
  `order_number` int DEFAULT '1' COMMENT '子状态序号',
  `stage_id` bigint DEFAULT NULL COMMENT '线索旅程阶段id',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='线索旅程阶段子状态表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_journey_task`
--

DROP TABLE IF EXISTS `iic_crm_leads_journey_task`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_journey_task` (
  `id` bigint unsigned NOT NULL COMMENT '主键',
  `tenant_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '租户id',
  `name_` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '阶段任务名称',
  `stage_id` bigint DEFAULT NULL COMMENT '线索旅程阶段id',
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '描述',
  `required` int NOT NULL DEFAULT '0' COMMENT '是否必填(1-必填;0-非必填;)',
  `order_no` int DEFAULT NULL COMMENT '任务顺序',
  `is_delete` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '逻辑删除（0：未删除，1：已删除）',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `task_tmpl_id` bigint DEFAULT NULL COMMENT '关联的任务模板id',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='线索阶段任务预设表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_journey_task_tmpl`
--

DROP TABLE IF EXISTS `iic_crm_leads_journey_task_tmpl`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_journey_task_tmpl` (
  `id` bigint unsigned NOT NULL COMMENT '主键',
  `tenant_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '租户id',
  `name_` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '阶段任务名称',
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '任务描述',
  `is_default` int NOT NULL DEFAULT '0' COMMENT '是否预设(1-预设;0-非预设;)',
  `is_delete` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '逻辑删除（0：未删除，1：已删除）',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='线索阶段任务预设表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_label`
--

DROP TABLE IF EXISTS `iic_crm_leads_label`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_label` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `label_id` int NOT NULL COMMENT '标签id',
  `label_content` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '标签内容',
  `leads_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '线索id',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `tenant_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '租户id',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1108 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='线索标签表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_label_detail`
--

DROP TABLE IF EXISTS `iic_crm_leads_label_detail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_label_detail` (
  `label_id` int NOT NULL AUTO_INCREMENT COMMENT '标签id（主键）',
  `agent_id` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '代理人id',
  `label_type` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '标签类型（0：预设，1：自定义标签）',
  `label_content` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '标签内容',
  `last_display_time` datetime DEFAULT NULL COMMENT '上次使用时间',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `tenant_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '租户id',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`label_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=159 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='线索详情表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_note`
--

DROP TABLE IF EXISTS `iic_crm_leads_note`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_note` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `note_content` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '备注内容',
  `leads_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '客户id',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `tenant_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '租户id',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `leads_id_idx` (`leads_id`)
) ENGINE=InnoDB AUTO_INCREMENT=32459 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='线索备注表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_occupation_income`
--

DROP TABLE IF EXISTS `iic_crm_leads_occupation_income`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_occupation_income` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `leads_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '线索id',
  `tenant_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '租户id',
  `occupation` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '职业',
  `employer` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '雇主（公司）名',
  `job_title` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '岗位',
  `annual_income` decimal(32,1) DEFAULT NULL COMMENT '年收入',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `iic_crm_leads_occupation_income_un` (`leads_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=9134 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='线索职业收入信息';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_operate`
--

DROP TABLE IF EXISTS `iic_crm_leads_operate`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_operate` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `leads_id` bigint NOT NULL,
  `operate` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'system' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'system' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_operate_leads_id` (`leads_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=58 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_payment`
--

DROP TABLE IF EXISTS `iic_crm_leads_payment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_payment` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `leads_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '线索id',
  `tenant_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '租户id',
  `default_payment_method` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '是否默认支付方式',
  `card_holder` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '卡主姓名',
  `account_number` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '银行卡号',
  `card_type` char(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '银行卡类型',
  `bank_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '银行名',
  `branch_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '银行机构名',
  `expires_on` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '银行卡有效期',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `leads_id_idx` (`leads_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8541 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='线索支付信息';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_personal`
--

DROP TABLE IF EXISTS `iic_crm_leads_personal`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_personal` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `leads_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '线索id',
  `tenant_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '租户id',
  `agent_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '代理人id',
  `salutation` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '称谓',
  `first_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '名',
  `last_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '姓',
  `full_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '全名',
  `gender` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '性别',
  `date_of_birth` date DEFAULT NULL COMMENT '出生日期',
  `age` int DEFAULT NULL COMMENT '年龄',
  `profile_photo` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '照片（头像）',
  `education` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '学历（PhD/ Master/ Bachelor/ High School/ Elementary School/ Other）',
  `weight` decimal(5,2) DEFAULT NULL COMMENT '体重',
  `height` decimal(5,2) DEFAULT NULL COMMENT '身高',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `title` varchar(50) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Mr对应Male，Mrs/Ms/Miss对应Female',
  `is_update_title` varchar(50) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Y表示可以修改 N表示不可以修改',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `iic_crm_leads_personal_un` (`leads_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='线索个人信息表 ';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_phone`
--

DROP TABLE IF EXISTS `iic_crm_leads_phone`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_phone` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户id',
  `leads_id` bigint DEFAULT NULL COMMENT '线索ID',
  `type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '类型',
  `number` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '号码',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '区号',
  `country_name` varchar(200) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '国家名',
  `number_type` varchar(50) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'RM表示Residential mobile,BR表示 Business mobile,RT表示 Residential telephone ,BT表示Business telephon',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`),
  KEY `leads_id_idx` (`leads_id`)
) ENGINE=InnoDB AUTO_INCREMENT=499596 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='线索联系方式表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_product_pipeline_status`
--

DROP TABLE IF EXISTS `iic_crm_leads_product_pipeline_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_product_pipeline_status` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `tenant_id` bigint NOT NULL COMMENT '租户id',
  `top_org_code` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '顶组组织：SA-PF、SA-MFC、......',
  `leads_status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'leads状态',
  `leads_status_desc` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'leads状态名称',
  `sub_status` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '产品子状态',
  `system_name` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '子系统名称，XPlan、RPP',
  `stage_id` bigint DEFAULT NULL COMMENT '关联的线索旅程id',
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=235 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='维护状态与子状态pipeline三者之间的关系表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_product_pipeline_status1012`
--

DROP TABLE IF EXISTS `iic_crm_leads_product_pipeline_status1012`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_product_pipeline_status1012` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `tenant_id` bigint NOT NULL COMMENT '租户id',
  `top_org_code` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '顶组组织：SA-PF、SA-MFC、......',
  `leads_status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'leads状态',
  `leads_status_desc` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'leads状态名称',
  `sub_status` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '产品子状态',
  `system_name` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '子系统名称，XPlan、RPP',
  `stage_id` bigint DEFAULT NULL COMMENT '关联的线索旅程id',
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=109 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='维护状态与子状态pipeline三者之间的关系表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_psi`
--

DROP TABLE IF EXISTS `iic_crm_leads_psi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_psi` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '租户id',
  `leads_id` bigint unsigned NOT NULL COMMENT '线索id',
  `digital_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '',
  `segment_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '',
  `channel_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '',
  `sales_code_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '',
  `sales_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '',
  `stuff_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '',
  `broker_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '',
  `performance_score` int DEFAULT NULL,
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `leads_id` (`tenant_id`,`leads_id`) USING BTREE,
  KEY `leads_id_index` (`leads_id`)
) ENGINE=InnoDB AUTO_INCREMENT=53610 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='线索psi关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_push`
--

DROP TABLE IF EXISTS `iic_crm_leads_push`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_push` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `data_id` varchar(60) COLLATE utf8mb4_bin NOT NULL COMMENT '唯一的业务key',
  `target_system` varchar(255) COLLATE utf8mb4_bin NOT NULL COMMENT '目标系统的名称或标识符,OneStream',
  `request_body` varchar(1000) COLLATE utf8mb4_bin NOT NULL COMMENT '入参',
  `push_time` datetime DEFAULT NULL COMMENT '推送时间',
  `push_status` char(1) COLLATE utf8mb4_bin NOT NULL COMMENT '推送状态，0-待推送 1-已推送',
  `push_result` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '推送结果，成功：000000，失败：oc:100000,third',
  `push_count` tinyint NOT NULL DEFAULT '0' COMMENT '推送次数，初始值为0',
  `last_push_time` datetime DEFAULT NULL COMMENT '上一次推送时间，初始值为null',
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `contact_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'one stream contactId',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `data_id` (`data_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11207 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='接口推送状态记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_push_exception`
--

DROP TABLE IF EXISTS `iic_crm_leads_push_exception`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_push_exception` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `data_id` varchar(60) COLLATE utf8mb4_bin NOT NULL COMMENT '唯一的业务key',
  `target_system` varchar(255) COLLATE utf8mb4_bin NOT NULL COMMENT '目标系统的名称或标识符,OneStream',
  `push_count` tinyint NOT NULL DEFAULT '0' COMMENT '推送次数，初始值为0',
  `exception_time` datetime NOT NULL COMMENT '异常发生时间',
  `exception_msg` varchar(3000) COLLATE utf8mb4_bin NOT NULL COMMENT '异常信息',
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=189893 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='接口推送异常记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_refer_record`
--

DROP TABLE IF EXISTS `iic_crm_leads_refer_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_refer_record` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `agent_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '代理人ID',
  `agent_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '代理人名称',
  `org_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '代理人组织',
  `origin_leads_id` bigint NOT NULL COMMENT '源线索ID',
  `new_leads_id` varchar(50) COLLATE utf8mb4_bin NOT NULL COMMENT '新线索ID',
  `refer_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '转介类型（1：保留并转介2：转介并关闭）',
  `refer_object` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '转介对象 1：adviser 2：SM 3:CHANNEL',
  `refer_to_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '转介对象编码',
  `refer_to_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '转介对象名称',
  `refer_date` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '转介时间',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '2' COMMENT '状态Issued:3 Referred:2 Closed:1',
  `first_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'first_name',
  `last_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'last_name',
  `full_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'full_name',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `need_type` varchar(32) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Customer Need Type',
  `sub_status` char(2) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '第三方系统子状态',
  `leads_category` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '线索类型',
  `issued_time` datetime DEFAULT NULL COMMENT 'issued时间',
  `close_time` datetime DEFAULT NULL COMMENT 'close时间',
  `external_party_response` json DEFAULT NULL COMMENT '第三方系统refer结果',
  `sub_status_name` varchar(50) COLLATE utf8mb4_bin DEFAULT NULL,
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_new_leads_id` (`new_leads_id`),
  KEY `idx_origin_leads_id` (`origin_leads_id`),
  KEY `idx_agent_id` (`agent_id`)
) ENGINE=InnoDB AUTO_INCREMENT=933 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='线索refer记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_refer_record2`
--

DROP TABLE IF EXISTS `iic_crm_leads_refer_record2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_refer_record2` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户id',
  `org_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '代理人组织',
  `leads_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '线索编号',
  `refer_object` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '转介对象 1：adviser',
  `refer_to_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '转介对象编码',
  `refer_to_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '转介对象名称',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT '0=未删除，1=已删除',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_create_by_date` (`created_by`,`created_date`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='DFA Support Para planner refer记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_refer_record_feedback`
--

DROP TABLE IF EXISTS `iic_crm_leads_refer_record_feedback`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_refer_record_feedback` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `refer_to_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '同iic_crm_leads_refer_record的refer_to_code',
  `reference` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '同iic_crm_leads_refer_record的new_leads_id',
  `feedback_status` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `feedback_date` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `feedback_time` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='iic_crm_leads_refer_record external party feedback表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_refer_record_feedback_iwyze`
--

DROP TABLE IF EXISTS `iic_crm_leads_refer_record_feedback_iwyze`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_refer_record_feedback_iwyze` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `reference` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '同iic_crm_leads_refer_record的new_leads_id',
  `feedback_status` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `feedback_status_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=52 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='iic_crm_leads_refer_record external party feedback iwyze表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_refer_record_feedback_omi`
--

DROP TABLE IF EXISTS `iic_crm_leads_refer_record_feedback_omi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_refer_record_feedback_omi` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `tenant_id` bigint NOT NULL COMMENT '租户id',
  `om_system_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'om子系统id,如OMI',
  `sub_status` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'om子系统状态',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '1' COMMENT '消费成功状态 1-成功 0-失败，默认有效-1',
  `msg` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '只保存简单的执行成功结果和异常信息',
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=562129 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='om子系统的子状态更新记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_rel_assign`
--

DROP TABLE IF EXISTS `iic_crm_leads_rel_assign`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_rel_assign` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `leads_id` bigint NOT NULL COMMENT '线索ID',
  `business_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '1:组织；2：角色；3：成员',
  `business_key` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '与bussiness_type对应的key',
  `decline_type` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '拒绝类型',
  `decline_reason` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '拒绝原因',
  `status` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '状态',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT '0=未删除，1=已删除',
  `assign_count` tinyint unsigned NOT NULL DEFAULT '0' COMMENT '分配次数',
  `assign_extend_code` varchar(50) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '分配扩展字段，分配给adviser时，存的是orgCode',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`),
  KEY `leads_id_idx` (`leads_id`),
  KEY `idx_leadsId_businessType_isDelete` (`leads_id`,`business_key`,`is_delete`) USING BTREE,
  KEY `idx_leadsId_isDelete` (`leads_id`,`is_delete`) USING BTREE,
  KEY `idx_businessType` (`business_key`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=206580 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='线索分配关系表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_rel_close_reason`
--

DROP TABLE IF EXISTS `iic_crm_leads_rel_close_reason`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_rel_close_reason` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '租户id',
  `leads_id` bigint unsigned NOT NULL COMMENT '线索id',
  `theme_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '主题code',
  `theme_desc` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '主题描述',
  `sub_theme_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '子主题code',
  `sub_theme_desc` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '子主题描述',
  `other_reason` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '其它原因',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `leads_id` (`tenant_id`,`leads_id`) USING BTREE,
  KEY `leads_id_index` (`leads_id`)
) ENGINE=InnoDB AUTO_INCREMENT=13359 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='线索关闭原因关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_same`
--

DROP TABLE IF EXISTS `iic_crm_leads_same`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_same` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT 'id',
  `agent_id` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '代理人',
  `lead_id` bigint NOT NULL COMMENT '线索id',
  `compare_id` bigint NOT NULL COMMENT '对比线索id',
  `compare_code` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '对比值，对比姓名/电话/邮箱，格式：001，0表示字段重复，1表示字段不重复',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='线索疑似重复表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_start_workflow_fail`
--

DROP TABLE IF EXISTS `iic_crm_leads_start_workflow_fail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_start_workflow_fail` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `tenant_id` bigint NOT NULL COMMENT '租户id',
  `leads_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '线索ID',
  `req_body` text COLLATE utf8mb4_bin NOT NULL COMMENT '入参',
  `retry_times` int DEFAULT '0' COMMENT '失败重试次数',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=253 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='开启工作流调用记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_status_msg_sync_history`
--

DROP TABLE IF EXISTS `iic_crm_leads_status_msg_sync_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_status_msg_sync_history` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `tenant_id` bigint NOT NULL COMMENT '租户id',
  `dae_lead_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '线索编号',
  `down_stream_lead_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '外部系统线索id',
  `system_name` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '子系统名称，XPlan、RPP',
  `policy_number` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '保单号',
  `product_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '产品名称',
  `sub_status` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '产品子状态',
  `product_expiry` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '产品过期日期',
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=99038 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='leads状态同步历史表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_strategy_detail_rel`
--

DROP TABLE IF EXISTS `iic_crm_leads_strategy_detail_rel`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_strategy_detail_rel` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '租户id',
  `leads_id` int NOT NULL COMMENT '线索id',
  `strategy_id` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '策略id',
  `step_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'step号',
  `type` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '类型(1-策略配置2-生日贺卡系统自动推送)',
  `is_done` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT 'N' COMMENT '是否完成',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_leadsIs_tenant_id` (`tenant_id`,`leads_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=108439 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='线索策略步骤记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_task_complete`
--

DROP TABLE IF EXISTS `iic_crm_leads_task_complete`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_task_complete` (
  `id` bigint unsigned NOT NULL COMMENT '主键',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `lead_id` bigint NOT NULL COMMENT '线索id',
  `stage_id` bigint NOT NULL COMMENT '阶段id',
  `task_id` bigint NOT NULL COMMENT '任务id',
  `is_done` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT 'N' COMMENT '是否完成，Y:已完成 N:未完成',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='线索任务完成记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_timer_action_task`
--

DROP TABLE IF EXISTS `iic_crm_leads_timer_action_task`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_timer_action_task` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `leads_id` bigint NOT NULL COMMENT '线索ID',
  `user_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '此时线索拥有者，可能是sm、adviser其中一个',
  `leads_status` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '见leads主表',
  `end_date` datetime NOT NULL COMMENT '结束时间，触发执行的时间',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '状态 0-待执行,1-执行成功,2-无需执行,-1-执行失败',
  `segment` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'segment',
  `dae_country_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `leads_id_idx` (`leads_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5933 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='线索定时action任务';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_workflow_info`
--

DROP TABLE IF EXISTS `iic_crm_leads_workflow_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_workflow_info` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` bigint NOT NULL COMMENT '租户ID',
  `business_key` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '线索id',
  `process_definition_key` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `process_instance_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `process_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `task_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `task_definition_key` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `action_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT '逻辑删除（0：未删除，1：已删除）',
  `user_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=30479 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='线索工作流信息';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_leads_xplan_feedback`
--

DROP TABLE IF EXISTS `iic_crm_leads_xplan_feedback`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_leads_xplan_feedback` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `tenant_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '租户id',
  `leads_id` bigint NOT NULL COMMENT '线索ID',
  `entity_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `container_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=282 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='iic_crm_leads_xplan feedback表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_need_type_product_rel`
--

DROP TABLE IF EXISTS `iic_crm_need_type_product_rel`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_need_type_product_rel` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` bigint NOT NULL COMMENT '租户id',
  `need_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'Need Type',
  `product_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '产品类型',
  `product_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '产品名称',
  `plan_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'Plan Code',
  `segment` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '组织类型PF、MFC',
  `is_deleted` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '是否已删除 0-未删除 1-已删除',
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=619 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='OM NeedType产品映射表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_om_sub_status_mapping`
--

DROP TABLE IF EXISTS `iic_crm_om_sub_status_mapping`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_om_sub_status_mapping` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `tenant_id` bigint NOT NULL COMMENT '租户id',
  `om_system_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'om子系统id,如OMI',
  `sub_status` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'om子系统状态',
  `dae_status` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'dae系统状态',
  `valid` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '1' COMMENT '有效状态 1-true 0-false，默认有效-1',
  `om_sub_status` varchar(60) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'om生产者消息过来的子状态',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='om子系统的子状态与Dae的状态映射表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_performance_tracking`
--

DROP TABLE IF EXISTS `iic_crm_performance_tracking`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_performance_tracking` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` bigint NOT NULL COMMENT '租户id',
  `user_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '用户id',
  `data_source` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '字段名为绩效统计数据源，绩效模块的字段，1-opportunity,2-appointment scheduled,3-appointment attended',
  `statistics_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '统计类型，对应create a lead等记录节点',
  `statistics_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '统计名称',
  `statistics_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '可被统计日期',
  `score` tinyint NOT NULL DEFAULT '0' COMMENT '计分字段，有1和-1',
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `sync_state` tinyint NOT NULL DEFAULT '0' COMMENT '推送状态：0-待推送，1-已推送',
  `branch_code` varchar(200) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'branch编码，多个逗号拼接',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_crm_pt_tenantId` (`tenant_id`),
  KEY `idx_crm_pt_statisticsDate` (`statistics_date`)
) ENGINE=InnoDB AUTO_INCREMENT=33400 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='绩效分埋点表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_policy`
--

DROP TABLE IF EXISTS `iic_crm_policy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_policy` (
  `id` bigint unsigned NOT NULL COMMENT '主键',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `customer_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '客户账户',
  `policy_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '保单号',
  `premium` decimal(15,2) DEFAULT NULL COMMENT '保费',
  `product_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '产品编码',
  `product_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '产品名称',
  `policy_begin_date` datetime DEFAULT NULL COMMENT '保单生效日期',
  `sum_insured` decimal(15,2) DEFAULT NULL COMMENT '保险金额',
  `policy_end_date` datetime DEFAULT NULL COMMENT '保单失效日期',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='保单主表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_policy_change`
--

DROP TABLE IF EXISTS `iic_crm_policy_change`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_policy_change` (
  `id` bigint unsigned NOT NULL COMMENT '主键',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户id',
  `policy_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '保单号',
  `bank_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '缴费银行',
  `bank_account` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '缴费账户',
  `card_holder` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '缴费用户名',
  `app_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '投保人电话',
  `app_email` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '投保人邮箱',
  `app_address` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '投保人地址',
  `app_zip_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '投保人邮编',
  `ins_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '被保人电话',
  `ins_email` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '被保人邮箱',
  `ins_address` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '被保人地址',
  `ins_zip_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '被保人邮编',
  `app_expiry_date` datetime DEFAULT NULL COMMENT '投保人证件有效期',
  `ins_expiry_date` datetime DEFAULT NULL COMMENT '被保人证件有效期',
  `ben_expiry_date` datetime DEFAULT NULL COMMENT '受益人证件有效期',
  `app_country` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '投保人国家',
  `app_married` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '投保人婚姻状况',
  `app_education` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '投保人学历',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='保单保全表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_policy_claim`
--

DROP TABLE IF EXISTS `iic_crm_policy_claim`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_policy_claim` (
  `id` bigint unsigned NOT NULL COMMENT '主键',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户id',
  `customer_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '客户账户',
  `policy_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '保单号',
  `claim_date` datetime DEFAULT NULL COMMENT '报案日期',
  `product_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '产品名称',
  `claim_status` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '理赔状态',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='客户理赔记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_practice_tracking`
--

DROP TABLE IF EXISTS `iic_crm_practice_tracking`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_practice_tracking` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` bigint NOT NULL COMMENT '租户id',
  `user_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '用户id',
  `data_source` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '字段名为绩效统计数据源，绩效模块的字段，1-opportunity,2-appointment scheduled,3-appointment attended',
  `data_source_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '来源id',
  `statistics_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '统计类型，对应create a lead等记录节点',
  `statistics_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '统计名称',
  `statistics_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '可被统计日期',
  `operate_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作日期',
  `score` tinyint NOT NULL DEFAULT '0' COMMENT '计分字段，有1,和0,和-1',
  `sync_state` tinyint NOT NULL DEFAULT '0' COMMENT '同步状态：0-待推送，1-已推送',
  `org_code` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'org编码,分割',
  `sales_week` int NOT NULL COMMENT 'sales_week',
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_practice_tracking_user_data_source` (`user_id`,`data_source_id`,`data_source`),
  KEY `idx_practice_tracking_sync_state` (`sync_state`)
) ENGINE=InnoDB AUTO_INCREMENT=16419 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='practice分埋点表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_prof_code`
--

DROP TABLE IF EXISTS `iic_crm_prof_code`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_prof_code` (
  `partner_id` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `code` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `description_zh_cn` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `description_en_us` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `description_ja_jp` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `grade` varchar(5) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `comm_flag` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `date_created` datetime NOT NULL COMMENT '创建时间',
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `date_updated` datetime NOT NULL COMMENT '更新时间',
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `class_code` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `subclass_code` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`code`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_prospect_sync_data`
--

DROP TABLE IF EXISTS `iic_crm_prospect_sync_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_prospect_sync_data` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `tenant_id` bigint NOT NULL COMMENT '租户ID',
  `prospect_id` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'prospect_id',
  `source` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '来源类型：Leads',
  `source_id` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'source_id',
  `data_type` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '数据类型：address/contact/identity/personal',
  `content` json NOT NULL COMMENT '内容（Json）',
  `revision` int NOT NULL DEFAULT '1' COMMENT '版本号',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_source_id_prospect_id` (`source_id`,`prospect_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Prospect数据同步表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_relation_network`
--

DROP TABLE IF EXISTS `iic_crm_relation_network`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_relation_network` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `tenant_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '租户id',
  `group_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'uuid',
  `type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '关系网类型1,Family Members\r\n2,Other Relationships',
  `level` int NOT NULL COMMENT '1：内圈:；2：外圈',
  `source_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '1,leads\r\n2,customer\r\n3,network_member',
  `source_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `relation_network_type` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT 'type=1时：1:Spouse2:Son3:Daughter4:Father5:Mother6:Grandparents7:In-Laws8:Siblings 9:Grandchildren10:Uncle11:Aunt12:Cousin13:Nephew14:Niece0:Other\r\n\r\ntype=2时：1:Friend2:Colleague0:Other；',
  `other_option` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '当relationship_type为other时，此字段填值',
  `is_delete` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '0' COMMENT ' 0:未删除 1:已删除 ',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=593 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='关系网表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_relation_network_member`
--

DROP TABLE IF EXISTS `iic_crm_relation_network_member`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_relation_network_member` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `tenant_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '租户id',
  `name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `gender` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `date_of_birth` datetime DEFAULT NULL,
  `phone` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `email` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `is_delete` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '0' COMMENT ' 0:未删除 1:已删除 ',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `id_type` char(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `id_no` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `age` int DEFAULT NULL,
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=312 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='关系网成员表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_relation_network_rel`
--

DROP TABLE IF EXISTS `iic_crm_relation_network_rel`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_relation_network_rel` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `tenant_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '租户id',
  `source_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '1,leads;2,customer',
  `source_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `relationship_group_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'uuid',
  `is_delete` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '0' COMMENT ' 0:未删除 1:已删除 ',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `source_type_source_id` (`source_type`,`source_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=58050 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='关系网rel表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_sales_date`
--

DROP TABLE IF EXISTS `iic_crm_sales_date`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_sales_date` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '租户id',
  `segment` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'segment',
  `date_value` date NOT NULL COMMENT '日期',
  `week_start_date` date NOT NULL COMMENT '周开始日期',
  `week_end_date` date NOT NULL COMMENT '周结束日期',
  `quarter` tinyint NOT NULL COMMENT '季度',
  `week_of_year` tinyint NOT NULL COMMENT '一年中第几周',
  `month_of_year` tinyint NOT NULL COMMENT '一年中第几月',
  `year` smallint NOT NULL COMMENT '归属年',
  `public_holiday_indicator` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0',
  `public_holiday_name` varchar(100) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '公共假期名称',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `type_date_value` (`tenant_id`,`segment`,`date_value`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=8067 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='销售日期配置';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_sales_date_0902`
--

DROP TABLE IF EXISTS `iic_crm_sales_date_0902`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_sales_date_0902` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '租户id',
  `segment` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'segment',
  `date_value` date NOT NULL COMMENT '日期',
  `week_start_date` date NOT NULL COMMENT '周开始日期',
  `week_end_date` date NOT NULL COMMENT '周结束日期',
  `quarter` tinyint NOT NULL COMMENT '季度',
  `week_of_year` tinyint NOT NULL COMMENT '一年中第几周',
  `month_of_year` tinyint NOT NULL COMMENT '一年中第几月',
  `year` smallint NOT NULL COMMENT '归属年',
  `public_holiday_indicator` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0',
  `public_holiday_name` varchar(100) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '公共假期名称',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `type_date_value` (`tenant_id`,`segment`,`date_value`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=6609 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='销售日期配置';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_sales_strategy_condition_setting`
--

DROP TABLE IF EXISTS `iic_crm_sales_strategy_condition_setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_sales_strategy_condition_setting` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` bigint NOT NULL COMMENT '租户id',
  `step_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '步骤号',
  `strategy_id` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '策略号',
  `category_node` bigint DEFAULT NULL,
  `category_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '分类项名称',
  `condition_code` bigint DEFAULT NULL COMMENT '条件编码',
  `condition_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '条件名称',
  `match_value` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '匹配值',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建日期',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改日期',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `first_level_node` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '一级节点编码',
  `second_level_node` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '二级选项编码',
  `match_value_code` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '匹配值编码',
  `field_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '字段类型',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_tenant_step_strategy` (`tenant_id`,`step_no`,`strategy_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=875 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='营销链路条件设置存储';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_sales_strategy_config_node`
--

DROP TABLE IF EXISTS `iic_crm_sales_strategy_config_node`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_sales_strategy_config_node` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '名称',
  `level` int NOT NULL COMMENT '层级',
  `parent_id` bigint DEFAULT NULL COMMENT '父级节点id',
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '节点类型:0-固定，1-下拉节点项，2-附加级联项 3-条件项 4.结果项',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建日期',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改日期',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `field_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '文本框类型',
  `status` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT '有效性（0：有效 1：无效）',
  `top_parent_id` bigint DEFAULT NULL COMMENT '顶级父id',
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '编码',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=182 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='经营链路表配置节点表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_search_customer_visit_record`
--

DROP TABLE IF EXISTS `iic_crm_search_customer_visit_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_search_customer_visit_record` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `tenant_id` bigint NOT NULL COMMENT '租户id',
  `record_unique_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `customer_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '业务key',
  `segment` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'MFC or PF',
  `first_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'first_name',
  `last_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'last_name',
  `reg_value` varchar(50) COLLATE utf8mb4_bin DEFAULT NULL,
  `date_of_birth` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'date_of_birth',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `country_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT 'ZA' COMMENT '客户countryCode: NA/ZA',
  `reg_type` char(1) COLLATE utf8mb4_bin DEFAULT NULL,
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `un_record_unique_code` (`record_unique_code`) USING BTREE,
  UNIQUE KEY `un_customer_id_created_by` (`created_by`,`customer_id`) USING BTREE,
  KEY `index_created_by_created_date` (`created_by`,`updated_date`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=523 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='customer search访问记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_search_org_customer_visit_record`
--

DROP TABLE IF EXISTS `iic_crm_search_org_customer_visit_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_search_org_customer_visit_record` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `tenant_id` bigint NOT NULL COMMENT '租户id',
  `record_unique_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `party_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '业务key',
  `segment` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'MFC or PF',
  `org_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'first_name',
  `org_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Close corporation； SA Private company； Special trust； Partnership； Foreign private company； Publicly listed company； Organ of state； Trust； Club； Fund； Other； Legal entity； Sole proprietorship； Religious concern；',
  `registration_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'registration_number',
  `dae_country_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `un_record_unique_code` (`record_unique_code`) USING BTREE,
  UNIQUE KEY `un_party_id_created_by` (`created_by`,`party_id`) USING BTREE,
  KEY `index_created_by_created_date` (`created_by`,`updated_date`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='customer org search访问记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_servicing_project`
--

DROP TABLE IF EXISTS `iic_crm_servicing_project`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_servicing_project` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '自增id',
  `SYSTEM_ID` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '系统项目编号',
  `SEGMENT` varchar(16) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '组织渠道:(PF/MFC)',
  `LINK_URI_PRD` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '生产环境链接地址',
  `LINK_URI_STG` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '测试环境链接地址',
  `LINK_URI_DEV` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '开发环境链接地址',
  `PRO_TYPE` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '项目信息类型(1:地址链接/2:邮件链接)',
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人员',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人员',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `STATUS` int DEFAULT '0' COMMENT '逻辑删除（0：未删除，1：已删除）',
  `TELEPHONE` varchar(50) COLLATE utf8mb4_bin DEFAULT '' COMMENT '电话号码',
  `PARENT_ID` int DEFAULT '0' COMMENT '项目父级ID, 0表示第一级',
  `sort` bigint DEFAULT NULL,
  `servicing_group` varchar(50) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '分组',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `fax` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '' COMMENT '传真',
  `title` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '' COMMENT '标题',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`),
  KEY `idx_sort` (`sort`),
  KEY `idx_pro_type` (`PRO_TYPE`)
) ENGINE=InnoDB AUTO_INCREMENT=77 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='Servicing项目信息';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_short_code`
--

DROP TABLE IF EXISTS `iic_crm_short_code`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_short_code` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `short_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '短码',
  `business_type` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '业务场景：1 one stream url跳转接受线索',
  `business_body` json NOT NULL COMMENT '业务信息',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '状态，0-未消费 1-已消费',
  `expired_date` datetime DEFAULT NULL COMMENT '过期时间',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `consumer_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '消费者',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `un_short_code` (`short_code`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=10940 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='短码表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_source_label`
--

DROP TABLE IF EXISTS `iic_crm_source_label`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_source_label` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `source_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '来源id',
  `source` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '类型(1-客户 2-线索)	',
  `label_type` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '标签类型(1-手动，2-系统，3-产品大类)',
  `label_value` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '标签value',
  `label_attribute` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '标签属性(标签一级分类)',
  `is_delete` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT ' 0:未删除 1:已删除 ',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_source_id_code` (`source_id`,`source`,`label_value`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=102895 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='标签表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_strategy`
--

DROP TABLE IF EXISTS `iic_crm_strategy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_strategy` (
  `id` bigint unsigned NOT NULL COMMENT '主键id',
  `strategy_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '策略号（SLM-ddmmyyyy-NO，SLM表示当前类别，中间为时间，最后为数字，同一天修改的情况下，数字逐渐累积）',
  `tenant_id` bigint NOT NULL COMMENT '租户id',
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '类型（1、Leads Marketing）',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_strategy_detail`
--

DROP TABLE IF EXISTS `iic_crm_strategy_detail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_strategy_detail` (
  `id` bigint unsigned NOT NULL COMMENT '主键id',
  `strategy_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '策略号（SLM-ddmmyyyy-NO，SLM表示当前类别，中间为时间，最后为数字，同一天修改的情况下，数字逐渐累积）',
  `tenant_id` bigint NOT NULL COMMENT '租户id',
  `step_no` bigint NOT NULL COMMENT 'Step号',
  `title` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '标题',
  `scope_of_lead` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '适用线索范围（1、all；2、under certain conditions）',
  `description` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '备注描述',
  `related_lead_stage` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '关联的线索旅程',
  `sales_tool` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '销售工具（加枚举FNA/Proposal/Products /Campaign/Business Card/video appointment）',
  `words_script` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '话术脚本',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '逻辑删除（0：未删除，1：已删除）',
  `tree_data` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '前端回显策略配置使用',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_strategy_his`
--

DROP TABLE IF EXISTS `iic_crm_strategy_his`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_strategy_his` (
  `id` bigint unsigned NOT NULL COMMENT '主键id',
  `strategy_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '策略号（SLM-ddmmyyyy-NO，SLM表示当前类别，中间为时间，最后为数字，同一天修改的情况下，数字逐渐累积）',
  `tenant_id` bigint NOT NULL COMMENT '租户id',
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '类型（1、Leads Marketing）',
  `last_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '原创人',
  `last_date` datetime NOT NULL COMMENT '原创时间',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '创建者(即更新人)',
  `created_date` datetime NOT NULL COMMENT '创建时间（即更新时间）',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '更新者(即更新人)',
  `updated_date` datetime NOT NULL COMMENT '更新时间(即更新时间）',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_survey`
--

DROP TABLE IF EXISTS `iic_crm_survey`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_survey` (
  `id` int NOT NULL AUTO_INCREMENT,
  `id_survey` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '问卷编码',
  `tenant_id` bigint DEFAULT NULL COMMENT '适用组织',
  `channel` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '渠道',
  `version_no` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '问卷版本号',
  `name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '问卷标题',
  `des` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '问卷描述',
  `state` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '问卷状态',
  `type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '问卷类型,1=个人需求问卷， 2=家庭需求问卷',
  `version_desc` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '问卷说明',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`),
  KEY `index_tenant_update_date` (`tenant_id`,`updated_date`),
  KEY `idx_updated_date` (`updated_date`),
  KEY `idx_state` (`state`)
) ENGINE=InnoDB AUTO_INCREMENT=86 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='问卷表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_survey_answer`
--

DROP TABLE IF EXISTS `iic_crm_survey_answer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_survey_answer` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_phone` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '客户手机号',
  `client_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '客户姓名',
  `agent_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '代理人编码',
  `id_topic` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '题目编码',
  `version_no` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '问卷版本',
  `answer` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '答案内容',
  `id_survey` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '题目类型 1=单选，2=多选，3=输入',
  `module_id` int NOT NULL COMMENT '模块id',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `result_code` varchar(30) COLLATE utf8mb4_bin NOT NULL COMMENT 'result表唯一code',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_five` (`id_survey`,`version_no`,`agent_code`,`client_name`,`client_phone`),
  KEY `iic_crm_survey_answer_result_code_idx` (`result_code`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=246935 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='问卷答案表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_survey_calculation_config`
--

DROP TABLE IF EXISTS `iic_crm_survey_calculation_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_survey_calculation_config` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `survey_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '问卷编码',
  `calculated_value_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '计算值编码',
  `calculated_value_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '计算值名称',
  `criteria_rule` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '判定对着，0:None；1：最小值  2：最大值',
  `variable_pool` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '额度计算变量库,题目表id',
  `variable_expression` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '额度计算公式',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=DYNAMIC COMMENT='问卷计算值配置表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_survey_customization_fields`
--

DROP TABLE IF EXISTS `iic_crm_survey_customization_fields`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_survey_customization_fields` (
  `id` int NOT NULL AUTO_INCREMENT,
  `result_code` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '问卷编码',
  `module_id` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '模块id',
  `field_key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'null' COMMENT '定制化字段key',
  `field_value` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '定制化字段值',
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'system' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'system' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_result_code` (`result_code`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=174058 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_survey_dependents_relationships`
--

DROP TABLE IF EXISTS `iic_crm_survey_dependents_relationships`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_survey_dependents_relationships` (
  `customer_id` varchar(50) COLLATE utf8mb4_bin NOT NULL COMMENT '客户ID',
  `result_code` bigint NOT NULL COMMENT '结果编码',
  `advisor_code` varchar(100) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '代理人编码',
  `client_phone` varchar(20) COLLATE utf8mb4_bin NOT NULL COMMENT '客户手机号',
  `client_name` varchar(100) COLLATE utf8mb4_bin NOT NULL COMMENT '客户姓名',
  `spouse` char(1) COLLATE utf8mb4_bin DEFAULT '0' COMMENT '0=未勾选，1=已勾选',
  `parents` char(1) COLLATE utf8mb4_bin DEFAULT '0' COMMENT '0=未勾选，1=已勾选',
  `children` char(1) COLLATE utf8mb4_bin DEFAULT '0' COMMENT '0=未勾选，1=已勾选',
  `other` char(1) COLLATE utf8mb4_bin DEFAULT '0' COMMENT '0=未勾选，1=已勾选',
  `created_by` varchar(50) COLLATE utf8mb4_bin NOT NULL,
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` varchar(50) COLLATE utf8mb4_bin DEFAULT NULL,
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='ena亲属关系表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_survey_result`
--

DROP TABLE IF EXISTS `iic_crm_survey_result`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_survey_result` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `result_code` bigint NOT NULL COMMENT '结果编码',
  `agent_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '代理人编号',
  `client_phone` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '客户手机号',
  `client_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '客户名字',
  `id_survey` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '问卷编码',
  `version_no` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '问卷版本号',
  `product_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '产品编码',
  `product_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '产品名',
  `recommend_reason` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '推荐原因',
  `recommend_amount` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '推荐保额',
  `product_category` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '产品类型',
  `product_desc` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '产品描述',
  `product_picture` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '产品图片',
  `contact_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '客户/线索id',
  `contact_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '客户/线索id类型：0-线索，1-客户',
  `insur_company_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '保司编码',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `draft` char(1) COLLATE utf8mb4_bin DEFAULT '0' COMMENT '0=已完成，1=草稿',
  `cur_module_id` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '草稿状态下当前模块',
  `common_dependant` text COLLATE utf8mb4_bin COMMENT '前端暂存字段',
  `currency_type` varchar(50) COLLATE utf8mb4_bin NOT NULL DEFAULT 'zar' COMMENT '默认值zar, zar代表南非货币 nad代表纳米比亚货币',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`),
  KEY `idx_created_date` (`created_date`),
  KEY `index_result_code_created_date` (`result_code`,`created_date`),
  KEY `idx_ena_query` (`result_code`,`contact_id`,`contact_type`,`draft`)
) ENGINE=InnoDB AUTO_INCREMENT=9240 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='问卷结果表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_survey_result_extend`
--

DROP TABLE IF EXISTS `iic_crm_survey_result_extend`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_survey_result_extend` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `result_code` bigint NOT NULL COMMENT '结果编码',
  `dynamic_field` json DEFAULT NULL COMMENT '计算结果字段',
  `plan` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'customer needs plan',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`),
  KEY `idx_result_code` (`result_code`)
) ENGINE=InnoDB AUTO_INCREMENT=8213 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='问卷计算结果表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_survey_show_config`
--

DROP TABLE IF EXISTS `iic_crm_survey_show_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_survey_show_config` (
  `id` int NOT NULL AUTO_INCREMENT,
  `id_topic` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '题目编码',
  `show_type` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '类型，1=必现，2=条件出现',
  `refer_topic_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '关联题目id',
  `click_type` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '击中模式，1=完全符合，2=任一一个符合即可',
  `click_options` varchar(400) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '击中选项',
  `formula` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '计算公式',
  `formula_array` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '计算公式拆分数组',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_delete` tinyint DEFAULT '0' COMMENT '0=未删除，1=已删除',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='问卷题目出现逻辑表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_survey_topic`
--

DROP TABLE IF EXISTS `iic_crm_survey_topic`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_survey_topic` (
  `id` int NOT NULL AUTO_INCREMENT,
  `id_topic` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '题目编码',
  `id_survey` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '问卷编码',
  `version_no` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '问卷版本号',
  `seq_no` int DEFAULT NULL COMMENT '排序序号',
  `topic_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '题目类型',
  `topic_title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '题目标题',
  `topic_title_short_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '题目简写',
  `topic_desc` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '题目描述',
  `topic_content` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '题目文本内容',
  `img_url` varchar(400) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `file_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '文件key',
  `module_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '模板id',
  `module_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '模板编码',
  `category_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '分类编码',
  `field_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '字段编码',
  `field_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '字段名',
  `module_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '表单模板名',
  `mandatory` char(1) COLLATE utf8mb4_bin DEFAULT '0' COMMENT '必填=1，非必填=0',
  `label` varchar(100) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '单行文本标签',
  `default_topic` char(1) COLLATE utf8mb4_bin DEFAULT '0' COMMENT '值来源，0=手工输入,1=系统获取',
  `is_delete` tinyint DEFAULT '0' COMMENT '0=未删除，1=已删除',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  `parent_topic` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `index_id_survey_version_module_seq` (`id_survey`,`version_no`,`module_id`,`seq_no`) USING BTREE,
  KEY `idx_test` (`module_id`) USING BTREE,
  KEY `index_id_survey_version_no_seq_no` (`id_survey`,`version_no`,`seq_no`),
  KEY `index_id_topic_seq_no` (`id_topic`,`seq_no`),
  KEY `idx_seq_no` (`seq_no`),
  KEY `iic_crm_survey_topic_parent_topic_IDX` (`parent_topic`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=511 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='问卷题目表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_survey_topic_module`
--

DROP TABLE IF EXISTS `iic_crm_survey_topic_module`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_survey_topic_module` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '租户id',
  `id_survey` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '问卷编码',
  `version_no` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '问卷版本号',
  `seq_no` int DEFAULT NULL COMMENT '排序序号',
  `module_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '模板编码',
  `module_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '模板名',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_delete` tinyint DEFAULT '0' COMMENT '0=未删除，1=已删除',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`),
  KEY `index_id_version_is_delete_seq` (`id_survey`,`version_no`,`is_delete`,`seq_no`)
) ENGINE=InnoDB AUTO_INCREMENT=116 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='问卷题目模块表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_survey_topic_option`
--

DROP TABLE IF EXISTS `iic_crm_survey_topic_option`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_survey_topic_option` (
  `id` int NOT NULL AUTO_INCREMENT,
  `id_topic` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '题目编码',
  `seq_no` int DEFAULT NULL COMMENT '排序序号',
  `value` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '选项值',
  `img_url` varchar(400) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '选项图标',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `file_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '文件key',
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '选项编码',
  `topic_type` varchar(100) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '选项控件类型',
  `mandatory` char(1) COLLATE utf8mb4_bin DEFAULT '0' COMMENT '必填=1，非必填=0',
  `label` varchar(100) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '单行文本标签',
  `is_delete` tinyint DEFAULT '0' COMMENT '0=未删除，1=已删除',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_id_topic` (`id_topic`)
) ENGINE=InnoDB AUTO_INCREMENT=100354 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='问卷题目选项表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_survey_topic_option_children`
--

DROP TABLE IF EXISTS `iic_crm_survey_topic_option_children`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_survey_topic_option_children` (
  `id` int NOT NULL AUTO_INCREMENT,
  `id_option` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '题目编码',
  `seq_no` int DEFAULT NULL COMMENT '排序序号',
  `value` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '选项值',
  `img_url` varchar(400) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '选项图标',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `file_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '文件key',
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '选项编码',
  `label` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '单行文本标签',
  `mandatory` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT '必填=1，非必填=0',
  `topic_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '选项控件类型',
  `dae_country_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `is_delete` tinyint DEFAULT '0' COMMENT '0=未删除，1=已删除',
  `created_by_login_user` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_id_option` (`id_option`)
) ENGINE=InnoDB AUTO_INCREMENT=2072 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='问卷题目选项子项表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_survey_user_module_record`
--

DROP TABLE IF EXISTS `iic_crm_survey_user_module_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_survey_user_module_record` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` varchar(32) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '租户ID',
  `id_survey` varchar(20) COLLATE utf8mb4_bin NOT NULL COMMENT '问卷ID',
  `result_code` varchar(32) COLLATE utf8mb4_bin NOT NULL COMMENT '问卷作答唯一标识',
  `agent_code` varchar(64) COLLATE utf8mb4_bin NOT NULL COMMENT '用户id',
  `module_id` int NOT NULL COMMENT '模块ID',
  `module_name` varchar(100) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '模块名称',
  `status` varchar(2) COLLATE utf8mb4_bin DEFAULT '0' COMMENT '完成状态,0:未完成/1:已完成',
  `created_by` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM',
  `created_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_by` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM',
  `updated_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_user_module_result_code_seq` (`result_code`),
  KEY `index_result_agent_module_seq` (`result_code`,`agent_code`,`module_id`)
) ENGINE=InnoDB AUTO_INCREMENT=50037 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='用户问卷模块完成记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_task_comment`
--

DROP TABLE IF EXISTS `iic_crm_task_comment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_task_comment` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `tenant_id` bigint NOT NULL COMMENT '租户id',
  `task_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '任务ID',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '评论内容',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT '逻辑删除（0：未删除，1：已删除）',
  `created_by_login_user` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`),
  KEY `index_task_id` (`task_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='任务comment表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_task_identity`
--

DROP TABLE IF EXISTS `iic_crm_task_identity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_task_identity` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户id',
  `identity_code` varchar(10) DEFAULT NULL COMMENT '身份编码',
  `identity_name` varchar(20) DEFAULT NULL COMMENT '身份名称',
  `is_deleted` tinyint(1) DEFAULT '0' COMMENT ' 0:未删除 1:已删除 ',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`),
  UNIQUE KEY `identity_code_tenant_id_idx` (`tenant_id`,`identity_code`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='任务身份表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_task_identity_permission`
--

DROP TABLE IF EXISTS `iic_crm_task_identity_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_task_identity_permission` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `identity_code` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '身份code',
  `resource_id` bigint NOT NULL COMMENT '资源ID',
  `status` int NOT NULL COMMENT '状态(0有效 1删除)',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='租户角色权限配置表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_task_info`
--

DROP TABLE IF EXISTS `iic_crm_task_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_task_info` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `task_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '任务id',
  `task_name` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '任务名称',
  `template_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '模板编码',
  `task_attribute` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '任务属性01：独立任务independent task;02:复合任务complex task;03:Joint Tracking Task',
  `task_associated_object` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '任务关联模块01:Leads;02:Customer;03:Events In Calendar',
  `task_desc` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '任务描述',
  `task_type` char(2) DEFAULT NULL COMMENT '任务类型：01=Induction/02=Performance/03=Worksite visit/04=Observation',
  `recipient_id` varchar(50) DEFAULT NULL COMMENT '接收人id',
  `recipient_name` varchar(50) DEFAULT NULL COMMENT '接收人名称',
  `task_mode` char(2) DEFAULT NULL COMMENT '模式，01：independent event; 02:scheduled event',
  `task_start_date` datetime DEFAULT NULL COMMENT '任务开始时间',
  `task_end_date` datetime DEFAULT NULL COMMENT '任务结束时间',
  `worksite` varchar(100) DEFAULT NULL COMMENT 'wokeSite组织',
  `worksite_code` varchar(100) DEFAULT NULL COMMENT 'wokeSite组织编码',
  `location` varchar(3000) DEFAULT NULL COMMENT '地址',
  `category` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '模板类别，01：JFW; 02: Coaching Session; 03: Performance',
  `auto_rule_config` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '自动分配开关1开0否',
  `task_status` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '01' COMMENT '任务状态 01 In Progress, 02 To Be Acknowledged, 03 Cancelled, 04 Completed',
  `auto_rule` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '自动分配规则',
  `questionnaire_id` varchar(50) DEFAULT NULL COMMENT '问卷id',
  `creator_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '创建人id',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户id',
  `is_delete` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '是否删除1是0否',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '修改人',
  `all_day` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT '是否一整天：0 否;1是',
  `cancel_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '取消人',
  `cancel_date` datetime DEFAULT NULL COMMENT '取消时间',
  `task_type_label` varchar(100) DEFAULT NULL COMMENT '任务类型标签',
  `branch_code` varchar(50) DEFAULT NULL COMMENT 'branchCode',
  `un_acknowledge_date` datetime DEFAULT NULL COMMENT '待确认日期',
  `acknowledge_date` datetime DEFAULT NULL COMMENT '确认日期',
  `dae_country_code` varchar(20) DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `team_goal_id` varchar(32) DEFAULT NULL COMMENT 'teamPerformance的goalId',
  `business_type` varchar(2) NOT NULL DEFAULT '0' COMMENT 'task业务类型，0task列表创建，1绩效cal创建',
  `view_status` varchar(2) NOT NULL DEFAULT '0' COMMENT '0:未读，1已读（暂只有business_type为1时，此字段有用）',
  `created_by_login_user` varchar(50) DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) DEFAULT 'SYSTEM' COMMENT '实际修改人',
  `questionnaire_flag` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '0' COMMENT '区分新旧单 0 旧单 1新单',
  `recipient_work_sites` varchar(3072) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `next_task_start_date` datetime DEFAULT NULL COMMENT '下次任务开始时间',
  `next_task_end_date` datetime DEFAULT NULL COMMENT '下次任务结束时间',
  `link_task_id` varchar(50) DEFAULT NULL COMMENT '关联任务id',
  `submitted_date` datetime DEFAULT NULL COMMENT '提交时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_iic_crm_task_id` (`task_id`) USING BTREE,
  KEY `idx_iic_crm_task_info_recipient_updated_date` (`recipient_id`,`updated_date`),
  KEY `idx_task_start_date` (`task_start_date`)
) ENGINE=InnoDB AUTO_INCREMENT=438 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='任务主表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_task_info_event`
--

DROP TABLE IF EXISTS `iic_crm_task_info_event`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_task_info_event` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `task_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '任务id',
  `task_event_id` varchar(300) DEFAULT NULL COMMENT '任务操作id',
  `original_event_id` varchar(300) DEFAULT NULL COMMENT '原操作id',
  `user_id` varchar(50) DEFAULT NULL COMMENT '用户id',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户id',
  `is_delete` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '是否删除1是0否',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '修改人',
  `dae_country_code` varchar(20) DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_task_id` (`task_id`)
) ENGINE=InnoDB AUTO_INCREMENT=549 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='任务事件关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_task_notify_message`
--

DROP TABLE IF EXISTS `iic_crm_task_notify_message`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_task_notify_message` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `operator_user_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '操作人id',
  `action_identity_code` varchar(10) COLLATE utf8mb4_bin NOT NULL COMMENT '操作人权限',
  `message` varchar(200) COLLATE utf8mb4_bin NOT NULL COMMENT '通知消息',
  `category` varchar(10) COLLATE utf8mb4_bin NOT NULL COMMENT '通知消息类型 01:JWF, 02:CS',
  `notify_user_id` varchar(20) COLLATE utf8mb4_bin NOT NULL COMMENT '被通知人id',
  `notify_identity_code` varchar(10) COLLATE utf8mb4_bin NOT NULL COMMENT '被通知人权限',
  `task_id` bigint NOT NULL COMMENT '任务id',
  `notify_status` varchar(10) COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '通知是否查看状态',
  `tenant_id` bigint NOT NULL COMMENT '租户id',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `iic_crm_task_notify_message_task_id_IDX` (`task_id`) USING BTREE,
  KEY `iic_crm_task_notify_message_notify_user_id_IDX` (`notify_user_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=99 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='task操作变动消息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_task_questionnaire`
--

DROP TABLE IF EXISTS `iic_crm_task_questionnaire`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_task_questionnaire` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `template_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '模板编码',
  `questionnaire_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '问卷id',
  `title_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '问题id',
  `questionnaire_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '问题类型',
  `questionnaire_title` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '问题标题',
  `required_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT '是否必填 0:必填 1:选填',
  `answer_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT '答案类型 0:单选 1:多选 2：freeText',
  `answer_content` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT '答案内容 （A:answer1;B:answer2.......以此类推）',
  `comments` text COMMENT '备注',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户id',
  `is_delete` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '是否删除1是0否',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '修改人',
  `dae_country_code` varchar(20) DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `role_type` char(1) DEFAULT '1' COMMENT '1=sm，2=am',
  `is_remark` char(1) DEFAULT '0' COMMENT '是否需要remark, 1=是，0=否',
  `created_by_login_user` varchar(50) DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=107 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='任务问卷表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_task_resource`
--

DROP TABLE IF EXISTS `iic_crm_task_resource`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_task_resource` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `permission_code` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '权限编码',
  `permission_name` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '权限名称',
  `url` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '接口url',
  `status` tinyint DEFAULT '0',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`),
  UNIQUE KEY `permission_code_idx` (`permission_code`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='操作资源权限基础表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_task_status_permission`
--

DROP TABLE IF EXISTS `iic_crm_task_status_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_task_status_permission` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `task_status_code` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '任务状态',
  `identity_code` varchar(10) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '身份编码',
  `resource_id` bigint NOT NULL COMMENT '资源ID',
  `status` int NOT NULL COMMENT '状态(0有效 1删除)',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='任务状态权限配置表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_task_template`
--

DROP TABLE IF EXISTS `iic_crm_task_template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_task_template` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `task_template_unique_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '模板编码',
  `template_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '任务模板名称',
  `attribute` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '任务属性：01：独立任务independent task;02:复合任务complex task;03:Joint Tracking Task',
  `associated_object` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '对象关联:01:Leads;02:Customer;03:Events In Calendar',
  `auto_rule_config` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '自动规则触发:0:否；1:是',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT '备注',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '状态（0：disable，1：active）',
  `category` char(2) COLLATE utf8mb4_bin DEFAULT NULL COMMENT '模板类别，01：JFW; 02: Policy; 03: Service',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户id',
  `is_deleted` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '是否删除，1是0否',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='任务模板表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_task_type`
--

DROP TABLE IF EXISTS `iic_crm_task_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_task_type` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `task_category` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '模板类别，01：JFW; 02: Coaching Session; 03: Performance',
  `type_code` varchar(10) DEFAULT NULL COMMENT '编码',
  `description` varchar(100) DEFAULT NULL COMMENT '描述',
  `parent_code` varchar(10) DEFAULT NULL COMMENT '父编码',
  `sort` int NOT NULL COMMENT '排序',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户id',
  `is_delete` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '是否删除1是0否',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '修改人',
  `dae_country_code` varchar(20) DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`),
  KEY `idx_sort` (`sort`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='任务类型表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_task_user_answer`
--

DROP TABLE IF EXISTS `iic_crm_task_user_answer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_task_user_answer` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `task_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '任务id',
  `questionnaire_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '问卷id',
  `user_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '用户id',
  `title_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '问题id',
  `title_answer` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '问题答案',
  `is_delete` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '是否删除1是0否',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `created_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `updated_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '修改人',
  `responsible_person_id` varchar(50) DEFAULT NULL COMMENT '负责人id',
  `responsible_person_name` varchar(50) DEFAULT NULL COMMENT '负责人名称',
  `due_date` datetime DEFAULT NULL COMMENT '到期日',
  `sort` int DEFAULT NULL COMMENT '排序',
  `dae_country_code` varchar(20) DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `remark` varchar(500) DEFAULT NULL COMMENT 'remark内容',
  `created_by_login_user` varchar(50) DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1912 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='用户任务问卷答案表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_task_user_identity`
--

DROP TABLE IF EXISTS `iic_crm_task_user_identity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_task_user_identity` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '用户ID',
  `task_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '任务id',
  `identity_code` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '身份code',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户id',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1405 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='任务用户身份关系表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_template_birthday_card`
--

DROP TABLE IF EXISTS `iic_crm_template_birthday_card`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_template_birthday_card` (
  `id` bigint unsigned NOT NULL COMMENT '主键',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `file_key` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `is_cover` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT '是否封面',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT '逻辑删除（0：未删除，1：已删除）',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_id_createdDate` (`id`,`created_date`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='template生日贺卡表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_template_blessing_word`
--

DROP TABLE IF EXISTS `iic_crm_template_blessing_word`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_template_blessing_word` (
  `id` bigint unsigned NOT NULL COMMENT '主键',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `content` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT '逻辑删除（0：未删除，1：已删除）',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='template生日祝福语表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_tenant_organization_info`
--

DROP TABLE IF EXISTS `iic_crm_tenant_organization_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_tenant_organization_info` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `org_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '组织编码',
  `org_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '组织名称',
  `parent_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '组织父节点',
  `org_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '组织路径',
  `org_code_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '组织编码链路',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户id',
  `org_level` bigint DEFAULT NULL COMMENT '组织层级',
  `status` int DEFAULT NULL COMMENT '状态（0有效，时效1）',
  `created_date` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '创建人',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '更新时间',
  `updated_date` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `org_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '组织类型',
  `tenant_org_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '租户自定义组织代码',
  `cost_center` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Cost Center',
  `org_status` int DEFAULT NULL COMMENT '组织状态',
  `dae_country_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_iic_crm_tenant_organization_info_org_path` (`org_path`) USING BTREE,
  KEY `org_code_parent_tenant_idx` (`org_code`,`parent_id`,`tenant_id`) USING BTREE,
  KEY `idx_org_name` (`org_name`) USING BTREE,
  KEY `idx_iic_crm_tenant_organiza_info_parent_id` (`parent_id`) USING BTREE,
  KEY `idx_org_code_path` (`org_code_path`) USING BTREE,
  KEY `idx_crm_organization_info_org_code_path` (`org_code_path`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_third_common_log`
--

DROP TABLE IF EXISTS `iic_crm_third_common_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_third_common_log` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `tenant_id` bigint NOT NULL COMMENT '租户ID',
  `interface_code` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '接口编号',
  `interface_name` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '接口名称',
  `uri` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '接口uri',
  `result_code` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '返回结果状态码',
  `mandate_reference` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '银行授权号',
  `auth_service` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'authService值为‘AC TT1’,‘AC TT2’',
  `tt1_type` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'tt1_type值为REALTIME,DELAYED,TTR等',
  `upstream_time` datetime NOT NULL COMMENT '上行时间（发往OM的时间）',
  `upstream_data` json NOT NULL COMMENT '上行报文（JSON格式）',
  `upstream_response_time` datetime DEFAULT NULL COMMENT '上行响应时间（收到OM响应的时间）',
  `upstream_response_data` json NOT NULL COMMENT '上行响应报文（JSON格式）',
  `upstream_system` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '上行系统代号（即OM系统代号）',
  `revision` int NOT NULL DEFAULT '1' COMMENT '版本号',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_delete` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT '逻辑删除（0：未删除，1：已删除）',
  `created_by_login_user` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`),
  KEY `idx_interface_code` (`interface_code`),
  KEY `idx_upstream_time` (`upstream_time`),
  KEY `idx_mandate_reference` (`mandate_reference`),
  KEY `idx_result_code` (`result_code`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='第三方重要接口日志表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_timeline`
--

DROP TABLE IF EXISTS `iic_crm_timeline`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_timeline` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT 'id',
  `source_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '来源id',
  `message` varchar(3000) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '信息',
  `address` varchar(3000) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '地址',
  `timeline_type` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'timeline类型',
  `source` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '1:线索;2:客户;3:JFW-TASK ; 4:Coaching Session;',
  `start_date` datetime DEFAULT NULL COMMENT '开始时间',
  `end_date` datetime DEFAULT NULL COMMENT '结束时间',
  `tenant_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '租户id',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `sub_type` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '子类型',
  `agent_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '代理人id',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `source_id_idx` (`source_id`),
  KEY `idx_created_date` (`created_date`)
) ENGINE=InnoDB AUTO_INCREMENT=749588 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='timeline表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_timeline_note`
--

DROP TABLE IF EXISTS `iic_crm_timeline_note`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_timeline_note` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `timeline_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'timelineId',
  `agent_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '代理人',
  `agent_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '代理人姓名',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '备注内容',
  `is_delete` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT ' 0:未删除 1:已删除 ',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `index_timeline` (`timeline_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=100146 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='timeline备注表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_timeline_rel_action_code`
--

DROP TABLE IF EXISTS `iic_crm_timeline_rel_action_code`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_timeline_rel_action_code` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `type` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '对接渠道',
  `action_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `timeline_type` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `sub_type` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `type_action_code` (`type`,`action_code`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='timeline_rel_action_code表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_timeline_template`
--

DROP TABLE IF EXISTS `iic_crm_timeline_template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_timeline_template` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `timeline_type` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `sub_type` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `message` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '信息',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `timeline_type_sub_type` (`timeline_type`,`sub_type`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=72 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='timeline_template表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_trx_log`
--

DROP TABLE IF EXISTS `iic_crm_trx_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_trx_log` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `trx_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '业务id',
  `trx_status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '0=未执行，1=已执行',
  `type_` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '业务类型',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_use_setting`
--

DROP TABLE IF EXISTS `iic_crm_use_setting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_use_setting` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `type` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '1-线索列表，2-线索池 3-客户联系列表 4-客户列表 5-客户池 6-全局线索待分配 7-全局线索已分配 8-团队线索管理待分配 9-团队线索管理已分配 10-团队客户池待分配 11- 团队客户池已分配 12-全局代理人待分配 13-全局代理人已分配 j-teamleads leadsInProgress open k-teamleads toBeActionedByMe l-teamleads toBeAccepted m-teamleads leadsInProgress close',
  `agent_id` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '代理人id',
  `leads_list_column_setting` json NOT NULL COMMENT '线索列表列字段json设置',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_default` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '0' COMMENT '是否默认 0:默认 1：非默认',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_agent_id` (`agent_id`),
  KEY `idx_type` (`type`)
) ENGINE=InnoDB AUTO_INCREMENT=543 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='使用设置表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_user`
--

DROP TABLE IF EXISTS `iic_crm_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_user` (
  `id` bigint unsigned NOT NULL COMMENT '主键',
  `user_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '用户ID',
  `user_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '用户名',
  `company_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '公司编码',
  `department_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '机构编码',
  `staff_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '职位id',
  `user_type` int DEFAULT NULL COMMENT '用户类型(0-内部;1-外部)',
  `email` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '邮箱',
  `telephone` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '手机号',
  `data_source` int NOT NULL DEFAULT '0' COMMENT '用户来源(0-自建;1-对接;...)（hm_base_data基表type_name为data_source）',
  `status` int NOT NULL COMMENT '用户状态(0-lock;1-active;2-删除;...)（hm_base_data基表type_name为user_status）',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建者',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新者',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `iic_crm_user_un` (`user_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='用户信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iic_crm_user_top_info`
--

DROP TABLE IF EXISTS `iic_crm_user_top_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iic_crm_user_top_info` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `agent_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '代理人ID',
  `agent_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '代理人名称',
  `sales_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '代理人销售编码',
  `top_label` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '1' COMMENT 'top标签 0:非TOP  1:TOP',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'SYSTEM' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `dae_country_code` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'country级别的organizationId映射对应的国家编码',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='代理人top标签表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `migrate_leads_error_detail`
--

DROP TABLE IF EXISTS `migrate_leads_error_detail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `migrate_leads_error_detail` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `request_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '请求id（同migrate_leads_record表的request_id）',
  `adviser_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '代理人id',
  `leads_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '线索id',
  `migrate_method` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'migrate有离职、换组两种场景，4中方法,记录报错的方法',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '备注',
  `status` int DEFAULT '-1' COMMENT '状态0成功；-1失败',
  `tenant_id` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT '121' COMMENT '租户id',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'system' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建日期',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'system' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日期',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='离职换组lead迁移记录报错lead明细';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `migrate_leads_record`
--

DROP TABLE IF EXISTS `migrate_leads_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `migrate_leads_record` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `request_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '请求id',
  `request_body` varchar(5000) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '请求体',
  `migrate_type` int DEFAULT '0' COMMENT '迁移类型：0 离职，1 换组',
  `status` int DEFAULT '0' COMMENT '状态0成功；-1失败',
  `tenant_id` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT '121' COMMENT '租户id',
  `retry_count` int DEFAULT '0' COMMENT '重试次数统计，重试最大次数3次，超过3次的人工介入，查询原因并调用接口补偿',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '备注',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'system' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建日期',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'system' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日期',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=57582 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='离职换组lead迁移记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sensitive_info_shield`
--

DROP TABLE IF EXISTS `sensitive_info_shield`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sensitive_info_shield` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT 'The Primary Key',
  `SYS_NAME` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'The name of the subsystem to which the table belongs',
  `BUSINESSDB` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'The name of the Database which the table belongs',
  `TABLE_NAME` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'The name of the the table',
  `COLUMN_NAME` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'The name of the column that contains sensitive data',
  `DESCRIPTION` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'The description of the column that contains sensitive data',
  `SHIELD_ITEM` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'Desensitization method',
  `Estimat_percent` float(3,2) DEFAULT '1.00' COMMENT 'Estimate Percent Rows of the Table',
  `SCRIPT` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT 'Customize desensitization scripts, if there is a special desensitization script for this column_name',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `UK_SENSITIVE_INFO_SHIELD` (`BUSINESSDB`,`TABLE_NAME`,`COLUMN_NAME`,`SHIELD_ITEM`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `test`
--

DROP TABLE IF EXISTS `test`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `test` (
  `id` int DEFAULT NULL,
  `name` varchar(20) COLLATE utf8mb4_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `transaction_local_msg_table`
--

DROP TABLE IF EXISTS `transaction_local_msg_table`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transaction_local_msg_table` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `request_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '请求id',
  `queue` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '队列queue名称',
  `request_body` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '请求体',
  `business_key` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '业务key',
  `request_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '类型，请求request、响应respone',
  `remark` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '备注',
  `status` int DEFAULT '0' COMMENT '状态1成功；-1失败',
  `tenant_id` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT '121' COMMENT '租户id',
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'system' COMMENT '创建人',
  `created_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建日期',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'system' COMMENT '更新人',
  `updated_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日期',
  `retry_max` int DEFAULT '5' COMMENT '重试最大次数',
  `retry_count` int DEFAULT '0' COMMENT '重试次数统计',
  `manual_handle` int DEFAULT '0',
  `business` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '业务场景',
  `operation` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '操作',
  `created_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际操作人',
  `updated_by_login_user` varchar(50) COLLATE utf8mb4_bin DEFAULT 'SYSTEM' COMMENT '实际修改人',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `un_request_id` (`request_id`) USING BTREE,
  KEY `index_business_key` (`business_key`) USING BTREE,
  KEY `transaction_local_msg_table_business_key_IDX` (`business_key`) USING BTREE,
  KEY `transaction_local_msg_table_request_id_IDX` (`request_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=46799 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC COMMENT='本地消息事务表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary view structure for view `view_campaign_info`
--

DROP TABLE IF EXISTS `view_campaign_info`;
/*!50001 DROP VIEW IF EXISTS `view_campaign_info`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `view_campaign_info` AS SELECT 
 1 AS `id`,
 1 AS `campaign_code`,
 1 AS `campaign_name`,
 1 AS `tenant_id`,
 1 AS `campaign_source_type`,
 1 AS `created_agent_id`*/;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `view_campaign_info`
--

/*!50001 DROP VIEW IF EXISTS `view_campaign_info`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`deployop`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `view_campaign_info` AS select `iic_crm_campaign`.`id` AS `id`,`iic_crm_campaign`.`campaign_code` AS `campaign_code`,`iic_crm_campaign`.`campaign_name` AS `campaign_name`,`iic_crm_campaign`.`tenant_id` AS `tenant_id`,'default' AS `campaign_source_type`,`iic_crm_campaign`.`created_agent_id` AS `created_agent_id` from `iic_crm_campaign` union select `iic_crm_campaign_om`.`campaign_code` AS `id`,`iic_crm_campaign_om`.`campaign_code` AS `campaign_code`,`iic_crm_campaign_om`.`name` AS `campaign_name`,`iic_crm_campaign_om`.`tenant_id` AS `tenant_id`,'om' AS `campaign_source_type`,NULL AS `created_agent_id` from `iic_crm_campaign_om` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-03-19  6:52:03
