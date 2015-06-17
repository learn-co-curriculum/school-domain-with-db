require_relative 'spec_helper'

describe Student do

  context "attributes" do
    describe "instance" do
      it " has an id, name, tagline, github username, twitter handle, blog_url, image_url, biography" do

        attributes = {
          :id => 1,
          :name => "Avi",
          :tagline => "Teacher",
          :github => "aviflombaum",
          :twitter => "aviflombaum",
          :blog_url => "http://aviflombaum.com",
          :image_url => "http://aviflombaum.com/picture.jpg",
          :biography => "Programming is my favorite thing in the whole wide world."
        }

        avi = Student.new
        avi.id = attributes[:id]
        avi.name = attributes[:name]
        avi.tagline = attributes[:tagline]
        avi.github = attributes[:github]
        avi.twitter = attributes[:twitter]
        avi.blog_url = attributes[:blog_url]
        avi.image_url = attributes[:image_url]
        avi.biography = attributes[:biography]

        expect(avi.id).to eq(attributes[:id])
        expect(avi.name).to eq(attributes[:name])
        expect(avi.tagline).to eq(attributes[:tagline])
        expect(avi.github).to eq(attributes[:github])
        expect(avi.twitter).to eq(attributes[:twitter])
        expect(avi.blog_url).to eq(attributes[:blog_url])
        expect(avi.image_url).to eq(attributes[:image_url])
        expect(avi.biography).to eq(attributes[:biography])

      end
    end
  end

  describe '.create_table' do
    it 'creates a student table' do
      DB[:conn].execute('DROP TABLE IF EXISTS students')
      Student.create_table

      table_check_sql = "SELECT tbl_name FROM sqlite_master WHERE type='table' AND tbl_name='students';"
      expect(DB[:conn].execute(table_check_sql)[0]).to eq(['students'])
    end
  end

  describe '::drop_table' do
    it "drops the student table" do
      Student.drop_table

      table_check_sql = "SELECT tbl_name FROM sqlite_master WHERE type='table' AND tbl_name='students';"
      expect(DB[:conn].execute(table_check_sql)[0]).to be_nil
    end
  end

  describe '#insert' do
    it 'inserts the student into the database' do
      avi = Student.new
      avi.name = "Avi"
      avi.tagline = "Teacher"
      avi.github = "aviflombaum"
      avi.twitter = "aviflombaum"
      avi.blog_url = "http://aviflombaum.com"
      avi.image_url = "http://aviflombaum.com/picture.jpg"
      avi.biography = "aviflombaum"

      avi.insert

      select_sql = "SELECT name FROM students WHERE name = 'Avi'"
      result = DB[:conn].execute(select_sql)[0]

      expect(result[0]).to eq("Avi")
    end

    it 'updates the current instance with the ID of the student from the database' do
      avi = Student.new
      avi.name = "Avi"
      avi.tagline = "Teacher"
      avi.github = "aviflombaum"
      avi.twitter = "aviflombaum"
      avi.blog_url = "http://aviflombaum.com"
      avi.image_url = "http://aviflombaum.com/picture.jpg"
      avi.biography = "aviflombaum"

      avi.insert

      expect(avi.id).to eq(1)
    end
  end

  describe '::new_from_db' do
    it 'creates an instance with corresponding attribute values' do
      row = [1, "Avi", "Teacher", "aviflombaum", "aviflombaum", "http://aviflombaum.com", "http://aviflombaum.com/picture.jpg"]
      avi = Student.new_from_db(row)

      expect(avi.id).to eq(row[0])
      expect(avi.name).to eq(row[1])
      expect(avi.tagline).to eq(row[2])
      expect(avi.github).to eq(row[3])
      expect(avi.twitter).to eq(row[4])
      expect(avi.blog_url).to eq(row[5])
      expect(avi.image_url).to eq(row[6])
      expect(avi.biography).to eq(row[7])
    end
  end

  describe '::find_by_name' do
    it 'returns an instance of student that matches the name from the DB' do
      avi = Student.new
      avi.name = "Avi"
      avi.tagline = "Teacher"
      avi.github = "aviflombaum"
      avi.twitter = "aviflombaum"
      avi.blog_url = "http://aviflombaum.com"
      avi.image_url = "http://aviflombaum.com/picture.jpg"
      avi.biography = "aviflombaum"

      avi.insert

      avi_from_db = Student.find_by_name("Avi")
      expect(avi_from_db.name).to eq("Avi")
      expect(avi_from_db).to be_an_instance_of(Student)
    end
  end

  describe "#update" do
    it 'updates and persists a student in the database' do
      avi = Student.new
      avi.name = "Avi"
      avi.insert

      avi.name = "Bob"
      original_id = avi.id

      avi.update

      avi_from_db = Student.find_by_name("Avi")
      expect(avi_from_db).to be_nil

      bob_from_db = Student.find_by_name("Bob")
      expect(bob_from_db).to be_an_instance_of(Student)
      expect(bob_from_db.name).to eq("Bob")
      expect(bob_from_db.id).to eq(original_id)
    end
  end

  describe '#save' do
    it "chooses the right thing on first save" do
      avi = Student.new
      avi.name = "Avi"
      expect(avi).to receive(:insert)
      avi.save
    end

    it 'chooses the right thing for all others' do
      avi = Student.new
      avi.name = "Avi"
      avi.save

      avi.name = "Bob"
      expect(avi).to receive(:update)
      avi.save
    end
  end
end
