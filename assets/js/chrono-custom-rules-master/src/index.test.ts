import { describe, test, expect, jest } from '@jest/globals'
import { ChronoHelper } from '.'

describe('Test expected parsing results', () => {
  test('should return today at 17:00', () => {
    const todayAt8 = new Date()
    todayAt8.setHours(8, 0, 0, 0)
    const result = ChronoHelper.extractDateAndText('do stuff at 5pm', {
      forwardDate: true,
      forwardFrom: todayAt8,
      startDayHour: 8
    })
    expect(result.date).toBeInstanceOf(Date)
    expect(result.date?.getHours()).toBe(17)
  })

  test('should return undefined', () => {
    const todayAt8 = new Date()
    todayAt8.setHours(8, 0, 0, 0)
    const result = ChronoHelper.extractDateAndText('do stuff the day', {
      forwardDate: true,
      forwardFrom: todayAt8,
      startDayHour: 8
    })
    expect(result.date).toBe(undefined)
  })

  test('should return undefined when only `s` is used to define a time', () => {
    const todayAt8 = new Date()
    todayAt8.setHours(8, 0, 0, 0)
    const result = ChronoHelper.extractDateAndText('do stuff in 5s', {
      forwardDate: true,
      forwardFrom: todayAt8,
      startDayHour: 8
    })
    expect(result.date).toBe(undefined)
  })
  
  test('should return a time after few seconds from now', () => {
    const todayAt8 = new Date()
    todayAt8.setHours(8, 0, 0, 0)
    const result = ChronoHelper.extractDateAndText('do stuff in 5sec', {
      forwardDate: true,
      forwardFrom: todayAt8,
      startDayHour: 8
    })
    expect(result.date).toBeInstanceOf(Date)
    expect(result.date?.getTime()).toBeGreaterThan(todayAt8.getTime())
  })
})
