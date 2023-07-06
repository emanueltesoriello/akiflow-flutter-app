export class StringHelper {
  public static escapeRegExp = function (text: string): string {
    if (typeof text !== 'string') {
      return text
    }
    return text.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
  }
}
