require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through = self.class.assoc_options[through_name]
      source = through.model_class.assoc_options[source_name]

      through_primary = through.primary_key
      through_foreign = through.foreign_key
      source_primary = source.primary_key
      source_foreign = source.foreign_key

      through_name = through.table_name
      source_name = source.table_name

      filter = self.send(through_foreign)

      results = DBConnection.execute(<<-SQL, filter)
      SELECT
        #{source_name}.*
      FROM
        #{through_name} JOIN #{source_name}
        ON #{through_name}.#{source_foreign} = #{source_name}.#{source_primary}
      WHERE
        #{through_name}.#{through_primary} = ?
      SQL

      source.model_class.parse_all(results).first
    end
  end
end
