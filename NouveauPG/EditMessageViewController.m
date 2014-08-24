//
//  EditMessageViewController.m
//  NouveauPG
//
//  Created by John Hill on 7/10/14.
//  Copyright (c) 2014 John Hill. All rights reserved.
//

#import "EditMessageViewController.h"
#import "OpenPGPMessage.h"
#import "OpenPGPPacket.h"
#import "OpenPGPPublicKey.h"
#import "AppDelegate.h"
#import "OpenPGPEncryptedPacket.h"
#import "LiteralPacket.h"
#import "Identity.h"
#import "MessageRecipientsTableViewController.h"

#include <openssl/conf.h>
#include <openssl/evp.h>
#include <openssl/sha.h>
#include <openssl/rsa.h>

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

-(void)setDataSource: (Message *)dataSource {
    m_dataSource = dataSource;
    if (dataSource) {
        m_originalMessage = [[NSString alloc] initWithString:dataSource.body];
    }
}

-(IBAction)rightButton:(id)sender {
    if (m_mode == kModeEditing) {
        m_mode = 0;
        [m_textView setEditable:false];
        
        if (m_message) {
            [m_textView setText:m_originalMessage];
            
            [m_rightButton setTitle:@"Decrypt"];
        }
        else {
            // save message
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            m_dataSource.body = [m_textView text];
            m_dataSource.edited = [NSDate date];
            
            OpenPGPMessage *encryptedMessage = [[OpenPGPMessage alloc]initWithArmouredText: m_dataSource.body];
            if ([encryptedMessage validChecksum]) {
                for (OpenPGPPacket *eachPacket in [OpenPGPPacket packetsFromMessage:encryptedMessage]) {
                    if ([eachPacket packetTag] == 1) {
                        NSLog(@"Packet Tag 1");
                        unsigned char *ptr = (unsigned char *)[[eachPacket packetData] bytes];
                        ptr += 3;
                        if (*ptr == 3) {
                            NSString *keyId = [NSString stringWithFormat:@"%02x%02x%02x%02x",*(ptr+5),*(ptr+6),*(ptr+7),*(ptr+8)];
                            
                            for (Identity *eachIdentity in app.identities ) {
                                if ([[eachIdentity.primaryKeystore keyId] isEqualToString:keyId] || [[eachIdentity.encryptionKeystore keyId] isEqualToString:keyId]) {
                                    m_dataSource.keyId = eachIdentity.primaryKeystore.keyId;
                                }
                            }
                        }
                        
                    }
                }
            }

            
            [app saveContext];
            
            NSLog(@"Saved message.");
            
            [m_rightButton setTitle:@"Edit"];
        }
    }
    else {
        m_mode = kModeEditing;
        if (m_message) {
            // attempt to decrypt
            
            if ([self decryptMessage]) {
                [m_rightButton setTitle:@"Done"];
            }
            else {
                m_mode = 0;
            }
        }
        else {
            [m_textView setEditable:true];
            [m_textView becomeFirstResponder];
            
            [m_rightButton setTitle:@"Done"];
        }
    }
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    if (m_message) {
        [m_encryptButton setEnabled:false];
    }
    else {
        [m_encryptButton setEnabled:true];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [m_textView setText:m_originalMessage];
    
    self.navigationController.toolbarHidden = NO;
    
    m_message = [[OpenPGPMessage alloc]initWithArmouredText:m_originalMessage];
    if ([m_message validChecksum]) {
        [m_rightButton setTitle:@"Decrypt"];
    }
    else {
        [m_rightButton setTitle:@"Edit"];
    }
}

-(bool)decryptMessage {
    OpenPGPMessage *encryptedMessage = [[OpenPGPMessage alloc]initWithArmouredText:m_originalMessage];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    unsigned char *sessionKey = NULL;
    unsigned char *ptr;
    
    if ([encryptedMessage validChecksum]) {
        for (OpenPGPPacket *eachPacket in [OpenPGPPacket packetsFromMessage:encryptedMessage]) {
            if ([eachPacket packetTag] == 1) {
                ptr = (unsigned char *)[[eachPacket packetData] bytes];
                
                int buffer = 2;
                if ([eachPacket length] > 256) {
                    buffer = 3;
                }
                
                if (*(ptr+buffer) == 3) {
                    NSLog(@"Found tag 1 packet (encrypted session key) for Key Id: %02x%02x%02x%02x%02x%02x%02x%02x",*(ptr+4),*(ptr+5),*(ptr+6),*(ptr+7),*(ptr+8),*(ptr+9),*(ptr+10),*(ptr+11));
                    
                    NSString *searchingForKeyId = [NSString stringWithFormat:@"%02x%02x%02x%02x",*(ptr+8),*(ptr+9),*(ptr+10),*(ptr+11)];
                    
                    for(  Identity *recipient in app.identities ) {
                        unsigned int declaredBits = (*(ptr + 13) << 8) | (*(ptr + 14) & 0xff);
                        
                        if ([[recipient.primaryKeystore keyId] isEqualToString:searchingForKeyId]) {
                            NSLog(@"Key ID: %@ matches primary key.",searchingForKeyId);
                            if (![recipient.primaryKeystore isEncrypted]) {
                                sessionKey = [recipient.primaryKeystore decryptBytes:ptr+15 length:(declaredBits + 7) / 8];
                            }
                            else {
                                NSLog(@"Need to decrypt primary key.");
                                
                                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Identity locked" message:[NSString stringWithFormat:@"You must unlock the identity \"%@\" to decrypt this message.",recipient.name] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                                [alert show];
                                [[[self navigationController] tabBarController] setSelectedIndex:1];
                            }
                        }
                        if ([[recipient.encryptionKeystore keyId] isEqualToString:searchingForKeyId]) {
                            NSLog(@"Key ID: %@ matches encryption subkey in chain.",searchingForKeyId);
                            
                            if (![recipient.encryptionKeystore isEncrypted]) {
                                sessionKey = [recipient.encryptionKeystore decryptBytes:ptr+15 length:(declaredBits + 7) / 8];
                            }
                            else {
                                NSLog(@"Need to decrypt encryption subkey.");
                                
                                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Identity locked" message:[NSString stringWithFormat:@"You must unlock the identity %@ to decrypt this message.",recipient.name] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                                [alert show];
                                [[[self navigationController] tabBarController] setSelectedIndex:1];
                                
                                return false;
                            }
                            
                        }
                        
                    }
                }
                else {
                    NSLog(@"Unsupported tag 1 packet version (version %d found; only version 3 supported).",*ptr);
                }
                
            }
            else if([eachPacket packetTag] == 18) {
                if (sessionKey) {
                    int buffer = 2;
                    if ([eachPacket length] > 194) {
                        buffer = 3;
                    } else if( [eachPacket length] > 8385 ) {
                        buffer = 6;
                    }
                    
                    ptr = (unsigned char *)[[eachPacket packetData] bytes];
                    if (*(ptr+buffer) == 1) {
                        NSData *packetData = [[NSData alloc]initWithBytes:ptr length:[[eachPacket packetData] length]];
                        OpenPGPEncryptedPacket *encryptedPacket = [[OpenPGPEncryptedPacket alloc]initWithData:packetData];
                        OpenPGPPacket *resultantPacket = [encryptedPacket decryptWithSessionKey:sessionKey algo:7];
                        LiteralPacket *newLiteral = [[LiteralPacket alloc]initWithData:[resultantPacket packetData]];
                        if (newLiteral) {
                            
                            NSString *contentString = [[NSString alloc]initWithData:[newLiteral content] encoding:NSUTF8StringEncoding];
                            
                            [m_textView setText:contentString];
                            
                            return true;
                        }
                    }
                }
                else {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Could not decrypt" message:@"There is no key to decrypt the message in your Identities keychain." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                    [alert show];
                    
                    NSLog(@"Could not decrypt session key for message.");
                }
            }
        }
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Invalid checksum" message:@"The OpenPGP message is invalid or corrupt." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
        
        NSLog(@"Invalid OpenPGP message. (checksum failed)");
    }
    
    return false;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    MessageRecipientsTableViewController *viewController = [segue destinationViewController];
    NSString *plaintext = [m_textView text];
    [viewController setPlaintextMessage:plaintext];
}


@end
