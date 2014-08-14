//
//  ExportViewController.m
//  NouveauPG
//
//  Created by John Hill on 6/19/14.
//  Copyright (c) 2014 John Hill. All rights reserved.
//

#import "ExportViewController.h"
#import "MessageUI/MFMailComposeViewController.h"


@implementation ExportViewController

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
    // Do any additional setup after loading the view.
    
    self.navigationController.toolbarHidden = FALSE;
    
    [m_textView setText:m_textData];
}

-(void)setEmail: (NSString *)emailAddress {
    m_emailAddress = [[NSString alloc]initWithString:emailAddress];
}

-(void)viewDidAppear:(BOOL)animated {
    //NSRange newSelection = NSMakeRange(0, [m_textData length]);
    //[m_textView setSelectedRange:newSelection];
    
    [m_textView selectAll:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setText:(NSString *)textData {
    m_textData = [[NSString alloc]initWithString:textData];
}

-(IBAction)dismissButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(IBAction)copyButton:(id)sender {
    [m_textView copy:sender];
}

-(IBAction)saveButton:(id)sender {
    
}

-(IBAction)emailButton:(id)sender{
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc]init];
    [mailComposer setSubject:@"PGP Public Key Certificate"];
    [mailComposer setMessageBody:m_textData isHTML:FALSE];
    if (m_emailAddress) {
        [mailComposer setToRecipients:[NSArray arrayWithObject:m_emailAddress]];
    }
    mailComposer.mailComposeDelegate = self;
    [self presentViewController:mailComposer animated:YES completion:NULL];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissModalViewControllerAnimated:YES];
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
