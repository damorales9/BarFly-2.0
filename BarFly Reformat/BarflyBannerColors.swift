//
//  BarflyBannerColors.swift
//  BarFly Reformat
//
//  Created by Ben Pazienza on 11/21/19.
//  Copyright © 2019 LoFi Games. All rights reserved.
//

import Foundation
import NotificationBannerSwift

class BarflyBannerColors: BannerColorsProtocol {

    internal func color(for style: BannerStyle) -> UIColor {
        switch style {
        case .danger:    return .red
        case .info:        return .barflyblue
        case .customView:    return .clear
        case .success:    return .green
        case .warning:    return .yellow
        }
    }

}
