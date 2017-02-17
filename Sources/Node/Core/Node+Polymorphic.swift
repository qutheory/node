import Foundation

extension Node: Polymorphic {
    public var string: String? {
        switch self {
        case .bool(let bool):
            return "\(bool)"
        case .number(let number):
            return "\(number)"
        case .string(let string):
            return string
        case .date(let date):
            return Date.outgoingDateFormatter.string(from: date)
        default:
            return nil
        }
    }

    public var int: Int? {
        switch self {
        case .string(let string):
            return string.int
        case .number(let number):
            return number.int
        case .bool(let bool):
            return bool ? 1 : 0
        case .date(let date):
            return try? Date.outgoingTimestamp(date).int
        default:
            return nil
        }
    }

    public var uint: UInt? {
        switch self {
        case .string(let string):
            return string.uint
        case .number(let number):
            return number.uint
        case .bool(let bool):
            return bool ? 1 : 0
        case .date(let date):
            return try? Date.outgoingTimestamp(date).uint
        default:
            return nil
        }
    }

    public var double: Double? {
        switch self {
        case .number(let number):
            return number.double
        case .string(let string):
            return string.double
        case .bool(let bool):
            return bool ? 1.0 : 0.0
        case .date(let date):
            return try? Date.outgoingTimestamp(date).double
        default:
            return nil
        }
    }

    public var isNull: Bool {
        switch self {
        case .null:
            return true
        case .string(let string):
            return string.isNull
        default:
            return false
        }
    }

    public var bool: Bool? {
        switch self {
        case .bool(let bool):
            return bool
        case .number(let number):
            return number.bool
        case .string(let string):
            return string.bool
        case .null:
            return false
        default:
            return nil
        }
    }

    public var float: Float? {
        switch self {
        case .number(let number):
            return Float(number.double)
        case .string(let string):
            return string.float
        case .bool(let bool):
            return bool ? 1.0 : 0.0
        case .date(let date):
            let double = try? Date.outgoingTimestamp(date).double
            return double.flatMap { Float($0) }
        default:
            return nil
        }
    }

    public var array: [Polymorphic]? {
        switch self {
        case .array(let array):
            return array.map { $0 }
        case .string(let string):
            return string.array
        default:
            return nil
        }
    }
    
    public var date: Date? {
        switch self {
        case .string(let string):
            return Date.iso8601Formatter.date(from: string)
        case .number(let number):
            return Date.init(timeIntervalSince1970: TimeInterval(number.int))
        case .date(let date):
            return date
        default:
            return nil
        }
    }

    public var object: [String: Polymorphic]? {
        guard case let .object(ob) = self else { return nil }
        var object: [String: Polymorphic] = [:]

        ob.forEach { key, value in
            object[key] = value
        }

        return object
    }

    public var bytes: [UInt8]? {
        switch self {
        case .bytes(let bytes):
            return bytes
        case .string(let string):
            return string.bytes
        default:
            return nil
        }
    }
}
