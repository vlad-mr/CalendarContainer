//
//  ContactMode.swift
//  EventViewSDK
//
//  Created by Artem Grebinik on 07.08.2021.
//

import Foundation
import SwiftyBeaver

public let Logger = SwiftyBeaver.self

func configureLogger() {
    
    let console = ConsoleDestination()
    console.format = "$C$L$c $N.$F():$l - $M $C$c"
    
    console.levelColor.verbose = "🔷 🔷 "
    console.levelColor.debug = "🔰 🔰 "
    console.levelColor.info = "🍭 🍭 "
    console.levelColor.warning = "⚠️ ⚠️ "
    console.levelColor.error = "⛔️ ⛔️ "
    
    Logger.addDestination(console)
    
    #if RELEASE
    console.minLevel = .error
    #endif
}
