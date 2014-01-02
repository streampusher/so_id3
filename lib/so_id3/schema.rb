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
      ActiveRecord::ConnectionAdapters::TableDefinition.send :include, TableDefinition
    end
    module TableDefinition
      def add_i3_tags(column_name)
        COLUMNS.each_pair do |column, column_type|
          column "#{column_name}_#{column}", column_type
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, SoId3::Schema
