# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


ActiveRecord::Base.transaction do

  User.create!(:user_name => "eric")

  Poll.create!(:title => "Poll 1", :author_id => 1)

  Question.create!(:text => "Question 1?", :poll_id => 1)

  AnswerChoice.create!(:text => "Choice 1", :question_id => 1)

  Response.create!(:answer_choice_id => 1, :user_id => 1)

end