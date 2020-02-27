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
  rule(:logicalop)   { (str("and") | str("or")).as(:logical) >> space? }
  rule(:identifier) { match('\w').as(:id) >> space? }
  rule(:string) {
    quote >> (
      str('\\') >> any | quote.absent? >> any
    ).repeat.as(:string) >> quote
  }
  
  # Grammar parts
  # rule(:expr)         {(identifier >> operator >> literal).as(:expr) >> space?}
  # rule(:parenexpr)    { (lparen >> commonexpr >> rparen ).as(:group)  >> space?}
  # rule(:commonexpr)   { expr | logexpr | parenexpr}
  # rule(:logexpr)      { (logicalop >> expr).repeat }
  # rule(:literal)    { string | integer }
  # #rule(:query) { expr >> (logexpr.maybe)}
  # rule(:query){ commonexpr}
  # root :query
  rule(:clause) { (term.as(:lhs) >> (logicalop >> term.as(:rhs)).repeat.maybe) }
  rule(:term) { ( lparen >> clause >> rparen) | identifier }
  root(:clause)
end

require 'pp'
def parse(str)
  mini = MiniP.new

  mini.parse(str)
rescue Parslet::ParseFailed => failure
  puts failure.parse_failure_cause.ascii_tree
end
q = "(InvoiceID eq '67520098-b424-4108-98ca-9aa431e4654a/V0005' 
 or InvoiceID eq '67520098-b424-4108-98ca-9aa431e4654a/V0004' 
   or InvoiceID eq '67520098-b424-4108-98ca-9aa431e4654a/V0003' 
  or InvoiceID eq '67520098-b424-4108-98ca-9aa431e4654a/V0002' 
  or InvoiceID eq '67520098-b424-4108-98ca-9aa431e4654a/V0001')"

  s=[ "a",
    "(a)",
    "( b )",
    "( ( a ))",
  "a or b",
  "a or (b)",
  "( a or b )",
  "(a) and (b)",
  "a or b or c"]

  s.each do |w|
pp parse(w)
  end


