var superTinyCompiler = require('./super-tiny-compiler');
var assert            = require('assert');

var tokenizer     = superTinyCompiler.tokenizer;
var parser        = superTinyCompiler.parser;
var transformer   = superTinyCompiler.transformer;
var codeGenerator = superTinyCompiler.codeGenerator;
var compiler      = superTinyCompiler.compiler;

var input  = '(add 2 (subtract 4 2))';
var output = 'add(2, subtract(4, 2));';

var tokens = [
  { type: 'paren',  value: '('        },  // paren 意思是括弧（parenthesis）
  { type: 'name',   value: 'add'      },
  { type: 'number', value: '2'        },
  { type: 'paren',  value: '('        },
  { type: 'name',   value: 'subtract' },
  { type: 'number', value: '4'        },
  { type: 'number', value: '2'        },
  { type: 'paren',  value: ')'        },
  { type: 'paren',  value: ')'        }
];

var ast = {       // Abstract Syntax Tree = AST = 抽象语法树
  type: 'Program',
  body: [{
    type: 'CallExpression',
    name: 'add',
    params: [{
      type: 'NumberLiteral',
      value: '2'
    }, {
      type: 'CallExpression',
      name: 'subtract',
      params: [{
        type: 'NumberLiteral',
        value: '4'
      }, {
        type: 'NumberLiteral',
        value: '2'
      }]
    }]
  }]
};

var newAst = {
  type: 'Program',
  body: [{
    type: 'ExpressionStatement',
    expression: {
      type: 'CallExpression',
      callee: {
        type: 'Identifier',
        name: 'add'
      },
      arguments: [{
        type: 'NumberLiteral',
        value: '2'
      }, {
        type: 'CallExpression',
        callee: {
          type: 'Identifier',
          name: 'subtract'
        },
        arguments: [{
          type: 'NumberLiteral',
          value: '4'
        }, {
          type: 'NumberLiteral',
          value: '2'
        }]
      }]
    }
  }]
};

assert.deepStrictEqual(tokenizer(input), tokens, 'Tokenizer should turn `input` string into `tokens` array');
assert.deepStrictEqual(parser(tokens), ast, 'Parser should turn `tokens` array into `ast`');
assert.deepStrictEqual(transformer(ast), newAst, 'Transformer should turn `ast` into a `newAst`');
assert.deepStrictEqual(codeGenerator(newAst), output, 'Code Generator should turn `newAst` into `output` string');
assert.deepStrictEqual(compiler(input), output, 'Compiler should turn `input` into `output`');

console.log('All Passed!');

// console.log 之前的那 5 行 assert.deepStrictEqual 是关键
// 
// 这整个文件就是把编译器的各个部分用手写方式检验是否正确.
// 先人类分析什么是正确结果, 然后手写出来, 然后把程序输出的比对一下
// tokenizer
// parser
// transformer
// codeGenerator
// compiler
// 全都是手工提前写好正确的结果, 然后拿程序的输出检验
// 还检验了整个编译器编译后的结果是否正确(也是用手写方式, 看上面的 input 和 output 变量)


