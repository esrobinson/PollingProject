class Response < ActiveRecord::Base
  attr_accessible :user_id, :answer_choice_id

  validates :user_id, :answer_choice_id, :presence => true
  validate :respondent_has_not_already_answered_question
  validate :pollster_has_not_answered_question

  belongs_to(
    :answer_choice,
    :primary_key => :id,
    :foreign_key => :answer_choice_id,
    :class_name => "AnswerChoice"
  )

  belongs_to(
    :respondent,
    :primary_key => :id,
    :foreign_key => :user_id,
    :class_name => "User"
  )

  def existing_responses_by_user
    Response.find_by_sql(<<-SQL, :a => self.user_id, :b => self.answer_choice_id)
      SELECT
        responses.*
      FROM
        responses
      JOIN
        answer_choices ON responses.answer_choice_id = answer_choices.id
      WHERE
        responses.user_id = :a AND answer_choices.question_id = (
          SELECT
            answer_choices.question_id
          FROM
            answer_choices
          WHERE
            answer_choices.id = :b
          )
    SQL

  end

  def respondent_has_not_already_answered_question
    user_responses = existing_responses_by_user
    return if user_responses.empty? || (user_responses[0].id == self.id &&
    user_responses.count == 1)
    errors[:user] << "has already answered question"
  end

  def pollster_has_not_answered_question
    author_id = AnswerChoice
                .joins(:question)
                .joins(:poll)
                .where("answer_choices.id = ?", self.answer_choice_id)
                .select("polls.author_id")

    return unless author_id = self.user_id
    errors[:user] << "cast this poll and may not respond to it"
  end
end