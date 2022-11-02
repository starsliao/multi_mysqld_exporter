# multi_mysqld_exporter
#### 官方main版本的代码已经支持多目标的mysqld_exporter，只是还没有发Releases。
- https://github.com/prometheus/mysqld_exporter/tree/main
- 当前main为2022.09.24更新的版本，对应提交id如下：
- https://github.com/prometheus/mysqld_exporter/commit/503f1fa222f0afc74a1dcf4a0ef5a7c2dfa4d105

### 本仓库基于以上源码编译了二进制包和docker镜像，可参考docker-compose文件使用。

### docker-compose使用说明：
- 该镜像是专门用于多mysql实例使用一个mysqld_exporter。
- docker-compose中有2个变量：**监控专用的mysql账号和密码**，注意修改掉后再启动。
- **该docker-compose配置方式是所有的mysql实例都配置了一样的mysql监控账号和密码。**
- 如果你有不同mysql实例需要配置不同监控账号密码的需求，请参考官方readme使用配置文件的方式启动。

## 推荐使用【ConsulManager】来管理主机、MySQL与站点监控，自动同步云厂商资源到Prometheus，更多惊喜！
## [【ConsulManager介绍】](https://github.com/starsliao/ConsulManager)
### [如何优雅的使用一个mysqld_exporter监控所有的MySQL实例](https://github.com/starsliao/ConsulManager/blob/main/docs/%E5%A6%82%E4%BD%95%E4%BC%98%E9%9B%85%E7%9A%84%E4%BD%BF%E7%94%A8%E4%B8%80%E4%B8%AAmysqld_exporter%E7%9B%91%E6%8E%A7%E6%89%80%E6%9C%89%E7%9A%84MySQL%E5%AE%9E%E4%BE%8B.md)
- 💖增加RDS云数据库监控接入：支持同步华为云、阿里云、腾讯云的RDS信息到Consul并接入到Prometheus监控！
- 💖提供了一个支持1对多目标的Mysqld_exporter(官方main分支编译)：使用1个mysqld_exporter就可以监控所有的MySQL了！
- 💖增加了MySQL的Grafana监控看板：基于官方版本汉化，增加总览页，增加表大小行数统计，优化重要指标展示！


### prometheus配置说明：
静态配置方式：
```
  - job_name: multi_mysqld_exporter
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
        replacement: localhost:9104
```
consul动态配置方式参考：
```
  - job_name: multi_mysqld
    scrape_interval: 30s
    metrics_path: /probe
    consul_sd_configs:
      - server: '10.0.0.26:8500'
        token: 'xxxxxxxxxxxxxx'
        services: ['hw_mysqld_exporter']
    relabel_configs:
      - source_labels: [__meta_consul_service_address,__meta_consul_service_port]
        regex: ([^:]+)(?::\d+)?;(\d+)
        target_label: __param_target
        replacement: $1:$2
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: 10.0.0.26:9104
      - source_labels: ["__meta_consul_service_metadata_iaccount"]
        target_label: iaccount
      - source_labels: ["__meta_consul_service_metadata_igroup"]
        target_label: igroup
      - source_labels: ["__meta_consul_service_metadata_iname"]
        target_label: iname
      - source_labels: ["__meta_consul_service_metadata_iid"]
        target_label: iid
```
