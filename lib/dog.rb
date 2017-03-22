require 'pry'

class Dog

  #attr and initialize

  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  #class methods

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT

      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE dogs
    SQL
    DB[:conn].execute(sql)

  end

  def self.create(name:, breed:, id: nil)
    new_dog = self.new(name: name, breed: breed, id: id)
    new_dog.save
    new_dog
  end

  def self.new_from_db(row)
    new_dog = self.new(name: row[1], breed: row[2], id: row[0])
    new_dog

  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
    SQL
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first

  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
      SQL
    result = DB[:conn].execute(sql, id)[0]
    Dog.new(name: result[1], breed: result[2], id: result[0])
  end

  def self.find_or_create_by(name:, breed:)
    new_dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !new_dog.empty?
      new_dog_data = new_dog[0]
      new_dog = Dog.new(name: new_dog_data[1], breed: new_dog_data[2], id: new_dog_data[0])
    else
      new_dog = self.create(name: name, breed: breed)
    end
    new_dog
  end

  #instance methods

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
    end
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end





end
