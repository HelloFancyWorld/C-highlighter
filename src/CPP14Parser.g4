parser grammar CPP14Parser;

options {
    superClass = CPP14ParserBase;
    tokenVocab = CPP14Lexer;
}

translationUnit
    : declarationseq? EOF
    ;

primaryExpr
    : literal+
    | This
    | LeftParen expr RightParen
    | idExpr
    | lambdaExpr
    ;

idExpr
    : unqualifiedId
    | qualifiedId
    ;

unqualifiedId
    : Identifier
    | Tilde className
    ;

qualifiedId
    : nestedNameSpecifier unqualifiedId
    ;

nestedNameSpecifier
    : (theTypeName | namespaceName)? Doublecolon
    | nestedNameSpecifier Identifier Doublecolon
    ;

lambdaExpr
    : lambdaIntroducer lambdaDeclarator? compoundStatement
    ;

lambdaIntroducer
    : LeftBracket lambdaCapture? RightBracket
    ;

lambdaCapture
    : captureList
    | captureDefault (Comma captureList)?
    ;

captureDefault
    : And
    | Assign
    ;

captureList
    : capture (Comma capture)* Ellipsis?
    ;

capture
    : simpleCapture
    | initcapture
    ;

simpleCapture
    : And? Identifier
    | This
    ;

initcapture
    : And? Identifier initializer
    ;

lambdaDeclarator
    : LeftParen parameterDeclarationClause? RightParen Mutable? trailingReturnType?
    ;

postfixExpr
    : primaryExpr
    | postfixExpr LeftBracket (expr | bracedInitList) RightBracket
    | postfixExpr LeftParen exprList? RightParen
    | simpleTypeSpecifier (
        LeftParen exprList? RightParen
        | bracedInitList
    )
    | postfixExpr (Dot | Arrow) ( idExpr | pseudoDestructorName)
    | postfixExpr (PlusPlus | MinusMinus)
    | (Dynamic_cast | Static_cast | Reinterpret_cast | Const_cast) Less theTypeId Greater LeftParen expr RightParen
    | typeIdOfTheTypeId LeftParen (expr | theTypeId) RightParen
    ;


typeIdOfTheTypeId
    : Typeid_
    ;

exprList
    : initializerList
    ;

pseudoDestructorName
    : nestedNameSpecifier? (theTypeName Doublecolon)? Tilde theTypeName
    ;

unaryExpr
    : postfixExpr
    | (PlusPlus | MinusMinus | unaryOperator | Sizeof) unaryExpr
    | Sizeof (LeftParen theTypeId RightParen | Ellipsis LeftParen Identifier RightParen)
    | Alignof LeftParen theTypeId RightParen
    | newExpr_
    | deleteExpr
    ;

unaryOperator
    : Or
    | Star
    | And
    | Plus
    | Tilde
    | Minus
    | Not
    ;

newExpr_
    : Doublecolon? New newPlacement? (newTypeId | LeftParen theTypeId RightParen) newInitializer_?
    ;

newPlacement
    : LeftParen exprList RightParen
    ;

newTypeId
    : typeSpecifierSeq newDeclarator_?
    ;

newDeclarator_
    : pointerOperator newDeclarator_?
    | noPointerNewDeclarator
    ;

noPointerNewDeclarator
    : LeftBracket expr RightBracket
    | noPointerNewDeclarator LeftBracket constantExpr RightBracket
    ;

newInitializer_
    : LeftParen exprList? RightParen
    | bracedInitList
    ;

deleteExpr
    : Doublecolon? Delete (LeftBracket RightBracket)? castExpr
    ;

castExpr
    : unaryExpr
    | LeftParen theTypeId RightParen castExpr
    ;

pointerMemberExpr
    : castExpr ((DotStar | ArrowStar) castExpr)*
    ;

multiplicativeExpr
    : pointerMemberExpr ((Star | Div | Mod) pointerMemberExpr)*
    ;

additiveExpr
    : multiplicativeExpr ((Plus | Minus) multiplicativeExpr)*
    ;

shiftExpr
    : additiveExpr (shiftOperator additiveExpr)*
    ;

shiftOperator
    : Greater Greater
    | Less Less
    ;

relationalExpr
    : shiftExpr ((Less | Greater | LessEqual | GreaterEqual) shiftExpr)*
    ;

equalityExpr
    : relationalExpr ((Equal | NotEqual) relationalExpr)*
    ;

andExpr
    : equalityExpr (And equalityExpr)*
    ;

exclusiveOrExpr
    : andExpr (Caret andExpr)*
    ;

inclusiveOrExpr
    : exclusiveOrExpr (Or exclusiveOrExpr)*
    ;

logicalAndExpr
    : inclusiveOrExpr (AndAnd inclusiveOrExpr)*
    ;

logicalOrExpr
    : logicalAndExpr (OrOr logicalAndExpr)*
    ;

conditionalExpr
    : logicalOrExpr (Question expr Colon assignmentExpr)?
    ;

assignmentExpr
    : conditionalExpr
    | logicalOrExpr assignmentOperator initializerClause
    ;

assignmentOperator
    : Assign
    | StarAssign
    | DivAssign
    | ModAssign
    | PlusAssign
    | MinusAssign
    | RightShiftAssign
    | LeftShiftAssign
    | AndAssign
    | XorAssign
    | OrAssign
    ;

expr
    : assignmentExpr (Comma assignmentExpr)*
    ;

constantExpr
    : conditionalExpr
    ;

statement
    : labeledStatement
    | declarationStatement
    | (
        exprStatement
        | compoundStatement
        | selectionStatement
        | iterationStatement
        | jumpStatement
    )
    ;

labeledStatement
    : (Identifier | Case constantExpr | Default) Colon statement
    ;

exprStatement
    : expr? Semi
    ;

compoundStatement
    : LeftBrace statementSeq? RightBrace
    ;

statementSeq
    : statement+
    ;

selectionStatement
    : If LeftParen condition RightParen statement (Else statement)?
    | Switch LeftParen condition RightParen statement
    ;

condition
    : expr
    | declSpecifierSeq declarator (
        Assign initializerClause
        | bracedInitList
    )
    ;

iterationStatement
    : While LeftParen condition RightParen statement
    | Do statement While LeftParen expr RightParen Semi
    | For LeftParen (
        forInitStatement condition? Semi expr?
        | forRangeDeclaration Colon forRangeInitializer
    ) RightParen statement
    ;

forInitStatement
    : exprStatement
    | simpleDeclaration
    ;

forRangeDeclaration
    : declSpecifierSeq declarator
    ;

forRangeInitializer
    : expr
    | bracedInitList
    ;

jumpStatement
    : (Break | Continue | Return (expr | bracedInitList)? | Goto Identifier) Semi
    ;

declarationStatement
    : blockDeclaration
    ;

declarationseq
    : declaration+
    ;

declaration
    : blockDeclaration
    | functionDefinition
    | namespaceDefinition
    | emptyDeclaration_
    ;

blockDeclaration
    : simpleDeclaration
    | usingDeclaration
    | usingDirective
    ;

simpleDeclaration
    : declSpecifierSeq? initDeclaratorList? Semi
    | declSpecifierSeq? initDeclaratorList Semi
    ;

emptyDeclaration_
    : Semi
    ;

declSpecifier
    : Friend
    | typeSpecifier
    | functionSpecifier
    | Typedef
    | Constexpr
    ;

declSpecifierSeq
    : declSpecifier+?
    ;

functionSpecifier
    : Inline
    | Explicit
    ;

typedefName
    : Identifier
    ;

typeSpecifier
    : trailingTypeSpecifier
    | classSpecifier
    ;

trailingTypeSpecifier
    : simpleTypeSpecifier
    | cvQualifier
    ;

typeSpecifierSeq
    : typeSpecifier+
    ;

trailingTypeSpecifierSeq
    : trailingTypeSpecifier+
    ;

simpleTypeLengthModifier
    : Short
    | Long
    ;

simpleTypeSignednessModifier
    : Unsigned
    | Signed
    ;

simpleTypeSpecifier
    : nestedNameSpecifier? theTypeName
    | Char
    | Char16
    | Char32
    | Wchar
    | Bool
    | Short
    | Int
    | Long
    | Float
    | Signed
    | Unsigned
    | Float
    | Double
    | Void
    | Auto
    ;

theTypeName
    : className
    | typedefName
    ;

namespaceName
    : originalNamespaceName
    ;

originalNamespaceName
    : Identifier
    ;

namespaceDefinition
    : Inline? Namespace (Identifier | originalNamespaceName)? LeftBrace namespaceBody = declarationseq? RightBrace
    ;

usingDeclaration
    : Using (Typename_? nestedNameSpecifier | Doublecolon) unqualifiedId Semi
    ;

usingDirective
    : Using Namespace nestedNameSpecifier? namespaceName Semi
    ;

initDeclaratorList
    : initDeclarator (Comma initDeclarator)*
    ;

initDeclarator
    : declarator initializer?
    ;

declarator
    : pointerDeclarator
    | noPointerDeclarator parametersAndQualifiers trailingReturnType
    ;

pointerDeclarator
    : (pointerOperator Const?)* noPointerDeclarator
    ;

noPointerDeclarator
    : declaratorid
    | noPointerDeclarator (
        parametersAndQualifiers
        | LeftBracket constantExpr? RightBracket
    )
    | LeftParen pointerDeclarator RightParen
    ;

parametersAndQualifiers
    : LeftParen parameterDeclarationClause? RightParen cvqualifierseq? refqualifier?
    ;

trailingReturnType
    : Arrow trailingTypeSpecifierSeq abstractDeclarator?
    ;

pointerOperator
    : (And | AndAnd)
    | nestedNameSpecifier? Star cvqualifierseq?
    ;

cvqualifierseq
    : cvQualifier+
    ;

cvQualifier
    : Const
    | Volatile
    ;

refqualifier
    : And
    | AndAnd
    ;

declaratorid
    : Ellipsis? idExpr
    ;

theTypeId
    : typeSpecifierSeq abstractDeclarator?
    ;

abstractDeclarator
    : pointerAbstractDeclarator
    | noPointerAbstractDeclarator? parametersAndQualifiers trailingReturnType
    | abstractPackDeclarator
    ;

pointerAbstractDeclarator
    : noPointerAbstractDeclarator
    | pointerOperator+ noPointerAbstractDeclarator?
    ;

noPointerAbstractDeclarator
    : noPointerAbstractDeclarator (
        parametersAndQualifiers
        | noPointerAbstractDeclarator LeftBracket constantExpr? RightBracket
    )
    | parametersAndQualifiers
    | LeftBracket constantExpr? RightBracket
    | LeftParen pointerAbstractDeclarator RightParen
    ;

abstractPackDeclarator
    : pointerOperator* noPointerAbstractPackDeclarator
    ;

noPointerAbstractPackDeclarator
    : noPointerAbstractPackDeclarator (
        parametersAndQualifiers
        | LeftBracket constantExpr? RightBracket
    )
    | Ellipsis
    ;

parameterDeclarationClause
    : parameterDeclarationList (Comma? Ellipsis)?
    ;

parameterDeclarationList
    : parameterDeclaration (Comma parameterDeclaration)*
    ;

parameterDeclaration
    : declSpecifierSeq (declarator | abstractDeclarator?) (
        Assign initializerClause
    )?
    ;

functionDefinition
    : declSpecifierSeq? declarator functionBody
    ;

functionBody
    : constructorInitializer? compoundStatement
    | Assign (Default | Delete) Semi
    ;

initializer
    : braceOrEqualInitializer
    | LeftParen exprList RightParen
    ;

braceOrEqualInitializer
    : Assign initializerClause
    | bracedInitList
    ;

initializerClause
    : assignmentExpr
    | bracedInitList
    ;

initializerList
    : initializerClause Ellipsis? (Comma initializerClause Ellipsis?)*
    ;

bracedInitList
    : LeftBrace (initializerList Comma?)? RightBrace
    ;

className
    : Identifier
    ;

classSpecifier
    : classHead LeftBrace memberSpecification? RightBrace
    ;

classHead
    : classKey (classHeadName classVirtSpecifier?)?
    ;

classHeadName
    : nestedNameSpecifier? className
    ;

classVirtSpecifier
    : Final
    ;

classKey
    : Class
    | Struct
    ;

memberSpecification
    : (memberdeclaration | accessSpecifier Colon)+
    ;

memberdeclaration
    : declSpecifierSeq? memberDeclaratorList? Semi
    | functionDefinition
    | usingDeclaration
    | emptyDeclaration_
    ;

memberDeclaratorList
    : memberDeclarator (Comma memberDeclarator)*
    ;

memberDeclarator
    : declarator (
        braceOrEqualInitializer
        | { this.IsPureSpecifierAllowed() }? pureSpecifier
    )
    | declarator
    | Identifier? Colon constantExpr
    ;

pureSpecifier
    : Assign IntLiteral
    ;

accessSpecifier
    : Private
    | Protected
    | Public
    ;

constructorInitializer
    : Colon memInitializerList
    ;

memInitializerList
    : memInitializer Ellipsis? (Comma memInitializer Ellipsis?)*
    ;

memInitializer
    : meminitializerid (LeftParen exprList? RightParen | bracedInitList)
    ;

meminitializerid
    : Identifier
    ;


theOperator
    : New (LeftBracket RightBracket)?
    | Delete (LeftBracket RightBracket)?
    | Plus
    | Minus
    | Star
    | Div
    | Mod
    | Caret
    | And
    | Or
    | Tilde
    | Not
    | Assign
    | Greater
    | Less
    | GreaterEqual
    | PlusAssign
    | MinusAssign
    | StarAssign
    | ModAssign
    | XorAssign
    | AndAssign
    | OrAssign
    | Less Less
    | Greater Greater
    | RightShiftAssign
    | LeftShiftAssign
    | Equal
    | NotEqual
    | LessEqual
    | AndAnd
    | OrOr
    | PlusPlus
    | MinusMinus
    | Comma
    | ArrowStar
    | Arrow
    | LeftParen RightParen
    | LeftBracket RightBracket
    ;

literal
    : IntLiteral
    | CharLiteral
    | FloatLiteral
    | StringLiteral
    | BooleanLiteral
    | PointerLiteral
    | UserDefinedLiteral
    ;