# ldd-blog
赖东东的个人博客，使用hugo搭建，even主题

## 项目结构
```
.
├── archetypes  // 原型模版
├── content  // 站点内容，每个目录作为一个section
├── data  // 存放数据 .json .yaml .toml，可以创建动态内容
├── layouts  // html模版，设置站点布局
├── static  // 静态文件 css js image
├── themes  // 主题
└── config.toml  // 配置
```

## Develop
```bash
# 默认启动http://localhost:1313/
hugo server
```

## Deploy
```bash
docker-compose up -d --build
```

## TODO
- [x] 添加侧边栏：分类列表、标签列表、最新n篇文章、相关n篇文章


