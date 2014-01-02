require 'active_record'
require 'rupeepeethree'

module SoId3
  module ActiveRecord
    attr_accessor :column
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      def has_tags(opts)
        SoId3::ActiveRecord::LocalInstanceMethods.send(:define_method, :so_id3_column) do
          self.send(opts[:column].to_sym)
        end
        include SoId3::ActiveRecord::LocalInstanceMethods
      end
    end

    module LocalInstanceMethods
      def tags
        Rupeepeethree::Tagger.tags(so_id3_column)
      end
    end
  end
end

ActiveRecord::Base.send :include, SoId3::ActiveRecord
