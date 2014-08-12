//
//  MessageCell.m
//  NouveauPG
//
//  Created by John Hill on 7/10/14.
//  Copyright (c) 2014 John Hill. All rights reserved.
//

#import "MessageCell.h"

@implementation MessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setPreviewText: (NSString *)preview {
    [m_previewText setText:preview];
}

-(void)setDate: (NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [m_dateText setText:[formatter stringFromDate:date]];
}

-(void)setKeyId: (NSString *)keyId {
    if (keyId) {
        [m_encryptedDescriptor setText:@"PGP Encrypted Message"];
        [m_encryptedDescriptor setHidden:NO];
        [m_previewText setHidden:YES];
        
        NSInteger newIdenticonCode = 0;
        
        NSString *input = [keyId uppercaseString];
        for (int i = 0; i < 8; i++) {
            unichar c = [input characterAtIndex:i];
            if ((int)c < 58) {
                newIdenticonCode |=  ((int)c-48);
            }
            else {
                newIdenticonCode |= ((int)c-55);
            }
            if (i < 7) {
                newIdenticonCode <<= 4;
            }
        }
        [m_identicon setIdenticonCode:newIdenticonCode];
        [m_identicon setHidden:NO];
    }
    else {
        [m_encryptedDescriptor setHidden:YES];
        [m_previewText setHidden:NO];
        [m_identicon setHidden:YES];
    }
}

@end
