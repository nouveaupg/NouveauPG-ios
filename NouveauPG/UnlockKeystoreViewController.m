//
//  UnlockKeystoreViewController.m
//  NouveauPG
//
//  Created by John Hill on 6/22/14.
//  Copyright (c) 2014 John Hill. All rights reserved.
//

#import "UnlockKeystoreViewController.h"
#import "OpenPGPMessage.h"
#import "OpenPGPPacket.h"
#import "OpenPGPPublicKey.h"

@interface UnlockKeystoreViewController ()

@end

@implementation UnlockKeystoreViewController

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

-(void)setKeystore:(NSString *)asciiArmouredData {
    m_keystoreData = [[NSString alloc]initWithString:asciiArmouredData];
}

-(IBAction)unlockKeystore:(id)sender {
    NSString *password = [m_passwordField text];
    
    OpenPGPMessage *keystoreMessage = [[OpenPGPMessage alloc]initWithArmouredText:m_keystoreData];
    if (keystoreMessage && [keystoreMessage validChecksum]) {
        NSArray *packets = [OpenPGPPacket packetsFromMessage:keystoreMessage];
        for (OpenPGPPacket *eachPacket in packets) {
            NSLog(@"Packet tag: %d",[eachPacket packetTag]);
            if ([eachPacket packetTag] == 5) {
                OpenPGPPublicKey *key = [[OpenPGPPublicKey alloc]initWithEncryptedPacket:eachPacket];
                if ([key decryptKey:password]) {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Change password?" message:@"Would you like to export the keystore protected by a different password than you just entered?" delegate:nil cancelButtonTitle:@"No" otherButtonTitles: @"Yes",nil];
                    [alert show];
                    break;
                }
                else {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Wrong password" message:@"The password you entered will not encrypt the keystore." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
                    [alert show];
                    break;
                }
            }
        }
    }
    else {
        NSLog(@"Invalid keystore OpenPGP message.");
    }
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
