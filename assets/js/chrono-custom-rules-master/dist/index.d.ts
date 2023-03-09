export interface IExtractedDateAndText {
    textWithoutDate: string;
    date?: Date;
    hasTime?: boolean;
    hasDate?: boolean;
    hasMeridiem?: boolean;
    parseResult?: any;
}
export interface IExtractDataFromTextOptions {
    forwardDate?: boolean;
    forwardFrom?: Date;
    startFromDate?: Date;
    startDayHour?: number;
    startFromDateTime?: Date;
}
export declare class ChronoHelper {
    private static customChrono;
    static extractDateAndText: (text: string, options: IExtractDataFromTextOptions) => IExtractedDateAndText;
    private static setCustomChrono;
}
