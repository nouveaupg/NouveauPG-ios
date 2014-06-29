//
//  ExportViewController.h
//  NouveauPG
//
//  Created by John Hill on 6/19/14.
//  Copyright (c) 2014 John Hill. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExportViewController : UIViewController {
    IBOutlet UITextView *m_textView;
}

-(void)setText:(NSString *)textData;

-(IBAction)dismissButton:(id)sender;
-(IBAction)copyButton:(id)sender;
-(IBAction)saveButton:(id)sender;
-(IBAction)emailButton:(id)sender;

@end
