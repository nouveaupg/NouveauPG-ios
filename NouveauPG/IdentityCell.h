//
//  IdentityCell.h
//  NouveauPG
//
//  Created by John Hill on 6/16/14.
//  Copyright (c) 2014 John Hill. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IdenticonView.h"

@interface IdentityCell : UITableViewCell {
    IBOutlet UILabel *m_name;
    IBOutlet UILabel *m_keyMetadata;
    IBOutlet IdenticonView *m_identicon;
}

-(void) setName: (NSString *)name;
-(void) setKeyMetadata: (NSString *)metadata;
-(void) setIdenticonCode: (NSInteger)identiconCode;

@end
