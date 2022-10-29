# multi_mysqld_exporter
#### 官方main版本的代码已经支持多目标的mysqld_exporter
- https://github.com/prometheus/mysqld_exporter/tree/main
- 20220924版本，对应提交id如下：
- https://github.com/prometheus/mysqld_exporter/commit/503f1fa222f0afc74a1dcf4a0ef5a7c2dfa4d105

### 本仓库基于以上源码编译了二进制包和docker镜像

### docker-compose使用说明：
- 该镜像是专门用于多mysql实例使用一个mysqld_exporter。
- docker-compose中有2个变量：监控专用的mysql账号和密码，注意修改掉后再启动。
- **该docker-compose配置方式是所有的mysql实例都配置了一样的mysql监控账号和密码。**
- 如果你有不同mysql实例需要配置不同监控账号密码的需求，请参考官方readme使用配置文件的方式启动。
