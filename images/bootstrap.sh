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
