require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    self.class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @foreign_key = (name.to_s.downcase + '_id').to_sym
    @primary_key = :id
    @class_name = name.to_s.camelcase

    if !options.empty?
      options.each do |key, value|
        send("#{key}=", value)
      end
    end

  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key = (self_class_name.downcase.to_s + '_id').to_sym
    @primary_key = :id
    @class_name = name.to_s.camelcase.singularize

    if !options.empty?
      options.each do |key, value|
        send("#{key}=", value)
      end
    end
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name.to_s, options)
    assoc_options[name] = options
    define_method(name) do

      foreign = options.foreign_key
      primary = options.primary_key
      target = name.to_s.capitalize.constantize

      target.where({primary => self.send(foreign)}).first
    end

  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name.to_s.singularize, self.to_s, options)

    define_method(name) do

      primary = options.foreign_key
      foreign = options.primary_key
      target = name.to_s.singularize.capitalize.constantize

      target.where({primary => self.send(foreign)})
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end
end

class SQLObject
  include Searchable
  extend Associatable

end
