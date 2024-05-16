import fs from "fs";
import antlr4 from "antlr4";
import cppParserLexer from "./CPP14Lexer.js";
import cppParserParser from "./CPP14Parser.js";
import cppParserVisitor from "./CPP14ParserVisitor.js";
import getTokenType from "./utils.js";
import { createInterface } from "readline";
const keywords = [
  "auto",
  "bool",
  "break",
  "case",
  "catch",
  "char",
  "class",
  "const",
  "continue",
  "default",
  "delete",
  "do",
  "double",
  "else",
  "enum",
  "explicit",
  "export",
  "extern",
  "false",
  "final",
  "float",
  "for",
  "friend",
  "goto",
  "if",
  "inline",
  "int",
  "interface",
  "long",
  "mutable",
  "namespace",
  "new",
  "operator",
  "private",
  "protected",
  "public",
  "return",
  "short",
  "static",
  "signed",
  "switch",
  "template",
  "this",
  "throw",
  "true",
  "try",
  "typeof",
  "typeid",
  "unsigend",
  "void",
  "virtual",
  "while",
];
const keyobjects = [
  "std::string",
  "std::vector",
  "std::map",
  "std::set",
  "std::list",
  "std::queue",
  "std::stack",
  "std::iostream",
  "std::ifstream",
  "std::ofstream",
  "std::stringstream",
  "std::thread",
];
const keyfunctions = [
  "printf",
  "scanf",
  "cin",
  "cout",
  "getline",
  "malloc",
  "calloc",
  "free",
  "memcpy",
  "memset",
  "strlen",
  "strcmp",
  "strcpy",
  "strcat",
  "strstr",
  "strcat",
  "strcat",
];
var completionList = [];
function get_tokens(data) {
  const chars = new antlr4.InputStream(data);
  const lexer = new cppParserLexer(chars);
  const tokens = new antlr4.CommonTokenStream(lexer);
  tokens.fill();
  const token_list = tokens.tokens.map((token) => ({
    start: token.start,
    channel: token.channel,
    stop: token.stop,
    line: token.line,
    column: token.column,
    text: token.text,
    type: cppParserLexer.symbolicNames[token.type],
  }));
  return token_list;
}
function get_variables(root) {
  if (typeof root == "string") return;
  //variable;
  // if (root.type == "initDeclarator") {
  //     if (root.body[1].body[0] != "(") {
  //         root.body[0].body[0].body.forEach((item) => {
  //             if (item.type == "noPointerDeclarator") {
  //                 completionList.push({
  //                     maybe: item.text,
  //                     kind: "variable",
  //                 });
  //                 return;
  //             }
  //         });
  //     }
  // }
  //class
  if (root.type == "classHead") {
    let varName = root.body[1].body[0].text; // classDeclaration[1] -> identifier
    completionList.push({ maybe: varName, kind: "class", detail: "" });
  }
  //function
  else if (root.type == "functionDefinition") {
    root.body.forEach((item) => {
      if (item.type == "declarator") {
        completionList.push({
          maybe: item.body[0].body[0].body[0].text,
          kind: "function",
          detail: "",
        });
        return;
      }
    });
  } else if (root.type == "simpleDeclaration") {
    if (
      root.body[0].type == "declSpecifierSeq" &&
      root.body[1].type == "initDeclaratorList"
    ) {
      root.body[1].body[0].body[0].body[0].body.forEach((item) => {
        if (item.type == "noPointerDeclarator") {
          completionList.push({
            maybe: item.text,
            kind: "variable",
            detail: root.body[0].body[0].text,
          });
          return;
        }
      });
    }
  }

  root.body.forEach((element) => {
    get_variables(element);
  });
}
function get_AST(data) {
  const chars = new antlr4.InputStream(data);
  const lexer = new cppParserLexer(chars);
  const tokens = new antlr4.CommonTokenStream(lexer);
  const parser = new cppParserParser(tokens);
  tokens.fill();
  parser.buildParseTrees = true;

  var ruleNames = parser.ruleNames;
  var tree = parser.translationUnit();
  class Visitor {
    visitChildren(ctx) {
      let ret = {};
      if (!ctx) {
        return;
      }
      ret["type"] = ruleNames[ctx.ruleIndex];
      ret["text"] = ctx.getText();
      if (ctx.children) {
        ret["body"] = [];
        ctx.children.forEach((child) => {
          if (child.children && child.children.length != 0) {
            ret["body"].push(child.accept(this));
          } else {
            ret["body"].push(child.getText());
          }
        });
      }
      return ret;
    }
  }
  var result = tree.accept(new Visitor());
  return result;
}
var functionList = [];
var field = "";
function get_functions(root) {
  if (typeof root == "string") return;

  if (root.type == "functionDefinition") {
    // console.log("functionDeclaration");
    let son = root;
    let name = "";
    let fucname = "";
    let params = [];
    root.body.forEach((item) => {
      if (item.type == "declarator") {
        name += item.body[0].body[0].text; // functionname
        fucname += item.body[0].body[0].body[0].text;
        if (item.body[0].body[0].body[1].type == "parametersAndQualifiers") {
          let child = item.body[0].body[0].body[1];
          child.body.forEach((item2) => {
            if (item2.type == "parameterDeclarationClause") {
              item2.body[0].body.forEach((item3) => {
                if (item3.type == "parameterDeclaration") {
                  params.push(item3.text);
                }
              });
            }
          });
        }
      }
    });
    if (fucname == field) {
      functionList.push({
        name: name,
        parameters: params,
        field: "",
      });
    } else {
      if (field != "") {
        completionList.forEach((item) => {
          if (item.detail == field) {
            functionList.push({
              name: item.maybe + "." + name,
              parameters: params,
              field: field,
            });
          }
        });
      } else {
        functionList.push({
          name: name,
          parameters: params,
          field: field,
        });
      }
    }
  }
  root.body.forEach((element) => {
    get_functions(element);
  });
  // console.log(functionList);
}
var toMatchText;
var resultText;
var resultList = [];
function get_headname(root) {
  if (typeof root == "string") return;
  root.body.forEach((item) => {
    if (item.type == "classHeadName") {
      //console.log(item.text);
      field = item.text;
      //console.log(field);
    }
  });
  root.body.forEach((element) => {
    get_headname(element);
  });
}
function get_all1(data) {
  var target = data.split("\n").length - 4;
  data.split("\n").forEach((line, index) => {
    if (index == target) {
      toMatchText = line;
    } else {
      resultText += line + "\n";
    }
  });
  var AST = get_AST(data);
  completionList = [];
  get_variables(AST);
  keywords.forEach((item) => {
    completionList.push({ maybe: item, kind: "keyword" });
  });
  keyobjects.forEach((item) => {
    completionList.push({ maybe: item, kind: "class" });
  });
  keyfunctions.forEach((item) => {
    completionList.push({ maybe: item, kind: "function" });
  });
  //console.log(completionList);
  // const need_tokens = get_tokens(toMatchText);
  // console.log(need_tokens);
  // const need_name = need_tokens.filter((item) => item.type == "Identifier")[0]
  //     .text;
  // completionList.forEach((item) => {
  //     if (item.maybe.startsWith(need_name)) {
  //         resultList.push(item);
  //     }
  // });
  // console.log(resultList);
}
function get_all2(data) {
  resultList = [];
  var target = data.split("\n").length - 4;
  data.split("\n").forEach((line, index) => {
    if (index == target) {
      toMatchText = line;
    } else {
      resultText += line + "\n";
    }
  });
  var AST = get_AST(data);
  functionList = [];
  for (var i = 0; i < AST.body[0].body.length; i++) {
    field = "";
    if (AST.body[0].body[i].body[0].type == "blockDeclaration") {
      get_headname(AST.body[0].body[i]);
    }
    get_functions(AST.body[0].body[i]);
  }
}
function completion(data) {
  let rl = createInterface({
    input: process.stdin,
    output: process.stdout,
  });

  rl.question("请输入代码：", (input) => {
    const words = input.split(" ");
    const lastWord = words[words.length - 1];

    const allKeywords = [...completionList.map((item) => item.maybe)];

    // 找出所有重复的关键词
    const duplicates = allKeywords.filter(
      (item, index) => allKeywords.indexOf(item) !== index
    );
    const matches = allKeywords
      .filter((keyword) => keyword.startsWith(lastWord))
      .map((keyword) => {
        // 只为重复的关键词添加 kind 属性
        if (duplicates.includes(keyword)) {
          const items = completionList.filter((item) => item.maybe === keyword);
          return items.map((item) => `${keyword} (${item.kind})`);
        }
        return keyword;
      })
      .flat() // 将生成的数组扁平化
      .filter((item, index, self) => self.indexOf(item) === index); // 去除重复项

    console.log("可能的补全选项：", matches);

    const funclist = functionList;
    const funcmatches = funclist
      .filter((func) => func.name.split("(")[0] === lastWord)
      .map((func) => {
        return `${func.name.split("(")[0]} ( ${func.parameters.join(", ")} )`;
      })
      .flat() // 将生成的数组扁平化
      .filter((item, index, self) => self.indexOf(item) === index); // 去除重复项

    console.log("函数参数：", funcmatches);

    rl.close();
  });
}

const path = process.argv.slice(2);
const fileContent = fs.readFileSync(path[0], "utf-8");
//highlight(fileContent);
get_all1(fileContent);
get_all2(fileContent);
completion(fileContent);
