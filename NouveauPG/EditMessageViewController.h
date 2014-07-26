//
//  EditMessageViewController.h
//  NouveauPG
//
//  Created by John Hill on 7/10/14.
//  Copyright (c) 2014 John Hill. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenPGPMessage.h"

#define kModeEditing 1

@interface EditMessageViewController : UIViewController {
    IBOutlet UITextView *m_textView;
    IBOutlet UIBarButtonItem *m_rightButton;
    
    OpenPGPMessage *m_message;
    
    NSString *m_originalMessage;
    NSInteger m_mode;
}

-(void)setText:(NSString *)newText;
-(IBAction)rightButton:(id)sender;

@end
