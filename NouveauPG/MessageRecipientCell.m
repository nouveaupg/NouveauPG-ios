//
//  MessageRecipientCell.m
//  NouveauPG
//
//  Created by John Hill on 8/8/14.
//  Copyright (c) 2014 John Hill. All rights reserved.
//

#import "MessageRecipientCell.h"

@implementation MessageRecipientCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setName:(NSString *)name
{
    [m_name setText:name];
}

-(void)setEmail:(NSString *)email
{
    [m_email setText:email];
}

-(void)setKeyInfo:(NSString *)keyInfo
{
    [m_keyInfo setText:keyInfo];
}

-(void)setIdenticonCode:(NSInteger)identiconCode
{
    [m_identiconView setIdenticonCode:identiconCode];
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

@end
