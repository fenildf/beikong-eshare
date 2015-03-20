defpack 2 do
  User.create!(:login    => 'admin',
               :name     => '系统管理员',
               :password => '1234',
               :role     => :admin)
end