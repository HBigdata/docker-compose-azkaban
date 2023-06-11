## 一、概述
`Apache Azkaban` 是一个开源的批处理**工作流调度系统**，用于管理和调度Hadoop生态系统中的任务和作业。

- `Azkaban` 提供了一个直观的Web界面，让用户能够轻松地定义、调度和监控作业流。它支持工作流的可视化编辑，可以将任务以依赖关系的方式组织起来，从而实现复杂的工作流程。用户可以定义作业的依赖关系、时间调度、重试机制等，并监控作业的执行情况和日志。

- `Azkaban` 可以与Hadoop生态系统中的各种工具和框架集成，如Hadoop、Hive、Pig、Spark等。它通过与这些工具的集成，可以方便地调度和执行这些工具生成的作业。

- `Azkaban` 还提供了一套安全机制，可以控制用户对作业流的访问权限，确保敏感数据和任务的安全性。

总的来说，Apache Azkaban是一个功能强大的批处理工作流调度系统，可以帮助用户管理和调度Hadoop生态系统中的作业和任务，提高工作效率和数据处理的可靠性。

![在这里插入图片描述](https://img-blog.csdnimg.cn/6f14abaf3e22499491b594a35641373c.png)
这里只是讲解容器化快速部署过程，想了解更多关于 Azkaban 的知识点可关注我以下文章：

- [大数据Hadoop之——任务调度器Azkaban（Azkaban环境部署）](https://blog.csdn.net/qq_35745940/article/details/123586736)
- [大数据Hadoop之——Azkaban API详解](https://blog.csdn.net/qq_35745940/article/details/123697886)
- [【云原生】Azkaban on k8s 讲解与实战操作](https://blog.csdn.net/qq_35745940/article/details/127174772)

## 二、Azkaban 的调度流程
![在这里插入图片描述](https://img-blog.csdnimg.cn/80c76c9d125744b3adae23aa72e6dcfa.png)
Apache Azkaban的调度流程可以概括为以下几个步骤：

1. **定义作业流**：使用Azkaban的Web界面或Azkaban的DSL语言，用户定义作业流并指定任务之间的依赖关系。作业流由一系列任务组成，可以按照顺序或并行方式执行。

2. **作业提交**：当作业流需要执行时，Azkaban会将任务提交到执行环境中（如Hadoop集群）。这可以通过调用相应的执行引擎（如Azkaban Executor）来实现。任务提交时，Azkaban会将任务的相关信息和依赖关系传递给执行引擎。

3. **依赖关系解析**：执行引擎接收到任务后，会解析任务之间的依赖关系。它会检查每个任务所依赖的其他任务是否已经完成。如果有未满足的依赖关系，任务将等待依赖任务完成后再执行。

4. **任务执行**：一旦任务的依赖关系满足，执行引擎会开始执行任务。任务可以是各种类型，如Hadoop作业、Shell脚本、Spark作业等。执行引擎会调用相应的执行器来执行任务，并提供所需的参数和配置。

5. **任务监控和日志**：在任务执行期间，Azkaban会实时监控任务的执行状态，并记录任务的日志输出。用户可以通过Azkaban的Web界面查看任务的执行进度、日志和错误信息。这有助于及时发现和排查执行问题。

6. **依赖关系检查**：在任务执行完成后，执行引擎会检查任务的输出和后续任务的依赖关系。如果有后续任务依赖当前任务的输出，执行引擎会传递相应的输出给后续任务，并继续执行后续任务。

7. **完成和报告**：当作业流中的所有任务都执行完成后，Azkaban会将作业流的执行状态标记为完成，并生成执行报告。报告可以包括任务的执行结果、执行时间、日志等信息，以便用户进行审查和分析。

总的来说，Apache Azkaban的调度流程包括定义作业流、任务提交、依赖关系解析、任务执行、监控和日志、依赖关系检查以及完成和报告等步骤。这些步骤确保了作业流的正确执行和管理，并提供了实时的监控和日志记录功能。
## 三、前期准备
### 1）部署 docker
```bash
# 安装yum-config-manager配置工具
yum -y install yum-utils

# 建议使用阿里云yum源：（推荐）
#yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

# 安装docker-ce版本
yum install -y docker-ce
# 启动并开机启动
systemctl enable --now docker
docker --version
```
### 2）部署 docker-compose
```bash
curl -SL https://github.com/docker/compose/releases/download/v2.16.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose
docker-compose --version
```
## 四、创建网络

```bash
# 创建，注意不能使用hadoop_network，要不然启动hs2服务的时候会有问题！！！
docker network create hadoop-network

# 查看
docker network ls
```
## 五、Azkaban 编排部署
### 1）安装 MySQL
如想快速部署MySQL，可参考我这篇文章：[通过 docker-compose 快速部署 MySQL保姆级教程](https://blog.csdn.net/qq_35745940/article/details/130856734)

### 2）下载 Azkaban 编译

```bash
git clone https://github.com/azkaban/azkaban.git

# 编译
cd azkaban; ./gradlew build installDist
```
这里也提供一下我编译的安装包，下载地址如下：
> 链接：[https://pan.baidu.com/s/1zvUyfXg3sCPqBfESWY-oLQ](https://pan.baidu.com/s/1zvUyfXg3sCPqBfESWY-oLQ)
提取码：`6666`
### 3）初始化 azkaban 用户和表
创建 azkaban 用户
```bash
#【温馨提示】一般公司禁止mysql -u root -p123456这种方式连接，在history里有记录，存在安全隐患，小伙伴不要被公司安全审计哦，切记！！！
mysql -u root -p
# 输入密码：123456

CREATE DATABASE azkaban;
CREATE USER 'azkaban'@'%' IDENTIFIED BY 'azkaban';
GRANT SELECT,INSERT,UPDATE,DELETE ON azkaban.* to 'azkaban'@'%' WITH GRANT OPTION;
```
开始初始化表数据

```bash
cd ${AZKABAN_HOME}/azkaban-db
# 连接mysql
mysql -u root -p
#密码：123456

use azkaban
# 可能版本不一样，sql文件也不太一样，create-all-sql-*.sql
source create-all-sql-3.91.0-313-gadb56414.sql
```
### 4）配置
- `conf/exec/azkaban.properties`

```bash
azkaban.name=Test
azkaban.label=My Local Azkaban
azkaban.default.servlet.path=/index
web.resource.dir=web/
default.timezone.id=Asia/Shanghai
# default.timezone.id=America/Los_Angeles
user.manager.class=azkaban.user.XmlUserManager
user.manager.xml.file=conf/azkaban-users.xml
executor.global.properties=conf/global.properties
azkaban.project.dir=projects
velocity.dev.mode=false
jetty.use.ssl=false
jetty.maxThreads=25
jetty.port=8081
# azkaban.webserver.url=http://localhost:8081
azkaban.webserver.url=https://azkaban-web:8081
mail.sender=
mail.host=
job.failure.email=
job.success.email=
lockdown.create.projects=false
cache.directory=cache
jetty.connector.stats=true
executor.connector.stats=true
azkaban.jobtype.plugin.dir=plugins/jobtypes
database.type=mysql
mysql.port=3306
mysql.host=mysql
# mysql.host=localhost
mysql.database=azkaban
mysql.user=azkaban
mysql.password=azkaban
mysql.numconnections=100
executor.maxThreads=50
executor.flow.threads=30
azkaban.executor.runtimeProps.override.eager=false
executor.port=12321
```
参数说明：

```bash
executor.port：不设置就是随机值了，不方便管理，所以这里还是固定一个端口号，看资料大部分都是使用12321这个端口，这里也随大流
```

- `conf/web/azkaban.properties`

```bash
azkaban.name=Test
azkaban.label=My Local Azkaban
azkaban.default.servlet.path=/index
web.resource.dir=web/
default.timezone.id=Asia/Shanghai
# default.timezone.id=America/Los_Angeles
user.manager.class=azkaban.user.XmlUserManager
user.manager.xml.file=conf/azkaban-users.xml
executor.global.properties=conf/global.properties
azkaban.project.dir=projects
velocity.dev.mode=false
jetty.use.ssl=false
jetty.maxThreads=25
jetty.port=8081
mail.sender=
mail.host=
job.failure.email=
job.success.email=
lockdown.create.projects=false
cache.directory=cache
jetty.connector.stats=true
executor.connector.stats=true
database.type=mysql
mysql.port=3306
mysql.host=mysql
# mysql.host=localhost
mysql.database=azkaban
mysql.user=azkaban
mysql.password=azkaban
mysql.numconnections=100
azkaban.use.multiple.executors=true
azkaban.executorselector.filters=StaticRemainingFlowSize,CpuStatus
# azkaban.executorselector.filters=StaticRemainingFlowSize,MinimumFreeMemory,CpuStatus
azkaban.executorselector.comparator.NumberOfAssignedFlowComparator=1
azkaban.executorselector.comparator.Memory=1
azkaban.executorselector.comparator.LastDispatched=1
azkaban.executorselector.comparator.CpuUsage=1
```
参数说明：
```bash
azkaban.executorselector.filters：调度策略
# 把MinimumFreeMemory去掉，因为MinimumFreeMemory是6G，自己电脑资源有限，如果小伙伴的机器资源雄厚，可以保留
# StaticRemainingFlowSize：根据排队的任务数来调度任务到哪台executor机器
# CpuStatus：跟据cpu空闲状态来调度任务到哪台executor机器
```
### 5）启动脚本 bootstrap.sh

```bash
#!/usr/bin/env sh

wait_for() {
    echo Waiting for $1 to listen on $2...
    while ! nc -z $1 $2; do echo waiting...; sleep 1s; done
}

startAzkaban() {

   node_type=$1

   if [ "$node_type" = "exec" ];then

      {
        activateAzkabanExec
      }&

      # 【注意】需要切到exec目录下启动，因为配置文件配置的是相对路径
      cd ${AZKABAN_HOME}/azkaban-exec-server
      ./bin/internal/internal-start-executor.sh 2>&1 |tee -a executorServerLog__`date +%F+%T`.out
      # 激活 exec
      activateAzkabanExec

   elif [ "$node_type" = "web" ];then
      first_exec=$2
      exec_port=$3
      wait_for $first_exec $exec_port
      # 【注意】需要切到web目录下启动，因为配置文件配置的是相对路径
      cd ${AZKABAN_HOME}/azkaban-web-server
      ./bin/internal/internal-start-web.sh 2>&1 |tee -a webServerLog_`date +%F+%T`.out
   fi

}

# 激活 exec
activateAzkabanExec(){
  until netstat -ntlp|grep -q :12321; do echo waiting for azkaban-exec; sleep 1; done
  curl -G "`hostname`:12321/executor?action=activate" && echo
}

startAzkaban $@
```

> 注意先启动exec，再启动web，否则web会报No active executors found的异常信息。
### 6）构建镜像 Dockerfile

```bash
FROM registry.cn-hangzhou.aliyuncs.com/bigdata_cloudnative/centos-jdk:7.7.1908

# 添加 azkaban 包
ENV AZKABAN_VERSION 3.91.0-313
RUN mkdir /opt/apache/azkaban-${AZKABAN_VERSION}
ADD ./azkaban-${AZKABAN_VERSION}/azkaban-db.tar.gz /opt/apache/azkaban-${AZKABAN_VERSION}/
ADD ./azkaban-${AZKABAN_VERSION}/azkaban-exec-server.tar.gz /opt/apache/azkaban-${AZKABAN_VERSION}/
ADD ./azkaban-${AZKABAN_VERSION}/azkaban-web-server.tar.gz /opt/apache/azkaban-${AZKABAN_VERSION}/
ENV AZKABAN_HOME /opt/apache/azkaban
RUN ln -s /opt/apache/azkaban-${AZKABAN_VERSION} $AZKABAN_HOME

# copy bootstrap.sh
COPY bootstrap.sh /opt/apache/
RUN chmod +x /opt/apache/bootstrap.sh

RUN chown -R hadoop:hadoop /opt/apache

WORKDIR $AZKABAN_HOME
```
开始构建镜像

```bash
docker build -t registry.cn-hangzhou.aliyuncs.com/bigdata_cloudnative/azkaban:3.91.0-313 . --no-cache

# 为了方便小伙伴下载即可使用，我这里将镜像文件推送到阿里云的镜像仓库
docker push registry.cn-hangzhou.aliyuncs.com/bigdata_cloudnative/azkaban:3.91.0-313

### 参数解释
# -t：指定镜像名称
# . ：当前目录Dockerfile
# -f：指定Dockerfile路径
#  --no-cache：不缓存
```

### 7）编排 docker-compose.yaml

```bash
version: '3'
services:
  azkaban-web:
    image: registry.cn-hangzhou.aliyuncs.com/bigdata_cloudnative/azkaban:3.91.0-313
    user: "hadoop:hadoop"
    container_name: azkaban-web
    hostname: azkaban-web
    restart: always
    privileged: true
    depends_on:
      - azkaban-exec
    env_file:
      - .env
    volumes:
      - ./conf/web/azkaban.properties:${AZKABAN_HOME}/azkaban-web-server/conf/azkaban.properties
    ports:
      - "${AZKABAN_WEB_PORT}"
    command: ["sh","-c","/opt/apache/bootstrap.sh web azkaban-azkaban-exec-1 ${AZKABAN_EXEC_PORT}"]
    networks:
      - hadoop-network
    healthcheck:
      test: ["CMD-SHELL", "netstat -tnlp|grep :${AZKABAN_WEB_PORT} || exit 1"]
      interval: 10s
      timeout: 20s
      retries: 3
  azkaban-exec:
    image: registry.cn-hangzhou.aliyuncs.com/bigdata_cloudnative/azkaban:3.91.0-313
    user: "hadoop:hadoop"
    restart: always
    privileged: true
    deploy:
      replicas: ${AZKABAN_EXEC_REPLICAS}
    env_file:
      - .env
    volumes:
      - ./conf/exec/azkaban.properties:${AZKABAN_HOME}/azkaban-exec-server/conf/azkaban.properties
    expose:
      - "${AZKABAN_EXEC_PORT}"
    command: ["sh","-c","/opt/apache/bootstrap.sh exec"]
    networks:
      - hadoop-network
    healthcheck:
      test: ["CMD-SHELL", "netstat -tnlp|grep :${AZKABAN_EXEC_PORT} || exit 1"]
      interval: 10s
      timeout: 10s
      retries: 3

# 连接外部网络
networks:
  hadoop-network:
    external: true
```

`.env` 文件内容

```bash
AZKABAN_HOME=/opt/apache/azkaban
AZKABAN_EXEC_REPLICAS=2
AZKABAN_WEB_PORT=8081
AZKABAN_EXEC_PORT=12321
```

### 8）开始部署

```bash
# --project-name指定项目名称，默认是当前目录名称
docker-compose --project-name=azkaban -f docker-compose.yaml up -d

# 查看
docker-compose --project-name=azkaban -f docker-compose.yaml ps

# 卸载
docker-compose --project-name=azkaban -f docker-compose.yaml down
```

## 六、简单测试验证
```bash
# 查看对外端口
docker-compose -p=azkaban ps
```
web 访问：`http://ip:port`
账号/密码：`azkaban/azkaban`
![在这里插入图片描述](https://img-blog.csdnimg.cn/105fda1816aa4a7ea62cc48045f01190.png)
## 七、常用的 Azkaban 客户端命令
### 1）服务启停

```bash
### 1、azkaban-exec-server
# azkaban-exec-server 启动（前台）
cd ${AZKABAN_HOME}/azkaban-exec-server
./bin/internal/internal-start-executor.sh
# 后台启动
cd ${AZKABAN_HOME}/azkaban-exec-server
./bin/start-exec.sh
# 重启
cd ${AZKABAN_HOME}/azkaban-exec-server
./bin/shutdown-exec.sh && ./bin/start-exec.sh

### 2、azkaban-web-server
# azkaban-web-server 启动（前台）
cd ${AZKABAN_HOME}/azkaban-web-server
./bin/internal/internal-start-web.sh
# 后台启动
cd ${AZKABAN_HOME}/azkaban-web-server
./bin/start-web.sh
# 重启
cd ${AZKABAN_HOME}/azkaban-web-server
./bin/shutdown-web.sh && ./bin/start-web.sh
```
### 2）azkaban exec 节点激活
```bash
curl -G "${exec_ip}:12321/executor?action=activate" && echo
```
### 3）其它常用api接口
以下是一些Apache Azkaban中常用的API接口：
#### 1、创建项目

```bash
URL：/manager?action=create
方法：POST
参数：name（项目名称）、description（项目描述）
```

#### 2、上传项目ZIP文件

```bash
URL：/manager?action=upload
方法：POST
参数：file（ZIP文件）
```

#### 3、获取项目流列表

```bash
URL：/manager?action=fetchprojectflows
方法：GET
参数：project（项目名称）
```

#### 4、执行项目流

```bash
URL：/executor
方法：POST
参数：ajax（固定值executeFlow）、project（项目名称）、flow（流名称）
```

#### 5、取消执行项目流

```bash
URL：/executor
方法：POST
参数：ajax（固定值cancelFlow）、execid（执行ID）
```

#### 6、获取执行状态

```bash
URL：/executor
方法：GET
参数：ajax（固定值fetchexecflow）、execid（执行ID）
```

#### 7、获取执行日志

```bash
URL：/executor
方法：GET
参数：ajax（固定值fetchExecJobLogs）、execid（执行ID）、jobId（任务ID）、offset（偏移量）、length（日志长度）
```

#### 8、获取执行报告

```bash
URL：/executor
方法：GET
参数：ajax（固定值fetchexecflow）&execid（执行ID）
```

这些API接口可以通过发送HTTP请求与Azkaban的Web服务器进行交互，执行项目的创建、上传、执行以及获取执行状态、日志和报告等操作。可以根据具体需求使用适当的API接口来管理和调度Azkaban中的作业流。

以下是使用Python示例代码来演示如何使用Azkaban的API接口：

```python
import requests

# 创建项目
def create_project(project_name, description):
    url = "http://localhost:8081/manager"
    params = {
        "action": "create",
        "name": project_name,
        "description": description
    }
    response = requests.post(url, params=params)
    print(response.text)

# 上传项目ZIP文件
def upload_project_zip(project_name, zip_file_path):
    url = "http://localhost:8081/manager"
    files = {
        "file": open(zip_file_path, "rb")
    }
    params = {
        "action": "upload",
        "project": project_name
    }
    response = requests.post(url, params=params, files=files)
    print(response.text)

# 执行项目流
def execute_flow(project_name, flow_name):
    url = "http://localhost:8081/executor"
    params = {
        "ajax": "executeFlow",
        "project": project_name,
        "flow": flow_name
    }
    response = requests.post(url, params=params)
    print(response.text)

# 获取执行状态
def get_execution_status(execution_id):
    url = f"http://localhost:8081/executor?ajax=fetchexecflow&execid={execution_id}"
    response = requests.get(url)
    print(response.text)

# 获取执行日志
def get_execution_logs(execution_id, job_id, offset, length):
    url = f"http://localhost:8081/executor?ajax=fetchExecJobLogs&execid={execution_id}&jobId={job_id}&offset={offset}&length={length}"
    response = requests.get(url)
    print(response.text)

# 获取执行报告
def get_execution_report(execution_id):
    url = f"http://localhost:8081/executor?ajax=fetchexecflow&execid={execution_id}"
    response = requests.get(url)
    print(response.text)

# 示例用法
create_project("my_project", "My Azkaban project")
upload_project_zip("my_project", "path/to/project.zip")
execute_flow("my_project", "my_flow")
get_execution_status("12345")
get_execution_logs("12345", "my_job", 0, 100)
get_execution_report("12345")
```

到此 通过 docker-compose 快速部署 Azkaban 保姆级教程就完结了，有任何疑问欢迎关注我公众号【大数据与云原生技术分享】加群交流或私信沟通~

