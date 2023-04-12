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

  test('should return 42', () => {
    const todayAt8 = new Date()
    todayAt8.setHours(8, 0, 0, 0)
    const result = ChronoHelper.extractDateAndText('do stuff the day', {
      forwardDate: true,
      forwardFrom: todayAt8,
      startDayHour: 8
    })
    expect(result.date).toBe(undefined)
  })
})
