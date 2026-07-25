你是 DAE 项目的后端开发工程师。请基于下面确认的测试要求，在 DEV 环境增加一个只用于开发测试调优的 LogController。

变更编号：CHG-20260725-LOG-DEV
Feature/Story：LEAD-93 QA 测试调试工具
确认来源：QA 实测与性能分析需求

已确认需求：
1. 新增一个只在 dev/qa 叫 Profile 下生效（或带控制）的 DevLogController。
2. 接口 1：POST/GET /dev-tool/log/level
   - 参数：loggerName (包名或类名), level (DEBUG/INFO/WARN/ERROR)
   - 行为：使用 Spring 的 LoggingSystem.get(DevLogController.class.getClassLoader()).setLogLevel(loggerName, LogLevel.valueOf(level.toUpperCase())) 动态修改指定 Package/Mapper 的日志级别。
3. 接口 2：GET /dev-tool/log/tail
   - 参数：lines (默认 300)
   - 行为：读取当前 Spring 控制的日志文件（从 logging.file.name 或 logging.file.path 读取），读取最后 lines 行文本并以 text/plain 或 JSON 结构返回。

现状代码证据：
- Spring Boot 框架自带 org.springframework.boot.logging.LoggingSystem。
- 部署端口：192.168.31.110:8086。

本次实现范围：
- 必须新增：DevLogController.java (位于合适包下，标记 @Profile({"dev", "test", "qa"}) 或不影响主逻辑)
- 明确不修改：任何现有的业务 SQL、Service、Mapper 和生产代码逻辑。

实现约束：
1. 代码简洁，异常处理完善（日志文件不存在或权限问题时优雅返回错误）。
2. 不影响任何现有业务 API。
3. 提供基础防护（如 lines 最大限制 2000 行，避免 OOM）。

请执行并返回：
1. 计划新增的文件路径与代码。
2. 接口 URL 路径与参数说明。
3. 单元/自测结果。
