//
//  MessageRecipientsTableViewController.m
//  NouveauPG
//
//  Created by John Hill on 8/8/14.
//  Copyright (c) 2014 John Hill. All rights reserved.
//

#import "MessageRecipientsTableViewController.h"
#import "MessageRecipientCell.h"
#import "AppDelegate.h"
#import "Recipient.h"
#import "RecipientDetails.h"
#import "OpenPGPPublicKey.h"
#import "OpenPGPMessage.h"
#import "OpenPGPPacket.h"
#import "EncryptedEnvelope.h"
#import "LiteralPacket.h"
#import "EncryptedViewController.h"

@interface MessageRecipientsTableViewController ()

@end

@implementation MessageRecipientsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)setPlaintextMessage:(NSString *)message {
    m_plaintextMessage = [[NSString alloc]initWithString:message];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationController.toolbarHidden = YES;
}

-(void)viewWillAppear:(BOOL)animated {
    self.navigationController.toolbarHidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return [app.recipients count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"messageRecipientCell" forIndexPath:indexPath];
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    MessageRecipientCell *recipientCell = (MessageRecipientCell *)cell;
    Recipient *obj = [app.recipients objectAtIndex:[indexPath row]];
    [recipientCell setName:obj.details.userName];
    [recipientCell setEmail:obj.details.email];
    
    NSInteger newIdenticonCode = 0;
    
    NSString *keyId = obj.details.keyId;
    for (int i = 0; i < 8; i++) {
        unichar c = [keyId characterAtIndex:i];
        if ((int)c < 58) {
            newIdenticonCode |=  ((int)c-48);
        }
        else {
            newIdenticonCode |= ((int)c-55);
        }
        if (i < 7) {
            newIdenticonCode <<= 4;
        }
    }
    
    [recipientCell setKeyInfo:[keyId uppercaseString]];
    [recipientCell setIdenticonCode:newIdenticonCode];
    
    if (obj.warning < 0) {
        switch (obj.warning) {
            case -1:
                [recipientCell showWarning:@"Unsupported public key algorithm"];
                break;
            case -2:
                [recipientCell showWarning:@"Invalid UserId signature"];
                break;
            case -3:
                [recipientCell showWarning:@"Invalid subkey signature"];
                break;
                
            default:
                [recipientCell showWarning:@"Public key certificate error"];
                break;

        }
        
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    Recipient *obj = [app.recipients objectAtIndex:[indexPath row]];
    
    OpenPGPMessage *message = [[OpenPGPMessage alloc]initWithArmouredText:obj.certificate];
    
    if (obj.warning < 0) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Certificate Problem" message:@"Cannot encrypt a message with this certificate because there is a problem with it." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if ([message validChecksum]) {
        OpenPGPPublicKey *primaryKey = nil;
        OpenPGPPublicKey *encryptionKey = nil;
        for (OpenPGPPacket *eachPacket in [OpenPGPPacket packetsFromMessage:message]) {
            if ([eachPacket packetTag] == 6) {
                primaryKey = [[OpenPGPPublicKey alloc]initWithPacket:eachPacket];
            }
            else if ([eachPacket packetTag] == 14) {
                encryptionKey = [[OpenPGPPublicKey alloc]initWithPacket:eachPacket];
            }
        }
        if (primaryKey) {
            if (encryptionKey) {
                NSLog(@"Using encryption subkey ID: %@",encryptionKey.keyId);
            }
            else {
                encryptionKey = primaryKey;
            }
            
            LiteralPacket *newPacket = [[LiteralPacket alloc]initWithUTF8String:m_plaintextMessage];
            EncryptedEnvelope *envelope = [[EncryptedEnvelope alloc]initWithLiteralPacket:newPacket publicKey:encryptionKey];
            
            
            m_recipientEmail = obj.details.email;
            
            if (envelope) {
                m_encryptedMessage = [[NSString alloc]initWithString:[envelope armouredMessage]];
                [self performSegueWithIdentifier:@"encryptMessage" sender:self];
            }
            
        }
        else {
            NSLog(@"No valid public key found.");
        }
    }
    else {
        NSLog(@"Error decoding public key certificate.");
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    EncryptedViewController *viewController = (EncryptedViewController *)[segue destinationViewController];
    [viewController setEncryptedMessage:m_encryptedMessage recipientEmail:m_recipientEmail];
}


@end
