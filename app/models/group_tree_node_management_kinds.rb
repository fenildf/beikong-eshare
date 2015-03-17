module GroupTreeNodeManagementKinds
  module GROUP_KIND
    OTHER  = "OTHER"
    GRADE  = "GRADE"
    KCLASS = "KCLASS"

    def self.all
      [OTHER, GRADE, KCLASS]
    end
  end

  module GRADE_KIND
    OTHER  = "OTHER"
    SENIOR = "SENIOR"
    JUNIOR = "JUNIOR"

    def self.all
      [OTHER, SENIOR, JUNIOR]
    end
  end

  def self.included(base)
    base.const_set "GROUP_KIND", GROUP_KIND
    base.const_set "GRADE_KIND", GRADE_KIND
    base.send :include, InstanceMethods

    base.instance_eval do
      attr_accessible :group_kind, :grade_kind, :year

      validates :group_kind, :inclusion => {:in => GROUP_KIND.all}
      validates :group_kind, :uniqueness => {
        :scope => :manage_user_id,
        :if    => ->(node) {GROUP_KIND::KCLASS == node.group_kind}
      }

      validate do
        case group_kind
        when GROUP_KIND::OTHER
          invalid_grade_kind_and_year_for(GROUP_KIND::OTHER) do
            !grade_kind.blank? || !year.blank?
          end
        when GROUP_KIND::GRADE
          invalid_grade_kind_and_year_for(GROUP_KIND::GRADE) do
            !GRADE_KIND.all.include?(grade_kind) || year.blank?
          end
        when GROUP_KIND::KCLASS
          invalid_grade_kind_and_year_for(GROUP_KIND::KCLASS) do
            !grade_kind.blank?
          end
        end
      end

      after_move :set_year_to_parents
    end
  end

  module InstanceMethods
    def set_year_to_parents
      if parent && GROUP_KIND::GRADE == parent.group_kind &&
          GROUP_KIND::KCLASS == group_kind && grade_kind.blank?

        self.year = parent.year
      end
    end

    def invalid_grade_kind_and_year_for(group_kind, &cond)
      if instance_eval(&cond)
        errors.add(:base, "Invalid grade_kind and year combination with GROUP_KIND::#{group_kind}")
      end
    end
  end
end
