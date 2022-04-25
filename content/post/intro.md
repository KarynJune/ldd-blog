---
title: "Intro"
date: 2022-02-11T18:25:08+08:00
draft: true
tags: ["tag1", "tag2", "tag3"]
categories: ["类别A"]
---

## 二级标题

> 引用
> 内容

### 三级标题

![](/img/2022-02-12-17-17-41.png)
看看`go`的代码：

```go
nums := make([]int, 10)
```

## Tables

```
| _Colors_      | Fruits          | Vegetable         |
| ------------- |:---------------:| -----------------:|
| Red           | *Apple*         | [Pepper](#Tables) |
| ~~Orange~~    | Oranges         | **Carrot**        |
| Green         | ~~***Pears***~~ | Spinach           |
```

| _Colors_   |     Fruits      |  Vegetable |
| ---------- | :-------------: | ---------: |
| Red        |     _Apple_     |     Pepper |
| ~~Orange~~ |     Oranges     | **Carrot** |
| Green      | ~~**_Pears_**~~ |    Spinach |

| Class or Enum    | Year                                            | Month                                           |                       Day                       |                      Hours                      |                     Minutes                     | Seconds\*                                       |                   Zone Offset                   |                     Zone ID                     | toString Output                             | Where Discussed                                                                                     |
| ---------------- | ----------------------------------------------- | ----------------------------------------------- | :---------------------------------------------: | :---------------------------------------------: | :---------------------------------------------: | ----------------------------------------------- | :---------------------------------------------: | :---------------------------------------------: | ------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| `Instant`        |                                                 |                                                 |                                                 |                                                 |                                                 | <center>![checked](/favicon-16x16.png)</center> |                                                 |                                                 | `2013-08-20T15:16:26.355Z`                  | [Instant Class](https://docs.oracle.com/javase/tutorial/datetime/iso/instant.html)                  |
| `LocalDate`      | <center>![checked](/favicon-16x16.png)</center> | <center>![checked](/favicon-16x16.png)</center> | <center>![checked](/favicon-16x16.png)</center> |                                                 |                                                 |                                                 |                                                 |                                                 | `2013-08-20`                                | [Date Classes](https://docs.oracle.com/javase/tutorial/datetime/iso/date.html)                      |
| `LocalDateTime`  | <center>![checked](/favicon-16x16.png)</center> | <center>![checked](/favicon-16x16.png)</center> | <center>![checked](/favicon-16x16.png)</center> | <center>![checked](/favicon-16x16.png)</center> | <center>![checked](/favicon-16x16.png)</center> | <center>![checked](/favicon-16x16.png)</center> |                                                 |                                                 | `2013-08-20T08:16:26.937`                   | [Date and Time Classes](https://docs.oracle.com/javase/tutorial/datetime/iso/datetime.html)         |
| `ZonedDateTime`  | <center>![checked](/favicon-16x16.png)</center> | <center>![checked](/favicon-16x16.png)</center> | <center>![checked](/favicon-16x16.png)</center> | <center>![checked](/favicon-16x16.png)</center> | <center>![checked](/favicon-16x16.png)</center> | <center>![checked](/favicon-16x16.png)</center> | <center>![checked](/favicon-16x16.png)</center> | <center>![checked](/favicon-16x16.png)</center> | `2013-08-21T00:16:26.941+09:00[Asia/Tokyo]` | [Time Zone and Offset Classes](https://docs.oracle.com/javase/tutorial/datetime/iso/timezones.html) |
| `LocalTime`      |                                                 |                                                 |                                                 | <center>![checked](/favicon-16x16.png)</center> | <center>![checked](/favicon-16x16.png)</center> | <center>![checked](/favicon-16x16.png)</center> |                                                 |                                                 | `08:16:26.943`                              | [Date and Time Classes](https://docs.oracle.com/javase/tutorial/datetime/iso/datetime.html)         |
| `MonthDay`       |                                                 | <center>![checked](/favicon-16x16.png)</center> | <center>![checked](/favicon-16x16.png)</center> |                                                 |                                                 |                                                 |                                                 |                                                 | `--08-20`                                   | [Date Classes](https://docs.oracle.com/javase/tutorial/datetime/iso/date.html)                      |
| `Year`           | <center>![checked](/favicon-16x16.png)</center> |                                                 |                                                 |                                                 |                                                 |                                                 |                                                 |                                                 | `2013`                                      | [Date Classes](https://docs.oracle.com/javase/tutorial/datetime/iso/date.html)                      |
| `YearMonth`      | <center>![checked](/favicon-16x16.png)</center> | <center>![checked](/favicon-16x16.png)</center> |                                                 |                                                 |                                                 |                                                 |                                                 |                                                 | `2013-08`                                   | [Date Classes](https://docs.oracle.com/javase/tutorial/datetime/iso/date.html)                      |
| `Month`          |                                                 | <center>![checked](/favicon-16x16.png)</center> |                                                 |                                                 |                                                 |                                                 |                                                 |                                                 | `AUGUST`                                    | [DayOfWeek and Month Enums](https://docs.oracle.com/javase/tutorial/datetime/iso/enum.html)         |
| `OffsetDateTime` | <center>![checked](/favicon-16x16.png)</center> | <center>![checked](/favicon-16x16.png)</center> | <center>![checked](/favicon-16x16.png)</center> | <center>![checked](/favicon-16x16.png)</center> | <center>![checked](/favicon-16x16.png)</center> | <center>![checked](/favicon-16x16.png)</center> | <center>![checked](/favicon-16x16.png)</center> |                                                 | `2013-08-20T08:16:26.954-07:00`             | [Time Zone and Offset Classes](https://docs.oracle.com/javase/tutorial/datetime/iso/timezones.html) |
| `OffsetTime`     |                                                 |                                                 |                                                 | <center>![checked](/favicon-16x16.png)</center> | <center>![checked](/favicon-16x16.png)</center> | <center>![checked](/favicon-16x16.png)</center> | <center>![checked](/favicon-16x16.png)</center> |                                                 | `08:16:26.957-07:00`                        | [Time Zone and Offset Classes](https://docs.oracle.com/javase/tutorial/datetime/iso/timezones.html) |
| `Duration`       |                                                 |                                                 |                      \*\*                       |                      \*\*                       |                      \*\*                       | <center>![checked](/favicon-16x16.png)</center> |                                                 |                                                 | `PT20H` (20 hours)                          | [Period and Duration](https://docs.oracle.com/javase/tutorial/datetime/iso/period.html)             |
| `Period`         | <center>![checked](/favicon-16x16.png)</center> | <center>![checked](/favicon-16x16.png)</center> | <center>![checked](/favicon-16x16.png)</center> |                                                 |                                                 |                                                 |                     \*\*\*                      |                     \*\*\*                      | `P10D` (10 days)                            | [Period and Duration](https://docs.oracle.com/javase/tutorial/datetime/iso/period.html)             |
