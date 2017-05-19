###  This fork repo translate all english comment to chinese, intent to help chinese programmer understand compiler
## 超小编译器  (原作者: James Kyle, 译者: Github@1c7)


### 0. 简单介绍：
这个库里有个 200 行代码的小编译器。  
目的是帮助你理解编译器这个东西怎么运行的，如果你在学编译器，那么这个库对你有帮助。    
这个编译器只能把 ``` (add 2 (substract 4 2)) ``` 编译成 ``` add(2, subtract(4, 2)); ```    
仅此而已，没有别的，不能跑 Hello World 也不能 print 一些东西。    
但是它简短的代码很清楚的讲解了编译器的核心概念。



### 1. 首先
1. 这个编译器用的语言是 Node.js <br/>
2. 编译器能把 ``` (add 2 (substract 4 2)) ``` 编译成 ``` add(2, subtract(4, 2)); ``` <br/>
3. 关于翻译风格: 你来看编译器的代码必然是希望理解整个编译器是怎么跑的, 所以我的翻译也是朝着这个目标,
所以我不会完完全全忠实原文翻译, 因为我发现个别地方忠实原文翻译会比较难理解. (约翰, 你这个该死的家伙, 我发誓我会踢你的屁股的!)


#### 2. 建议
1. 当前(2016年4月)的 Node.js 版本是 5.10.1 如果你的版本还是旧的 0.10 记得升级, 不然运行不了.

2. 如果你英文还行, 强烈建议看英文原视频(Youtube): https://www.youtube.com/watch?v=Tar4WgAfMr4 <br/>
哪怕英文不行, 看原视频里作者放 PPT 时也可以帮助理解, PPT 里没代码注释.  <br/>
纯代码, 有代码高亮, 作者每次高亮几行然后讲解, 结构更清晰一些. <br/>
 <br/>
super-tiny-compiler.js 里的注释多, 一方面帮助理解, <br/>
但另一方面代码被太多注释隔开, 脑子里掌握不了代码的整体结构<br/>
不过口述内容和代码里的英文注释基本一样. <br/>
视频的前三分之一是介绍，后面就是代码带你走一遍<br/>
<br/>


#### 3. 怎么学
这里只有2个最重要的文件

```super-tiny-compiler.js``` 是编译器 <br/>
```test.js``` 是测试 ```super-tiny-compiler.js``` 这个编译器 <br/><br/>


1. 先跑一遍 ```nodejs test.js``` 看下结果  
![test.js 运行结果](run%20testjs.png)

2. 打开 ``` test.js ``` 理解是怎么测的 (手工先写好正确结果, 然后看程序输出的是否匹配 )  
![test.js 文件内容](test.png)

3. 打开 ```super-tiny-compiler.js``` 看代码和注释即可 <br/>
![super-tiny-compiler.js 文件内容](compiler.png)

3.  (Python 版)看完 NodeJS 版本应该就差不多了, 觉得没理解想换种语言看看的, 
<br/> 可以看 Python 版的: https://github.com/josegomezr/the-super-tiny-compiler <br/>

4.  (Ruby 版)想看 Ruby 版的可以看 [super_tiny_compiler.rb](super_tiny_compiler.rb) <br/>

5. (Go 版) https://github.com/hazbo/the-super-tiny-compiler <br/>

<br/>
文件说明: 

```
super-tiny-compiler.js               编译器(NodeJS)

test.js                              是测编译器的代码, 提前手写了正确的结果, 再和程序输出的比对.

no-comments-super-tiny-compiler.js   没注释的编译器, 读完有注释的版本后可以看下这个

super-tiny-compiler.rb               编译器(Ruby)
```


### 下面的说明不重要，可以不看

---

#### 1. token 是什么
token 的英文意思: <br/>
A programming token is the basic component of source code . Character s are categorized as one of five classes of tokens that describe their functions (constants, identifiers, operators, reserved words, and separators) in accordance with the rules of the programming language.

简单说就是源代码里的基础块(basic component), 不可继续分割
``` javascript
var a = 42;

```

var 是一个 token <br/>
a 是一个 token <br/>
= 是一个 token <br/>
42 是一个 token <br/>
; 是一个 token <br/>

#### 2. 文档里有一段注释 AST 结构的看不大清楚，我重新复制下
建议弄到 json formatter 里弄成可以折叠的，这样看的更清楚
https://jsonformatter.curiousconcept.com/
```
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
```
整理后：Original AST  
```
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
```

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
   
```


```
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

```





