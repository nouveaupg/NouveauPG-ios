//
//  ImportViewController.m
//  NouveauPG
//
//  Created by John Hill on 5/10/14.
//  Copyright (c) 2014 John Hill. All rights reserved.
//

#import "ImportViewController.h"
#import "OpenPGPMessage.h"
#import "OpenPGPPacket.h"
#import "UserIDPacket.h"

#import "AppDelegate.h"

@interface ImportViewController ()

@end

@implementation ImportViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)importFromTextView:(id)sender {
    NSString *importData = [m_importText text];
    OpenPGPMessage *openPGPMessage = [[OpenPGPMessage alloc]initWithArmouredText:importData];
    if ([openPGPMessage validChecksum]) {
        NSLog(@"Valid PGP Message found.");
        NSArray *packets = [OpenPGPPacket packetsFromMessage:openPGPMessage];
        for ( OpenPGPPacket *eachPacket in packets ) {
            NSLog(@"Packet tag: %ld, length: %ld", (long)[eachPacket packetTag], (unsigned long)[[eachPacket packetData] length]);
            if ([eachPacket packetTag] == 13) {
                UserIDPacket *userIdPacket = [[UserIDPacket alloc] initWithPacket:eachPacket];
                NSLog(@"Found UserId: %@", [userIdPacket stringValue]);
            }
            if ([eachPacket packetTag] == 6) {
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegate addRecipientWithCertificate:[openPGPMessage originalArmouredText]];
            }
        }
    }
    [m_importText resignFirstResponder];
}

-(IBAction)clearTextView:(id)sender {
    [m_importText setText:@""];
    
    [m_importText resignFirstResponder];
}

-(IBAction)pasteToTextView:(id)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [m_importText insertText:pasteboard.string];
    
    [m_importText resignFirstResponder];
    
    [self importFromTextView:sender];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
