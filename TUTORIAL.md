# Basic Student ORM

This lab involves building a basic ORM for a Student object.

## Objectives
* Understand what an Object Relational Mapper(ORM) is
* Gain ability to implement characteristics of an ORM when using a relational database management system (RDBMS) in a ruby program

#### What is ORM?
An ORM is an Object Relational Mapper. An ORM is basically a class that acts as an analogy for how instances of Objects in an object-oriented program correspond to rows in a database; that is it wraps the functionality of the database into our class.


## RSpec Test 1: `#attributes`


```ruby
Student
  mapping instance attributes
    to rows in student table
      the attributes (id, name, tagline, github username, twitter handle, blog_url, image_url, biography) of each student instance corresponds to the rows in the student table (FAILED - 1)

Failures:
  1) Student mapping instance attributes to rows in student table
      the attributes (id, name, tagline, github username, twitter handle,
      blog_url, image_url, biography) of each student instance corresponds to
      the rows in the student table

     Failure/Error: avi.id = attributes[:id]
     NoMethodError:
       undefined method `id=' for #<Student:0x007f8db27110f0>
     # ./spec/student_spec.rb:20:in `block (4 levels) in <top (required)>'
```

The NoMethodError `undefined method id= for #<Student:0x007f8db27110f0>` hints at the fact that we are going to need to define getters and setters for each attribute that is going to be defined on our Student Object.

Lets' solve the first error by defining a getter and setter for the id attribute

```
class Student

  def id=(some_integer)
    @id = some_integer
  end

  def id
    @id
  end
end

```
If we run `RSpec --f-f` now we will get an error that is similar to the one above except for the fact that this time we are missing a setter method for the name attribute

```
Student
  mapping instance attributes
    to rows in student table
      the attributes (id, name, tagline, github username, twitter handle, blog_url, image_url, biography) of each student instance corresponds to the rows in the student table (FAILED - 1)

Failures:
  1) Student mapping instance attributes to rows in student table
      the attributes (id, name, tagline, github username, twitter handle,
      blog_url, image_url, biography) of each student instance corresponds to
      the rows in the student table

     Failure/Error: avi.name = attributes[:name]
     NoMethodError:
      undefined method `name=' for #<Student:0x007fdaf402cca0>
     # ./spec/student_spec.rb:22:in `block (4 levels) in <top (required)>'

```
If we want to, we could go ahead and write out getters and setters for each attribute. An easier solution would be to apply the class marco `attr_accessor` to each attribute

```
class Student
  attr_accessor :id, :name, :tagline, :github, :twitter, :blog_url, :image_url, :biography
end
```


## RSpec Test 2: `::create_table`

```
Student
  ::create_table
     creates a student table (FAILED - 1)

Failures:

  1) Student::create_table creates a student table
     Failure/Error: Student.create_table
     NoMethodError:
       undefined method `create_table' for Student:Class
     # ./spec/student_spec.rb:46:in `block (3 levels) in <top (required)>'

```
To solve the NoMethodError `undefined method 'create_table' for Student:Class`. This class method needs to create a student table in our database. Do you remember the sql command to run when you need to create a table? Look it up if you don't.


```
  class Student
    attr_accessor :name, :id, :tagline, :blog_url, :twitter, :image_url, :biography, :github

    def self.create_table
      sql = "CREATE TABLE students
        (
          id INTEGER primary key autoincrement,
          name TEXT,
          tagline TEXT,
          blog_url TEXT,
          twiiter TEXT,
          image_url TEXT,
          biography TEXT,
        github TEXT
       )"
     DB[:conn].execute(sql)
    end

  end
```
Unfortunately the above won't pass the test. Can you guess why?

> Because although we have the correct SQL command, we haven't executed the correct SQL command in our student database.

Take a look at line 4 in `school-domain-with-db/config/environment` and notice that Line 4 is where we establish a connection with a sqlite Relational Database Management System.  To connect to this database in our `create_table` class method, we simply need to reference the `DB` constant and the `:conn` key. So basically `DB[:conn]` represents our applications' connection to the database.

Next we need to execute the SQL command within the context of that database connection.  Sqlite3 has an `execute` method that accepts a string argument, which will be the string version of the SQL command we first wrote down. Our new `create_table` class method should now look like this:

```
  def self.create_table
    sql = "CREATE TABLE students
    (
      id INTEGER primary key autoincrement,
      name TEXT,
      tagline TEXT,
      blog_url TEXT,
      twiiter TEXT,
      image_url TEXT,
      biography TEXT,
      github TEXT
      )"
    DB[:conn].execute(sql)
  end
```

## RSpec Test 3: `::drop_table`

```
Student
  ::drop_table
     drops the student table (FAILED - 1)

Failures
  1) Student::drop_table drops the student table
     Failure/Error: Student.drop_table
     NoMethodError:
       undefined method `drop_table' for Student:Class
     # ./spec/student_spec.rb:55:in `block (3 levels) in <top (required)>'

```

To pass this test, we need to write a `drop_table` class method that will drop the student table.

```ruby
 def self.drop_table
     sql = "DROP TABLE students"
    DB[:conn].execute(sql)
  end
```

## RSpec Test 4: `#inserts`

```
Student
  #inserts
     inserts the student into the database (FAILED - 1)

Failures:
  1) Student#insert inserts the student into the database
     Failure/Error: avi.insert
     NoMethodError:
       undefined method `insert' for #<Student:0x007fb44947db28>
     # ./spec/student_spec.rb:73:in `block (3 levels) in <top (required)>'

```

This time we need to define an instance method called `inserts` that will insert a new student instance into the student database.  To get this test to pass, we will write out a string verstion of the SQL command for insert into, establish a connection to our application database and execute the sql command.

```ruby
  def insert
    sql = "INSERT INTO students
    (name, tagline, blog_url, twitter, image_url, biography, github)
     VALUES (?, ?, ?, ?, ?, ?, ?)
     "
     DB[:conn].execute(sql, self.name, self.tagline, self.blog_url, self.twitter, self.image_url, self.biography, self.github)
  end

```

We update our codebase and run `rspec --f-f`. Did the test pass? Yes **BUT** we get another error:

```ruby
Student
  #inserts
     inserts the student into the database
     updates the current instance with the ID of the student from the database (FAILED - 1)

Failures:

  1) Student#insert updates the current instance with the ID of the student from the database
     Failure/Error: expect(avi.id).to eq(1)

       expected: 1
            got: nil

       (compared using ==)
     # ./spec/student_spec.rb:93:in `block (3 levels) in <top (required)>'


```

the above error lets us know what the method `inserts`, in addition to inserting the new student instance (and its associated attributes) into the database, needs to also make sure to update the inserted student instance with the ID assigned to it.
> take away: method `insert` is performing two actions

At this point, the question we should be asking is: What SQL command/query would return the last row in the students table?

Thankfully, Sqlite has a [last_insert_rowid()](https://www.sqlite.org/c3ref/last_insert_rowid.html) function that returns the rowid of the most recent successful INSERT into a rowid table.

> A rowid is simply an integer key that uniquely identifies the row within its table. All rows in SQLite tables have a rowid. Read more about rowid [here](https://www.sqlite.org/lang_createtable.html#rowid).

Once we have the rowid of the most recent successful INSERT into a rowid table, we need to set that rowid to equal the id of the inserted student instance. See if you can figure out how to do this on your own before looking at the solution. Using pry will help you insert the result of excuting `last_insert_rowid()` SQL function.

```ruby
  def insert
    sql = "INSERT INTO students
     (name, tagline, blog_url, twitter, image_url, biography, github)
     VALUES (?, ?, ?, ?, ?, ?, ?)
    "
    DB[:conn].execute(sql, self.name, self.tagline, self.blog_url, self.twitter, self.image_url, self.biography, self.github)
    sql = "SELECT last_insert_rowid() FROM students"
   self.id = DB[:conn].execute(sql).flatten.first if self.id == nil
  end
```


## RSpec Test 5: `::new_from_db`

```ruby
Student
::new_from_db
    creates an instance with corresponding attribute values (FAILED - 1)

Failures:
  1) Student::new_from_db creates an instance with corresponding attribute values
     Failure/Error: avi = Student.new_from_db(row)
     NoMethodError:
       undefined method `new_from_db' for Student:Class
     # ./spec/student_spec.rb:100:in `block (3 levels) in <top (required)>'


```

Can you tell error if this error pertains to a class method or an instance method error?  Can you write down in plain english what this method is trying to accomplish?  See if you can answer both of these question before reading the next paragraph.

PAUSE
HAVE YOU TRIED THINKING THROUGH THE QUESTIONS ABOVE?

Okay then, lets move on.
The first step is to define a class method that accepts an argument (a row from the database).

```ruby
  def self.new_from_db(row_from_db)
  end
```

The next error we get:

```ruby
Student
::new_from_db
    creates an instance with corresponding attribute values (FAILED - 1)

Failures:

  1) Student::new_from_db creates an instance with corresponding attribute values
     Failure/Error: expect(avi.id).to eq(row[0])
     NoMethodError:
       undefined method `id' for nil:NilClass
     # ./spec/student_spec.rb:102:in `block (3 levels) in <top (required)>'


```
in addition to the test for `::new_from_db` in `spec/student_spec.rb`:

```ruby
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
```

lets us know that our `::new_from_db` method is expected to turn a row from our SQlite database into a student object; that is it builds a student object using the student's data inserted into the DB.

> **The critical thing to keep in mind is that you need to:**
> - instantiate a new student instance (think of how you would do this - what method in ruby handles the instantiation of a new object?)
> - and then set the value of each student instance attribute to its corresponding value in `row__from__db`

There are many ways to do this but we are going to use a method called [`tap`](http://ruby-doc.org/core-2.2.2/Object.html#method-i-tap).

 > How does method `tap` work?
 `tap` yields `self` to the block. When self is yielded to the block, the code in the block runs/is carried out - for example, in our case one of the things we want to do is set the yielded id of self (`self.id`) to row[0].  Self will continued to be yielded to the block untill all the attributes of the new instance object have been matched to their corresponding row values.

To get a better understanding of how this works, we are going to use `pry gem` to inspect what happens when we use tap.

```ruby
  def self.new_from_db(row_from_db)
    binding.pry
      # what does row_from_db look like?
        row_from_db
      => [1,
        "Avi",
        "Teacher",
        "aviflombaum",
        "aviflombaum",
        "http://aviflombaum.com",
        "http://aviflombaum.com/picture.jpg"]

          # How do you grab the value of id in row?
          # What about the rest of attributes?
      end
    end

```

Once we have a good idea of what `row_from_db` looks like we can take a look at what the newly instantiated student object looks like.

```ruby
  def self.new_from_db(row_from_db)
    self.new.tap do |new_student_instance|
    binding.pry
      # what is new_student_instance?
      # what is the return value when you call id on it?
      # how can you set the value of self.id equal to id in row__from__db?
    end
  end
```

 Try to step into the method using the code samples provided above. Play with it and see if you can answer the questions before taking a look at the solution below.

 Our final solution for `::new_from_db` should look something like what is below:
 > Keep in mind that the solution below is just one way (out of other possibles) of defining our method.

```ruby
def self.new_from_db(row)
  self.new.tap do |new_student_instance|
    new_student_instance.id = row[0]
    new_student_instance.name = row[1]
    new_student_instance.tagline = row[2]
    new_student_instance.twitter = row[3]
    new_student_instance.blog_url = row[4]
    new_student_instance.image_url = row[5]
    new_student_instance.biography = row[6]
  end
end
```

## RSpec Test 6: `::find_by_name`

```ruby
Student
::find_by_name
    returns an instance of student that matches the name from the DB (FAILED - 1)

Failures:

  1) Student::find_by_name returns an instance of student that matches the name from the DB
     Failure/Error: avi_from_db = Student.find_by_name("Avi")
     NoMethodError:
       undefined method `find_by_name' for Student:Class
     # ./spec/student_spec.rb:126:in `block (3 levels) in <top (required)>'


```

Can you tell error if this error pertains to a class method or an instance method error?  Can you write down in plain english what this method is trying to accomplish?  See if you can answer both of these question before reading the next paragraph.

PAUSE
HAVE YOU TRIED THINKING THROUGH THE QUESTIONS ABOVE?

Okay then, lets move on.
The first step is to define a class method that accepts an argument, which is string.

```ruby
  def self.find_by_name(student_name)
  end
```
if we run `rspec --f-f` at this point, we get the error below:

```ruby
Failures:

  1) Student::find_by_name returns an instance of student that matches the name from the DB
     Failure/Error: expect(avi_from_db.name).to eq("Avi")
     NoMethodError:
       undefined method `name' for nil:NilClass
     # ./spec/student_spec.rb:127:in `block (3 levels) in <top (required)>'

```

which lets us know that `::find_by_name` is supposed to return from the application SQLite database an instance of student that matches the name of the student passed to the method.

Here I want a SQL command that queries the application database for a student with a particualr name, finds that student and returns a student that matches

The correct SQL command for this query is: `SELECT * from students WHERE name = ?;`. Our method should look something like this:

```ruby
  def self.find_by_name(student_name)
    sql = "SELECT * FROM students WHERE name = ?;"
    DB[:conn].execute(sql, student_name)
  end
```

The above code won't pass the test. Can you guess why? If you are having a difficult time figuring out why, use `pry` gem to step into the method.

> Questions to consider:
> - Since we want to return an instance, can we leverage `::new_from_db`
> - what happens if the name isn't found? How do you want to deal with this edge case?

When you are ready, compare your code with the code below:

```ruby
  def self.find_by_name(student_name)
    sql = "SELECT * FROM students WHERE name = ?"

    row = DB[:conn].execute(sql, student_name).flatten
    !row.empty? ? new_from_db(row) : nil
  end
```

## RSpec Test 7: `#update`
```ruby
Student
#update
  updates and persists a student in the database (FAILED - 1)

Failures:
  1) Student#update updates and persists a student in the database
     Failure/Error: avi.update
     NoMethodError:
       undefined method `update' for #<Student:0x007fa82d16cee8 @id=1, @name="Bob">
     # ./spec/student_spec.rb:141:in `block (3 levels) in <top (required)>'

```

- Is the above error a class method or an instance method error?
- Can you write down in plain english what this method is trying to accomplish?

See if you can answer both of these question before reading the next paragraph.

PAUSE
HAVE YOU TRIED THINKING THROUGH THE QUESTIONS ABOVE?

Okay then, lets move on.
As usual, we first define the method:

```ruby
  def update
  end
```

run `rspec --f-f` to find out what error (if any) we get next.

```ruby
Student
#update
  updates and persists a student in the database (FAILED - 1)

Failures:
  1) Student#update updates and persists a student in the database
     Failure/Error: expect(avi_from_db).to be_nil
       expected: nil
            got: #<Student:0x007fe36d8859c0 @id=nil, @name="Avi", @tagline=nil, @github=nil, @twitter=nil, @blog_url=nil, @image_url=nil, @biography=nil>
     # ./spec/student_spec.rb:144:in `block (3 levels) in <top (required)>'
```

Looking at the above error, it appears that the `update` method takes an existing instance of the student class and updates their record in the application DB.

> Questions to consider:
> - which attributes of a student instance is our `#update` method updating? Take a look at the spec file to see if you can figure it out.
> - If you can't figure it out by looking at the spec_file, place a binding.pry inside the method and call self to see what the value of self is; the return value of self should give you an idea of what attribute(s) you need to update in this method
> - What SQL command can we use to update a student record?
> - what happens if a student with the attributes being queried is not found? How do you want to deal with this edge case?
> - see if you can refactor update to handle all attributes (not just the attribute the test tests for).


See if you can answer the question before taking a look at the solution eading the next paragraph.

PAUSE
HAVE YOU TRIED THINKING THROUGH THE QUESTIONS ABOVE?

```ruby
   def update
    sql = "UPDATE students SET name = ?, tagline = ?, github = ?, twitter = ?, blog_url = ?, image_url = ?, biography = ? WHERE id = ?;"
    DB[:conn].execute(sql, self.name, self.tagline, self.github, self.twitter, self.blog_url, self.image_url, self.biography, self.id)
  end
```

## RSpec Test 8: `#save`
```ruby
Student
#save
  chooses the right thing on first save (FAILED - 1)

Failures:
  1) Student#save chooses the right thing on first save
     Failure/Error: avi.save
     NoMethodError:
       undefined method `save' for #<Student:0x007ff754ff2000 @name="Avi">
     # ./spec/student_spec.rb:159:in `block (3 levels) in <top (required)>'

```
- Is the above error a class method or an instance method error?
- Can you write down in plain english what this method is trying to accomplish?

See if you can answer both of these question before reading the next paragraph.

**PAUSE**
**HAVE YOU TRIED THINKING THROUGH THE QUESTIONS ABOVE?**

Okay then, lets move on.

As usual, we first define the method:

```ruby
  def save
  end
```

and then run `rspec --f-f` to find out what error (if any) we get next.

```ruby
Student
#save
  chooses the right thing on first save (FAILED - 1)

Failures:
  1) Student#save chooses the right thing on first save
     Failure/Error: expect(avi).to receive(:insert)
       (#<Student:0x007ffa9a167410>).insert(*(any args))
           expected: 1 time with any arguments
           received: 0 times with any arguments
     # ./spec/student_spec.rb:158:in `block (3 levels) in <top (required)>'
```

Looking at the above error, it appears that the `save` method expects the student object to receive the `inserts` method - that is we expect self to receive the `insert` method. Our updated code should look something like this:

```ruby
  def save
    self.inserts
  end
```
we run `rspec --f-f` to find out what error (if any) we get next. And we do get an error:

```ruby
Student
  #save
    chooses the right thing on first save
    chooses the right thing for all others (FAILED - 1)

Failures:
  1) Student#save chooses the right thing for all others
     Failure/Error: expect(avi).to receive(:update)
       (#<Student:0x007f95211586b0>).update(*(any args))
           expected: 1 time with any arguments
           received: 0 times with any arguments
     # ./spec/student_spec.rb:168:in `block (3 levels) in <top (required)>'
```

The above error indicates that `save` method expects to the student object to receive `update` method - that is we expect to call `update` on self. Again we update our code

```ruby
  def save
    self.inserts
    self.update
  end
```

and run `rspec --f-f` to find out what error (if any) we get next.

And tada!

```ruby
Student
  attributes
    instance
      has an id, name, tagline, github username, twitter handle, blog_url, image_url, biography
.  ::create_table
    creates a student table
.  ::drop_table
    drops the student table
.  #insert
    inserts the student into the database
.    updates the current instance with the ID of the student from the database
.  ::new_from_db
    creates an instance with corresponding attribute values
.  ::find_by_name
    returns an instance of student that matches the name from the DB
.  #update
    updates and persists a student in the database
.  #save
    chooses the right thing on first save
.    chooses the right thing for all others
.

Finished in 0.02457 seconds (files took 1.03 seconds to load)
10 examples, 0 failures

```

**PASSING TESTS!!!**

That feels good, doesn't it?

If you want to, take a break (you have earned it).  When you return, you should take a stab at working on the bonus section of the lab.
