require './errors'
module Sapphire
    class Parser
        attr_accessor :lexer,:tokens
        def initialize(lexer=nil)
            @lexer = lexer
            @tokens = []
        end
        def string(str)
            if not str.class == String then
                raise Sapphire::ParserError, "Parser.string expects a string, not type " + str.class.to_s
            end
            if check(@lexer) then
                #puts "Starting to lex string #{str}"
                @tokens = @lexer.tokenize_string(str)
            end
        end
        def check(l)
            if not l then
                raise Sapphire::ParserError.new, "Lexer is nil"
            end
            return true
        end
    end
end