# -*- coding: utf-8 -*-
defpack 4 do
  User.create!(:login    => 'admin',
               :name     => '系统管理员',
               :password => '1234',
               :role     => :admin)
  User.create!(:login    => 'manager',
               :name     => 'manager',
               :password => '1234',
               :role     => :manager)
end