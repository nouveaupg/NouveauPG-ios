//
//  MessagesViewController.h
//  NouveauPG
//
//  Created by John Hill on 7/10/14.
//  Copyright (c) 2014 John Hill. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"

@interface MessagesViewController : UITableViewController {
    NSMutableArray *m_messages;
    Message *m_selectedMessage;
}

-(IBAction)newMessage:(id)sender;

@end
