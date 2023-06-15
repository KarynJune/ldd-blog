---
title: "RESTful 的 Web API 设计"
date: 2023-06-15T11:37:06+08:00
draft: true
tags: ["Web", "翻译"]
categories: ["Web"]
---

## API 设计

> 翻译自原文：[https://learn.microsoft.com/en-us/azure/architecture/best-practices/api-design](https://learn.microsoft.com/en-us/azure/architecture/best-practices/api-design)

现代大多数 Web 应用会暴露 API 给客户端，用来与应用交互。一个设计良好的应用应该支持：

- **平台独立性**。任何客户端都应该能调用 API，不需要管 API 的内部是如何实现的。这就需要使用标准协议，并且有一个机制使得客户端和Web服务要交换的数据格式一致。
- **服务迭代**。web API 要能独立于客户端迭代功能。API 迭代的时候，现有的客户端不用修改能继续执行。所有功能都应该是可见的，以便客户端能完全使用 API。

这篇指引描述了当你设计一个网站API时需要考虑的问题。

### 什么是REST

2000年，Roy Fielding 提出表现状态转移（Representational State Transfer，REST）作为设计 web 服务的体系结构方法。 REST是一种基于超媒体构建分布式系统的架构风格。REST 独立于任何底层协议，也不需要和 HTTP 绑定。但是，大多数通用的 REST API 使用 HTTP 作为应用协议来执行，本指南的重点是为 HTTP 设计 REST API。

REST 相对于 HTTP 一个主要优点是它使用开放标准，并且 API 和客户端不需要绑定特定的实现。例如，一个 REST web 服务可能用 ASP.NET 编写，客户端可以用任何语言或者能生成 HTTP 请求和解析HTTP响应的工具包。

使用 HTTP 的 RESTful API 的一些主要原则如下：

- REST API 围绕*资源*设计，即能被客户端访问的任何类型对象、数据或服务。
- 一个资源有一个*标识符*，是唯一标识该资源的 URI。例如，一个特定的客户订单可能长这样：

    ```http
    https://adventure-works.com/orders/1
    ```

- 客户端通过交换资源的*表示*与客户端交互。许多 web API 使用 JSON 作为交换格式。例如，上述 URI 的一个 GET 请求可能返回这样的响应体：

```json
{"orderId":1,"orderValue":99.90,"productId":1,"quantity":1}
```

- REST API 使用统一的接口帮助分离客户端和服务端的实现。对于在 HTTP 上构建的 REST API。统一接口包括使用标准HTTP动词对资源执行操作。最通用的操作是 GET、POST、PUT、PATCH 以及 DELETE。

- REST API 使用无状态请求模型。HTTP 请求应该是独立的且以任何顺序发生，因此在请求之间保持瞬时的状态信息是不可行的。唯一存储信息的地方是资源本身，每个请求都应该是原子操作。这一约束使得 web 服务变得高可扩展，因为不需要保留客户端和特定服务端之间任何亲缘关系。任何服务都可以处理来自任何客户端的请求。也就是说，其他因素可能限制可扩展性。例如，许多 web 服务写入后端数据库，可能很难去扩展。关于扩展一个数据存储的更多信息，看[水平、垂直和功能性数据分区](https://learn.microsoft.com/en-us/azure/architecture/best-practices/data-partitioning)。

- REST API 由表示中包含的超媒体链接驱动。例如，下面展示了一个订单的 JSON 表示。它包含获取和更新与订单关联的客户的链接。

    ```json
    {
        "orderID":3,
        "productID":2,
        "quantity":4,
        "orderValue":16.60,
        "links": [
            {"rel":"product","href":"https://adventure-works.com/customers/3", "action":"GET" },
            {"rel":"product","href":"https://adventure-works.com/customers/3", "action":"PUT" }
        ]
    }
    ```

2008 年，Leonard Richardson 为 web API 提出[成熟度模型](https://martinfowler.com/articles/richardsonMaturityModel.html)：

- 等级0: 定义一个 URI，并且所有操作都用 POST 来请求。
- 等级1: 为单个资源创建单独的 URI。
- 等级2: 使用 HTTP 方法来定义资源的操作。
- 等级3: 使用超媒体（HATEOAS，如下所述）。

根据 Fielding 的定义，等级3符合真正的 RESTful API。实际上，需要已发布的 web API 都在等级2左右。

### 围绕资源设计API

关注 web API 公开的业务实体。例如，一个电子商务系统中，主要的实体可能是客户和订单。创建一个订单可以通过发送一个 包含订单信息的 HTTP POST 请求来实现。HTTP 响应指示订单是否成功下发。可能的话，资源 URI 应该基于名词（即资源）而不是动词（对资源的操作）。

```http
https://adventure-works.com/orders // 推荐

https://adventure-works.com/create-order // 避免使用
```

一个资源不用基于单个的物理数据项。例如，一个订单资源可能在内部实现是关系数据库中的多个表，但是作为单个实体呈现给客户端。避免创建只反映数据库内部结构的API。REST 的目的是对实体建模，并且应用可以对这些实体操作。客户端不应被暴露出内部实现。

实体通常被分组到集合中（订单，客户）。一个集合与集合中的项目是不同的资源，应该有它自己的 URI。例如，下面的 URI 可能呈现订单的集合：

```http
https://adventure-works.com/orders
```

## API 实现

> 翻译自原文：[https://learn.microsoft.com/en-us/azure/architecture/best-practices/api-implementation](https://learn.microsoft.com/en-us/azure/architecture/best-practices/api-implementation)
