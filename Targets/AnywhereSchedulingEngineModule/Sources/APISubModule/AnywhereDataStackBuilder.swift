//
//  AnywhereDataStackBuilder.swift
//  AnywhereDataStack
//
//  Created by Illia Postoienko on 23.07.2021.
//

import Foundation

public enum AnywhereDataStackBuilder {

  public static func buildProvider() -> AnywhereDataProviderType {
    AnywhereDataProvider()
  }
}
