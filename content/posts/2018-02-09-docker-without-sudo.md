---
layout: posts
title: "如何使用非root用户执行docker命令"
subtitle: ""
description: "如何使用非root用户执行docker命令"
excerpt: "如何使用非root用户执行docker命令"
date: 2018-02-09 10:00:00
author: "赵化冰"
image: "/images/posts/8.jpg"
published: true
showtoc: false
tags:
  - Tips
  - Docker
  - service Mesh
URL: "/2018/02/09/docker-without-sudo/"
categories:
  - 赵化冰博客
---

### Add the docker group if it doesn't already exist:

sudo groupadd docker

### Add the connected user "$USER" to the docker group. Change the user name to match your preferred user if you do not want to use your current user:

sudo gpasswd -a $USER docker

### Either do a newgrp docker or log out/in to activate the changes to groups.
