# -*- coding: utf-8 -*-
require './script/helper'
require './script/pack1'
require './script/pack2'
require './script/pack3'
require './script/pack4'
require './script/pack5'
require './script/pack6'

case ARGV[0]
when 'clear-pack-records'
  puts '删除脚本运行记录....'
  `rm -rf tmp/scripts`
  exit
when 'clear-db'
  puts '清空数据库....'
  `rake db:drop rake db:create rake db:migrate > /dev/null`
  exit
end

prompt = '
==============================================
            请选择要进行的数据操作
==============================================
1. 创建一个管理员用户，登录名：admin
   创建 30 个教师，登录名 teacher1 - teacher30
   创建 50 个学生，登录名 student1 - student50
   所有用户的密码都是 1234
2. 用于演示/调试选课功能时：
   创建若干课程，若干班级，和若干选课志愿
3. 简单的清空 users 表，并不考虑数据耦合
4. 创建一个管理员用户和一个教学管理用户
   用户名：admin, manager
   密码： 1234
5. 用于演示/调试用户分组功能时，导入的一些演示数据
   包括很多学生老师和多级分组
6. 用于演示/调试课程分类功能时，导入的一些分类数据
==============================================

'

puts prompt

def get_choice
  print '请选择要导入的选项(1-6): '
  choice = gets.chomp.to_i
  return choice if (1..6) === choice
  get_choice
end

def run
  `mkdir -p tmp/scripts`
  choice = get_choice
  puts "准备运行选项-#{choice}......\n\n"
  send "pack#{choice}"
end

run
