
# Cloudreve Docker

    
默认使用sqlite数据库 如需使用mysql，联系作者qq：2930755201)
    


- 基于最新的Cloudreve V3
- 长期维护
- 镜像体积小
- 纯净安装，无多余组件

- 支持linux/amd64架构

简易安装

内含详细的Cloudreve+Caddy+Aria2部署教程

## Cloudreve

Cloudreve能助您以最低的成本快速搭建公私兼备的网盘系统。

官方网站：[https://cloudreve.org][1]

GitHub：[https://github.com/cloudreve/Cloudreve][2]

## 开始
运行模式

- Docker Run方式运行

 - OC: 仅Cloudreve

- CAC: Caddy反代+Aria2离线下载服务+Cloudreve

### 获取PUID和PGID

为什么要使用PUID和PGID参见: [Understanding PUID and PGID](https://docs.linuxserver.io/general/understanding-puid-and-pgid)


假设当前登陆用户为root，则执行

    id root

就会得到类似于下面的一段代码

    uid=1000(root) gid=1001(root)

则PUID填入1000，PGID填入1001

Docker Run方式运行
# OC
以/dockercnf/cloudreve为cloudreve配置目录

    mkdir -p /dockercnf/cloudreve/uploads \
        && touch /dockercnf/cloudreve/conf.ini \
        && touch /dockercnf/cloudreve/cloudreve.db

    docker run -d \
      --name cloudreve \
      -e PUID=1000 \ # optional
      -e PGID=1000 \ # optional
      -e TZ="Asia/Shanghai" \ # optional
      -p 5212:5212 \ 
      --restart=unless-stopped \
      -v /dockercnf/cloudreve/uploads:/cloudreve/uploads \
      -v /dockercnf/cloudreve/conf.ini:/cloudreve/conf.ini \
      -v /dockercnf/cloudreve/cloudreve.db:/cloudreve/cloudreve.db \
      cjs520/cloudreve-docker

说明

首次启动后请执行docker logs -f cloudreve获取初始密码

PUID以及PGID的获取方式详见获取PUID和PGID

TZ设置时区，默认值为Asia/Shanghai
创建好上传目录，配置文件，数据库文件

<PATH TO UPLOADS>:上传目录

<PATH TO conf.ini>: 配置文件

<PATH TO cloudreve.db>: 数据库文件

# CAC

## VPS 一键脚本 
```
bash cloudreve_docker.sh
```
⚠️注意：此教程仅在linux/amd64架构测试，如果您正在使用arm架构，部分参数请根据实际情况调整。

前提

已安装docker，如果没有请执行wget -qO- https://get.docker.com/ | bash安装docker。
一个域名并解析到运行Cloudreve的服务器，这里以cloudreve.example.com为例。

Step1. 配置caddy

    wget https://raw.githubusercontent.com/cjs520/webbackup/master/caddy.sh&&bash caddy.sh

Step2. 启动Aria2服务（如不需要离线下载功能该步骤略过）

    docker run -d \
        --name aria2 \
        --restart unless-stopped \
        --log-opt max-size=1m \
        -e PUID=1000 \
        -e PGID=1000 \
        -e RPC_SECRET=<SECRET> \  #自己设定
        -p 6800:6800 \ #1
        -p 6888:6888 -p 6888:6888/udp \
        --network my-network \
        -v <PATH TO CONFIG>:/config \
        -v <PATH TO TEMP>:/downloads \
        p3terx/aria2-pro

说明

PUID以及PGID的获取方式详见获取PUID和PGID。
<SECRET>: Aria2 RPC密码（你可以去这里生成随机字符串）。请记下该密码！在后续Cloudreve设置Aria2中会使用。
<PATH TO CONFIG>: Aria2的配置文件夹，例如/dockercnf/aria2/conf。
<PATH TO TEMP>: 临时下载文件夹，需要与Cloudreve的/downloads对应，例如/dockercnf/aria2/temp。
如果不需要外网访问Aria2可以将#1所在行删除。
Step3. 预创建Cloudreve的数据库和配置文件，这里以/dockercnf/cloudreve为cloudreve配置目录

    mkdir -p /dockercnf/cloudreve/uploads \
        && touch /dockercnf/cloudreve/conf.ini \
        && touch /dockercnf/cloudreve/cloudreve.db

Step6. 启动Cloudreve

    docker run -d \
      --name cloudreve \
      -e PUID=1000 \ # optional
      -e PGID=1000 \ # optional
      -e TZ="Asia/Shanghai" \ # optional
      -p 5212:5212 \ 
      --restart=unless-stopped \
      -v /dockercnf/cloudreve/uploads:/cloudreve/uploads \
      -v /dockercnf/cloudreve/conf.ini:/cloudreve/conf.ini \
      -v /dockercnf/cloudreve/cloudreve.db:/cloudreve/cloudreve.db \
      cjs520/cloudreve-docker

说明

首次启动后请执行docker logs -f cloudreve获取初始密码

PUID以及PGID的获取方式详见获取PUID和PGID

<PATH TO UPLOADS>:上传目录, 例如/sharedfolders

<PATH TO TEMP>: 临时下载文件夹，需要与Aria的/downloads对应，例如/dockercnf/aria2/temp（如不需要离线下载功能#1可以删除）

<PATH TO conf.ini>: 配置文件，如/dockercnf/cloudreve/conf.ini

<PATH TO cloudreve.db>: 数据库文件，如/dockercnf/cloudreve/cloudreve.db

Step7. 配置Cloudreve连接Aria2服务器

以管理员身份登陆

点击"头像（右上角） > 管理面板"

点击"参数设置 > 离线下载"

RPC服务器地址: http://aria2:6800/ 或http://你的域名:6800/
RPC Secret: 参见启动Aria2服务中的<SECRET>
临时下载地址: /downloads
其他选项按照默认值即可
测试连接并保存

升级：
```
bash update.sh
```


  [1]: https://cloudreve.org
  [2]: https://github.com/cloudreve/Cloudreve
