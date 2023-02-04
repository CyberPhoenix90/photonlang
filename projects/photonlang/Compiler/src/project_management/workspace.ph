import { Solution } from './solution.ph';
import Collections from 'System/Collections/Generic';

export class Workspace {
    public readonly solutions: Collections.List<Solution> = new Collections.List<Solution>();
}
