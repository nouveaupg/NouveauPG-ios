//
//  EditMessageViewController.h
//  NouveauPG
//
//  Created by John Hill on 7/10/14.
//  Copyright (c) 2014 John Hill. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"
#import "OpenPGPMessage.h"

#define kModeEditing 1

@interface EditMessageViewController : UIViewController {
    IBOutlet UITextView *m_textView;
    IBOutlet UIBarButtonItem *m_rightButton;
    IBOutlet UIBarButtonItem *m_encryptButton;
    
    Message *m_dataSource;
    OpenPGPMessage *m_message;
    
    NSString *m_originalMessage;
    NSInteger m_mode;
}

-(bool)decryptMessage;
-(void)setDataSource: (Message *)dataSource;
-(IBAction)rightButton:(id)sender;

@end
