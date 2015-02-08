require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject

  def self.columns
    rows = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL

    @columns = rows[0].map(&:to_sym)
  end

  def self.finalize!

    columns.each do |name|
      define_method(name) do
        self.attributes[name]
      end
      define_method("#{name}=") do |arg|
        self.attributes[name] = arg
      end
    end
  end

  def self.table_name=(table_name)
    @title = table_name
  end

  def self.table_name
    if @title.nil?
      @title = self.to_s.tableize
    end
    @title

  end

  def self.all
    results = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{@title}
    SQL

    self.parse_all(results)
  end

  def self.parse_all(results)
    converted = []

    results.each do |convert|
      converted << self.new(convert)
    end

    converted
  end

  def self.find(id)
    results = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{@title}
      WHERE
        id = #{id}
    SQL

    if results.length >= 1
      found = self.parse_all(results)
      found[0]
    else
      nil
    end

  end

  def initialize(params = {})
    params.each do |k, v|
      if self.class.columns.include?(k.to_sym)
        self.send("#{k}=", v)
      else
        raise "unknown attribute '#{k}'"
      end
    end
  end

  def attributes
    @attributes ||= {}

  end

  def attribute_values
    @attributes.values
  end

  def attribute_keys
    @attributes.keys
  end

  def insert
    question_marks = (['?'] * @attributes.length).join(', ')
    col_names = attribute_keys.join(', ')

    DBConnection.execute(<<-SQL, *self.attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL

    self.id= DBConnection.last_insert_row_id
  end

  def update
    col_setters = attribute_keys.join(' = ?, ') + '= ?'
    DBConnection.execute(<<-SQL, *self.attribute_values)
      UPDATE
        #{self.class.table_name}
      SET
        #{col_setters}
      WHERE
        id = #{self.id}
    SQL
  end

  def save
    if id.nil?
      insert
    else
      update
    end
  end

end
