# -*- coding: utf-8 -*-
defpack 2, :depends => [1] do
  teachers = User.with_role :teacher
  students = User.with_role :student


  course_names = %w{NOI信息学竞赛训练 科学发明创新 物理实验 物理竞赛训练 趣味化学}
  course_teachers = teachers[0..4]
  # 创建五个课程
  p "创建五个课程"
  courses = []
  course_names.each_with_index do |name,index|
    arr = %w{一 二 三 四 五}
    course = Course.create(
      :name => name, 
      :cid => randstr, 
      :creator => course_teachers[index], 
      :approve_status => 'YES',
      :least_user_count => 5,
      :most_user_count => 20,
      :time => "9:00",
      :lesson_hour => 16,
      :credit => 3,
      :location => "第#{arr[index]}教学楼"
    )
    courses << course
  end

  team_1_teacher = teachers[5]
  team_2_teacher = teachers[6]
  team_1_students = students[0..9]
  team_2_students = students[10..19]

  p "创建两个班级"

  group_tree_node = GroupTreeNode.create(
                      :name => 'ZHANGSAN',
                      :kind => GroupTreeNode::TEACHER,
                      :parent_id => nil,
                      :manage_user => team_1_teacher.first
                    )
  team_1_students.each do |user|
    group_tree_node.add_user(user)
  end

  group_tree_node = GroupTreeNode.create(
                      :name => 'LISI',
                      :kind => GroupTreeNode::TEACHER,
                      :parent_id => nil,
                      :manage_user => team_2_teacher.first
                    )
  team_2_students.each do |user|
    group_tree_node.add_user(user)
  end

  has_intent_users = team_1_students[0..4] + team_2_students[5..9]

  p "10 个 随机选择随机选择志愿"

  has_intent_users.each do |user|
    first_index = rand(5)
    second_index = (first_index+1)%5
    third_index = (first_index+2)%5

    user.set_select_course_intent(:first, courses[first_index])
    user.set_select_course_intent(:second, courses[second_index])
    user.set_select_course_intent(:third, courses[third_index])
  end
end
