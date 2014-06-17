//
//  IdentityCell.m
//  NouveauPG
//
//  Created by John Hill on 6/16/14.
//  Copyright (c) 2014 John Hill. All rights reserved.
//

#import "IdentityCell.h"

@implementation IdentityCell

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

-(void) setName: (NSString *)name {
    [m_name setText:name];
}

-(void) setKeyMetadata: (NSString *)metadata {
    [m_keyMetadata setText:metadata];
}

-(void) setIdenticonCode: (NSInteger)identiconCode {
    [m_identicon setIdenticonCode:identiconCode];
}

@end
