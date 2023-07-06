declare type GenericDate = Date | string | number;

export class DateTimeHelper {
  public static isSameDay = (dateA: GenericDate, dateB: GenericDate): boolean => {
    if (!DateTimeHelper.isDateObject(dateA)) {
      dateA = new Date(dateA)
    }
    if (!DateTimeHelper.isDateObject(dateB)) {
      dateB = new Date(dateB)
    }
    return DateTimeHelper.toStandardDateString(dateA) === DateTimeHelper.toStandardDateString(dateB)
  }

  public static today = (): Date => {
    const dateObj = new Date()
    dateObj.setHours(0, 0, 0, 0)
    return dateObj
  }

  public static tomorrow = () => (
    DateTimeHelper.addDays(DateTimeHelper.today(), 1)
  )

  public static addDays = (date: GenericDate, days = 0): Date => {
    const clonedDate = new Date(date)
    return new Date(clonedDate.setDate(clonedDate.getDate() + days))
  }

  public static addTime = (date: GenericDate, time: number = 0) => {
    const clonedDate = new Date(date)
    return new Date(clonedDate.getTime() + time)
  }

  public static addSeconds = (date: GenericDate, seconds: number = 0) => (
    DateTimeHelper.addTime(date, seconds * 1000)
  )

  public static addMinutes = (date: GenericDate, minutes: number = 0) => (
    DateTimeHelper.addSeconds(date, minutes * 60)
  )

  public static resetTime = (date: GenericDate) => {
    if (typeof date === 'string' && date.length === 10) {
      // if the date is a string with only the date, add the time, otherwise the date will be set to the current time in GMT
      date += ' 00:00:00'
    }
    const clonedDate = new Date(date)
    clonedDate.setHours(0, 0, 0, 0)
    return clonedDate
  }

  public static toStandardDateString = (genericDate: GenericDate, separator = '-'): string => {
    const date = !DateTimeHelper.isDateObject(genericDate) ? DateTimeHelper.resetTime(genericDate) : genericDate as Date
    return [
      date.getFullYear(),
      ('0' + (date.getMonth() + 1)).slice(-2),
      ('0' + date.getDate()).slice(-2)
    ].join(separator)
  }

  public static isDateObject = function (date: Date | string | number): boolean {
    return Object.prototype.toString.call(date) === '[object Date]' &&
      date instanceof Date &&
      !isNaN(date?.getTime())
  }
}
