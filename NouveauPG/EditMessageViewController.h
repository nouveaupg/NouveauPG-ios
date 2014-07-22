//
//  EditMessageViewController.h
//  NouveauPG
//
//  Created by John Hill on 7/10/14.
//  Copyright (c) 2014 John Hill. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditMessageViewController : UIViewController {
    IBOutlet UITextView *m_textView;
    NSString *m_originalMessage;
}

-(void)setText:(NSString *)newText;

@end
