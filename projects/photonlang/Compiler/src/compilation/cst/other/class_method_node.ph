import { Lexer } from '../../parsing/lexer.ph';
import { CSTNode } from '../basic/cst_node.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import Collections from 'System/Collections/Generic';
import { Keywords } from '../../../static_analysis/keywords.ph';
import { FunctionArgumentsDeclarationNode } from './function_arguments_declaration_node.ph';
import { TypeExpressionNode } from '../type_expressions/type_expression_node.ph';
import { BlockStatementNode } from '../statements/block_statement_node.ph';
import { Exception } from 'System';
import { TypeDeclarationNode } from './type_declaration_node.ph';

export class ClassMethodNode extends CSTNode {
    public static ParseClassMethod(lexer: Lexer): ClassMethodNode {
        const units = new Collections.List<LogicalCodeUnit>();

        if (lexer.IsOneOfKeywords(<string>[Keywords.PUBLIC, Keywords.PRIVATE, Keywords.PROTECTED])) {
            units.AddRange(lexer.GetKeyword());
        }

        let isStatic = false;
        let isConstructor = false;
        let isAbstract = false;

        if (lexer.IsKeyword(Keywords.STATIC)) {
            isStatic = true;
            units.AddRange(lexer.GetKeyword());
        }

        if (lexer.IsKeyword(Keywords.ABSTRACT)) {
            isAbstract = true;
            units.AddRange(lexer.GetKeyword());
        }

        if (lexer.IsKeyword(Keywords.CONSTRUCTOR)) {
            if (isStatic) {
                throw new Exception('Static constructors are not allowed');
            }
            isConstructor = true;
            units.AddRange(lexer.GetKeyword());
        } else {
            units.AddRange(lexer.GetIdentifier());
        }

        units.Add(FunctionArgumentsDeclarationNode.ParseFunctionArgumentsDeclaration(lexer));

        if (!isConstructor) {
            units.Add(TypeDeclarationNode.ParseTypeDeclaration(lexer));
        }

        if (isAbstract) {
            units.AddRange(lexer.GetPunctuation(';'));
        } else {
            units.Add(BlockStatementNode.ParseBlockStatement(lexer));
        }

        return new ClassMethodNode(units);
    }
}
