import Collections from 'System/Collections/Generic';
import { Keywords } from '../../../static_analysis/keywords.ph';
import { Lexer } from '../../parsing/lexer.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import { CSTHelper } from '../cst_helper.ph';
import { TypeExpressionNode } from './type_expression_node.ph';

export class TypeIdentifierExpressionNode extends TypeExpressionNode {
    public get name(): string {
        return CSTHelper.GetFirstCodingToken(this).value;
    }

    public static ParseTypeIdentifierExpression(lexer: Lexer): TypeIdentifierExpressionNode {
        const units = new Collections.List<LogicalCodeUnit>();
        if (lexer.IsIdentifier()) {
            units.AddRange(lexer.GetIdentifier());
        } else {
            units.AddRange(
                lexer.GetOneOfKeywords(
                    //prettier-ignore
                    <string>[
                            "undefined",
                            Keywords.STRING,
                            Keywords.BOOL,
                            Keywords.INT,
                            Keywords.FLOAT,
                            Keywords.VOID,
                            Keywords.DOUBLE,
                            Keywords.UINT,
                            Keywords.LONG,
                            Keywords.ULONG,
                            Keywords.SHORT,
                            Keywords.USHORT,
                            Keywords.BYTE,
                            Keywords.SBYTE,
                            Keywords.CHAR,
                            Keywords.DECIMAL,
                            Keywords.OBJECT,
                            Keywords.ANY,
                            Keywords.NINT,
                            Keywords.NUINT,
                            Keywords.NULL,
                        ],
                ),
            );
        }
        return new TypeIdentifierExpressionNode(units);
    }
}
