//
//  LanguageService.swift
//  
//
//  Created by Manuel M T Chakravarty on 10/01/2023.
//
//  This file defines the interface for external services (such as an LSP server) to provide language-specific
//  syntactic and semantic information to the code editor for a single file. It uses `Combine` for the asynchronous
//  communication between information providers and the code editor, where necessary.
//
//  An instance of a language service is specific to a single file. Hence, locations etc are always relative to the file
//  associated with the used language service.

import SwiftUI
import Combine


/// Provider of document-specific location information for a language service.
///
public protocol LocationService: LocationConverter {

  /// Yields the length of the given line.
  ///
  /// - Parameter line: The line of which we want to know the length, starting from 0.
  /// - Returns: The length (number of characters) of the given line, including any trainling newline character, or
  ///     `nil` if the line does not exist.
  ///
  func length(of line: Int) -> Int?
}

/// Function that instantiates a language service from a location converter.
///
public typealias LanguageServiceBuilder = (LocationService) async throws -> LanguageService

/// Determines the capabilities and endpoints for language-dependent external services, such as an LSP server.
///
public protocol LanguageService {
  
  /// Notifies the code editor about a new set of diagnoistic messages. A new set replaces the previous set (merging
  /// happens server-side, not client-side).
  ///
  var diagnostics: CurrentValueSubject<Set<TextLocated<Message>>, Never> { get }

  /// Requests semantic token information for all tokens in the given line range.
  ///
  /// - Parameter lineRange: The lines whose semantic token information is being requested. The line count is zero-based.
  /// - Returns: Semantic tokens together with their line-relative character range divided up per line. The first
  ///     subarray contains the semantic tokens for the first line of `lineRange` and so on.
  ///
  /// The number of elements of the result is the same as the number of lines in the `lineRange`.
  ///
  func tokens(for lineRange: Range<Int>) async throws -> [[(token: LanguageConfiguration.Token, range: NSRange)]]

  /// Yields an info popover for the given location in the file associated with the current language service.
  ///
  /// - Parameter location: Index position in the associated textual representation of the code.
  /// - Returns: If semantic infotmation is available for the provided location, a view displaying that information is
  ///   being returned. Optionally, the view may be accompanied by the character range to which the returned information
  ///   pertains.
  ///
  ///   In case there is an error, such as an invalid location, the function is expected to throw. However, if there is
  ///   simply no extra information available for the given location, the function simply returns `nil`.
  ///
  func info(at location: Int) async throws -> (view: any View, anchor: NSRange?)?
}
