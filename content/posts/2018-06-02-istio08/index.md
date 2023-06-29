---
title: "Istio 0.8 Release发布"
subtitle: "来自Istio的儿童节礼物"
excerpt: "Istio 0.8 Release新特性"
author: "赵化冰"
date: 2018-06-02
description: "在6月1日这一天的早上，Istio社区宣布发布0.8 Release，除了常规的故障修复和性能改进外，这个儿童节礼物里面还有什么值得期待内容呢？让我们来看一看："
image: "/images/posts/20.jpg"
published: true
tags: [Istio]
categories: [Tech]
URL: "/2018/06/02/istio08/"
---

> 在 6 月 1 日这一天的早上，Istio 社区宣布发布 0.8 Release，除了常规的故障修复和性能改进外，这个儿童节礼物里面还有什么值得期待内容呢？让我们来看一看：

## Networking

### 改进的流量管理模型

0.8 版本采用了新的流量管理配置模型[v1alpha3 Route API](https://istio.io/blog/2018/v1alpha3-routing/)。新版本的模型添加了一些新的特性，并改善了之前版本模型中的可用性问题。主要的改动包括：

#### Gateway

新版本中不再使用 K8s 中的 Ingress，转而采用 Gateway 来统一配置 Service Mesh 中的各个 HTTP/TCP 负载均衡器。Gateway 可以是处理入口流量的 Ingress Gateway，负责 Service Mesh 内部各个服务间通信的 Sidecar Proxy，也可以是负责出口流量的 Egress Gateway。

Mesh 中涉及到的三类 Gateway:  
![Gateway](./gateways.svg)

该变化的原因是 K8s 中的 Ingress 对象功能过于简单，不能满足 Istio 灵活的路由规则需求。在 0.8 版本中，L4-L6 的配置和 L7 的配置被分别处理，Gateway 中只配置 L4-L6 的功能，例如暴露的端口，TLS 设置。然后用户可以采用 VirtualService 来配置标准的 Istio 规则，并和 Gateway 进行绑定。

#### VirtualService

采用 VirtualService 代替了 alpha2 模型中的 RouteRule。采用 VirtualService 有两个优势：

**可以把一个服务相关的规则放在一起管理**

例如下面的路由规则，发向 reviews 的请求流量缺省 destination 为 v1，如果 user 为 jason 则路由到 v2。在 v1 模型中需要采用两条规则来实现，采用 VirtualService 后放到一个规则下就可以实现。

```
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: reviews
spec:
  hosts:
    - reviews
  http:
  - match:
    - headers:
        cookie:
          regex: "^(.*?;)?(user=jason)(;.*)?$"
    route:
    - destination:
        host: reviews
        subset: v2
  - route:
    - destination:
        host: reviews
        subset: v1
```

**可以对外暴露一个并不存在的“虚拟服务”，然后将该“虚拟服务”映射到 Istio 中的 Service 上**

下面规则中的 bookinfo.com 是对外暴露的“虚拟服务”，bookinfo.com/reviews 被映射到了 reviews 服务，bookinfo.com/ratings 被映射到了 ratings 服务。通过采用 VirtualService，极大地增强了 Istio 路由规则的灵活性，有利于 Legacy 系统和 Istio 的集成。

```
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: bookinfo
spec:
  hosts:
    - bookinfo.com
  http:
  - match:
    - uri:
        prefix: /reviews
    route:
    - destination:
        host: reviews
  - match:
    - uri:
        prefix: /ratings
    route:
    - destination:
        host: ratings
  ...
```

### Envoy V2

控制面和数据面标准接口支持 Envoy

### 用 Gateway 代替 Ingress/Engress Kubernets

前面已经介绍到，新的版本中不再支持将 Kubernetes 的 Ingress 和 Istio 路由规则一起使用。Istio 0.8 支持平台无关的 Ingress/Egress Gateway,可以在 Kubernetes，Cloud Foundry 中和 Istio 路由规则无缝集成。

### 对入站端口进行限制

0.8 版本只允许访问 Pod 内已声明端口的入站流量。

## Security

### 安全组件 Citadel

将 Istio 的安全组件 Istio-Auth/Istio-CA 正式命名为 Citadel（堡垒）。

### 跨集群支持

部署在多个 Cluster 中的 Citadel 可以共享同一 Root Certificate，以支持不同 Cluster 内的服务可以跨 Cluster 进行认证。

### 认证策略

认证策略既支持 Service-to-Service 认证，也支持对终端用户进行认证。

## 遥测

Mixer 和 Pilot 将上报自身的遥测数据，其上报的流程和 Mesh 中的普通服务相同。

## 安装

按需安装部分组件：支持只安装所需的组件，如果只需要使用 Istio 的路由规则，可以选择只安装 Pilot，而不安装 Mixer 和 Citadel。

## Mixer

CloudWatch：增加了一个 CloudWatch 插件，可以向 AWS CloudWatch 上报度量数据。

## 已知故障：

- 如果 Gateway 绑定的 VirtualService 指向的是 headless service，则该规则不能正常工作。
- 0.8 版本和 Kubernetes1.10.2 存在兼容问题，目前建议采用 1.9 版本。
- convert-networking-config 工具存在故障，一个其它的 namespace 可能会被修改为 istio-system namespace。可以在允许转换工具后手动修改文件来避免。

## 总结

0.8 版本带来的最大变化是流量配置模型的重构，重构后的模型整合了外部 Gateway 和内部 Sidecar Proxy 的路由配置。同时 VirtualService 的引入使路由规则的配置更为集中和灵活。
