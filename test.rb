#!/usr/bin/env ruby

require 'parslet'

class MiniP < Parslet::Parser
  # Single character rules
  rule(:space)      { match('\s').repeat(1) }
  rule(:space?)     { space.maybe }

  rule(:lparen)     { str('(') >> space? }
  rule(:rparen)     { str(')') >> space? }
  # Things
  rule(:quote)      { str("'") }
  #rule(:stringend)  { match["[^']"].repeat >> nonword}
  rule(:integer)    { match('[0-9]').repeat(1).as(:int) }
  rule(:operator)   { str("eq").as(:op) >> space? }
  rule(:logicalop)  { (str("and") | str("or")).as(:logical) >> space? }
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
  rule(:clause)   { (term >> (logicalop >> term.as(:rhs)).repeat.maybe).as(:c) }
  root(:clause)
end

IntLit = Struct.new(:int) do
  def eval; int.to_i; end
end
Addition = Struct.new(:left, :right) do
  def eval; left.eval + right.eval; end
end
FunCall = Struct.new(:name, :args) do
  def eval; p args.map { |s| s.eval }; end
end
Comparison = Struct.new(:id,:op,:lit) do
end
BooleanOp = Struct.new(:op,:rhs) do
end

class MiniT < Parslet::Transform
  rule(:string => simple(:string) ) { String.new(string)}
  rule(:int => simple(:int) ) { Integer(int)}

  rule( :id => simple(:id),
        :op => simple(:op),
        :lit => simple(:lit) )      {Comparison.new(id,op,lit)}
  
  rule( :logical => simple(:op),
         :rhs => simple(:rhs))  { BooleanOp.new(op,rhs)}

end


require 'pp'
def parse(str)
  mini = MiniP.new
  transf = MiniT.new

  transf.apply(
    mini.parse(str)
  )
rescue Parslet::ParseFailed => failure
  puts failure.parse_failure_cause.ascii_tree
end



q = "(InvoiceID eq '67520098-b424-4108-98ca-9aa431e4654a/V0005' 
  or InvoiceID eq '67520098-b424-4108-98ca-9aa431e4654a/V0004' 
  or InvoiceID eq '67520098-b424-4108-98ca-9aa431e4654a/V0003' 
  or (InvoiceID eq '67520098-b424-4108-98ca-9aa431e4654a/V0002' 
  and InvoiceID eq '67520098-b424-4108-98ca-9aa431e4654a/V0001'))"

  s=[ "a",
    "(a)",
    "( b )",
    "( ( a ))",
  "a or b",
  "a or (b)",
  "( a or b )",
  "(a) and (b)",
  "a or b or c",
  "(a or b ) and ((c or d) and e)"]


  r = "InvoiceID eq '67520098-b424-4108-98ca-9aa431e4654a/V0005' or X eq 4"
pp parse(q)

# s.each do |w|
#   pp parse(w)
# end


