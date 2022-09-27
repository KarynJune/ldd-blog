---
title: "Python元类-metaclasses"
date: 2022-09-26T14:02:47+08:00
draft: false
tags: ["Python", "翻译"]
categories: ["Python"]
---

> 翻译自原文：[https://realpython.com/python-metaclasses/](https://realpython.com/python-metaclasses/)


术语**元编程**是指程序了解或操纵自身的潜力。Python为类提供了元编程的一种形式叫**元类**。

元类是一种深奥的[OOP概念](https://realpython.com/python3-object-oriented-programming/)，几乎隐藏在所有Python代码中。无论你是否意识到，你都在使用元类。大多数时候，你也不需要意识到。大多数Python开发者很少必须考虑元类。

但是当有这样的需要时，Python提供了一种不是所有面向对象语言都支持的能力：你可以了解内部原理并且自定义元类。自定义元类的使用是有些争议的，正如下面引用Tim Peters的建议，他是Python领袖，编写了[Python之禅](https://www.python.org/dev/peps/pep-0020)。

> “元类比99%的用户担心的更有魔力。如果你想要知道你是否需要用他们，那你就不需要用（真正需要用的准确地知道他们需要，且不需要任何解释）。”
>
> —— Tim Peters


有些Pythonistas（Python爱好者们被称为Pythonistas）认为你永远不应该用自定义元类。这可能有点过，但自定义元类大多不必要很可能是真的。如果一个问题不是很明显需要元类，那如果用一种更简单的方式解决，可能更清晰、更可读。

然而，理解Python元类是值得的，因为它更好地带领我们理解Python类的内部结构。你永远不知道会不会有一天发现自己就处在这样的境况中，只知道自定义元类就是你想要的。


## 旧式类 vs. 新式类

在Python中，一个类[可以是两种类型之一](https://wiki.python.org/moin/NewClassVsClassicClass)。没有确定的官方术语，所以两种类型被非正式地称作旧式类和新式类。

### 旧式类

在旧式类中，类和类型是不同的。一个旧式类的实例总是实现于一个叫`instance`的单个内置类型。假设`obj`是一个旧式类的实例，`obj.__class__`指定为该类，但`type(obj)`总是`instance`。下面的例子取自Python 2.7：
```python
>>> class Foo:
...     pass
...
>>> x = Foo()
>>> x.__class__
<class __main__.Foo at 0x000000000535CC48>
>>> type(x)
<type 'instance'>
```

### 新式类
新式类统一了类和类型的概念。假设`obj`是一个新式类的实例，`obj.__class__`和`type(obj)`是相同的：
```python
>>> class Foo:
...     pass
>>> obj = Foo()
>>> obj.__class__
<class '__main__.Foo'>
>>> type(obj)
<class '__main__.Foo'>
>>> obj.__class__ is type(obj)
True
```

```python
>>> n = 5
>>> d = { 'x' : 1, 'y' : 2 }

>>> class Foo:
...     pass
...
>>> x = Foo()

>>> for obj in (n, d, x):
...     print(type(obj) is obj.__class__)
...
True
True
True
```

## 类型和类
Python3中，所有的类都是新式类。因此，在Python3中可以交替引用对象的类型和类。

> **Note:** Python2中，类默认都是旧式的，Python2.2以前是完全不支持新式类的。从Python2.2开始，可以创建他们但必须显性地声明为新式的。

记住，[Python中一切都是对象](https://web.archive.org/web/20151210024637/https://mail.python.org/pipermail/python-list/2015-June/691689.html)。类也是对象。因此，类必须有一个类型。一个类的类型是什么呢？

思考以下内容：
```pyhton
>>> class Foo:
...     pass
...
>>> x = Foo()

>>> type(x)
<class '__main__.Foo'>

>>> type(Foo)
<class 'type'>
```

如你所见，`x`的类型是`Foo`类，但类自身`Foo`的类型是`type`。通常来说，所有新式类的类型是`type`。

你所熟悉的内置类的类型也是`type`：
```python
>>> for t in int, float, dict, list, tuple:
...     print(type(t))
...
<class 'type'>
<class 'type'>
<class 'type'>
<class 'type'>
<class 'type'>
```

同样的，`type`的类型也是`type`（是的，是真的）：
```python
>>> type(type)
<class 'type'>
```

`type`是一个元类，它的类是实例。正如一个普通对象是一个类的实例，Python中任何新式类，以及Python3中的所有类，都是`type`元类的一个实例。

在上述案例中：
- `x`是`Foo`类的一个实例。
- `Foo`是`type`元类的一个实例。
- `type`也是`type`元类的一个实例，因此它是它自己的一个实例。

![](/img/python/metaclasses_1.png)


## 动态定义一个类

内置函数`type()`传递一个参数，返回一个对象的类型。对于新式类，一般和[对象的__class__属性](https://docs.python.org/3/library/stdtypes.html#instance.__class__)获取的一致：
```python
>>> type(3)
<class 'int'>

>>> type(['foo', 'bar', 'baz'])
<class 'list'>

>>> t = (1, 2, 3, 4, 5)
>>> type(t)
<class 'tuple'>

>>> class Foo:
...     pass
...
>>> type(Foo())
<class '__main__.Foo'>
```

你也可以用三个参数调用`type()`——`type(<name>, <bases>, <dct>)`:
- `<name>`指定类名。成为类的__name__属性。
- `<bases>`指定类继承的基类元组。成为类的__bases__属性。
- `<dct>`指定一个包含类主体定义的命名空间字典。成为类的__dict__属性

用这种方式调用`type()`创建`type`元类的新实例。换句话说，它动态创建了一个新的类。

在下面的每个示例中，上面的代码段用`type()`动态定义了一个类，下面的代码段用`class`语句最通用的方式定义类。每个示例这两个代码段在功能上是相等的。


### 示例1
第一个示例，传入`type()`的`<bases>`和`<dct>`参数都为空，没有指定继承任何父类，命名空间字典中也没有初始放任何东西。这是尽可能最简单的类定义：
```python
>>> Foo = type('Foo', (), {})

>>> x = Foo()
>>> x
<__main__.Foo object at 0x04CFAD50>
```
```python
>>> class Foo:
...     pass
...
>>> x = Foo()
>>> x
<__main__.Foo object at 0x0370AD50>
```

### 示例2
这里`<bases>`是只有一个元素`Foo`的元组，指定`Bar`继承这个父类。属性`attr`被初始放在命名空间字典：

```python
>>> Bar = type('Bar', (Foo,), dict(attr=100))

>>> x = Bar()
>>> x.attr
100
>>> x.__class__
<class '__main__.Bar'>
>>> x.__class__.__bases__
(<class '__main__.Foo'>,)
```
```python
>>> class Bar(Foo):
...     attr = 100
...

>>> x = Bar()
>>> x.attr
100
>>> x.__class__
<class '__main__.Bar'>
>>> x.__class__.__bases__
(<class '__main__.Foo'>,)
```

### 示例3
这一次`<bases>`再次为空，两个对象通过`<dct>`被放进命名空间字典。第一个是一个命名为`attr`的属性，第二个是命名为`attr_val`的函数，成为被定义类的一个方法：
```python
>>> Foo = type(
...     'Foo',
...     (),
...     {
...         'attr': 100,
...         'attr_val': lambda x : x.attr
...     }
... )

>>> x = Foo()
>>> x.attr
100
>>> x.attr_val()
100
```

```python
>>> class Foo:
...     attr = 100
...     def attr_val(self):
...         return self.attr
...

>>> x = Foo()
>>> x.attr
100
>>> x.attr_val()
100
```

### 示例4
只有非常简单的函数可以用[Python的lambda](https://dbader.org/blog/python-lambda-functions)来定义。在下面的示例中，在外部定义一个略微复杂点的函数，在命名空间字典中分配给`attr_val`命名为f：
```python
>>> def f(obj):
...     print('attr =', obj.attr)
...
>>> Foo = type(
...     'Foo',
...     (),
...     {
...         'attr': 100,
...         'attr_val': f
...     }
... )

>>> x = Foo()
>>> x.attr
100
>>> x.attr_val()
attr = 100
```
```python
>>> def f(obj):
...     print('attr =', obj.attr)
...
>>> class Foo:
...     attr = 100
...     attr_val = f
...

>>> x = Foo()
>>> x.attr
100
>>> x.attr_val()
attr = 100
```


## 自定义元类
再思考下这个旧示例：
```python
>>> class Foo:
...     pass
...
>>> f = Foo()
```

表达式`Foo()`创建了一个类`Foo`的一个新实例。当解释器遇到`Foo()`，将发生下面情形：
- `Foo`父类的`__call__()`方法被调用。因为`Foo`是一个标准的新式类，它的父类是`type`元类，所以`type`的`__call__()`方法被调用。
- `__call__()`方法依次调用下面方法：
  - `__new__()`
  - `__init__()`


如果`Foo`没有定义`__new__()`和`__init__()`，默认方法是继承自`Foo`的祖先。但是如果`Foo`定义了这些方法，他们重写祖先的那些方法，允许在实例化`Foo`时自定义行为。

在下面的示例中，定义了一个自定义方法`new()`，并且分配给`Foo`作为`__new__()`方法：
```python
>>> def new(cls):
...     x = object.__new__(cls)
...     x.attr = 100
...     return x
...
>>> Foo.__new__ = new

>>> f = Foo()
>>> f.attr
100

>>> g = Foo()
>>> g.attr
100
```

这修改了类`Foo`的实例化行为：每次`Foo`的一个实例被创建，默认初始化一个叫`attr`的属性，并赋值100。（像这样的代码更常出现在`__init__()`方法里，不常在`__new__()`。这个示例是为了演示目的而设计。）

现在，正如已经重申的，类也是对象。假设你创建一个像`Foo`的类时，想要类似的自定义实例化行为。如果你遵循上面的模式，你要再定义一个自定义方法，并将其赋值给`Foo`是其实例的类的`__new__()`方法。`Foo`是`type`元类的一个实例，所以代码如下：
```python
# 剧透警告：这行不通！
>>> def new(cls):
...     x = type.__new__(cls)
...     x.attr = 100
...     return x
...
>>> type.__new__ = new
Traceback (most recent call last):
  File "<pyshell#77>", line 1, in <module>
    type.__new__ = new
TypeError: can't set attributes of built-in/extension type 'type'
```
但是，如你所见，你不能给`type`元类重新赋值`__new__()`方法。Python是不允许的。

这或许也没关系。`type`是派生所有新式类的元类，你的确不应该乱动它。但是有什么方式来自定义实例化一个类呢？

一个可能的方案是自定义元类。实际上你可以定义自己的元类，它派生自`type`，而不是搞乱`type`元类。

第一步是定义一个派生自`type`的元类，如下：
```python
>>> class Meta(type):
...     def __new__(cls, name, bases, dct):
...         x = super().__new__(cls, name, bases, dct)
...         x.attr = 100
...         return x
...
```

定义头`class Meta(type)`：指定`Meta`派生自`type`。因为`type`是一个元类，所以`Meta`也是一个元类。

注意到为`Meta`定义了一个自定义的`__new__()`方法，这是不可能为`type`元类这样定义的。这个`__new__()`方法做了如下的事：
- 通过`super()`委托父元类（`type`）的`__new__()`方法创建一个新类
- 给这个类分配自定义属性`attr`，并赋值100
- 返回新创建的类

现在是巫毒的另一半：定义一个新类`Foo`并指定元类是自定义元类`Meta`，而不是标准元类`type`。这是像下面这样使用类定义中的`metaclass`完成的：
```python
>>> class Foo(metaclass=Meta):
...     pass
...
>>> Foo.attr
100
```

看！`Foo`自动从`Meta`元类拿到了`attr`属性。当然，任何类似定义的其他类也能这样：
```python
>>> class Bar(metaclass=Meta):
...     pass
...
>>> class Qux(metaclass=Meta):
...     pass
...
>>> Bar.attr, Qux.attr
(100, 100)
```

和类作为创建对象的模版作用一样，元类也作为创建类的模版发挥作用。元类有时被称为[类工厂](https://en.wikipedia.org/wiki/Factory_(object-oriented_programming))。

对比下面两个示例：

### 对象工厂
```python
>>> class Foo:
...     def __init__(self):
...         self.attr = 100
...

>>> x = Foo()
>>> x.attr
100

>>> y = Foo()
>>> y.attr
100

>>> z = Foo()
>>> z.attr
100
```

### 类工厂
```python
>>> class Meta(type):
...     def __init__(
...         cls, name, bases, dct
...     ):
...         cls.attr = 100
...
>>> class X(metaclass=Meta):
...     pass
...
>>> X.attr
100

>>> class Y(metaclass=Meta):
...     pass
...
>>> Y.attr
100

>>> class Z(metaclass=Meta):
...     pass
...
>>> Z.attr
100
```

## 真的重要吗？

尽管上面的类工厂示例很简单，它是元类如果起作用的本质。他们允许自定义类的实例化。

不过，仅仅是把自定义属性`attr`赋予给每个新创建的类就需要大量的忙活。你真需要为此用元类吗？

在Python中，至少有几种其他方式可以有效地完成同样的事情：
### 简单的继承
```python
>>> class Base:
...     attr = 100
...

>>> class X(Base):
...     pass
...

>>> class Y(Base):
...     pass
...

>>> class Z(Base):
...     pass
...

>>> X.attr
100
>>> Y.attr
100
>>> Z.attr
100
```

### 类装饰器
```python
>>> def decorator(cls):
...     class NewClass(cls):
...         attr = 100
...     return NewClass
...
>>> @decorator
... class X:
...     pass
...
>>> @decorator
... class Y:
...     pass
...
>>> @decorator
... class Z:
...     pass
...

>>> X.attr
100
>>> Y.attr
100
>>> Z.attr
100
```

## 结论

正如Tim Peters建议的，**元类**很容易变成“查询问题的解决方案”。通常不需要创建自定义元类。如果问题能用一种更简单的方式解决，就应该用简单的解决。尽管如此，理解元类还是有好处的，以便你能总体上理解[Python类](https://realpython.com/python3-object-oriented-programming/)，并能意识到什么时候元类是真正合适的使用工具。