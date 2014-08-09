//
//  MessageRecipientsTableViewController.h
//  NouveauPG
//
//  Created by John Hill on 8/8/14.
//  Copyright (c) 2014 John Hill. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageRecipientsTableViewController : UITableViewController {
    NSString *m_plaintextMessage;
    NSString *m_encryptedMessage;
    NSString *m_recipientEmail;
}

-(void)setPlaintextMessage:(NSString *)message;

@end
