//
//  RecipientCell.m
//  NouveauPG
//
//  Created by John Hill on 5/4/14.
//  Copyright (c) 2014 John Hill. All rights reserved.
//

#import "RecipientCell.h"

@implementation RecipientCell

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

- (void) setPublicKeyAlgo:(NSString *)publicKeyAlgo {
    [m_publicKeyAlgo setText:publicKeyAlgo];
}

- (void) setKeyId:(NSString *)keyId {
    [m_keyId setText:keyId];
}

- (void) setName:(NSString *)name {
    [m_name setText:name];
}

- (void) setEmail:(NSString *)email {
    [m_email setText:email];
}

- (void) setIdenticonCode: (NSInteger)newIdenticonCode {
    [m_indenticonView setIdenticonCode:newIdenticonCode];
}

@end
