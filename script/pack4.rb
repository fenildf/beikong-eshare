# -*- coding: utf-8 -*-
require './script/makers/user_maker'

defpack 4 do
  User.create!(:login    => 'admin',
               :name     => '系统管理员',
               :password => '1234',
               :role     => :admin)
  User.create!(:login    => 'manager',
               :name     => '教学管理员',
               :password => '1234',
               :role     => :manager)
  ['teachers', 'students'].each {|yaml| UserMaker.new(yaml).produce}
end
