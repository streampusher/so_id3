require 'active_record'

module SoId3
  module Schema
    # pretty much copied from paperclip/schema.rb >_<
    COLUMNS = {artist: :string,
               title: :string,
               album: :string,
               year: :integer,
               track: :integer}

    def self.included(base)
      ActiveRecord::ConnectionAdapters::Table.send :include, TableDefinition
      ActiveRecord::ConnectionAdapters::TableDefinition.send :include, TableDefinition
      ActiveRecord::ConnectionAdapters::AbstractAdapter.send :include, Statements
    end
    module Statements
      def add_id3_tags table_name
        COLUMNS.each_pair do |column, column_type|
          add_column table_name, column, column_type
        end
      end

      def remove_id3_tags table_name
        COLUMNS.each_pair do |column, column_type|
          remove_column table_name, column
        end
      end
    end
    module TableDefinition
      def id3_tags
        COLUMNS.each_pair do |column, column_type|
          column column, column_type
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, SoId3::Schema
