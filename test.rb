#!/usr/bin/env ruby

require 'parslet'
require 'pp'

class MiniP < Parslet::Parser
  # Single character rules
  rule(:space)      { match('\s').repeat(1) }
  rule(:space?)     { space.maybe }

  rule(:lparen)     { str('(') >> space? }
  rule(:rparen)     { str(')') >> space? }
  # Things
  rule(:quote)      { str("'") }
  rule(:integer)    { match('[0-9]').repeat(1).as(:int) }
  rule(:operator)   { str("eq").as(:op) >> space? }
  rule(:logicalop)  { (str("and") | str("or")).as(:bool) >> space? }
  rule(:identifier) { match('\w').repeat.as(:id) >> space? }
  rule(:string) {
    quote >> (
      str('\\') >> any | quote.absent? >> any
    ).repeat.as(:string) >> quote
  }
  
  # Grammar parts
  rule(:literal)  { (string | integer).as(:lit) }
  rule(:expr)     { (identifier >> operator >> literal) >> space? }
  rule(:term)     { (lparen >> clause >> rparen) | expr }
  rule(:clause) { infix_expression( term , [logicalop, 1, :left] )}
  root(:clause)
end


Equality = Struct.new(:id,:op,:lit) do
  def to_s
    operation = case op
    when 'eq'
      '=='
    end
    "#{id.to_s} #{operation} \"#{lit.to_s}\""
  end
end


BooleanOp = Struct.new(:lhs,:rhs) do
  def to_s
    "(#{lhs.to_s}) #{op.upcase}\n (#{rhs.to_s})"
  end
end

class AndExpr < BooleanOp
  def op
    :and
  end
end
class OrExpr < BooleanOp
  def op
    :or
  end
end



class MiniT < Parslet::Transform
  rule(:string => simple(:string) ) { String.new(string)}
  rule(:int => simple(:int) ) { Integer(int)}
  rule(:bool => simple(:string) ) { String.new(string)}
  rule(:id => simple(:string) ) { String.new(string)}
  rule(:op => simple(:string) ) { String.new(string)}

  rule( :id => simple(:id),
        :op => simple(:op),
        :lit => simple(:lit) )      {Equality.new(id,op,lit)}
  
  rule( :l => simple(:lhs),
        :o => simple(:op),
        :r => simple(:rhs))  do
          case op
          when 'and'
            AndExpr.new(lhs,rhs)
          when 'or'
            OrExpr.new(lhs,rhs)
          end
        end


end

# A parse function that applies the parser and transform

def parse(str)
  mini = MiniP.new
  transf = MiniT.new

  transf.apply(
    mini.parse(str)
  )
rescue Parslet::ParseFailed => failure
  puts failure.parse_failure_cause.ascii_tree
end


# Some examples

q = "(InvoiceID eq '67520098-b424-4108-98ca-9aa431e4654a/V0005' 
  or InvoiceID eq '67520098-b424-4108-98ca-9aa431e4654a/V0004' 
  or InvoiceID eq '67520098-b424-4108-98ca-9aa431e4654a/V0003' 
  or (InvoiceID eq '67520098-b424-4108-98ca-9aa431e4654a/V0002' 
  and SomthingElse eq 'V0002'))"

s=[ "a eq 1",
  "(a eq 2)",
  "( b eq 2)",
  "( ( a eq 2))",
"a eq 2 or b eq 2",
"a eq 2 or (b eq 2)",
"( a eq 2 or b eq 2 )",
"(a eq 2) and (b eq 2)",
"a eq 2 or b eq 2 or c eq 2",
"(a eq 2 or b eq 2 ) and ((c eq 2 or d eq 2) and e eq 2)"]


r = "InvoiceID eq '67520098-b424-4108-98ca-9aa431e4654a/V0005' "

puts '-' * 120
puts r
pp parse(r)
puts parse(r).to_s

puts '-' * 120
puts q
pp parse(q)
puts parse(q).to_s
  
s.each do |w|
  puts w
  pp parse(w)
  puts
  puts
end


