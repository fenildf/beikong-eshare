# -*- coding: utf-8 -*-
defpack 3 do
  User.create!(:login    => 'admin',
               :name     => '系统管理员',
               :password => '1234',
               :role     => :admin)
  User.create!(:login    => 'manager',
               :name     => '教学管理员',
               :password => '1234',
               :role     => :manager)
end