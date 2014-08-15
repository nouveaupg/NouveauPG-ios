//
//  ImportViewController.h
//  NouveauPG
//
//  Created by John Hill on 5/10/14.
//  Copyright (c) 2014 John Hill. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImportViewController : UIViewController <UITextViewDelegate> {
    IBOutlet UITextView *m_importText;
    IBOutlet UIButton *m_clipboardButton;

}

-(IBAction)importFromTextView:(id)sender;
-(IBAction)clearTextView:(id)sender;
-(IBAction)pasteToTextView:(id)sender;

@end
