import { Lexer } from '../../parsing/lexer.ph';
import { CSTNode } from '../basic/cst_node.ph';
import { LogicalCodeUnit } from '../basic/logical_code_unit.ph';
import Collections from 'System/Collections/Generic';
import { Keywords } from '../../../project_management/keywords.ph';
import { CSTHelper } from '../cst_helper.ph';

export class AccessorNode extends CSTNode {
    public get accessor(): string {
        return CSTHelper.GetFirstCodingToken(this).value;
    }

    public static ParseAccessor(lexer: Lexer): AccessorNode {
        const units = new Collections.List<LogicalCodeUnit>();

        units.AddRange(lexer.GetOneOfKeywords(<string>[Keywords.PUBLIC, Keywords.PRIVATE, Keywords.PROTECTED]));

        return new AccessorNode(units);
    }
}
