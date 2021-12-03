//
//  MediaCustomCell.swift
//  MeditationApp2
//
//  Created by 千葉和貴 on 2021/06/22.
//

import UIKit

class MediaCustomCell: UITableViewCell {

    @IBOutlet weak var thumbnailsImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
