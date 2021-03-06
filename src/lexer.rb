require 'yaml'
require './errors'
module Sapphire
	class Lexer
		attr_accessor :pos,
		  :tokens,
		  :monsters,
		  :string,
		  :line,
		  :white_space_seen

		def initialize(string="")
			@tokens = []
			@monsters = []
			@string = string
			@pos = 0
			@line = 1
			@white_space_seen = 0
		end
		def next
			return nil if @pos >= @string.length
			if @monsters.empty? then
				raise Sapphire::LexerError, "you must specify at least one token monster"
			end
			consume_whitespace
			@monsters.each do |mon|
				res = mon.consume(@string,@pos)
				if res[0].class == Sapphire::Token
					@pos = res[1]
					return res[0]
				else
					next
				end
			end
		end
		def consume_whitespace
			c = @string[ @pos ]
			return if c.nil?
			if c.match(/\n/) then
				@line += 1
				@pos += 1
				consume_whitespace
			elsif c.match(/\r/) then
				if @string[ @pos + 1 ] == "\n" then
					@pos += 1
				end
				@line += 1
				@pos += 1
				consume_whitespace
			elsif c.match(/\s/) then
				@white_space_seen += 1
				@pos += 1
				consume_whitespace
			end
		end
		def tokenize_string(str)
			@pos = 0
			@string = str
			tokens = []
			while token = self.next do
				token.line = self.line
				token.file = "StringInput(#{@string.length})"
				tokens << token
			end
			return tokens
		end
		def show_state
			puts YAML.dump(self)
		end
	end
end

