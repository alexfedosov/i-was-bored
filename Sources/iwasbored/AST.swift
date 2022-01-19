protocol StatementVisitor {
  associatedtype T
  func visit(node: Statement) throws -> T
  func visit(node: BlockStatement) throws -> T
  func visit(node: ExpressionStatement) throws -> T
  func visit(node: IfStatement) throws -> T
  func visit(node: PrintStatement) throws -> T
  func visit(node: VarStatement) throws -> T
  func visit(node: WhileStatement) throws -> T
}

protocol Statement {
  func accept<V: StatementVisitor>(visitor: V) throws -> V.T
}

struct BlockStatement: Statement {
  let statements: [Statement]

  func accept<V: StatementVisitor>(visitor: V) throws -> V.T {
    try visitor.visit(node: self)
  }
}

struct ExpressionStatement: Statement {
  let expression: Expression

  func accept<V: StatementVisitor>(visitor: V) throws -> V.T {
    try visitor.visit(node: self)
  }
}

struct IfStatement: Statement {
  let condition: Expression
  let thenBlock: Statement
  let elseBlock: Statement?

  func accept<V: StatementVisitor>(visitor: V) throws -> V.T {
    try visitor.visit(node: self)
  }
}

struct PrintStatement: Statement {
  let expression: Expression

  func accept<V: StatementVisitor>(visitor: V) throws -> V.T {
    try visitor.visit(node: self)
  }
}

struct VarStatement: Statement {
  let name: Token
  let initializer: Expression

  func accept<V: StatementVisitor>(visitor: V) throws -> V.T {
    try visitor.visit(node: self)
  }
}

struct WhileStatement: Statement {
  let condition: Expression
  let block: Statement

  func accept<V: StatementVisitor>(visitor: V) throws -> V.T {
    try visitor.visit(node: self)
  }
}

protocol ExpressionVisitor {
  associatedtype T
  func visit(node: Expression) throws -> T
  func visit(node: AssignmentExpression) throws -> T
  func visit(node: BinaryExpression) throws -> T
  func visit(node: GroupingExpression) throws -> T
  func visit(node: LiteralExpression) throws -> T
  func visit(node: LogicalExpression) throws -> T
  func visit(node: UnaryExpression) throws -> T
  func visit(node: VariableExpression) throws -> T
}

protocol Expression {
  func accept<V: ExpressionVisitor>(visitor: V) throws -> V.T
}

struct AssignmentExpression: Expression {
  let name: Token
  let value: Expression

  func accept<V: ExpressionVisitor>(visitor: V) throws -> V.T {
    try visitor.visit(node: self)
  }
}

struct BinaryExpression: Expression {
  let left: Expression
  let op: Token
  let right: Expression

  func accept<V: ExpressionVisitor>(visitor: V) throws -> V.T {
    try visitor.visit(node: self)
  }
}

struct GroupingExpression: Expression {
  let expression: Expression

  func accept<V: ExpressionVisitor>(visitor: V) throws -> V.T {
    try visitor.visit(node: self)
  }
}

struct LiteralExpression: Expression {
  let value: Any?

  func accept<V: ExpressionVisitor>(visitor: V) throws -> V.T {
    try visitor.visit(node: self)
  }
}

struct LogicalExpression: Expression {
  let left: Expression
  let op: Token
  let right: Expression

  func accept<V: ExpressionVisitor>(visitor: V) throws -> V.T {
    try visitor.visit(node: self)
  }
}

struct UnaryExpression: Expression {
  let op: Token
  let right: Expression

  func accept<V: ExpressionVisitor>(visitor: V) throws -> V.T {
    try visitor.visit(node: self)
  }
}

struct VariableExpression: Expression {
  let name: Token

  func accept<V: ExpressionVisitor>(visitor: V) throws -> V.T {
    try visitor.visit(node: self)
  }
}
