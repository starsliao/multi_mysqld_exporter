# multi_mysqld_exporter
#### 官方main版本的代码已经支持多目标的mysqld_exporter，只是还没有发Releases。
- https://github.com/prometheus/mysqld_exporter/tree/main
- commit 93f3538969f36ab0f252511da79135db0841df74(2022.11.15)
### 本仓库基于以上源码编译了二进制包和docker镜像，可参考docker-compose文件使用。

```
# 输出日志带详细实例信息。
vi collector/exporter.go 
        level.Error(e.logger).Log("msg", "Error opening connection to database", "err", err, "dsn:", e.dsn)
        level.Error(e.logger).Log("msg", "Error pinging mysqld", "err", err, "dsn:", e.dsn)
        level.Error(e.logger).Log("msg", "Error from scraper", "scraper", scraper.Name(), "err", err, "dsn:", e.dsn)
```    
``` 
## 编译
CGO_ENABLED=0 go build
```

---

### docker-compose使用说明：
https://github.com/starsliao/multi_mysqld_exporter/blob/main/docker-compose.yml
- 该镜像是专门用于多mysql实例使用一个mysqld_exporter。
- docker-compose中有2个变量：**监控专用的mysql账号和密码**，注意修改掉后再启动。
- **该docker-compose配置方式是所有的mysql实例都配置了一样的mysql监控账号和密码。**
- 如果你有不同mysql实例需要配置不同监控账号密码的需求，请参考官方readme使用配置文件的方式启动。

#### 监控专用账户权限配置：
```
CREATE USER '监控专用用户名'@'multi_mysqld_exporter主机的IP' IDENTIFIED BY '监控专用密码' WITH MAX_USER_CONNECTIONS 10;
GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO '监控专用用户名'@'multi_mysqld_exporter主机的IP';
```

---

### 推荐使用【ConsulManager】来管理主机、MySQL、Redis与站点监控，自动同步云厂商资源到Prometheus，更多惊喜！
#### [【ConsulManager介绍】](https://github.com/starsliao/ConsulManager)
#### [如何优雅的使用一个mysqld_exporter监控所有的MySQL实例：](https://github.com/starsliao/ConsulManager/blob/main/docs/%E5%A6%82%E4%BD%95%E4%BC%98%E9%9B%85%E7%9A%84%E4%BD%BF%E7%94%A8%E4%B8%80%E4%B8%AAmysqld_exporter%E7%9B%91%E6%8E%A7%E6%89%80%E6%9C%89%E7%9A%84MySQL%E5%AE%9E%E4%BE%8B.md)
- 💖增加RDS云数据库监控接入：支持同步华为云、阿里云、腾讯云的RDS信息到Consul并接入到Prometheus监控！
- 💖提供了一个支持1对多目标的Mysqld_exporter(官方main分支编译)：使用1个mysqld_exporter就可以监控所有的MySQL了！
- 💖增加了MySQL的Grafana监控看板：基于官方版本汉化，增加总览页，增加表大小行数统计，优化重要指标展示！

---
### Mysqld Exporter Dashboard 中文版 [https://grafana.com/grafana/dashboards/17320](https://grafana.com/grafana/dashboards/17320)
**该看板基于Mysqld_Exporter的监控指标设计，基于官方版本汉化，增加总览页，增加表大小行数统计，优化重要指标展示。**
#### 对于图表中的CPU、内存、磁盘等部分Mysqld_Exporter不提供的指标：
- 自建Mysql：从node-exporter中获取以上信息，通过instance的IP部分进行关联。
- 云DRS：从ConsulManager-MySQL中获取，会根据实例ID进行关联。(数据来自云监控，从ConsulManager的Prometheus配置生成菜单中可生成配置。)

### 单独使用multi_mysqld_exporter的prometheus配置说明：
**静态配置方式：**
```
  - job_name: multi_mysqld_exporter
    scrape_interval: 30s
    metrics_path: /probe
    static_configs:
      - targets:
        - server1:3306
        - server2:3306
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: 你的mysqld_exporter地址:9104
```

---

**基于ConsulManager的动态配置方式参考(可在【ConsulManager-MySQL管理-Prometheus配置】菜单中自动生成)：**
```
  - job_name: 'ConsulManager-MySQL'
    scrape_interval: 30s
    scrape_timeout: 15s
    static_configs:
    - targets:
      - alicloud/xxxx/cn-shenzhen
      - alicloud/yyyy/cn-shenzhen
    relabel_configs:
      - source_labels: [__address__]
        target_label: __metrics_path__
        regex: (.*)
        replacement: /api/cloud_mysql_metrics/${1}
      - target_label: __address__
        replacement: 10.0.0.26:1026

  - job_name: multi_mysqld_exporter
    scrape_interval: 15s
    scrape_timeout: 5s
    metrics_path: /probe
    consul_sd_configs:
      - server: '10.0.0.26:8500'
        token: 'xxxxxxxxxx'
        refresh_interval: 30s
        services: ['selfrds_exporter', 'alicloud_xxxx_rds']
    relabel_configs:
      - source_labels: [__meta_consul_tags]
        regex: .*OFF.*
        action: drop
      - source_labels: [__meta_consul_service_address,__meta_consul_service_port]
        regex: ([^:]+)(?::\d+)?;(\d+)
        target_label: __param_target
        replacement: $1:$2
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: 10.0.0.26:9104
      - source_labels: ['__meta_consul_service_metadata_vendor']
        target_label: vendor
      - source_labels: ['__meta_consul_service_metadata_region']
        target_label: region
      - source_labels: ['__meta_consul_service_metadata_group']
        target_label: group
      - source_labels: ['__meta_consul_service_metadata_account']
        target_label: account
      - source_labels: ['__meta_consul_service_metadata_name']
        target_label: name
      - source_labels: ['__meta_consul_service_metadata_iid']
        target_label: iid
      - source_labels: ['__meta_consul_service_metadata_exp']
        target_label: exp
      - source_labels: ['__meta_consul_service_metadata_cpu']
        target_label: cpu
      - source_labels: ['__meta_consul_service_metadata_mem']
        target_label: mem
      - source_labels: ['__meta_consul_service_metadata_disk']
        target_label: disk
      - source_labels: ['__meta_consul_service_metadata_itype']
        target_label: itype
```
