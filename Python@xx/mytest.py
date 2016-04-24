import super_tiny_compiler as c

program = "(add 2 (substract 4 2))"
program = "(add 2 3)(subtract 3 4)"
#print c.compiler(program))

#my_program = "(multiple 2(add 9 9))(substract 1(add 2 3))"

tokens = c.tokenizer(program)
print(tokens)

ast = c.parser(tokens)
#print(ast)
#print(' AST ======================= ')

new_ast = c.transformer(ast)
#print(new_ast)
#print(ast)

output = c.codeGenerator(new_ast)
print(output)
