//
//  MessageCell.h
//  NouveauPG
//
//  Created by John Hill on 7/10/14.
//  Copyright (c) 2014 John Hill. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageCell : UITableViewCell {
    IBOutlet UILabel *m_encryptedDescriptor;
    IBOutlet UILabel *m_previewText;
    IBOutlet UILabel *m_dateText;
}

@end
