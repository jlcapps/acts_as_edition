class EditionMigrationGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.migration_template 'edition_migration.rb', 'db/migrate',
        :migration_file_name => "add_ancestor_id"
    end
  end
end
