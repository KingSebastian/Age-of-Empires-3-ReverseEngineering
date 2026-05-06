import { CharStreams, CommonTokenStream } from "antlr4ts";
import { XSLexer } from "../grammar/parser/XSLexer";
import { XSParser } from "../grammar/parser/XSParser";

const input = `
int x = 5;
if (x > 3) {
    x = x + 1;
}
`;

const chars = CharStreams.fromString(input);
const lexer = new XSLexer(chars);
const tokens = new CommonTokenStream(lexer);
const parser = new XSParser(tokens);

const tree = parser.program();

console.log(tree.toStringTree(parser.ruleNames));