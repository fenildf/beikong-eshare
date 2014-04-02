defpack 6 do
  Category.save_yaml(File.new("script/data/categories.yaml"))
  p "导入成功"
end