require 'minitest/spec'
require 'minitest/autorun'
require './lexer'
test_string = %Q[   (procedure my-proc (x,y) returns (number) do {
	return x + y 
})
]
test_ids = %Q[ id1   id_2
   *id-5]
test_assignment = %Q[ *my-id_ 
        = 
        -1,258.9]
describe Sapphire::Lexer do
    it "lexer instance" do
        Sapphire::Lexer.new.must_be_instance_of Sapphire::Lexer
    end
    it "should allow you to set a string to lexer when instantiating" do
        Sapphire::Lexer.new(test_string).string.must_equal test_string
    end
    it "should allow you to change the string" do
        lex = Sapphire::Lexer.new(test_string)
        lex.string = " hello world "
        lex.string.must_equal " hello world "
    end
    it "should consume whitespace correctly" do
        lex = Sapphire::Lexer.new(test_string)
        lex.string = " hello world "
        lex.consume_whitespace
        lex.pos.must_equal 1
    end
    it "should consume newlines as well" do
        lex = Sapphire::Lexer.new(test_string)
        lex.string = "\nhello world "
        lex.consume_whitespace
        lex.pos.must_equal 1
        lex.line.must_equal 2
    end
    it "should handle rn newlines as well" do
        lex = Sapphire::Lexer.new(test_string)
        lex.string = "\r\nhello world "
        lex.consume_whitespace
        lex.pos.must_equal 2
        lex.line.must_equal 2
    end
    it "should return id tokens" do
        lex = Sapphire::Lexer.new(test_string)
        lex.string = test_ids
        lex.monsters << Sapphire::Monster.new("Ids",:id, "()[]{} \n",nil)
        t1 = lex.next
        t2 = lex.next
        t3 = lex.next 
        t4 = lex.next
        t1.class.must_equal Sapphire::Token
        t1.pos.must_equal 1
        t1.string.must_equal "id1"

        t2.class.must_equal Sapphire::Token
        t2.pos.must_equal 7
        t2.string.must_equal "id_2"

        t3.class.must_equal Sapphire::Token
        t3.pos.must_equal 15
        t3.string.must_equal "*id-5"

        t4.class.must_equal NilClass
    end
    it "should return tokens of different types" do
        lex = Sapphire::Lexer.new(test_string)
        lex.string = test_assignment
        lex.monsters << Sapphire::Monster.new("Numbers",:number, "1234567890.,+-",true,"+-1234567890","1234567890")
        lex.monsters << Sapphire::Monster.new("Ops",:assign, "=",true)
        lex.monsters << Sapphire::Monster.new("Ids",:id, "()[]{} \n",nil)
        t1 = lex.next
        t2 = lex.next
        t3 = lex.next 
        t4 = lex.next
        [t1,t2,t3].each {|t| t.class.must_equal Sapphire::Token }
        t1.string.must_equal "*my-id_"
        t4.class.must_equal NilClass
        t3.string.must_equal "-1,258.9"
    end
    it "should return tokens of different types as an array" do
        lex = Sapphire::Lexer.new(test_string)
        lex.monsters << Sapphire::Monster.new("Numbers",:number, "1234567890.,+-",true,"+-1234567890","1234567890")
        lex.monsters << Sapphire::Monster.new("Ops",:assign, "=",true)
        lex.monsters << Sapphire::Monster.new("Ids",:id, "()[]{} \n",nil)
        tokens = lex.tokenize_string test_assignment
        tokens.each {|t| t.class.must_equal Sapphire::Token }
    end
    it "should raise an error if monsters is empty" do
        lex = Sapphire::Lexer.new(test_string)
        assert_raises Sapphire::LexerError do
                lex.next
        end
    end
end