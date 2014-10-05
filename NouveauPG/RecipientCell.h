//
//  RecipientCell.h
//  NouveauPG
//
//  Created by John Hill on 5/4/14.
//  Copyright (c) 2014 John Hill. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IdenticonView.h"

@interface RecipientCell : UITableViewCell {
    IBOutlet UILabel *m_publicKeyAlgo;
    IBOutlet UILabel *m_keyId;
    IBOutlet UILabel *m_name;
    IBOutlet UILabel *m_email;
    IBOutlet IdenticonView *m_indenticonView;
    IBOutlet UIImageView *m_warningImage;
}

- (void) setPublicKeyAlgo:(NSString *)publicKeyAlgo;
- (void) setKeyId:(NSString *)keyId;
- (void) setName:(NSString *)name;
- (void) setEmail:(NSString *)email;
- (void) setIdenticonCode: (NSInteger)newIdenticonCode;
- (void) showWarning: (NSString *)warning;

@end
