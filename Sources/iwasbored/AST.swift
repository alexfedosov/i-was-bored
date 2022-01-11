protocol StatementVisitor {
  associatedtype T
  func visit(node: Statement) throws -> T
  func visit(node: ExpressionStatement) throws -> T
}

protocol Statement {
  func accept<V: StatementVisitor>(visitor: V) throws -> V.T
}

struct ExpressionStatement: Statement {
  let expression: Expression

  func accept<V: StatementVisitor>(visitor: V) throws -> V.T {
    try visitor.visit(node: self)
  }
}

protocol ExpressionVisitor {
  associatedtype T
  func visit(node: Expression) throws -> T
  func visit(node: BinaryExpression) throws -> T
  func visit(node: LiteralExpression) throws -> T
  func visit(node: UnaryExpression) throws -> T
  func visit(node: GroupingExpression) throws -> T
}

protocol Expression {
  func accept<V: ExpressionVisitor>(visitor: V) throws -> V.T
}

struct BinaryExpression: Expression {
  let left: Expression
  let op: Token
  let right: Expression

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

struct UnaryExpression: Expression {
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
