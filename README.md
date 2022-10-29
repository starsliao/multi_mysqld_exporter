# multi_mysqld_exporter
#### 官方main版本的代码已经支持多目标的mysqld_exporter，只是还没有发Releases。
- https://github.com/prometheus/mysqld_exporter/tree/main
- 20220924版本，对应提交id如下：
- https://github.com/prometheus/mysqld_exporter/commit/503f1fa222f0afc74a1dcf4a0ef5a7c2dfa4d105

### 本仓库基于以上源码编译了二进制包和docker镜像，可参考docker-compose文件使用。

### docker-compose使用说明：
- 该镜像是专门用于多mysql实例使用一个mysqld_exporter。
- docker-compose中有2个变量：监控专用的mysql账号和密码，注意修改掉后再启动。
- **该docker-compose配置方式是所有的mysql实例都配置了一样的mysql监控账号和密码。**
- 如果你有不同mysql实例需要配置不同监控账号密码的需求，请参考官方readme使用配置文件的方式启动。

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
