import Collections from 'System/Collections/Generic';
import { Lexer } from '../../parsing/lexer.ph';
import { CSTNode } from '../basic/cst_node.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { CSTHelper } from '../cst_helper.ph';
import { IdentifierExpressionNode } from '../expressions/identifier_expression_node.ph';
import { ArrayBindingNode } from './array_binding_node.ph';
import { InitializerNode } from './initializer_node.ph';
import { TypeDeclarationNode } from './type_declaration_node.ph';

export class VariableDeclarationNode extends CSTNode {
    public get name(): string {
        return CSTHelper.GetFirstChildByType<IdentifierExpressionNode>(this).name;
    }

    public get type(): TypeDeclarationNode | undefined {
        return CSTHelper.GetFirstChildByType<TypeDeclarationNode>(this);
    }

    public get initializer(): InitializerNode | undefined {
        return CSTHelper.GetFirstChildByType<InitializerNode>(this);
    }

    public get arrayBinding(): ArrayBindingNode | undefined {
        return CSTHelper.GetFirstChildByType<ArrayBindingNode>(this);
    }

    public static ParseVariableDeclaration(lexer: Lexer): VariableDeclarationNode {
        const units = new Collections.List<LogicalCodeUnit>();

        if (lexer.IsPunctuation("[")) {
            units.Add(ArrayBindingNode.ParseArrayBinding(lexer));

        } else {
            units.Add(IdentifierExpressionNode.ParseIdentifierExpression(lexer));
        }

        if (lexer.IsPunctuation(':')) {
            units.Add(TypeDeclarationNode.ParseTypeDeclaration(lexer));
        }
        if (lexer.IsPunctuation('=')) {
            units.Add(InitializerNode.ParseInitializer(lexer));
        }

        return new VariableDeclarationNode(units);
    }
}
