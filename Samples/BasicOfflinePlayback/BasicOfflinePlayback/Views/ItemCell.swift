//
//  ItemCell.swift
//  BasicOfflinePlayback
//
//  Created by Tsung Cheng Lo on 2024/1/5.
//

import BVPlayer
import UIKit

final class ItemCell: UITableViewCell {

    static let identifier = "ItemCell"

    var sourceConfig: UniSourceConfig? {
        didSet {
            textLabel?.text = sourceConfig?.title
            detailTextLabel?.text = sourceConfig?.sourceDescription
        }
    }
}
