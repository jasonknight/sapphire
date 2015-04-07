require './errors'
require './sexp'
module Sapphire
    class Parser
        attr_accessor :lexer,:tokens, :tree
        def initialize(lexer=nil)
            @lexer = lexer
            @tokens = []
            @validators = []
            install_default_sapphire_validators
        end
        def install_default_sapphire_validators

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
        def create_tree
            @tree = parse_tree(@tokens)
        end
        def parse_tree(tkns)
            pos = 0
            open_parens = 0
            open_brackets = 0
            open_braces = 0
            sexp_count = 0
            if tkns[pos].real_type == :lparen then
                pos += 1
                open_parens += 1
                root = Sapphire::SEXP.new(tkns[0])
                sexp_count += 1
            else
                throw ParserError, "Root element must be Parenthesis ("
            end
            nodes = []
            c_root = root
            while pos < tkns.length do
                token = tkns[pos]
                case token.real_type
                when :lparen
                    open_parens += 1
                    node = Sapphire::SEXP.new(token)
                    sexp_count += 1
                    c_root.append(node)
                    nodes.push c_root
                    c_root = node
                when :rparen
                    open_parens -= 1
                    c_root = nodes.pop
                    if c_root.nil? then
                        c_root = root
                    end
                when :lbrace
                    open_braces += 1
                    c_root.append(token)
                when :rbrace 
                    open_braces -= 1
                    c_root.append(token)
                when :lbracket
                    open_brackets += 1
                    c_root.append(token)
                when :rbracket
                    open_brackets -= 1
                    c_root.append(token)
                else
                    c_root.append(token)
                end
                pos += 1
            end    
            @tree = c_root  
            if open_parens > 0 then
                throw ParserError, "Unmatched Parenthesis ( at end of tokens"
            end
            if open_braces > 0 then
                throw ParserError, "Unmatched Brace { at end of tokens"
            end
            if open_brackets > 0 then
                throw ParserError, "Unmatched Bracket [ at end of tokens"
            end

            return @tree      
        end
        def pretty_print_tree(t,pad=0)
            if t.class == Sapphire::SEXP then
                print "\t" * pad
                puts t.to_s + " ("
                pretty_print_tree(t.children, pad + 1)
            else
                t.each do |c|
                    if c.class == Sapphire::SEXP then
                        pretty_print_tree(c, pad + 1)
                    else
                        print "\t" * pad
                        puts c.to_s
                    end
                end
                print "\t" * pad
                puts ")"
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