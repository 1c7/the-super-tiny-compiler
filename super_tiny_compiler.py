# encoding=utf8
# https://github.com/josegomezr/the-super-tiny-compiler
import re

def tokenizer(input_program):
    current = 0
    tokens = []
    program_length = len(input_program)
    REGEX_WHITESPACE = re.compile(r"\s");
    REGEX_NUMBERS = re.compile(r"[0-9]");
    REGEX_LETTERS = re.compile(r"[a-z]", re.I);
    # 预先写好空格，数字，单词的正则表达
    while current < program_length:
        char = input_program[current]
        if char == '(':
            tokens.append({
                'type': 'lparen',
                'value': '('
            })
            current = current+1
            continue
        if char == ')':
            tokens.append({
                'type': 'rparen',
                'value': ')'
            })
            current = current+1
            continue

        if re.match(REGEX_WHITESPACE, char):
            current = current+1
            continue

        if re.match(REGEX_NUMBERS, char):
            value = ''
            while re.match(REGEX_NUMBERS, char):
                value += char
                current = current+1
                char = input_program[current];

            tokens.append({
                'type': 'number',
                'value': value
            })
            continue

        if re.match(REGEX_LETTERS, char):
            value = ''
            while re.match(REGEX_LETTERS, char):
                value += char
                current = current+1
                char = input_program[current]

            tokens.append({
                'type': 'name',
                'value': value
            })

            current = current+1
            continue

        raise ValueError('I dont know what this character is: ' + char);
    return tokens
        
def parser(tokens):
    global current
    current = 0
    def walk():
        global current
        token = tokens[current]
        if token.get('type') == 'number':
            current = current + 1
            return { # return here
                'type': 'NumberLiteral',
                'value': token.get('value')
            }
        if token.get('type') == 'lparen':
            current = current + 1
            token = tokens[current]
            node = {
                'type': 'CallExpression',
                'name': token.get('value'),
                'params': []
            }

            current = current + 1
            token = tokens[current]
            while token.get('type') != 'rparen':
                node['params'].append(walk()); # recursion 
                token = tokens[current]
            current = current + 1
            return node # return here
        raise TypeError(token.get('type'))
    ast = {
        'type': 'Program',
        'body': []
    }
    token_length = len(tokens)
    while current < token_length:
        ast['body'].append(walk()) # 如果有两个并列的式子, body 里就有2个并列元素  2个并列的CallExpression
    return ast

# traverser 这部分还是有点晕
# transformer 和  traverser
# traverser 遍历，调用 visitor 的对应名字方法，没了, 根据 programe 还是 call expression 得知该用哪个属性 (body, params)
def traverser(ast, visitor):

    def traverseArray(array, parent):
        print(array)
        print('------------')
        #print()
        for child in array:
            #print(child)
            traverseNode(child, parent)
    
    def traverseNode(node, parent):
        method = visitor.get(node['type'])
        if method:
            method(node, parent)
        if node['type'] == 'Program':
            traverseArray(node['body'], node)
        elif node['type'] == 'CallExpression':
            traverseArray(node['params'], node)
        elif node['type'] == 'NumberLiteral':
            pass
        else:
            raise TypeError(node['type'])
            
    traverseNode(ast, None) # call here

def transformer(ast):
    newAst = {
        'type': 'Program',
        'body': []
    }
    ast['_context'] = newAst.get('body')

    def NumberLiteralVisitor(node, parent):
        parent['_context'].append({ #NumberLiteralVisitor 的 parent 是 CallExpressionVisitor
            'type': 'NumberLiteral',
            'value': node['value']
        })
    def CallExpressionVisitor(node, parent):
        expression = {
            'type': 'CallExpression',
            'callee': {
                'type': 'Identifier',
                'name': node['name']
            },
            'arguments': []
        }
        
        node['_context'] = expression['arguments'] # here

        if parent.get('type') != 'CallExpression':
            expression = {
                'type': 'ExpressionStatement',
                'expression': expression
            }
        parent['_context'].append(expression) # here

    traverser( ast , {
        'NumberLiteral': NumberLiteralVisitor,
        'CallExpression': CallExpressionVisitor 
    })
    
    return newAst

def codeGenerator(node):
    if node['type'] == 'Program':
        return '\n'.join([code for code in map(codeGenerator, node['body'])])
        
    elif node['type'] == 'ExpressionStatement':
        expression = codeGenerator(node['expression']) 
        return '%s;' % expression #here
        
    elif node['type'] == 'CallExpression':
        callee = codeGenerator(node['callee']) 
        params = ', '.join([code for code in map(codeGenerator, node['arguments'])])
        return "%s(%s)" % (callee, params) # here
        
    elif node['type'] == 'Identifier':
        return node['name'] #here
        
    elif node['type'] == 'NumberLiteral':
        return node['value'] #here
    else:
        raise TypeError(node['type'])

def compiler(input_program):
    tokens = tokenizer(input_program)
    ast    = parser(tokens)
    newAst = transformer(ast)
    output = codeGenerator(newAst)
    return output
    

    
