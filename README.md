# parselet-odata-filter-parser

Using the parslet gem to parse OData filter parameter

This parser will parse an OData filter expression with the following caveats:
* Conditions are simple equalities ( `column_name eq string_or_integer_constant` )
* Conditions may be linked by the `and` or `or` boolean expressions
* Grouped expressions are honoured.

Given an expression like `(a eq 2 or b eq 2 ) and ((c eq 2 or d eq 2) and e eq 2)`
results in a parse tree like this:
```
#<struct AndExpr
 lhs=
  #<struct OrExpr
   lhs=#<struct Equality id="a"@1, op="eq"@3, lit=2>,
   rhs=#<struct Equality id="b"@11, op="eq"@13, lit=2>>,
 rhs=
  #<struct AndExpr
   lhs=
    #<struct OrExpr
     lhs=#<struct Equality id="c"@26, op="eq"@28, lit=2>,
     rhs=#<struct Equality id="d"@36, op="eq"@38, lit=2>>,
   rhs=#<struct Equality id="e"@48, op="eq"@50, lit=2>>>
```
