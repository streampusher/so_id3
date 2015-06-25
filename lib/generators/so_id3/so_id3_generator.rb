require 'rails/generators/active_record'

class SoId3Generator < ActiveRecord::Generators::Base
  desc "Create a migration to add id3 tag specific fields to your model. " +
       "The NAME argument is the name of your model."

  argument :mp3_file_names, :required => true, :type => :array, :desc => "The names of the mp3 file name column(s) to add tags to.",
           :banner => "mp3_file_name_one mp3_file_name_two mp3_file_name_three ..."

  def self.source_root
    @source_root ||= File.expand_path('../templates', __FILE__)
  end

  def generate_migration
    migration_template "so_id3_migration.rb.erb", "db/migrate/#{migration_file_name}"
  end

  def migration_name
    "add_id3_tags_to_#{mp3_file_names.join("_")}_to_#{name.underscore.pluralize}"
  end

  def migration_file_name
    "#{migration_name}.rb"
  end

  def migration_class_name
    migration_name.camelize
  end
end
