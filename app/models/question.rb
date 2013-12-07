class Question < ActiveRecord::Base
  attr_accessible :text, :poll_id

  belongs_to(
    :poll,
    :primary_key => :id,
    :foreign_key => :poll_id,
    :class_name => "Poll"
  )

  has_many(
  :answer_choices,
  :primary_key => :id,
  :foreign_key => :question_id,
  :class_name => "AnswerChoice"
  )

  def results
    result_array = AnswerChoice.find_by_sql([<<-SQL, :id => self.id])
      SELECT
        answer_choices.*, COUNT(responses.id) AS response_count
      FROM
        answer_choices
      LEFT OUTER JOIN
        responses ON answer_choices.id = responses.answer_choice_id
      WHERE
        answer_choices.question_id = :id
      GROUP BY
        answer_choices.id
      SQL
    p result_array
    counts = Hash.new(0)
    result_array.each do |result|
      counts[result.text] = result.response_count
    end
    counts
  end

end

