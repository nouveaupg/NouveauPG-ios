//
//  EditMessageViewController.m
//  NouveauPG
//
//  Created by John Hill on 7/10/14.
//  Copyright (c) 2014 John Hill. All rights reserved.
//

#import "EditMessageViewController.h"

@interface EditMessageViewController ()

@end

@implementation EditMessageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [m_textView setText:m_originalMessage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setText:(NSString *)newText {
    m_originalMessage = [[NSString alloc] initWithString:newText];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
