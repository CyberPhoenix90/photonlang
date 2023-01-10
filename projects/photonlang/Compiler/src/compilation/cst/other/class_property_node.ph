import { Lexer } from '../../parsing/lexer.ph';
import { CSTNode } from '../basic/cst_node.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import Collections from 'System/Collections/Generic';
import { Keywords } from '../../../static_analysis/keywords.ph';
import { TypeDeclarationNode } from './type_declaration_node.ph';
import { BlockStatementNode } from '../statements/block_statement_node.ph';
import { IdentifierExpressionNode } from '../expressions/identifier_expression_node.ph';

export class ClassPropertyNode extends CSTNode {
    public static ParseClassProperty(lexer: Lexer): ClassPropertyNode {
        const units = new Collections.List<LogicalCodeUnit>();
        let isAbstract = false;

        if (lexer.IsOneOfKeywords(<string>[Keywords.PUBLIC, Keywords.PRIVATE, Keywords.PROTECTED])) {
            units.AddRange(lexer.GetKeyword());
        }

        if (lexer.IsKeyword(Keywords.STATIC)) {
            units.AddRange(lexer.GetKeyword());
        }

        if (lexer.IsKeyword(Keywords.ABSTRACT)) {
            isAbstract = true;
            units.AddRange(lexer.GetKeyword());
        }

        const isSet = lexer.IsKeyword(Keywords.SET);
        units.AddRange(lexer.GetOneOfKeywords(<string>[Keywords.GET, Keywords.SET]));
        units.Add(IdentifierExpressionNode.ParseIdentifierExpression(lexer));

        units.AddRange(lexer.GetPunctuation('('));

        if (isSet) {
            units.AddRange(lexer.GetIdentifier());
            if (lexer.IsPunctuation(':')) {
                units.Add(TypeDeclarationNode.ParseTypeDeclaration(lexer));
            }
        }
        units.AddRange(lexer.GetPunctuation(')'));

        if (!isSet) {
            units.Add(TypeDeclarationNode.ParseTypeDeclaration(lexer));
        }

        if (!isAbstract) {
            units.Add(BlockStatementNode.ParseBlockStatement(lexer));
        } else {
            units.AddRange(lexer.GetPunctuation(';'));
        }

        return new ClassPropertyNode(units);
    }
}
