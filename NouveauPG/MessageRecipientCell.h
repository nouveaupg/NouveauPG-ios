//
//  MessageRecipientCell.h
//  NouveauPG
//
//  Created by John Hill on 8/8/14.
//  Copyright (c) 2014 John Hill. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IdenticonView.h"

@interface MessageRecipientCell : UITableViewCell {
    IBOutlet UILabel *m_name;
    IBOutlet UILabel *m_keyInfo;
    IBOutlet UILabel *m_email;
    IBOutlet IdenticonView *m_identiconView;
    IBOutlet UIImageView *m_warningImage;
}

-(void)setName:(NSString *)name;
-(void)setEmail:(NSString *)email;
-(void)setKeyInfo:(NSString *)keyInfo;
-(void)setIdenticonCode:(NSInteger)identiconCode;
-(void)showWarning: (NSString *)warning;


@end
