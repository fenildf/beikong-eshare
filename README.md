
beikong-eshare inhouse 定制
==============

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




### 开发环境初始化

```
apt-get install libmysqlclient-dev
bundle

rake db:create
rake db:migrate
```

```
启动 redis , 必须使用工程里的 ./deploy/sh/solr_server.sh start
如果系统已经有 redis 进程需要先 stop

启动 solr , 必须使用工程里的 ./deploy/sh/solr_server.sh start
同时需要一个 solr-server 文件，放置于 solr 的 example/bin 目录下，并把 bin 目录添加到 PATH. 文件内容见： http://markdown.4ye.me/EsEPcMDc/1
```

```
初始化用户 
rails r script/import.rb
```