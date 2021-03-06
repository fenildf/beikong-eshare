class SearchController < ApplicationController
  before_filter :authenticate_user!

  def search
    @query = query = params[:query]
    @course_search = Course.search { fulltext query }
    # @question_search = Question.search { fulltext query }
  end
end