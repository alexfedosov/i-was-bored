protocol StatementVisitor {
  associatedtype T
  func visit(node: Statement) throws -> T
  func visit(node: VarStatement) throws -> T
  func visit(node: ExpressionStatement) throws -> T
  func visit(node: PrintStatement) throws -> T
}

protocol Statement {
  func accept<V: StatementVisitor>(visitor: V) throws -> V.T
}

struct VarStatement: Statement {
  let name: Token
  let initializer: Expression

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

struct PrintStatement: Statement {
  let expression: Expression

  func accept<V: StatementVisitor>(visitor: V) throws -> V.T {
    try visitor.visit(node: self)
  }
}

protocol ExpressionVisitor {
  associatedtype T
  func visit(node: Expression) throws -> T
  func visit(node: GroupingExpression) throws -> T
  func visit(node: BinaryExpression) throws -> T
  func visit(node: UnaryExpression) throws -> T
  func visit(node: VariableExpression) throws -> T
  func visit(node: LiteralExpression) throws -> T
}

protocol Expression {
  func accept<V: ExpressionVisitor>(visitor: V) throws -> V.T
}

struct GroupingExpression: Expression {
  let expression: Expression

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

struct LiteralExpression: Expression {
  let value: Any?

  func accept<V: ExpressionVisitor>(visitor: V) throws -> V.T {
    try visitor.visit(node: self)
  }
}
