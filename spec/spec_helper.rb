require_relative '../config/environment'
DB[:conn] = SQLite3::Database.new ":memory:"

RSpec.configure do |config|
  # Use color not only in STDOUT but also in pagers and files
  config.tty = true

  # Use the specified formatter
  config.formatter = :progress # :progress, :html, :textmate

  #you can do global before/after here like this:
  config.before(:each) do
    if Student.respond_to?(:create_table)
      Student.create_table
    else
      DB[:conn].execute("DROP TABLE IF EXISTS students")
      DB[:conn].execute("CREATE TABLE IF NOT EXISTS students (id INTEGER PRIMARY KEY, name TEXT, tagline TEXT, github TEXT, twitter TEXT, blog_url TEXT, image_url TEXT, biography TEXT)")
    end
  end

  config.after(:each) do
      DB[:conn].execute("DROP TABLE IF EXISTS students")
  end
end
