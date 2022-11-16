---
title: "每个Web开发人员必须了解URL编码"
date: 2022-10-14T14:13:22+08:00
draft: true
tags: ["Web", "翻译"]
categories: ["Web"]
---

> 翻译自原文：[https://blog.lunatech.com/posts/2009-02-03-what-every-web-developer-must-know-about-url-encoding](https://blog.lunatech.com/posts/2009-02-03-what-every-web-developer-must-know-about-url-encoding)

这篇文章描述了有关**统一资源描述符**（[URL](http://en.wikipedia.org/wiki/URL)）的常见误解，然后尝试澄清[HTTP](http://en.wikipedia.org/wiki/HTTP)的[URL 编码](http://en.wikipedia.org/wiki/Percent-encoding)，再介绍常见问题及其解决方案。尽管这篇文章不特指某一个编程语言，但我们会用[Java](<http://en.wikipedia.org/wiki/Java_(programming_language)>)来说明问题，最后解释如何在 Java 中和多级 web 应用中解决 URL 编码问题。

## 介绍

当浏览[网络](http://en.wikipedia.org/wiki/World_Wide_Web)时，我们每天都在使用许多技术。显然有数据本身（网页）、数据格式、允许我们检索数据的传输机制，还有使得网络成为*网络*的基础：一个页面到其他页面到链接。这些链接就是 URL。

### 通用 URL 语法

目前为止每个人在他生活中至少看到过一次的 URL，以`http://www.google.com`为例。这是一个 URL。一个 URL 是一个*统一资源定位器*，实际是指向一个网页的指针（大多数情况下）。URL 实际在 1994 年[第一个规范](http://tools.ietf.org/html/rfc1738)以来就有非常明确的结构。

我们可以提取 URL`http://www.google.com`的详细信息：
｜ 部分 ｜ 数据 ｜
| ----: | ----: |
｜ 协议 ｜ http ｜
｜ 主机地址 ｜ www.google.com ｜

假设我们看到一个像`https://bob:bobby@www.lunatech.com:8080/file;p=1?q=2#third`这样更复杂的 URL，我们可以提取到下面信息：
｜ 部分 ｜ 数据 ｜
| ----: | ----: |
｜ 协议 ｜ https ｜
｜ 用户名 ｜ bob ｜
｜ 密码 ｜ bobby ｜
｜ 主机地址 ｜ www.lunatech.com ｜
｜ 端口 ｜ 8080 ｜
｜ 路径 ｜ /file ｜
｜ 路径参数 ｜ p=1 ｜
｜ 查询参数 ｜ q=2 ｜
｜ 片段 ｜ third ｜

_协议_（这里指*http*和*https*（安全 HTTP））定义了 URL 剩下部分的结构。大多数网络[URL 协议](http://www.iana.org/assignments/uri-schemes.html)都有一个通用的第一部分，指示了用户名、密码、主机名称和端口，然后跟着特定于协议的部分。这个通用的部分处理了身份验证，并且能知道连接到哪里来请求数据。

### HTTP URL 语法

对于 HTTP 的 URL（用*http*和*https*协议），特定于协议的部分定义了数据的*路径*，然后跟着一个可选的*查询*和*片段*。

*路径*部分包含在一个分层视图中，类似一个用文件夹和文件的文件系统层次结构。路径开始于一个`/`字符，然后每个文件夹再用`/`来分隔，直到到达文件。例如`/photos/egypt/cairo/first.jpg`有 4 个*路径段*：`photos`，`egypt`，`cairo`以及`first.jpg`，由此推断：文件`first.jpg`在`cairo`文件夹中，该文件夹在网站根目录里的`photos`文件夹下的`egypt`文件夹里。

每个*路径段*可以有可选的*路径参数*（也叫[矩阵参数](http://www.w3.org/DesignIssues/MatrixURIs.html)），在*路径段*结尾的`;`后，并用`;`字符分隔。每个参数名称和对应的值用`=`字符分隔，例如：`/file;p=1`定义了*路径段*`file`有一个值为`1`的*路径参数*`p`。这些参数不常使用——面对现实吧——但是他们确实存在，并且我们甚至在[Yahoo RESTful API 文档](http://en.wikipedia.org/wiki/Representational_State_Transfer)中发现一个很好的理由来用它：

> 矩阵参数使应用程序能够在调用 HTTP GET 操作时检索集合的一部分。有关示例请参阅[分页集合](http://developer.yahoo.com/social/rest_api_guide/partial-resources.html#paging-collection)。因为矩阵参数可以跟随 URI 中的任何集合路径段，所以可以在内部路径段上指定它们。

在路径段之后我们可以看到和*路径*之间用`?`分隔的*查询*，包含多个（用`&`分隔）用`=`分隔的参数名和参数值。例如`/file?q=2`定义了一个值为`2`的*查询参数*`q`。当我们提交[HTML 表单](http://www.w3.org/TR/html401/interact/forms.html)或者像 Google 搜索那样调用应用时用的很多。

HTTP URL 最后的*片段*指向的不是整个 HTML 页面，而是这个文件的特定部分。当你点击一个链接并且浏览器自动向下滚动来显示页面顶部看不到的部分时，你就是点击了一个带有*片段*的 URL。

### URL 语法

*http*URL 协议首次在[RFC1738](http://tools.ietf.org/html/rfc1738)（实际上甚至在[RFC1630](http://tools.ietf.org/html/rfc1630)之前）中定义，尽管后来没有重新定义*http*URL 协议，但整个 URL 语法已经从[扩展](http://tools.ietf.org/html/rfc2396)了[几次](http://tools.ietf.org/html/rfc2732)的[规范](http://tools.ietf.org/html/rfc1808)中概括为*统一资源标识符*（URI），以适应演变。

其中有一个语法定义了 URL 如何组成并且每个部分如何分隔。例如，`://`分隔了*协议*和*主机*部分；*主机*和*路径段*部分用`/`分隔；*查询*部分跟在`?`后面。这意味着某些字符是被语法*保留*的，有的为所有 URI 保留，有的只为特定的协议保留。在不允许的部分使用的所有*保留*字符（例如一个*路径段*——假设是一个文件名——包含了`?`字符）必须被*URL 编码*。

URL 编码是将字符（`?`）转换成改字符的无害表示，在 URL 中没有语法意义。通过用一个特定的[字符编码](http://en.wikipedia.org/wiki/Character_encoding)转换这个字符成一个字节序列来完成，然后用`%`开头的十六进制写入这些字节。因此问号在 URL 编码中为`%3F`。

我们可以写一个指向`to_be_or_not_to_be?.jpg`图片的 URL：`http://example.com/to_be_or_not_to_be%3F.jpg`来确保没有人会认为这里面可能有一个*查询*部分。

现在大多数浏览器先通过解码（将*百分比编码*的字节转换回原始的字符）来*显示*URL，同时为网络获取 URL 时能保持编码。这意味着用户几乎意识不到这样的这样的编码。

另一方面，开发者或者网页作者又不得不意识到它，因为有许多的陷阱在里面。

## URL 的常见陷阱

如果你正在使用 URL，那么了解一些你应该避免的最常见的陷阱是值得的。这里我们给出不完整的清单。

### 哪种字符编码？

URL 编码没有为百分比编码字节定义任何特定的字符编码。通常[ASCII](http://en.wikipedia.org/wiki/ASCII)字母数字字符允许不转义，但是对于保留字符和哪些不存在于 ASCII 的字符（例如法语单词`nœud`中的`œ`，读作`knot`），我们不得不搞清楚什么时候用什么编码来转换成百分比编码字节。

当然，如果只有[Unicode](http://en.wikipedia.org/wiki/Unicode)世界会更简单，因为**每个**字符都在这个集合中，但是这是[一个集合](http://en.wikipedia.org/wiki/Universal_Character_Set)，也可以说是个列表，而不是编码本身。

Unicode 可以用几种如[UTF-8](http://en.wikipedia.org/wiki/UTF-8)或者[UTF-16](http://en.wikipedia.org/wiki/UTF-16/UCS-2)（还有其他几种）的编码方式来编码，但是问题仍然存在：URL（通常是 URI）应该用哪种编码呢？

标准中没有定义一个 URI 可能指定用来的编码的任何方式，所以不得不从周围的信息中推导出来。对于 HTTP URL 可以是 HTML 的页面编码，或者 HTTP 头。这样通常令人迷惑且引发了很多错误。事实上，[最新版 URI 标准](http://tools.ietf.org/html/rfc3986)定义了新的 URI 方案使用[UTF-8](https://jira.lunatech.com/jira/browse/UTF-8)，并且*主机名称*（即时是现有方案）也使用这种编码，这引起了我的怀疑：*主机名*和*路径*部分真的可以用不同的编码吗？

### 每个部分的保留字符都不同

没错！没错！没错！（没错！）

对于 HTTP URL，在*路径段*部分一个空格必须编码成`%20`（绝对不是`+`），尽管这个**在路径段中**`+`字符可以不用编码。

现在在*查询*部分，空格可以编码成`+`（为了向后兼容：不要尝试在 URI 标准中查询）或者`%20`，而`+`字符（因为有歧义）必须被转义成`%2B`。

这意味着字符串`blue+light blue`必须在*路径*和*查询*部分进行不同编码：`http://example.com/blue+light%20blue?blue%2Blight+blue`。从这可以推断，没有 URL 语法结构的意识，是不可能编码一个完整结构的 URL。

假设下面 Java 代码构造一个 URL：

```java
String str = "blue+light blue";
String url = "http://example.com/" + str + "?" + str;
```

编码 URL 不是为了转义那些超出保留集的字符的简单迭代：我们必须知道我们想要编码的每个部分用的哪个保留集。

这意味着大多数 URL 重写过滤器，决定将 URL 子字符串从一个*部分*带入另一部分而不注意适当的编码，将是错误的。不了解 URL 特定的部分是不可能编码一个 URL 的。

### 保留字符不是你想的那样

大多数人忽略`+`是允许在*路径*部分的，并且特指加号而不是一个空格。还有其他惊喜：

- `?`在*查询*部分允许不被转义；
- `/`在*查询*部分允许不被转义；
- `=`在*路径*部分或者*查询参数*值以及*路径段*任何位置允许不被转义；
- `:@-.~!$&'()*+,;=`在*路径段*部分任何位置允许不被转义；
- `/?:@-.~!$&'()*+,;=`在*片段*部分任何位置允许不被转义。

尽管这有点疯狂，但`http://example.com/:@-.!$&'()+,=;:@-.!$&'()+,=:@-.!$&'()+,==?/?:@-.!$'()+,;=/?:@-.!$'()+,;==#/?:@-.!$&'()+,;=`是一个合法的 HTTP URL，这就是标准。

出于好奇，前面的 URL 扩展为：
｜ 部分 ｜ 数据 ｜
| ----: | ----: |
｜ 协议 ｜ http ｜
｜ 主机 ｜ example.com ｜
｜ 路径 ｜ /:@-._~!$&'()\*+,= ｜
｜ 路径参数名 ｜ :@-._~!$&'()*+, ｜
｜ 路径参数值 ｜ :@-._~!$&'()_+,== ｜
｜ 查询参数名 ｜ /?:@-.\_~!$'()_ ,; ｜
｜ 查询参数值 ｜ /?:@-._~!$'()\* ,;== ｜
｜ 片段 ｜ /?:@-._~!$&'()\*+,;= ｜

真疯狂。

### 解码后无法分析 URL

URL 的语法只在 URL 编码**之前**有意义：URL 解码之后，保留字符可能出现。

例如`http://example.com/blue%2Fred%3Fand+green`解码前有下面部分：
｜ 部分 ｜ 数据 ｜
| ----: | ----: |
｜ 协议 ｜ http ｜
｜ 主机 ｜ example.com ｜
｜ 路径段 ｜ blue%2Fred%3Fand+green ｜
｜ 被解码的路径段 ｜ blue/red?and+green ｜

因此，我们查找的是一个叫`blue/red?and+green`的文件，**不是**`blue`文件夹下的`red?and+green`文件。

如果我们在分析前解码`http://example.com/blue%2Fred%3Fand+green`，将给到这样的部分：
｜ 部分 ｜ 数据 ｜
| ----: | ----: |
｜ 协议 ｜ http ｜
｜ 主机 ｜ example.com ｜
｜ 路径段 ｜ blue ｜
｜ 路径段 ｜ red ｜
｜ 查询参数名 ｜ and+green ｜

这很明显是错的：分析保留字符和 URL 的部分必须在 URL 编码前完成。这意味着 URL 重写过滤器不应该尝试在匹配 URL 之前对其进行解码，**前提**是允许对保留字符进行 URL 编码（取决于你的应用）。

### 解码后的 URL 不能重新编码成同样的形式

如果你把`http://example.com/blue%2Fred%3Fand+green`解码成`http://example.com/blue/red?and+green`，然后继续编码（即使使用知道 URL 每个部分语法的编码器）你将得到`http://example.com/blue/red?and+green`，因为是一个合法的 URL。它和我们解码的原始 URL 完全不同。

## 用 Java 正确处理 URL

当你已经掌握了*URL-fu*的黑带时，你会发现当涉及 URL 时，仍然有相当多的 Java 特有陷阱。通往正确的 URL 处理之路不适合胆小的人。

### 不要对整个 URL 用`java.net.URLEncoder`或`java.net.URLDecoder`

我们没有开玩笑。这些类不是用来编码或解码 URL 的，因为他们的 API 文档[清晰地写着](http://download.java.net/jdk7/docs/api/java/net/URLEncoder.html)：

> 为 HTML 表单编码的工具类。这个类包含转换一个字符串到`application/x-www-form-urlencoded`MIME 格式的静态方法。关于 HTML 表单编码的更多信息，参阅 HTML 规范。

这与 URL 无关。充其量是类似*查询*部分的编码。使用它来编码或解码整个 URL 是错误的。你会认为标准的 JDK 有一个标准的类来正确的处理 URL 编码（即每个部分的），但是没有，或者我们没有找到它，这导致了很多人为了错误的目的来使用`URLEncoder`。

### 没有编码 URL 每个部分不要构建 URL

正如我们已经声明的：完整构建的 URL 不能被 URL 编码。

例如下面的案例：

```java
String pathSegment = "a/b?c";
String url = "http://example.com/" + pathSegment;
```

如果`a/b?c`意思是一个*路径段*，是不可能从`http://example.com/a/b?c`转换回本身的样子的，因为是它一个合法的 URL。我们前面已经解释过了。

这是正确的代码：

```java
String pathSegment = "a/b?c";
String url = "http://example.com/"
            + URLUtils.encodePathSegment(pathSegment);
```

现在我们使用工具类`URLUtils`，因为没有尽快在网上找到一个详细的可用类，我们不得不自己组装它。前面的代码将给你正确的被编码 URL`http://example.com/a%2Fb%3Fc`。

注意这同样出现在查询字符串：

```java
String value = "a&b==c";
String url = "http://example.com/?query=" + value;
```

这将给你一个合法 URL`http://example.com/?query=a&b==c`，但不是我们想要的`http://example.com/?query=a%26b==c`

### 不要指望[URI.getPath()](<http://download.java.net/jdk7/docs/api/java/net/URI.html#getPath()>)给你结构化数据

因为一旦一个 URL 已经被解码，语法信息就被丢失，下面的代码是错误的：

```java
URI uri = new URI("http://example.com/a%2Fb%3Fc");
for(String pathSegment : uri.getPath().split("/"))
  System.err.println(pathSegment);
```

它将先将路径`a%2Fb%3Fc`解码为`a/b?c`，然后拆分到不应该被拆分到*路径段*部分。

正确的代码当然是使用[未解码路径](<http://download.java.net/jdk7/docs/api/java/net/URI.html#getRawPath()>)：

```java
URI uri = new URI("http://example.com/a%2Fb%3Fc");

for(String pathSegment : uri.getRawPath().split("/"))
  System.err.println(URLUtils.decodePathSegment(pathSegment));
```

注意路径参数仍然存在：如果需要的话请处理他们。

### 不要指望 Apache Commons HTTPClient 的`URI`类能做到

[Apache Commons HTTPClient 3](http://hc.apache.org/httpclient-3.x/)的[`URI`](http://hc.apache.org/httpclient-3.x/apidocs/org/apache/commons/httpclient/URI.html)类使用[Apache Commons Code](http://commons.apache.org/codec/)的`URLCodec`来 URL 编码，正如他们[API 文档](http://commons.apache.org/codec/api-release/org/apache/commons/codec/net/URLCodec.html)提到的，这和使用`java.net.URLEncoder`一样是错误的。不仅因为它使用错误的编码器，而且对每个部分解码，就好像[他们有一样的保留集](http://svn.apache.org/repos/asf/httpcomponents/oac.hc3x/trunk/src/java/org/apache/commons/httpclient/URI.java)

## 修复 Web 应用中各级的 URL 编码

最近我们不得不在应用中修复了不少 URL 编码问题。从对 Java 的支持，到较低级别的 URL 重写。我们将在这里列出几个需要的修改：

### 始终在构建 URL 时为他们编码

在我们的 HTML 文件中，我们替换了所有出现的这个：

```js
var url = "#{vl:encodeURL(contextPath + '/view/' + resource.name)}";
```

改用：

```js
var url = "#{contextPath}/view/#{vl:encodeURLPathSegment(resource.name)}";
```

查询参数也是这样。

### 确保你的 URL 重写过滤器正确处理 URL

[Url Rewrite Filter](http://tuckey.org/urlrewrite/)是我们在[Seam](http://www.seamframework.org/)中使用的 URL 重写过滤器，用于将漂亮的 URL 转换为依赖于应用程序的 URL。

例如，我们用它来重写`http://beta.visiblelogistics.com/view/resource/FOO/bar`成`http://beta.visiblelogistics.com/resources/details.seam?owner=FOO&name=bar`。**显然**这涉及到把 URL 一些字符串从一个部分带到两一个部分，意味着我们不得不从*路径段*部分解码，并且作为*查询值*部分来重新编码

我们的初始规则看起来如下：

```html
<urlrewrite decode-using="utf-8">
  <rule>
    <from>^/view/resource/(.*)/(.*)$</from>
    <to encode="false">/resources/details.seam?owner=$1&name=$2</to>
  </rule>
</urlrewrite>
```

事实证明，只有两种方式处理 Url Rewrite Filter 的 URL 编码：

（未完，有空再说）

## 结论

我们希望澄清一些 URL 误区和常见错误。除了澄清它们之外，要明确的是，它并不像一些人认为的那样简单。我们已经说明了 Java 中的常见错误，以及 web 应用程序部署的整个链。现在每个人都是 URL 专家，我们希望再也不要看到相关的 bug。请 SUN，请**逐步**增加对 URL 编码/解码的标准支持。
