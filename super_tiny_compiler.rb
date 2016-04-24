# Ruby version 2.2
# Author: Github@1c7

# 这个版本纯属练手，因为看了 NodeJS 和 Python 
# 总觉得 Transformer 部分的 _context 没懂，想换个语言写写看会不会好一点
# 然后折腾了一下终于理解了

# 另外
# 由于 Ruby 里函数套函数的话, 再里面哪个函数会拿不到外面的参数，于是我稍微小改了一下结构
# 用了 Proc 
# 建议去看 Python 版的，那个我感觉比我写的 Ruby 会更好理解

input_program = "(add 2 (substract 4 2))"
#input_program = "(add 52 3)(subtract 3 4)"

=begin
 * ============================================================================
 *                               ヾ（〃＾∇＾）ﾉ♪
 *                                tokenizer
 * ============================================================================
=end
def tokenizer(input_program)
    current = 0
    tokens = []
    program_length = input_program.length

    while current < program_length
      char = input_program[current]
      
      if char == '('
        tokens.push({
          'type': 'paren',
          'value': '('
        })
        current = current+1
        next
      end
      
      if char == ')'
        tokens.push({
          'type': 'paren',
          'value': ')'
        })
        current = current+1
        next
      end
      
      if /\s/.match(char)
          current = current+1
          next
      end
      
      
      if /[0-9]/.match(char)
        value = ''
        while /[0-9]/.match(char)
            value += char
            current = current+1
            char = input_program[current]
        end

        tokens.push({
            'type': 'number',
            'value': value
        })
        next
      end
      
      if /[a-z]/i.match(char)
        value = ''
        while /[a-z]/i.match(char)
            value += char
            current = current+1
            char = input_program[current]
        end
        tokens.push({
            'type': 'name',
            'value': value
        })

        current = current+1
        next
      end
      
      raise 'I dont know what this character is: ' + char
      
    end
    return tokens
end

tokens = tokenizer(input_program)
#puts(tokens)

=begin
 * ============================================================================
 *                               ヾ（〃＾∇＾）ﾉ♪
 *                                   parser
 * ============================================================================
=end
def parser(tokens)
    $current = 0
    $tokens = tokens
    def walk()
        token = $tokens[$current]
        if token[:type] == 'number'   # 处理数字
            $current = $current + 1
            return { # return here
                'type': 'NumberLiteral',
                'value': token[:value]
            }
        end
        if token[:type] == 'paren'and token[:value] == '('  # 碰到左括号
            # 每次左括号就一个新节点
            $current = $current + 1   # 移动到下一位, 也就是 name, 比如 add, subtract.
            token = $tokens[$current]
            node = {
                'type': 'CallExpression', # 左括号就是 CallExpression
                'name': token[:value],
                'params': []
            }

            $current = $current + 1
            token = $tokens[$current]
            while token[:type] != 'paren' or ( token[:type] == 'paren' and token[:value] != ')' )
            # 不是括号 or 不是右括号, 那么就一直: 
            # 跳出情况: 是右括号
                node[:params].push(walk()); # recursion 注意这里，这样嵌套的就会跑到 params 里去了
                token = $tokens[$current]
            end
            $current = $current + 1
            return node # return here
        end
        raise token[:type]
    end
    ast = {
        'type': 'Program',
        'body': []
    }
    while $current < tokens.length
        ast[:body].push(walk()) # 如果有两个并列的式子, body 里就有2个并列元素  2个并列的CallExpression
    end
return ast
end

ast = parser(tokens)
#puts(ast)


# =============================================================================================

#
# 下面这俩不是自己跑的，要和 transformer 搭配服用
# traverser 这里我把两个函数都拆出来了，因为如果写了 traverser
# 里面2个函数拿不到 visitor，
# 其实之前 parser 是赋值 $token 变全局变量，  然后里面也 $token 取出来就可以了
# 
# 我写完之后才想起来 $visitor 这种写法应该也行，就不用拆出来了，不然既然都写好了就算了，
# 而且即便拆出来其实代码清晰度也不差
#


# 遍历需要遍历的节点(从左到右, for in 就是这么做的)
def traverseArray(array, parent, visitor)
    for child in array
        traverseNode(child, parent, visitor)
    end
end

# 这个函数知道碰到需要遍历的节点之后, 应该取哪个属性
# 如果有对应节点代码，就先执行。而后面的取属性不管咋样都会执行到的。
def traverseNode(node, parent, visitor)
# 第一次调用是 ast, nil, visitor
# 第二次进 Programe 分支 body, Program, visitor
# 第三次进 CallExpression 分支 params, CallExpression, visitor
# 
    # 这部分根据节点执行程序
    type = node[:type]
    if type == 'NumberLiteral'
      visitor[:NumberLiteral].call(node, parent)
    elsif type == 'CallExpression'
      visitor[:CallExpression].call(node, parent)
    end
    
    # 这部分取属性继续遍历
    if node[:type] == 'Program'
        traverseArray(node[:body], node, visitor)
    elsif node[:type] == 'CallExpression'
        traverseArray(node[:params], node, visitor)
    elsif node[:type] == 'NumberLiteral'
      # 数字节点没有子节点，不需要遍历，所以什么都不做
    else
        raise node[:type]
    end
end


def transformer(ast)
    newAst = {
        'type': 'Program',
        'body': []
    }
    ast["_context"] = newAst[:body]
    # 这样在老 AST 的 _context 节点操作的时候, 新 AST 的 body 里会有一样的结果‘
    # 注意现在老 AST 里有了 type, body, _context  他们3个是同层次的

    numberLiteral = Proc.new do |node, parent| 
        # NumberLiteral 的 parent 总是 CallExpression, 注意下面 CallExp 定义了一个 _context, 是 arguments
        # 就是说 push 到 CallExp 的 _context 里实际上就是 push 到 Call Exp 的 arguments 里
        
        #puts node, '==========================' # 可以看到2,4,2，你试试
        parent["_a"].push({  #注意这里不是 push 到 ast['_context'] 不要弄混， 是 callExp['_context']
            'type': 'NumberLiteral',
            'value': node[:value]
        })
    end
    callExpression = Proc.new do |node, parent|
        # puts node, '==========================' # 可以看到 add, subtract
        expression = {
            'type': 'CallExpression',
            'callee': {
                'type': 'Identifier',
                'name': node[:name]
            }, 
            'arguments': []
        }
        node["_a"] = expression[:arguments] #  Number and callEXP get into callExp because this!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        # CallExp 的 context = 新包层的 arguments
        
        if parent[:type] != "CallExpression"  # 这个 if 实际上就是看看要不要多包一层这样， 只有顶层是 Program 的会包一层.
            expression = {
                'type': 'ExpressionStatement',
                'expression': expression
            }
            parent["_context"].push(expression) # ！！！！！get into old ast _context, 所以也进了 new ast body
        else
            parent["_a"].push(expression) # 跑到这里，说明是 callExp 里的 callExp
            # 也就是说在这个例子里是 subtract, 只有 subtract 会跑到这里
            # 这样 push 到 _a 里面就等于 push 到 arguments 里面
        end
        
        # 最后是通过这一句挂到新 ast 的 body 里的
    end
    traverseNode( ast, nil, {
        'NumberLiteral': numberLiteral,
        'CallExpression': callExpression,
    })
    return newAst
end

=begin
  Transformer 调 travserseNode       扔 AST parentNode, visitor
  travserNode  根据类型掉 visitor 里面的方法
  只有 number 和 callExp 会调方法，其他的不管，
  
  注意肯定是先进 callExp 再进 number 的，
  这里 callExp 自己定义了个 _context, 
  于是 number 的 parent._context.push 就跑到 callExp里了
  
  number 就是 parent _context push 到老 AST 里
  callExp 就先把拿 name 包一层， 
=end

newAST = transformer(ast)
#puts newAST
# 命令行里看不清楚结构，用 http://jsonviewer.stack.hu/ 看之后：
=begin
{
  : type=>"Program",
  : body=>[
    {
      : type=>"ExpressionStatement",
      : expression=>{
        : type=>"CallExpression",
        : callee=>{
          : type=>"Identifier",
          : name=>"add"
        },
        : arguments=>[
          {
            : type=>"NumberLiteral",
            : value=>"2"
          },
          {
            : type=>"CallExpression",
            : callee=>{
              : type=>"Identifier",
              : name=>"substract"
            },
            : arguments=>[
              {
                : type=>"NumberLiteral",
                : value=>"4"
              },
              {
                : type=>"NumberLiteral",
                : value=>"2"
              }
            ]
          }
        ]
      }
    }
  ]
}
=end


=begin
 * ============================================================================
 *                               ヾ（〃＾∇＾）ﾉ♪
 *                               codeGenerator
 * ============================================================================
 遍历节点，生成代码
=end
def codeGenerator(node)
    type = node[:type]

    if type == 'Program' 
        # 碰到 Program 就知道我们在树的根节点, 要进去.
        # 这里用 for in 是因为可能 2 个程序并排 (add 2 3)(subtract 3 4)
        # 对于上面这个并排例子, body 里会有2个并排的元素
        sentence = []
        for child in node[:body]
          sentence.push(codeGenerator(child))
        end
        return sentence.join("\n") # (add 2 3)(subtract 3 4) 生成代码之后会分行显示,不会像源代码一样挤在一行

    elsif type == 'Identifier'
        return node[:name]
        
    elsif type == 'NumberLiteral'
        return node[:value]
        
    elsif type == 'ExpressionStatement'
        expression = codeGenerator(node[:expression]) 
        return "%s;" % [expression]
        
    elsif type == 'CallExpression'
        callee = codeGenerator(node[:callee]) 
        params = []
        for child in node[:arguments]
          params.push(codeGenerator(child))
        end
        params = params.join(', ')
        return "%s(%s)" % [callee,params] # here
    else
        raise node['type']
    end
end

puts codeGenerator(newAST)


def compiler(input_program)
    tokens = tokenizer(input_program)
    ast    = parser(tokens)
    newAst = transformer(ast)
    output = codeGenerator(newAst)
    return output
end 
    

#puts compiler(input_program) # add(2,substract(4,2));

=begin
输入输出例子

例子1

    a = "(add 2 (substract 4 2))"
    compiler(a)

      add(2, substract(4, 2));



例子2

    b = "(add 52 3)(subtract 3 4)"
    compiler(b)

      add(52, 3);
      subtract(3, 4);
    
=end




# ======= 编译器部分结束，后面是为了帮助理解写的一些代码, 可以不看 ========

=begin
 * ============================================================================
 *                    这里是为了单独理解 traverser 的具体作用
 * ============================================================================


(add 2 (substract 4 2)) 
如果画成树, 每个节点一个圈, 那么看起来是这样的

           (4)       (2)
                     ↖             ↗
    (2)     (subtract)
           ↖        ↗
        (add)


http://character-code.com/arrows-html-codes.php
      
      
可以看到输出结果表示了如何遍历 
 traverser 实际上就只负责遍历，以及遍历到特定对象就调一下 transformer 里的特定方法
 transformer 另一方面，函数里写了特定对象被调用的方法
 
 visitor 里面有碰到特定节点要跑的函数
=end

=begin
def traverser(ast, visitor)
    # 遍历需要遍历的节点(从左到右, for in 就是这么做的)
    def traverseArray(array, parent)
        for child in array
            traverseNode(child, parent)
        end
    end
    # 这个函数知道碰到需要遍历的节点之后, 应该取哪个属性
    def traverseNode(node, parent)
        if node[:type] == 'Program'
            traverseArray(node[:body], node)
        elsif node[:type] == "CallExpression"
           puts node[:name]                  # add, subtract
           traverseArray(node[:params], node)
        elsif node[:type] == 'NumberLiteral'
            puts node[:value]                # 2, 4, 2
        else
            raise node[:type]
        end
    end
    traverseNode(ast, nil) # call here
end


system 'clear'
system 'date +"%T"'
puts ast, '================↑ old ast===================='
puts 
traverser(ast , nil)

输出:
  add
  2
  substract
  4
  2
  
=end


=begin
 * ============================================================================
 
                        测试每次循环里  array 的值会是啥
                        
       这个是前面测 traverser 的进阶版
       traverser 是 add, 2, subtract, 4, 2
       而这里也是一样, 只不过把树给输出出来了而已. 实际意义还是一回事
 * ============================================================================
=end
=begin
def traverser(ast, visitor)
    def traverseArray(array, parent)
        puts array # notice here
        puts ""
        for child in array
            traverseNode(child, parent)
        end
    end
    def traverseNode(node, parent)
        if node[:type] == 'Program'
            traverseArray(node[:body], node)

        elsif node[:type] == "CallExpression"
            traverseArray(node[:params], node)

        elsif node[:type] == 'NumberLiteral'
        else
            raise node[:type]
        end
    end
            
    traverseNode(ast, nil) # call here
end
# 跑 traverseNode(ast, nil)
# 第一次 type 判定是 program, 跑到 body 里了, 拿到了 CallExpression(add)
# 然后 for child in CallExpression(add)
# 然后第一个 child 是 NumberLiteral(2), 这个 child 跑完了自然就去处理第二个 child 了
# 然后第二个 child 是 CallExpression(subtract)， 

# 然后 for child in CallExpression(subtract)
# 这次第一个 child 是 NumberLiteral(4)
# 然后第二个 child 是 NumberLiteral(2)
# 没了

system 'clear'
system 'date +"%T"'
puts ast, '================↑ old ast===================='
puts
puts
traverser(ast , nil)
=end



=begin

      $a  is a global var
      :b  is a symbol, symbol is hash key or string, but represting same value.
      http://stackoverflow.com/questions/255078/whats-the-difference-between-a-string-and-a-symbol-in-ruby

=end



