# -*- coding: utf-8 -*-
require './script/helper'
require './script/pack1'
require './script/pack2'
require './script/pack3'
require './script/pack4'

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
1.简单的清空 users 表，并不考虑数据耦合

2.创建一个系统管理员用户
  用户名：admin
  密码： 1234

3.创建一个系统管理员用户，登录名：admin
  创建一个教学管理员用户，登录名：manager
  所有用户的密码都是 1234

4.创建一个系统管理员用户，登录名：admin
  创建一个教学管理员用户，登录名：manager
  创建 30 个教师，登录名 teacher1 - teacher30
  创建 50 个学生，登录名 student1 - student50
  所有用户的密码都是 1234
==============================================

'

puts prompt

def get_choice
  print '请选择要导入的选项(1-4): '
  choice = gets.chomp.to_i
  return choice if (1..4) === choice
  get_choice
end

def run
  `mkdir -p tmp/scripts`
  choice = get_choice
  puts "准备运行选项-#{choice}......\n\n"
  send "pack#{choice}"
end

run
