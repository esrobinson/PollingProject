class User < ActiveRecord::Base
  attr_accessible :user_name

  validates :user_name, :presence => true, :uniqueness => true

  has_many(
    :responses,
    :primary_key => :id,
    :foreign_key => :user_id,
    :class_name => "Response"
  )

  has_many(
  :authored_polls,
  :primary_key => :id,
  :foreign_key => :author_id,
  :class_name => "Poll"
  )

#   has_many(:chosen_answers, :though => :responses, :source => :answer_choice)
#   has_many(:answered_questions,
#            :through => :chosen_answers,
#            :source => :question)
#   has_many(:answered_polls, :through => :answered_questions, :source => :poll)

  def completed_polls
    Poll.find_by_sql([<<-SQL, self.id])
      SELECT
        polls.*
      FROM
        responses
      JOIN
        answer_choices ON responses.answer_choice_id = answer_choices.id
      RIGHT JOIN
        questions ON answer_choices.question_id = questions.id
      JOIN
        polls ON questions.poll_id = polls.id
      WHERE
        responses.user_id = ?  OR responses.user_id IS NULL
      GROUP BY
        polls.id
      HAVING
        COUNT(*) = COUNT(answer_choices.id)
    SQL
  end

end
