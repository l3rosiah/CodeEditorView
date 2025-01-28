//
//  GCodeConfiguration.swift
//
//
//  Created by Josiah Rynne on 1/27/25.
//

import Foundation
import RegexBuilder

private let gcodeCommands = [
    "G0", "G1", "G2", "G3", "G4", "G28", "G90", "G91", "G92", // Common G commands
    "M0", "M1", "M3", "M4", "M5", "M6", "M30" // Common M commands
]

extension LanguageConfiguration {

    /// Language configuration for GCode
    ///
    public static func gcode(_ languageService: LanguageService? = nil) -> LanguageConfiguration {

        // Regex for matching GCode commands (e.g., G1, M3)
        let commandRegex: Regex<Substring> = Regex {
            ChoiceOf {
                "G"
                "M"
            }
            OneOrMore(.digit) // Match one or more digits after "G" or "M"
        }

        // Regex for matching parameters (e.g., X10.0, Y20, Z-5.5)
        let parameterRegex: Regex<Substring> = Regex {
            ChoiceOf {
                "X"
                "Y"
                "Z"
                "E"
                "F"
            }
            Optionally {
                "-"
            }
            OneOrMore(.digit) // Match one or more digits
            Optionally {
                "." // Decimal point
                OneOrMore(.digit)
            }
        }

        // Regex for matching comments (e.g., ; This is a comment or (This is a comment))
        let commentRegex: Regex<Substring> = Regex {
            ChoiceOf {
                ";" // Semicolon-style comment
                "(" // Parentheses-style comment
            }
            ZeroOrMore {
                /[^);]/ // Match everything except closing comment delimiters
            }
            ChoiceOf {
                "" // For semicolon-style comments
                ")" // For parentheses-style comments
            }
        }

        // Regex for matching numbers (used in parameters)
        let numberRegex: Regex<Substring> = Regex {
            Optionally {
                "-" // Optional negative sign
            }
            OneOrMore(.digit) // Match one or more digits
            Optionally {
                "." // Decimal point
                OneOrMore(.digit)
            }
        }

        return LanguageConfiguration(
            name: "GCode",
            supportsSquareBrackets: false,
            supportsCurlyBrackets: false,
            stringRegex: nil, // GCode doesn't have string literals
            characterRegex: nil, // GCode doesn't have single characters
            numberRegex: numberRegex,
            singleLineComment: ";", // Common single-line comment style in GCode
            nestedComment: (open: "(", close: ")"), // GCode supports inline comments using parentheses
            identifierRegex: commandRegex,
            operatorRegex: parameterRegex,
            reservedIdentifiers: gcodeCommands,
            reservedOperators: [],
            languageService: languageService
        )
    }
}
