import fs from "fs";
import antlr4 from "antlr4";
import cppParserLexer from "./CPP14Lexer.js";
import cppParserParser from "./CPP14Parser.js";
import cppParserVisitor from "./CPP14ParserVisitor.js";
import getTokenType from "./utils.js";
const colors = {
  keyword: "\x1b[31m", // red
  comment: "\x1b[32m", // green
  string: "\x1b[33m", // yellow
  number: "\x1b[34m", // blue
  enum: "\x1b[35m", //purple
  variable: "\x1b[36m",
  Lib: "\x1b[38;2;255;165;0m",
  default: "\x1b[0m", // reset color
};
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
function highlight(data) {
  var highlightedCode="";
  var token_list = get_tokens(data);
  token_list.forEach((token) => {
    var tokenText = token.text;
    var real_type = getTokenType(token.type);
    var colorCode = colors[real_type] || colors.default;
    if (real_type != "Lib") {
      if(token.type!=undefined)
        highlightedCode += colorCode + tokenText + colors.default;
    } else if (real_type == "Lib") {
      if (tokenText.indexOf("<")) {
        var split1 = tokenText.split("<");
        var split2 = split1[1].split(">");
        highlightedCode +=
          split1[0] +
          "<" +
          colorCode +
          split2[0] +
          colors.default +
          ">" +
          split2[1];
      } else if (tokenText.indexOf('"')) {
        var split1 = tokenText.split('"');
        highlightedCode +=
          split1[0] +
          '"' +
          colorCode +
          split1[1] +
          colors.default +
          '"' +
          split1[2];
      }
      // console.log(highlightedCode)
      // console.log("--------")
    }
  });
  console.log(highlightedCode);
}
function completion(data) {}

const path = process.argv.slice(2);
const fileContent = fs.readFileSync(path[0], "utf-8");
highlight(fileContent);
// get_all1(fileContent);
// get_all2(fileContent);
