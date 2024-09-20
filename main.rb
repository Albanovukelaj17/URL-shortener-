require 'securerandom'
require 'yaml'

name = "Ayanokoji"
zahl= 17

def greet(name)
    puts "welcome #{name}"
end

greet(name)

class Person
    def initialize(name,age)
        @name= name
        @age= age 
    end
     
    def introduce
        puts "Heloo, here is #{name}, he is #{age} old"
    end
end

person = new Person("Axi",17)
person.introduce
