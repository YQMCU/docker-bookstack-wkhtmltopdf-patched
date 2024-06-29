# 部署指南

## 安装docker

这里省略安装步骤

安装之后需要修改 /etc/docker/daemon.json 目的是为了拉取镜像更快一点


```bash
{
        "registry-mirrors" :
                [
                        "https://dhub.kubesre.xyz",
                        "https://ghcr.io",
                        "https://docker.m.daocloud.io",
                        "https://noohub.ru",
                        "https://huecker.io",
                        "https://dockerhub.timeweb.cloud"
                ],
        "data-root": "/opt/docker-root"
}
```


## 拉取镜像


```bash

docker pull ghcr.io/linuxserver/baseimage-alpine-nginx:3.20
docker pull lscr.io/linuxserver/mariadb

```

## 创建镜像

```bash

docker build -f Dockfile -t bookstack-wkhtmltopdf-patched-qt:v24.05.2-alpine-3.20 . 

```

**注意 上面的 build 之后有个 . 不能省略 **

## 部署应用

```bash

docker compose -f dist/book.yml up -d 

```

## 修改参数

```bash
cp bin/env.sample dist/bookstack_app_data/www/.env
```

## 访问web

默认的执行 `wget http://127.0.0.1:6875/login` 正常会有返回

在浏览器中将127.0.0.1改成部署服务器的IP即可访问

若是在虚拟机中部署，需要修改为虚拟机的IP或者网络端口转发的IP端口来访问

相应的需要修改.env参数中的 APP_URL 参数做出适配

以 http://127.0.0.1:6875 为例，若在浏览器中能正常访问了，

登陆账号 admin@admin.com 密码 password ，部署后及时修改密码


