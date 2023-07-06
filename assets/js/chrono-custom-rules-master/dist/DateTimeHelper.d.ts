declare type GenericDate = Date | string | number;
export declare class DateTimeHelper {
    static isSameDay: (dateA: GenericDate, dateB: GenericDate) => boolean;
    static today: () => Date;
    static tomorrow: () => Date;
    static addDays: (date: GenericDate, days?: number) => Date;
    static addTime: (date: GenericDate, time?: number) => Date;
    static addSeconds: (date: GenericDate, seconds?: number) => Date;
    static addMinutes: (date: GenericDate, minutes?: number) => Date;
    static resetTime: (date: GenericDate) => Date;
    static toStandardDateString: (genericDate: GenericDate, separator?: string) => string;
    static isDateObject: (date: Date | string | number) => boolean;
}
export {};
