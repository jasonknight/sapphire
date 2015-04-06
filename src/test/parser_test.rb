require 'minitest/spec'
require 'minitest/autorun'
require './lexer'
require './parser'
require './errors'
example_saf = ""
File.open("./test/example.saf", "r") do |f|
    example_saf = f.read
end
describe Sapphire::Parser do
    it "should start with a nil lexer" do
        p = Sapphire::Parser.new
        p.lexer.must_equal nil
    end
    it "should allow you to set a parser" do
        l = Sapphire::Lexer.new
        p = Sapphire::Parser.new(l)
        p.lexer.must_equal l
        l2 = Sapphire::Lexer.new
        p.lexer = l2
        p.lexer.must_equal l2
    end
    it "should raise an error when lexer is nil" do
        p = Sapphire::Parser.new
        assert_raises Sapphire::ParserError do
            p.string("")
        end
    end
    it "should raise an error if you pass Parser.string anything other than a String" do
        p = Sapphire::Parser.new
        assert_raises Sapphire::ParserError do
            p.string({})
        end
    end
    it "should parse the example file into tokens" do
        lex = Sapphire::Lexer.new
        p = Sapphire::Parser.new(lex)
        
        num_mon = Sapphire::Monster.new("Numbers",:number, "1234567890.,+-",true,"+-1234567890","1234567890")
        num_mon.validator = lambda do |buffer,stream,pos|
            if buffer == "+" or buffer == "-" then
                return false
            else
                return true
            end
        end
        lex.monsters << num_mon
        lex.monsters << Sapphire::Monster.new("Assign",:assign, "=",true)

        paren_matcher = Sapphire::Monster.new("Paren",:paren, "()[]{}",true)
        paren_matcher.match_times = 1
        lex.monsters << paren_matcher
        [:function,:return,:do,:returns].each do |kw|
            lex.monsters << Sapphire::Monster.new("Keyword_#{kw}", kw, "", true, kw.to_s, kw.to_s)
        end
        
        lex.monsters << Sapphire::Monster.new("Ids",:id, "()[]{}.,/ \n",nil)
        p.string(example_saf)
        p.tokens.each do |tkn|
            puts tkn.inspect
           tkn.class.must_equal Sapphire::Token
        end
        tkn_order = [:paren,:function,:id,:paren,:id,:id,:paren,:returns, :paren,:id,:paren,:do,:paren, :paren,:return, :paren, :id, :id, :id,
            :paren, :paren, :paren, :paren, :paren, :id, :number, :number, :paren]
        tkn_order.each do |tkn_sym|
            i = tkn_order.index tkn_sym
            p.tokens[i].type.must_equal tkn_sym
        end

    end
end