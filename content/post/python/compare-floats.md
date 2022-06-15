---
title: "Python正确的浮点数比较方式"
date: 2022-06-14T10:03:13+08:00
draft: false
tags: ["Python", "翻译"]
categories: ["Python", "翻译"]
---

> 翻译自原文：[https://davidamos.dev/the-right-way-to-compare-floats-in-python/](https://davidamos.dev/the-right-way-to-compare-floats-in-python/)


浮点数是快速且有效的存储和处理数字的方法，但也带来了一系列陷阱困扰住许多菜鸟程序员——也可能是一些有经验的程序员！经典的浮点数陷阱示例如下：

```python
>>> 0.1 + 0.2 == 0.3
False
```

第一次看到这个可能会迷惑，但不要把你的电脑扔到垃圾桶，这个现象是正确的！

这篇文章将告诉你为什么像上面这样的浮点数错误是常见的，为什么它们起作用，以及在Python中如何来解决它们。


## 你的计算机是一个骗子（有点）

你已经看到`0.1+0.2`不等于`0.3`，但不止如此，还有一些更迷惑人的示例：

```python
>>> 0.2 + 0.2 + 0.2 == 0.6
False

>>> 1.3 + 2.0 == 3.3
False

>>> 1.2 + 2.4 + 3.6 == 7.2
False
```

这样的问题不止限于判断相等：

```python
>>> 0.1 + 0.2 <= 0.3
False

>>> 10.4 + 20.8 > 31.2
True

>>> 0.8 - 0.1 > 0.7
True
```

那么到底发生了什么呢？是你的计算机欺骗你了吗？看起来好像是这样，但要透过表面看本质。

当你在Python解释器输入数字`0.1`时，会以浮点数存储在内存中。这时会发生转换。`0.1`是十进制数，但是浮点数是以二进制存储的。换句话说，`0.1`从十进制转化为二进制。

转化来的二进制数可能不能准确表达原始的十进制数。`0.1`便是如此，它的二进制表示为$0.0\overline{0011}$，即0.1的二进制表示是一个无限重复的小数。就好比你把分数$\frac{1}{3}$写成十进制的小数，会得到无限重复的小数$0.\overline{33}$

计算机内存是有限的，所以`0.1`二进制的无限重复分数会被四舍五入为一个有限分数。这个数值取决于你的计算机架构（32位和64位）。查看`0.1`存储的浮点数值的一种方式是使用`.as_integer_ratio()`来获取表示浮点数的分子和分母：

```python
>>> numerator, denominator = (0.1).as_integer_ratio()
>>> f"0.1 ≈ {numerator} / {denominator}"
'0.1 ≈ 3602879701896397 / 36028797018963968'
```

现在使用`format()`显示精确到小数点后55位的分数：
```python
>>> format(numerator / denominator, ".55f")
'0.1000000000000000055511151231257827021181583404541015625'
```

所以`0.1`被四舍五入到一个比它实际值略微大一点的数

> 在文章[3 Things You Might Not Know About Numbers in Python](https://davidamos.dev/three-things-you-might-not-know-about-numbers-in-python/)中学习更多如`.as_integer_ratio()`的数字方法。

这种错误被称作**浮点数表示错误**，比你想象的还要经常发生。


## 表示错误是*真的*很常见

当表示一个浮点数时数字被四舍五入有三个原因：

1. 该数比允许的浮点数有更多有效数字。
2. 无理数。
3. 有理数但有非终止的二进制表示。


64位的浮点数适用于大约16或17个有效数字，任何更多的有效数字都会被四舍五入。无理数如$\pi$和$e$，不能被任何整形基数的任何终止分数表示，所以不管怎样无理数作为浮点数存储时都将被四舍五入。

这两种情况会创建一组不能被准确表示为浮点数的无限数字。但是除非你是一个解决微小数字的化学家，或者是处理天文数字的物理学家，否则你不太可能遇到这些问题。

那么像`0.1`的二进制这样的非终止的有理数呢？这是你会遇到的大多数浮点数问题，并且由于数学运算决定了是否是终止的分数，遇到的表示错误比你想象的还要多。

在十进制中，如果分母是10的素因数的乘积则分数终止。10的素因数是2和5，所以像$\frac{1}{2}$，$\frac{1}{4}$，$\frac{1}{5}$，$\frac{1}{8}$，$\frac{1}{10}$这样的分数都会终止，但$\frac{1}{3}$，$\frac{1}{7}$，$\frac{1}{9}$不会终止。然而在二进制中，只有一个素因数：2，所以只有分母是2的乘积才会终止，所以像$\frac{1}{3}$，$\frac{1}{5}$，$\frac{1}{6}$，$\frac{1}{7}$，$\frac{1}{9}$，$\frac{1}{10}$这样的分数用二进制表达时都不会终止。

你现在应该能理解本文最开始的示例了。`0.1`，`0.2`和`0.3`被转化成浮点数时都被四舍五入了。
```python
>>> # -----------vvvv  显示小数点后17位
>>> format(0.1, ".17g")
'0.10000000000000001'

>>> format(0.2, ".17g")
'0.20000000000000001'

>>> format(0.3, ".17g")
'0.29999999999999999'
```


当0.1和0.2相加时，结果会比0.3略微大一点：
```python
>>> 0.1 + 0.2
0.30000000000000004
```

由于`0.1+0.2`比`0.3`略微大，且`0.3`的表示比自身又略微小，所有表达式`0.1+0.2==0.3`结果为`False`

> 浮点数表示错误是每种语言的每个程序员都需要了解且知道如何处理的，**并不特定在Python中出现**。你可以在Erik Wiffin的命名都恰如其分的网站[0.30000000000000004.com](https://0.30000000000000004.com/)中用不同的语言输入`0.1+0.2`查看结果。


## 在Python中如何比较浮点数

那么在Python中要如何解决比较浮点数时的浮点数表示错误呢？这个手段就是避免去检查相等。在浮点数中不要使用`==`，`>=`或者`<=`，而是用`math.isclose()`:
```python
>>> import math
>>> math.isclose(0.1 + 0.2, 0.3)
True
```

`math.isclose()`检查第一个参数是否可接受地接近于第二个参数。但这究竟是什么意思呢？关键点就在检查第一个参数和第二个参数的距离，相当于值差的绝对值：
```python
>>> a = 0.1 + 0.2
>>> b = 0.3
>>> abs(a - b)
5.551115123125783e-17
```

如果`abs(a - b)`小于`a`或`b`中较大者的某个百分比，则认为`a`接近“等于”`b`。这个百分比称为**相对容差**。你可以通过`math.isclose()`中`rel_tol`这个参数来指定相对容差，其默认值为`1e-9`。换句话说，如果`abs(a - b)`小于`1e-9 * max(abs(a), abs(b))`，那么`a`和`b`被认为是互相“接近”的。这个保证了`a`和`b`大约小数点后九位是相等的。


如果有需要可以改变相对容差：
```python
>>> math.isclose(0.1 + 0.2, 0.3, rel_tol=1e-20)
False
```


当然这个相对容差取决于你在解决的问题所设的约束。然而对日常大部分应用，这个默认相对容差应该足够了。

但是，如果`a`或`b`有一个值为0，且`rel_tol`小于1会出现问题，无论非0值有多接近0值，这个相对容差的接近性检查始终会失败。在这种情况下，使用绝对容差作为备选：
```python
>>> # 相对检查失败!
>>> # ---------------vvvv  相对容差
>>> # ----------------------vvvvv  max(0, 1e-10)
>>> abs(0 - 1e-10) < 1e-9 * 1e-10
False

>>> # 绝对检查成功!
>>> # ---------------vvvv  绝对容差
>>> abs(0 - 1e-10) < 1e-9
True
```

`math.isclose()`将自动为你做这个检查。参数`abs_tol`决定了绝对容差。但是，`abs_tol`的默认值是`0.0`，所以如果你要检查一个值与0的接近程度需要手动设置。


总而言之，`math.isclose()`返回了下面这个表达式的结果，把相对和绝对测试组合在一个表达式中：
```python
abs(a - b) <= max(rel_tol * max(abs(a), abs(b)), abs_tol)
```

`math.isclose()`在[PEP 485](https://peps.python.org/pep-0485/)中介绍并在Python 3.5开始可用。


## 什么时候该用`math.isclose()`

通常情况下，你需要对比浮点数时都应该用`math.isclose()`。用`math.isclose()`替换`==`:
```pyhton
>>> # 不要这样写:
>>> 0.1 + 0.2 == 0.3
False

>>> # 用这个替代:
>>> math.isclose(0.1 + 0.2, 0.3)
True
```

你还要注意`>=`和`<=`的比较。使用`math.isclose()`分别处理相等，然后再检查严格比较：
```python
>>> a, b, c = 0.1, 0.2, 0.3

>>> # >>> # 不要这样写:
>>> a + b <= c
False

>>> # 用这个替代:
>>> math.isclose(a + b, c) or (a + b < c)
True
```

还有多种替代`math.isclose()`的方案。如果你使用NumPy，你可以使用`numpy.allclose()`和`numpy.isclose()`：
```python
>>> import numpy as np

>>> # 使用numpy.allclose()来检查两个数组在容差内是否相等
>>> np.allclose([1e10, 1e-7], [1.00001e10, 1e-8])
False

>>> np.allclose([1e10, 1e-8], [1.00001e10, 1e-9])
True

>>> # 使用numpy.isclose()来检查两个数组的元素在容差内是否相等
>>> np.isclose([1e10, 1e-7], [1.00001e10, 1e-8])
array([ True, False])

>>> np.isclose([1e10, 1e-8], [1.00001e10, 1e-9])
array([ True, True])
```

记住相对和绝对容差的默认值和`math.isclose()`是不同的。`numpy.allclose()`和`numpy.isclose()`的相对容差默认值是`1e-05`，绝对容差默认值是`1e-08`。

尽管有其他替代方案，`math.isclose()`在单元测试中特别有用。Python内置的`unittest`模块就有个`unittest.TestCase.assertAlmostEqual()`方法。然而，那个方法仅适用于绝对差异测试，而且是个断言，意味着失败将会抛出`AssertionError`，不适合在业务逻辑中作比较。

单元测试中有一个好的替代方案是`pytest`包的`pytest.approx()`函数。和`math.isclose()`不同的是，`pytest.approx()`只带一个参数——即你期望的值：
```python
>>> import pytest
>>> 0.1 + 0.2 == pytest.approx(0.3)
True
```

`pytest.approx()`有`rel_tol`和`abs_tol`参数来设置相对和绝对容差。然而默认值不同于`math.isclose()`。`rel_tol`的默认值是`1e-6`，`abs_tol`的默认值是`1e-12`。

如果传给`pytest.approx()`的参数是类数组的，即它是Python中如列表或者元祖这样可迭代的，或者甚至是Numpy的数组，那么`pytest.approx()`的行为就会和`numpy.allclose()`相似，并且返回两个数组在容差内是否相等
```python
>>> import numpy as np                                                          
>>> np.array([0.1, 0.2]) + np.array([0.2, 0.4]) == pytest.approx(np.array([0.3, 0.6])) 
True
```

`pytest.approx()`同样适用于字典：
```python
>>> {'a': 0.1 + 0.2, 'b': 0.2 + 0.4} == pytest.approx({'a': 0.3, 'b': 0.6})
True
```

浮点数非常适合用在不需要绝对精度的地方。它们速度快、内存高效。但是如果你需要精度，你应该考虑浮点数的替代方案。


## 精确的浮点数替代方案

Python中提供了两个内置的数值类型，弥补浮点数提供全精度：`Decimal`和`Fraction`。


### `Decimal`类型

`Decimal`类型可以精确存储你需要的十进制值。`Decimal`默认保存28位有效数字，但是你可以随时改变这个值来适用你正在解决的问题：
```python
>>> # 从decimal模块导入Decimal类型
>>> from decimal import Decimal

>>> # 数值被精确表示所以没有四舍五入的错误发生
>>> Decimal("0.1") + Decimal("0.2") == Decimal("0.3")
True

>>> # 默认保存28位有效数字
>>> Decimal(1) / Decimal(7)
Decimal('0.1428571428571428571428571429')

>>> # 你可以根据需要修改有效数字
>>> from decimal import getcontext
>>> getcontext().prec = 6  # 使用6位有效数字
>>> Decimal(1) / Decimal(7)
Decimal('0.142857')
```

你可以在[Python docs](https://docs.python.org/3/library/decimal.html)中查阅更多关于`Decimal`类型的内容


### `Fraction`类型

另一个浮点数的替代方案是`Fraction`类型。`Fraction`可以精确存储有理数，并解决浮点数表示错误：
```python
>>> # 从fractions模块中导入Fraction
>>> from fractions import Fraction

>>> # 用一个分子和分母初始化Fraction
>>> Fraction(1, 10)
Fraction(1, 10)

>>> # 数值被精确表示所以没有四舍五入的错误发生
>>> Fraction(1, 10) + Fraction(2, 10) == Fraction(3, 10)
True
```

`Fraction`和`Decimal`都提供了比浮点数更多的好处。但是，这些好处也有代价：速度降低、高内存消耗。如果你不需要绝对精度，最好坚持用浮点数。但是对于一些金融和任务关键性应用，权衡使用`Fraction`和`Decimal`可能更值得。


## 结论

浮点数有好有坏。它们用不精确的表示为代价提供了快速的运算和高效的内存使用，在本文中，你已经学会了：
- 为什么浮点数是不精确的
- 为什么浮点数表示错误是普遍的
- Python中如何正确比较浮点数
- Python中如何用`Fraction`和`Decimal`表示数值精度

如果你新学到了东西，那么Python中关于数值可能还有很多你不了解的地方。例如，你知道Python中`int`类型不是唯一的整数类型吗？在文章[3 Things You Might Not Know About Numbers in Python](https://davidamos.dev/three-things-you-might-not-know-about-numbers-in-python/)中了解其他整数类型是什么以及其他关于数值的鲜为人知的事实。


## 补充资源

- [Floating-Point Arithmetic: Issues and Limitations](https://docs.python.org/3/tutorial/floatingpoint.html)
- [The Floating-Point Guide](https://floating-point-gui.de/)
- [The Perils of Floating Point](https://www.lahey.com/float.htm)
- [Floating-Point Math](https://0.30000000000000004.com/)
- [What Every Computer Scientist Should Know About Floating-Point Arithmetic](https://docs.oracle.com/cd/E19957-01/806-3568/ncg_goldberg.html)
- [How to Round Numbers in Python](https://realpython.com/python-rounding/)

感谢Brian Okken帮助解决了`pytest.approx()`示例的一个问题。