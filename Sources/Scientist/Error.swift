//
//  Error.swift
//  Scientist
//
//  Created by Yusuke Ohashi on 2018/06/30.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import Foundation

/// Errors thrown by ``Experiment/run(name:)``.
public enum ExperimentError: Error {
  /// No behavior is registered under the requested name.
  ///
  /// Either the control was never registered with ``Experiment/use(control:)``, or the
  /// `"run"` option named a candidate that does not exist.
  case behaviorNotFound

  /// The behaviors ran, but no observation was produced for the requested name, so there
  /// is no value to return.
  case valueNotReturned

  /// A failure with no more specific case.
  case unknownError
}
