---
title: "标准输入输出与重定向"
date: 2022-04-25T11:52:45+08:00
draft: false
tags: ["Linux", "Shell"]
categories: ["Linux"]
---

## 概述

Linux 的命令运行时会打开三个文件：标准输入、标准输出、标准错误

|      文件名称      | 文件描述符 | 默认指向 |  重定向命令符  |
| :----------------: | :--------: | :------: | :------------: |
| 标准输入（stdin）  |     0      |   键盘   |     <、<<      |
| 标准输出（stdout） |     1      |  控制台  | >、>>、1>、1>> |
| 标准错误（stderr） |     2      |  控制台  |    2>、2>>     |

- **文件描述符**：Linux 中一切都是文件，文件描述符是内核为了高效管理已被打开的文件创建的索引，是非负整数
- **默认指向**：默认指向的输入输出位置，如 stdin 默认从键盘输入数据
- **重定向命令符**：在命令之间插入特定的符号，实现改变其默认指向

## 重定向命令符

在命令之间插入特定的符号，实现改变其默认输入输出指向

如`echo "Hello world"`默认打印到控制台:

```bash
$ echo “hello world”
“hello world”
```

使用`>`重定向到文件，将打印到文件中:

```bash
$ echo “hello world” > my.txt
$ cat my.txt
“hello world”
```

下面介绍不同的重定向命令符：

### 标准的重定向命令符

- `>`：输出重定向到文件，并清空原文件内容

```bash
# 重写log.txt
$ echo "Hello world" > log.txt
```

- `>>`：输出重定向到文件，将追加到原文件内容后

```bash
# 追加内容到log.txt
$ echo "Hello world" >> log.txt
```

- `<`：输入重定向到从文件输入

```bash
# 统计log.txt行数
$ wc -l < log.txt
```

- `<<`：输入重定向到从屏幕输入，直到遇到“分隔符”

```bash
# 统计输入行数
$ wc -l << EOF
> row1
> row2
> EOF
2
```

### 组合的重定向命令符

- `1>`：输出 stdout 到文件，`>`默认就是`1>`，一般直接用`>`不需要指定描述符
- `2>`：输出 stderr 到文件，`>`默认是 stdout
- `2>&1`：表示 stderr 指向 stdout 的指向，即合并 stdout 与 stderr，&可以看作指针，&1 表示指向 stdout 的指向

```bash
# stdout与stderr都输入到log.txt，发生2次指向变化
# 1. >log.txt表示stdout重定向到文件log.txt
# 2. 2>&1表示stderr重定向到stdout的指向，即文件log.txt
$ python app.py >log.txt 2>&1

# 假如2>&1与>log.txt调换位置，此时stdout到log.txt，stderr到屏幕
# 1. 2>&1表示stderr重定向到stdout的指向，即默认的屏幕输出
# 2. >log.txt表示stdout重定向到文件log.txt
$ python app.py 2>&1 >log.txt
```

## 特殊的文件输出：/dev/null

- 写入/dev/null 的内容将被丢弃，相当于写了个寂寞
- 常用来筛选有用的输出，保证干净的打印

```bash
# 仅输出ping失败的内容
$ ping google.com 1> /dev/null

# 丢弃所有输出的内容
$ ping google.com > /dev/null 2>&1
```
