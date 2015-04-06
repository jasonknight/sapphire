require 'minitest/spec'
require 'minitest/autorun'
require './monster'
require './token'
multi_line_comment = %Q[/* this
is a
multi_line_comment
*/]

quoted_string = %Q["this is a quoted string"]
quoted_string_with_esc = %Q["this is \\065 \\nquoted string"]
describe Sapphire::Monster do
    it "should require only a name" do
        mon = Sapphire::Monster.new("Mon")
        mon.name.must_equal "Mon"
    end
    it "should have no validator if a block wasn't passed in" do
        mon = Sapphire::Monster.new("Mon")
        mon.validator.must_equal nil
    end
    it "should accept a block and set that as the validator" do
        mon = Sapphire::Monster.new("Mon") do |stream,token|

        end
        mon.validator.class.must_equal Proc
    end 
    it "should have a try lambda set" do
        mon = Sapphire::Monster.new("Mon")
        mon.try.class.must_equal Proc
    end
    it "should allow you to swap out the try lambda" do
        mon = Sapphire::Monster.new("Mon")
        old_try = mon.try
        res = (mon.try == old_try)
        res.must_equal true
        mon.try = lambda { return "yo" }
        res = (mon.try == old_try)
        res.must_equal false
    end
    it "should parse tokens from a string" do
        mon = Sapphire::Monster.new("Mon", :id, "abc")
        res = mon.consume("cab",0)
        res.class.must_equal Array
        res[0].class.must_equal Sapphire::Token
        res[0].type.must_equal :id
    end
    it "should parse c-style comments" do
        mon = Sapphire::Monster.new("Mon", :comment, "",nil,"/*","*/")
        res = mon.consume("/* hello, this is a comment */ ",0)
        res.class.must_equal Array
        res[0].class.must_equal Sapphire::Token
        res[0].type.must_equal :comment
    end
    it "should parse multi-line c-style comments" do
        mon = Sapphire::Monster.new("Mon", :comment, "",nil,"/*","*/")
        res = mon.consume(multi_line_comment,0)
        res.class.must_equal Array
        res[0].class.must_equal Sapphire::Token
        res[0].type.must_equal :comment
    end
    it "should not parse a weird c-style comment" do
        mon = Sapphire::Monster.new("Mon", :comment, "",nil,"/*","*/")
        res = mon.consume("/ * this is a bad comment */",0)
        res.class.must_equal Array
        res[0].class.must_equal NilClass
        res = mon.consume("*/ this is a bad comment */",0)
        res.class.must_equal Array
        res[0].class.must_equal NilClass
    end
    it "should parse double quoted strings" do
        mon = Sapphire::Monster.new("Mon", :string, "",nil,"\"","\"")
        res = mon.consume(quoted_string,0)
        res.class.must_equal Array
        res[0].class.must_equal Sapphire::Token
        res[0].type.must_equal :string
    end
    it "should support character escape sequences in strings" do
        mon = Sapphire::Monster.new("Mon", :string, "",nil,"\"","\"")
        mon.esc = "\\"
        res = mon.consume(quoted_string_with_esc,0)
        res.class.must_equal Array
        res[0].class.must_equal Sapphire::Token
        res[0].type.must_equal :string
        res[0].string.include?("this is A \nquoted").must_equal true
    end
    it "should support match_times, i.e. only match 1 or 3 etc" do
        mon = Sapphire::Monster.new("Mon", :paren, "(){}[]",true)
        mon.match_times = 1
        res1 = mon.consume("(((",0)
        res2 = mon.consume("(((",res1[1])
        res3 = mon.consume("(((",res2[1])
        [res1,res2,res2].each do |r|
            r[0].class.must_equal Sapphire::Token
            r[0].type.must_equal :paren
        end
    end

end