import Vapor

enum TestError: Error {
    case NotEnoughBudgetError, PlayerNotTransferable
}
