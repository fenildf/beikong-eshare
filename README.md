# eshare

[![Build Status](https://travis-ci.org/mindpin/eshare.png?branch=master)](https://travis-ci.org/mindpin/eshare)
[![Code Climate](https://codeclimate.com/github/mindpin/eshare.png)](https://codeclimate.com/github/mindpin/eshare)
[![Coverage Status](https://coveralls.io/repos/mindpin/eshare/badge.png?branch=master)](https://coveralls.io/r/mindpin/eshare)

## Requirements
* Ruby 2.0
* Mysql 5.0+
* ImageMagick 6.5+
* Libpng
* Redis 2.2+

## 参考

请开发者参考

[Rails 3 风格指南](https://github.com/ruby-china/rails-style-guide/blob/master/README-zhCN.md)

[Ruby 风格指南](https://github.com/ruby-china/ruby-style-guide/blob/master/README-zhCN.md)

[rspec + capybara BDD 测试驱动开发入门](http://ruby-china.org/topics/7770)

## Dependencies
### roles-field
https://github.com/mindpin/roles-field

用于实现简单的角色逻辑

[![Gem Version](https://badge.fury.io/rb/roles-field.png)](http://badge.fury.io/rb/roles-field)
[![Build Status](https://travis-ci.org/mindpin/roles-field.png?branch=master)](https://travis-ci.org/mindpin/roles-field)
[![Code Climate](https://codeclimate.com/github/mindpin/roles-field.png)](https://codeclimate.com/github/mindpin/roles-field)

### simple-navbar

https://github.com/mindpin/simple-navbar

用于实现导航菜单配置

[![Code Climate](https://codeclimate.com/github/mindpin/simple-navbar.png)](https://codeclimate.com/github/mindpin/simple-navbar)

### simple-page-layout

https://github.com/mindpin/simple-page-layout

用于简化 view layouts 的编写

[![Gem Version](https://badge.fury.io/rb/simple-page-layout.png)](http://badge.fury.io/rb/simple-page-layout)


## 开发环境初始化

### 下载安装 solr-server
```
cd /usr/local
wget http://60.247.110.148/static_files/solr-server.tar
tar xf solr-server.tar
# 把 /usr/local/solr-server/bin 设置到 PATH 变量,保证可以直接运行 solr-server 命令
```

### 配置好 redis-server
安装 redis 并设置好 PATH 变量，保证可以直接运行 redis-server 命令


### 工程初始化数据库
```
bundle

rake db:create
rake db:migrate
```

### 启动依赖服务
```
启动 redis , 必须使用工程里的 ./deploy/sh/solr_server.sh start
如果系统已经有 redis 进程需要先 stop

启动 solr , 必须使用工程里的 ./deploy/sh/solr_server.sh start
```

### 初始化数据
```
初始化用户 
rails r script/import.rb
```

### 启动工程
```
rails s
```


