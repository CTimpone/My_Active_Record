require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_columns = params.keys.join(' = ? AND ') + ' = ?'

    if self.class == Class
      cls = self
    else
      cls = self.class
    end

    results = DBConnection.execute(<<-SQL, *params.values)
      SELECT
        *
      FROM
        #{cls.table_name}
      WHERE
        #{where_columns}
    SQL

    cls.parse_all(results)
  end
end

class SQLObject
  extend Searchable
end
