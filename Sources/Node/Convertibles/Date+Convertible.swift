import Foundation

extension Date: NodeConvertible {
    /**
        If a date receives a numbered node, it will use this closure
        to convert that number into a Date as a timestamp
     
        By default, this timestamp uses seconds via timeIntervalSince1970.
     
        Override for custom implementations
    */
    public static var incomingTimestamp: (Node.Number) throws -> Date = {
        return Date(timeIntervalSince1970: $0.double)
    }

    /**
        In default scenarios where a timestamp should be represented as a 
        Number, this closure will be used.
     
        By default, uses seconds via timeIntervalSince1970.
     
        Override for custom implementations.
    */
    public static var outgoingTimestamp: (Date) throws -> Node.Number = {
        return Node.Number($0.timeIntervalSince1970)
    }

    /**
        A prioritized list of date formatters to use when attempting
        to parse a String into a Date.
     
        Override for custom implementations, or to remove supported formats
    */
    public static var incomingDateFormatters: [DateFormatter] = [
        .iso8601(),
        .mysql(),
        .rfc1123()
    ]

    /**
        A default formatter to use when serializing a Date object to 
        a String.
     
        Defaults to ISO 8601
     
        Override for custom implementations.
     
        For complex scenarios where various string representations must be used,
        the user is responsible for handling their date formatting manually.
    */
    public static var outgoingDateFormatter: DateFormatter = .iso8601()

    /**
        Initializes a Date object with another Node.date, a number representing a timestamp,
        or a formatted date string corresponding to one of the `incomingDateFormatters`.
    */
    public init(node: Node) throws {
        switch node.wrapped {
        case let .date(date):
            self = date
        case let .number(number):
            self = try Date.incomingTimestamp(number)
        case let .string(string):
            guard
                let date = Date.incomingDateFormatters
                    .lazy
                    .flatMap({ $0.date(from: string) })
                    .first
                else { fallthrough }
            self = date
        default:
            throw NodeError.unableToConvert(
                input: node,
                expectation: "\(Date.self), formatted time string, or timestamp",
                path: []
            )
        }
    }

    /// Creates a node representation of the date
    public func makeNode(in context: Context?) throws -> Node {
        return .date(self, in: context)
    }
}

extension StructuredData {
    public var date: Date? {
        return try? Date(node: self, in: nil)
    }
}

extension DateFormatter {
    /**
        ISO8601 Date Formatter -- preferred in JSON

        http://stackoverflow.com/a/28016692/2611971
    */
	public static func iso8601() -> DateFormatter {
		if let formatter = Thread.current.threadDictionary["codes.vapor.iso8601DateFormatter"] as? DateFormatter {
			return formatter
		}
		else {
			let formatter = DateFormatter()

			formatter.locale = Locale(identifier: "en_US_POSIX")
			formatter.timeZone = TimeZone(secondsFromGMT: 0)
			formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"

			Thread.current.threadDictionary["codes.vapor.iso8601DateFormatter"] = formatter

			return formatter
		}
	}
}

extension DateFormatter {
    /**
        A date formatter for mysql formatted types
    */
	public static func mysql() -> DateFormatter {
		if let formatter = Thread.current.threadDictionary["codes.vapor.mysqlDateFormatter"] as? DateFormatter {
			return formatter
		}
		else {
			let formatter = DateFormatter()

			formatter.timeZone = TimeZone(abbreviation: "UTC")
			formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

			Thread.current.threadDictionary["codes.vapor.mysqlDateFormatter"] = formatter

			return formatter
		}
	}
}

extension DateFormatter {
    /**
        A date formatter conforming to RFC 1123 spec
    */
	public static func rfc1123() -> DateFormatter {
		if let formatter = Thread.current.threadDictionary["codes.vapor.rfc1123DateFormatter"] as? DateFormatter {
			return formatter
		}
		else {
			let formatter = DateFormatter()

			formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"

			Thread.current.threadDictionary["codes.vapor.rfc1123DateFormatter"] = formatter

			return formatter
		}
	}
}
