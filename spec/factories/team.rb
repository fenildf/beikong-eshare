FactoryGirl.define do
  factory :team do
    sequence(:name) {|n| "name_n"}

    teacher_user
  end
end