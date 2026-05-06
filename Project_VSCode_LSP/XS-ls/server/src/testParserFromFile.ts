import fs from "fs";
import { CharStreams, CommonTokenStream } from "antlr4ts";

import { XSLexer } from "../grammar/parser/XSLexer";
import { XSParser } from "../grammar/parser/XSParser";
import { argv, exit } from "process";


argv.forEach((val, index) => {
    if (index < 3) { return }
    const filePath = process.argv[index];
    console.log(`${index}: ${val}`);


    if (!filePath) {
        console.error("Usage: ts-node testParserFromFile.ts <file.xs>");
        process.exit(1);
    }

    // 1. Read file
    const code = fs.readFileSync(filePath, "utf-8");

    // 2. Create input stream
    const input = CharStreams.fromString(code);

    // 3. Lexer
    const lexer = new XSLexer(input);
    const tokens = new CommonTokenStream(lexer);

    // 4. Parser
    const parser = new XSParser(tokens);

    // OPTIONAL: remove default error spam
    parser.removeErrorListeners();

    parser.addErrorListener({
        syntaxError: (rec, sym, line, col, msg) => {
            console.log(`Syntax error at ${line}:${col}: ${msg}`);
            exit()
        }
    });

    // // 5. Parse entry rule
    // const tree = parser.program();

    // // 6. Output
    console.log(`✅${index}: Parse successful`);
    // console.log(tree.toStringTree(parser.ruleNames));

});