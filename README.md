##### 超小编译器 (原作者: James Kyle, 译者: Github@1c7)
##### 中文注释在最下面, 最上面这里我保留了原作者的英文说明.
<a href="super-tiny-compiler.js"><img width="731" alt="THE SUPER TINY COMPILER" src="https://cloud.githubusercontent.com/assets/952783/14171276/ed7bf716-f6e6-11e5-96df-80a031c2769d.png"/></a>

***Welcome to The Super Tiny Compiler!***

This is an ultra-simplified example of all the major pieces of a modern compiler
written in easy to read JavaScript.

Reading through the guided code will help you learn about how *most* compilers
work from end to end.

### [Want to jump into the code? Click here](super-tiny-compiler.js)

---

### Why should I care?

That's fair, most people don't really have to think about compilers in their day
jobs. However, compilers are all around you, tons of the tools you use are based
on concepts borrowed from compilers.

### But compilers are scary!

Yes, they are. But that's our fault (the people who write compilers), we've
taken something that is reasonably straightforward and made it so scary that
most think of it as this totally unapproachable thing that only the nerdiest of
the nerds are able to understand.

### Okay so where do I begin?

Awesome! Head on over to the [super-tiny-compiler.js](super-tiny-compiler.js)
file.

### I'm back, that didn't make sense

Ouch, I'm really sorry. I'm planning on doing a lot more work on this to add
inline annotations. If you want to come back when that's done, you can either
watch/star this repo or follow me on
[twitter](https://twitter.com/thejameskyle) for updates.

### Tests

Run with `node test.js`

---

[![cc-by-4.0](https://licensebuttons.net/l/by/4.0/80x15.png)](http://creativecommons.org/licenses/by/4.0/)


<br/>
---


### 首先
这里用的语言是 Node.js    你必须对 Node.js 有基础的了解.
当前(2016年4月)的 Node.js 版本是 5.10.1 如果你的版本还是旧的 0.10 记得升级, 不然运行不了.

建议看 https://www.youtube.com/watch?v=Tar4WgAfMr4 (Youtube 原视频)
作者放 代码 PPT 的时候是没注释, 口述的, 结构会更清晰一些.
不过讲代码的口述内容和代码里的英文注释基本一样.
视频前半部分讲(00:00~00:00)
视频后半部分讲(

如果你对翻译有任何改进意见可以直接开 issue(比较省事) 或者是 fork 下来自己改, 然后 pull request.


### 怎么学 各个文件

```
super-tiny-compiler.js               是编译器
test.js                              是测试编译器的代码, 提前手写了正确的结果, 再和程序输出的比对.
no-comments-super-tiny-compiler.js   没注释的编译器, 读完有注释的版本后可以看下这个
```

### token 是什么
token 的英文意思: 
A programming token is the basic component of source code . Character s are categorized as one of five classes of tokens that describe their functions (constants, identifiers, operators, reserved words, and separators) in accordance with the rules of the programming language.

简单说就是源代码里的基础块(basic component), 不可继续分割
``` javascript
var a = 42;

```

var 是一个 token
a 是一个 token
= 是一个 token
42 是一个 token
; 是一个 token


##### 用到了啥数据结构? 
编译器里用到了树, 以及树的遍历


##### module.exports 是什么? (super-tiny-compiler.js)
module.exports 使得别的文件 require 本文件之后可以用这些函数,
如果不写就拿不到, 会报错.


##### assert 是什么? (test.js)
assert 是 Node.js 的内置模块，用于断言。如果表达式不符合预期，就抛出一个错误。

test.js 里检验部分的第一行是这样写的:
assert.deepStrictEqual(tokenizer(input), tokens, 'Tokenizer should turn `input` string into `tokens` array');

简单说:
前两个参数是要检查的, 如果前两个不一样, 就会报错.
第三个字符串参数是如果出错, 会输出的错误信息.
第三个参数是可选的, 如果不给，默认输出出错的那一行代码

assest 的文档（非常建议看）:
https://nodejs.org/api/assert.html#assert_assert_deepstrictequal_actual_expected_message



### 文档里有一段注释 AST 结构的看不大清楚，我重新复制下
建议弄到 json formatter 里弄成可以折叠的，这样看的更清楚
https://jsonformatter.curiousconcept.com/

原文:
 * ----------------------------------------------------------------------------
 *   Original AST                     |   Transformed AST
 * ----------------------------------------------------------------------------
 *   {                                |   {
 *     type: 'Program',               |     type: 'Program',
 *     body: [{                       |     body: [{
 *       type: 'CallExpression',      |       type: 'ExpressionStatement',
 *       name: 'add',                 |       expression: {
 *       params: [{                   |         type: 'CallExpression',
 *         type: 'NumberLiteral',     |         callee: {
 *         value: '2'                 |           type: 'Identifier',
 *       }, {                         |           name: 'add'
 *         type: 'CallExpression',    |         },
 *         name: 'subtract',          |         arguments: [{
 *         params: [{                 |           type: 'NumberLiteral',
 *           type: 'NumberLiteral',   |           value: '2'
 *           value: '4'               |         }, {
 *         }, {                       |           type: 'CallExpression',
 *           type: 'NumberLiteral',   |           callee: {
 *           value: '2'               |             type: 'Identifier',
 *         }]                         |             name: 'subtract'
 *       }]                           |           },
 *     }]                             |           arguments: [{
 *   }                                |             type: 'NumberLiteral',
 *                                    |             value: '4'
 * ---------------------------------- |           }, {
 *                                    |             type: 'NumberLiteral',
 *                                    |             value: '2'
 *                                    |           }]
 *  (sorry the other one is longer.)  |         }
 *                                    |       }
 *                                    |     }]
 *                                    |   }
 * ----------------------------------------------------------------------------

整理后：Original AST  
```json
{
   type:'Program',
   body:[
      {
         type:'CallExpression',
         name:'add',
         params:[
            {
               type:'NumberLiteral',
               value:'2'
            },
            {
               type:'CallExpression',
               name:'subtract',
               params:[
                  {
                     type:'NumberLiteral',
                     value:'4'
                  },
                  {
                     type:'NumberLiteral',
                     value:'2'
                  }
               ]
            }
         ]
      }
   ]
}

```

整理后：Transformed AST
```json

{
   type:'Program',
   body:[
      {
         type:'ExpressionStatement',
         expression:{
            type:'CallExpression',
            callee:{
               type:'Identifier',
               name:'add'
            },
            arguments:[
               {
                  type:'NumberLiteral',
                  value:'2'
               },
               {
                  type:'CallExpression',
                  callee:{
                     type:'Identifier',
                     name:'subtract'
                  },
                  arguments:[
                     {
                        type:'NumberLiteral',
                        value:'4'
                     },
                     {
                        type:'NumberLiteral',
                        value:'2'
                     }
                  ]
               }
            }
         }
      ]
   }
   
'''





总结下区别，因为我看了半天..

token 有几种类型: paren name number

token 变 AST 之后: 

number -> NumberLiteral
paren,name -> CallExpression


新 AST：

1 顶层的 CallExpression 套在了 ExpressionStatement 里面
2 params 变成了 arguments

3 name: 'subtract', 套了一层, 变成了
callee:{
   type:'Identifier',
   name:'subtract'
},

















