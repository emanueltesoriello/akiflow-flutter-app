import * as chrono from 'chrono-node'
import { DateTimeHelper } from './DateTimeHelper'
import { StringHelper } from './StringHelper'

export interface IExtractedDateAndText {
  textWithoutDate: string
  date?: Date
  hasTime?: boolean
  hasDate?: boolean
  hasMeridiem?: boolean
  parseResult?: any
}

export interface IExtractDataFromTextOptions {
  forwardDate?: boolean
  forwardFrom?: Date
  startFromDate?: Date
  startDayHour?: number
  startFromDateTime?: Date
}

export const customParsers = {
  tod: {
    pattern: () => /\btod\b/i,
    extract: () => {
      const today = DateTimeHelper.today()
      return {
        day: today.getDate(),
        month: today.getMonth() + 1,
        year: today.getFullYear()
      }
    }
  },
  toda: {
    pattern: () => /\btoda\b/i,
    extract: () => {
      const today = DateTimeHelper.today()
      return {
        day: today.getDate(),
        month: today.getMonth() + 1,
        year: today.getFullYear()
      }
    }
  },
  tom: {
    pattern: () => /\btom\b/i,
    extract: () => {
      const tomorrow = DateTimeHelper.tomorrow()
      return {
        day: tomorrow.getDate(),
        month: tomorrow.getMonth() + 1,
        year: tomorrow.getFullYear()
      }
    }
  },
  tmrw: {
    pattern: () => /\btmrw\b/i,
    extract: () => {
      const tomorrow = DateTimeHelper.tomorrow()
      return {
        day: tomorrow.getDate(),
        month: tomorrow.getMonth() + 1,
        year: tomorrow.getFullYear()
      }
    }
  },
  tmw: {
    pattern: () => /\btmw\b/i,
    extract: () => {
      const tomorrow = DateTimeHelper.tomorrow()
      return {
        day: tomorrow.getDate(),
        month: tomorrow.getMonth() + 1,
        year: tomorrow.getFullYear()
      }
    }
  },
  tmr: {
    pattern: () => /\btmr\b/i,
    extract: () => {
      const tomorrow = DateTimeHelper.tomorrow()
      return {
        day: tomorrow.getDate(),
        month: tomorrow.getMonth() + 1,
        year: tomorrow.getFullYear()
      }
    }
  },
  addMinutes: {
    pattern: () => /\b(\d+)(\s?)(m)\b/i,
    extract: (context, match) => {
      const minutes = parseInt(match[1])
      if (minutes) {
        const updatedDate = DateTimeHelper.addMinutes(context.refDate, minutes)
        return {
          day: updatedDate.getDate(),
          month: updatedDate.getMonth() + 1,
          year: updatedDate.getFullYear(),
          minute: updatedDate.getMinutes(),
          hour: updatedDate.getHours()
        }
      }
    }
  }
}

export const extractDateAndText = function (customChrono: chrono.Chrono, text: string, options: IExtractDataFromTextOptions) {
  const forwardFrom = options?.forwardFrom || new Date()
  forwardFrom.setMilliseconds(0)

  customChrono.refiners.push({
    refine: (_, results) => {
      results.forEach((result) => {
        const date = result.start.date()
        // if there's no am/pm we imply if hour is earlier than ref date
        // we either increase meridiem or bump to next day
        const impliedHourDifference = forwardFrom.getHours() - (result?.start?.get?.('hour') ?? 0)
        const hasTime = result.start.isCertain('hour') || result.start.isCertain('minute')
        if (hasTime && !result.start.isCertain('meridiem') && DateTimeHelper.isSameDay(date, forwardFrom)) {
          if (impliedHourDifference > 0 && impliedHourDifference <= 12) {
            result.start.assign('meridiem', 1)
            result.start.assign('hour', (result?.start?.get?.('hour') ?? 0) + 12)
          } else if (impliedHourDifference > 0) {
            // eslint-disable-next-line dot-notation
            result.start.imply('day', result.start['impliedValues'].day + 1)
          }
        }
      })
      return results
    }
  }, {
    refine: (_, results) => {
      results.forEach((result) => {
        // if part of day let's assign time & not just imply it
        const partOfDayWords = ['now', 'morning', 'noon', 'afternoon', 'evening', 'night']
        const partOfDayRegex = new RegExp('\\b' + partOfDayWords.join('\\b|\\b') + '\\b', 'gi')
        if (result.text) {
          const matches = result.text.match(partOfDayRegex)
          if (matches?.length) {
            const match = matches[0]
            switch (match) {
              case 'now': {
                const now = new Date()
                result.start.assign('hour', now.getHours())
                result.start.assign('minute', now.getMinutes())
                break
              }
              case 'morning':
                result.start.assign('meridiem', 0)
                result.start.assign('hour', options?.startDayHour ?? 9)
                break
              case 'noon':
                result.start.assign('meridiem', 1)
                result.start.assign('hour', 12)
                break
              case 'afternoon':
                result.start.assign('meridiem', 1)
                result.start.assign('hour', 14)
                break
              case 'evening':
                result.start.assign('meridiem', 1)
                result.start.assign('hour', 18)
                break
              case 'night':
                result.start.assign('meridiem', 1)
                result.start.assign('hour', 22)
                break
            }
          }
        }
      })
      return results
    }
  }, {
    refine: (context, results) => (
      results.filter((result) => {
      // allow certain month-only (without day) parsing only if previous word is "in"
        const isMonthWithoutDay = result.start && result.start.isCertain('month') && !result.start.isCertain('day')
        if (result.text && isMonthWithoutDay) {
          const matches = context.text.match(new RegExp(`\\w+(?=\\s+${result.text})`, 'i'))
          return !!matches?.length && matches[0].toLowerCase() === 'in'
        }
        return true
      }))
  }, {
    refine: (_, results) => (
      // fix: chrono parses "any" word as "an year" wrongly
      results.filter((result) => !result.text.startsWith('any'))
    )
  }, {
    refine: (_, results) => {
      // Check if all these conditions are met:
      //   - there are exactly 2 results
      //   - in each result, day is uncertain and one of the months is uncertain
      //   - the two results have a different hour
      // If so, we can assume that the user meant to specify the day and month, and then the hour
      if (results.length !== 2) {
        return results
      }
      const bothCertainDay = results.every((result) => result.start.isCertain('day'))
      const atLeastOneCertainMonth = results.some((result) => result.start.isCertain('month'))
      const allHourAreEqual = results.every((result) => result.start.get('hour') === results[0].start.get('hour'))
      if (!bothCertainDay && !atLeastOneCertainMonth && !allHourAreEqual) {
        // We are unsure of the day and at least one month, and we have different hours
        // We can assume that the user meant to specify the day and month, and then the hour
        // Note: assuming the date comes first is not always correct, but it's a good guess
        results[0].start.assign('day', (results?.[0]?.start?.get?.('day') ?? 0))
        results[0].start.assign('hour', (results?.[1]?.start?.get?.('hour') ?? 0))
        results[0].start.assign('minute', (results?.[1]?.start?.get?.('minute') ?? 0))
        results[1].start.assign('day', (results?.[0]?.start?.get?.('day') ?? 0))
      }
      return results
    }
  }, {
    refine: (_, results) => {
      const hasCertainDayMonth = results.some((result) => result.start.isCertain('day') && result.start.isCertain('month'))
      if (hasCertainDayMonth) {
        return results
      }
      const hasCertainHour = results.some((result) => result.start.isCertain('hour'))
      if (!hasCertainHour) {
        return results
      }
      const now = new Date()
      const isToday = results.every((result) => DateTimeHelper.isSameDay(result.start.date(), now))
      if (isToday) {
        const isInPast = results.every((result) => (result?.start?.get?.('hour') ?? 0) < now.getHours() || (result.start.get('hour') === now.getHours() && (result?.start?.get?.('minute') ?? 0) < now.getMinutes()))
        if (isInPast) {
          results.forEach((result) => {
            result.start.imply('day', (result?.start?.get?.('day') ?? 0) + 1)
          })
        }
      }
      return results
    }
  })

  const parseResults = customChrono.parse(text, forwardFrom, options)
    .sort((resultA, resultB) => {
      // sort by with "in" word, ascending
      const matchesInResultA = text.match(new RegExp(`\\w+(?=\\s+${resultA.text})`, 'i'))
      const matchesInResultB = text.match(new RegExp(`\\w+(?=\\s+${resultB.text})`, 'i'))
      const isMatchinInResultA = !!matchesInResultA?.length && matchesInResultA[0].toLowerCase() === 'in'
      const isMatchinInResultB = !!matchesInResultB?.length && matchesInResultB[0].toLowerCase() === 'in'
      return Math.sign(+isMatchinInResultA - +isMatchinInResultB)
    })

  const parseResult = parseResults?.length ? parseResults[parseResults.length - 1] : null

  let extractedDateAndText: IExtractedDateAndText = { date: undefined, textWithoutDate: text }
  if (parseResult) {
    const date = parseResult.start.date()
    const regularExpressionWithTimeToRemove = new RegExp('(^|\\s)(in\\s+)?' + StringHelper.escapeRegExp(parseResult.text), 'g')
    const textWithoutDate = text.replace(regularExpressionWithTimeToRemove, '')
    if (parseResult.start.isCertain('weekday') &&
      !parseResult.start.isCertain('day') &&
      !parseResult.start.isCertain('month') &&
      !parseResult.start.isCertain('year') &&
      date.toDateString() === (new Date()).toDateString()) {
      // if the the user wrote "friday 3pm" and today is friday, we want to suggest next friday. Chrono suggests today
      date.setDate(date.getDate() + 7)
    }

    const hasTime = parseResult.start.isCertain('hour') || parseResult.start.isCertain('minute')

    if (options?.startFromDateTime && date < options.startFromDateTime) {
      if (options?.startFromDate && date >= options.startFromDate && !hasTime) {
        // allow dates without time
      } else {
        return extractedDateAndText
      }
    }

    extractedDateAndText = {
      date,
      textWithoutDate,
      hasTime,
      hasDate: parseResult.start.isCertain('day') || parseResult.start.isCertain('month') || parseResult.start.isCertain('year') || parseResult.start.isCertain('weekday') || date.toDateString() !== (new Date()).toDateString(),
      hasMeridiem: parseResult.start.isCertain('meridiem'),
      parseResult
    }
  }
  return extractedDateAndText
}