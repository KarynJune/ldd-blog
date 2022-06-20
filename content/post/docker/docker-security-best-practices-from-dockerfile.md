---
title: "Dockerfile的安全最佳实践"
date: 2022-06-17T10:40:51+08:00
draft: false
tags: ["Docker", "翻译"]
categories: ["Docker"]
---


> 翻译自原文：[https://cloudberry.engineering/article/dockerfile-security-best-practices/](https://cloudberry.engineering/article/dockerfile-security-best-practices/)


Docker和容器安全是个很大的议题，有很多触手可及的方式可以降低风险。一个好的开端是遵从一些编写Dockerfile的最佳实践。

我编辑了一份常见的Docker安全问题列表以及如何避免他们。对每个问题还写了一个[开放策略代理](https://www.openpolicyagent.org/)规则，可以使[conftest](https://conftest.dev/)静态分析你的Dockerfile。你不能比这更早发现问题了！

你可以在[这个库](https://github.com/gbrindisi/dockerfile-security)里找到.rego的规则集。期待你的反馈与贡献。


## 1. 不要在你的环境变量里存储密钥

第一个Docker安全问题就是避免在Dockerfile里存储纯文本的密钥。

密钥分发是个麻烦的问题并且很容易做错。对于容器化的应用，可以通过文件挂载或者更便利地通过环境变量来显示。

不幸的是使用`ENV`来存储令牌、密码或者证书都是不好的方式：因为Dockerfile通常和应用一起分发，所以和硬编码在代码里没啥区别。

如何检测：

```
secrets_env = [
    "passwd",
    "password",
    "pass",
 #  "pwd", 不要使用这个   
    "secret",
    "key",
    "access",
    "api_key",
    "apikey",
    "token",
    "tkn"
]

deny[msg] {    
    input[i].Cmd == "env"
    val := input[i].Value
    contains(lower(val[_]), secrets_env[_])
    msg = sprintf("Line %d: Potential secret in ENV key found: %s", [i, val])
}
```


## 2. 只使用被信任的基础镜像

另一个普遍的Docker安全问题是[供应链攻击](https://en.wikipedia.org/wiki/Supply_chain_attack)的高风险。

对于容器化的应用，这种风险来自于构建容器本身的层次结构中。

罪魁祸首显然就是基础镜像的使用。**不被信任的镜像是高风险的**，无论何时都应该要避免使用。

Docker为最常使用的操作系统和应用提供了[官方的基础镜像集](https://docs.docker.com/docker-hub/official_images/)。通过使用它们，我们通过利用Docker本身的某种共享责任来提高Docker容器的安全性。

如何检测：

```
deny[msg] {
    input[i].Cmd == "from"
    val := split(input[i].Value[0], "/")
    count(val) > 1
    msg = sprintf("Line %d: use a trusted base image", [i])
}
```

这个规则针对DockerHub的官方镜像调整。这非常愚蠢因为我只检测到命名空间的缺失。

信任的定义取决于你的环境：相应地修改这个规则。


## 3. 基础镜像不要使用“latest”标签

固定你基础镜像的版本可以让你放心地考虑你正在构建的容器的可预测性。

如果你依赖于latest”的镜像，你可能默默地继承了被更新的包，最好的糟糕情况是可能影响你应用的可靠性，最差的糟糕情况是可能导致漏洞。

如何检测：
```
deny[msg] {
    input[i].Cmd == "from"
    val := split(input[i].Value[0], ":")
    contains(lower(val[1]), "latest"])
    msg = sprintf("Line %d: do not use 'latest' tag for base images", [i])
}
```


## 避免使用curl

从互联网上拉取东西然后装到shell里是很不好的。不幸的是，它是简化软件安装广泛使用的解决方案。

```
wget https://cloudberry.engineering/absolutely-trustworthy.sh | sh
```

这个风险和供应链攻击风险结构是一样的**归纳起来就是信任**。如果你真的不得不用curl，那就用正确的方式：
- 使用被信任的源
- 使用安全的连接
- 验证你下载东西的真实性和完整性

如何检测：
```
deny[msg] {
    input[i].Cmd == "run"
    val := concat(" ", input[i].Value)
    matches := regex.find_n("(curl|wget)[^|^>]*[|>]", lower(val), -1)
    count(matches) > 0
    msg = sprintf("Line %d: Avoid curl bashing", [i])
}
```


## 5. 不要升级你的系统包

这个可能有点牵强，但是有如下原因：你有想要固定版本的软件依赖，如果你执行`apt-get upgrade`，你将把它们所有都升级到最新的版本。

如果你在使用`latest`标签的基础镜像中做升级操作，你将扩大你依赖树的不可预测性。

你要做的就是固定基础镜像版本，然后执行`apt/apk update`。

如何检测：
```
upgrade_commands = [
    "apk upgrade",
    "apt-get upgrade",
    "dist-upgrade",
]

deny[msg] {
    input[i].Cmd == "run"
    val := concat(" ", input[i].Value)
    contains(val, upgrade_commands[_])
    msg = sprintf(“Line: %d: Do not upgrade your system packages", [i])
}
```


## 尽可能不要使用ADD

`ADD`命令的一个特征就是你可以指向一个远程链接，它将在构建时拉取内容。

```
ADD https://cloudberry.engineering/absolutely-trust-me.tar.gz
```

讽刺的是官方文档建议使用curl来代替。

从安全的角度来看同样的建议是：不要这样做。无论获取什么你需要内容之前，都要验证它然后再用`ADD`。但是如果你真的不得不用，**在安全链接上使用被信任的源**

注意：如果你有一个动态生成Dockerfile的花哨的构建系统，那么`ADD`实际就是个请求被利用的接收器。

如何检测：
```
deny[msg] {
    input[i].Cmd == "add"
    msg = sprintf("Line %d: Use COPY instead of ADD", [i])
}
```


## 不要用root

容器中的root和主机的root同一个，但是受限于docker的守护进程配置。不管有什么显示，如果一个参与者跳出容器，它仍将可以获取主机的所有访问权限。

当然，这并不理想，威胁模型不能忽略作为root用户运行所带来的风险。

因此最好总是指定一个用户：
```
USER hopefullynotroot
```

注意在Dockerfile中显示地设置一个用户只是一层防御，并不能解决[用root运行](https://www.redhat.com/en/blog/understanding-root-inside-and-outside-container)所有的问题。

相反我们可以——而且应该——采用纵深防御的方法，在整个堆栈中进一步减轻风险：严格配置docker守护进程，或者使用无root容器方案，限制运行配置（例如尽可能禁止`-- privileged`）等。

如何检测：
```
any_user {
    input[i].Cmd == "user"
 }

deny[msg] {
    not any_user
    msg = "Do not run as root, use USER instead"
}
```


## 不要使用sudo

作为`不要使用root`的推论，你也不应该使用sudo。

即便你用用户身份运行，也要确保这个用户不在可以使用sudo的用户里。

```
deny[msg] {
    input[i].Cmd == "run"
    val := concat(" ", input[i].Value)
    contains(lower(val), "sudo")
    msg = sprintf("Line %d: Do not use 'sudo' command", [i])
}
```


## 结论

Docker安全，或者一般的容器安全是很棘手的，有许多解决方案可以降低风险。

本文展示了如何在构建阶段解决问题，通过给Dockerfile设置简单的安全检查器。如果你想了解更多，可以从[容器安全的介绍](https://cloudberry.engineering/article/practical-introduction-container-security/)中找到有用信息。

感谢阅读！


## 致谢

这个作品受到了[Madhu Akula](https://blog.madhuakula.com/@madhuakula)的[现有技术](https://blog.madhuakula.com/dockerfile-security-checks-using-opa-rego-policies-with-conftest-32ab2316172f)的启发和迭代。