require 'sqlite3'
require 'singleton'

class QuestionDB < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class User
  attr_accessor :fname, :lname
  attr_reader :id

  def self.find_by_id(id)
    data = QuestionDB.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL

    return nil if data.empty?

    User.new(data.first)
  end

  def self.find_by_name(fname, lname)
    data = QuestionDB.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL

    return "User not found" if data.empty?

    User.new(data.first)
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def authored_questions
    questions = Question.find_by_user_id(@id)
    # questions.each { |question| puts question.body }
  end

  def authored_replies
    replies = Reply.find_by_user_id(@id)
    # replies.each { |reply| puts reply.body  }
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end
end

class Question
  attr_accessor :title, :body, :user_id
  attr_reader :id

  def self.find_by_id(id)
    data = QuestionDB.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL

    return nil if data.empty?

    Question.new(data.first)
  end

  def self.find_by_user_id(user_id)
    data = QuestionDB.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        questions
      WHERE
        user_id = ?
    SQL

    return nil if data.empty?

    if data.length == 1
      Question.new(data.first)
    else
      data.map {|datum| Question.new(datum)}
    end
  end

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @user_id = options['user_id']
  end

  def author
    user = User.find_by_id(@user_id)
    "#{user.fname} #{user.lname}"
  end

  def replies
    Reply.find_by_question_id(@id)
  end

  def followers
    QuestionFollow.followers_for_question_id(@id)
  end
end

class Reply
  attr_accessor :question_id, :body, :parent_id, :user_id
  attr_reader :id

  def self.find_by_id(id)
    data = QuestionDB.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL

    return nil if data.empty?

    Reply.new(data.first)
  end

  def self.find_by_user_id(user_id)
    data = QuestionDB.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL

    return nil if data.empty?

    if data.length == 1
      Reply.new(data.first)
    else
      data.map { |datum| Reply.new(datum) }
    end
  end

  def self.find_by_question_id(question_id)
    data = QuestionDB.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL

    return nil if data.empty?

    if data.length == 1
      Reply.new(data.first)
    else
      data.map { |datum| Reply.new(datum) }
    end
  end

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @body = options['body']
    @parent_id = options['parent_id']
    @user_id = options['user_id']
  end

  def author
    User.find_by_id(@user_id)
  end

  def question
    Question.find_by_id(@question_id)
  end

  def parent_reply
    return "has no parents" if @parent_id.nil?
    parent = Reply.find_by_id(@parent_id)
  end

  def child_replies
    children = Reply.find_by_question_id(@question_id)
    children.find { |child| child.id > @id }
  end
end

class QuestionFollow
  attr_accessor :user_id, :question_id

  def self.followers_for_question_id(question_id)
    data = QuestionDB.instance.execute(<<-SQL, question_id)
      SELECT
        users.*
      FROM
        users
      JOIN
        question_follows ON question_follows.user_id = users.id
      WHERE
        question_follows.question_id = ?
    SQL

    return nil if data.empty?

    data.map { |datum| User.new(datum) }
  end

  def self.followed_questions_for_user_id(user_id)
    data = QuestionDB.instance.execute(<<-SQL, user_id)
      SELECT
        questions.*
      FROM
        questions
      JOIN
        question_follows ON question_follows.question_id = questions.id
      WHERE
        question_follows.user_id = ?
    SQL

    return nil if data.empty?

    data.map { |datum| Question.new(datum) }
  end

  def self.most_followed_questions(n)
    data = QuestionDB.instance.execute(<<-SQL, n)
      SELECT
        questions.*, COUNT(question_follows.user_id) AS Count
        -- questions.*, COUNT(question_follows.user_id) AS Count
      FROM
        questions
      JOIN
        question_follows ON question_follows.question_id = questions.id
      GROUP BY
        question_id
      ORDER BY
        COUNT(question_follows.user_id) DESC
      LIMIT
        ?
    SQL

    return nil if data.empty?

    puts "The most followed question is #{data.first['title']} with #{data.first['Count']} followers"
    data.map { |datum| Question.new(datum) }
  end
end
