import * as chrono from 'chrono-node';
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
export declare const customParsers: {
    tod: {
        pattern: () => RegExp;
        extract: () => {
            day: number;
            month: number;
            year: number;
        };
    };
    toda: {
        pattern: () => RegExp;
        extract: () => {
            day: number;
            month: number;
            year: number;
        };
    };
    tom: {
        pattern: () => RegExp;
        extract: () => {
            day: number;
            month: number;
            year: number;
        };
    };
    tmrw: {
        pattern: () => RegExp;
        extract: () => {
            day: number;
            month: number;
            year: number;
        };
    };
    tmw: {
        pattern: () => RegExp;
        extract: () => {
            day: number;
            month: number;
            year: number;
        };
    };
    tmr: {
        pattern: () => RegExp;
        extract: () => {
            day: number;
            month: number;
            year: number;
        };
    };
    addMinutes: {
        pattern: () => RegExp;
        extract: (context: any, match: any) => {
            day: number;
            month: number;
            year: number;
            minute: number;
            hour: number;
        };
    };
};
export declare const extractDateAndText: (customChrono: chrono.Chrono, text: string, options: IExtractDataFromTextOptions) => IExtractedDateAndText;
