//
//  GenerateKeyViewController.m
//  NouveauPG
//
//  Created by John Hill on 6/15/14.
//  Copyright (c) 2014 John Hill. All rights reserved.
//

#import "GenerateKeyViewController.h"
#import "OpenPGPPublicKey.h"
#import "OpenPGPSignature.h"
#import "AppDelegate.h"

#import "NSString+Base64.h"

#define kVersionString @"NouveauPG 1.10 (iOS)"

@interface GenerateKeyViewController ()

@end

@implementation GenerateKeyViewController

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
    // Do any additional setup after loading the view
    [m_nameField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)generateKey:(id)sender {
    
    NSString *publicKeyCertificate = nil;
    NSString *privateKeystore = nil;
    
    if (![[m_passwordField text] isEqualToString:[m_passwordRepeatField text]]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Can't create identity" message:@"Passwords don't match!" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    OpenPGPPublicKey *identityKey = [[OpenPGPPublicKey alloc]initWithKeyLength:2048 isSubkey:NO];
    OpenPGPPublicKey *encryptionSubkey = [[OpenPGPPublicKey alloc]initWithKeyLength:2048 isSubkey:YES];
    
    OpenPGPPacket *identityPublicKeyPacket = [identityKey exportPublicKey];
    OpenPGPPacket *encryptionPublicKeyPacket = [encryptionSubkey exportPublicKey];
    
    size_t messageSize = 0;
    NSString *userId = nil;
    if ([[m_emailField text] length] > 0) {
        userId = [NSString stringWithFormat:@"%@ <%@>",[m_nameField text],[m_emailField text]];
    }
    else {
        userId = [NSString stringWithString:[m_nameField text]];
    }
    
    // Generating and self-signing public key certificate
    
    NSMutableArray *packets = [[NSMutableArray alloc]initWithCapacity:5];
    [packets addObject:identityPublicKeyPacket];
    messageSize += [[identityPublicKeyPacket packetData] length];
    
    NSData *userIdData = [NSData dataWithBytes:[userId UTF8String] length:[userId length]];
    OpenPGPPacket *userIdPacket = [[OpenPGPPacket alloc]initWithPacketBody:userIdData tag:13 oldFormat:YES];
    messageSize += [[userIdPacket packetData] length];
    [packets addObject:userIdPacket];
    
    OpenPGPPacket *userIdSig = [OpenPGPSignature signUserId:userId withPublicKey:identityKey];
    [packets addObject:userIdSig];
    messageSize += [[userIdSig packetData] length];
    
    [packets addObject:encryptionPublicKeyPacket];
    messageSize += [[encryptionPublicKeyPacket packetData] length];
    
    OpenPGPPacket *subkeySig = [OpenPGPSignature signSubkey:encryptionSubkey withPrivateKey:identityKey];
    [packets addObject:subkeySig];
    messageSize += [[subkeySig packetData] length];
    
    NSMutableData *publicKeyCertificateData = [[NSMutableData alloc]initWithCapacity:messageSize];
    for (OpenPGPPacket *eachPacket in packets) {
        [publicKeyCertificateData appendData:[eachPacket packetData]];
    }
    
    unsigned char *messageData = (unsigned char *)[publicKeyCertificateData bytes];
    
    // RFC 4880
    
    long crc = 0xB704CEL;
    for (int i = 0; i < messageSize; i++) {
        crc ^= (*(messageData+i)) << 16;
        for (int j = 0; j < 8; j++) {
            crc <<= 1;
            if (crc & 0x1000000) {
                crc ^= 0x1864CFBL;
            }
        }
    }
    crc &= 0xFFFFFFL;
    
    char data[3];
    data[0] = ( crc >> 16 ) & 0xff;
    data[1] = ( crc >> 8 ) & 0xff;
    data[2] = crc & 0xff;
    
    NSData *crcData = [NSData dataWithBytes:data length:3];
    NSMutableString *stringBuilder = [[NSMutableString alloc]initWithFormat:@"-----BEGIN PGP PUBLIC KEY BLOCK-----\nVersion: %@\n\n",kVersionString];
    [stringBuilder appendString:[publicKeyCertificateData base64EncodedString]];
    [stringBuilder appendFormat:@"\n=%@\n-----END PGP PUBLIC KEY BLOCK-----",[crcData base64EncodedString]];

    publicKeyCertificate = [[NSString alloc]initWithString:stringBuilder];
    
    [packets removeAllObjects];
    
    // Now generating the private keystore and encrypting it for storage

    [packets addObject:[identityKey exportPrivateKey:@""]];
    [packets addObject:userIdPacket];
    [packets addObject:[encryptionSubkey exportPrivateKey:@""]];
    
    privateKeystore = [OpenPGPMessage privateKeystoreFromPacketChain:packets];
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app addIdentityWithPublicCertificate:publicKeyCertificate privateKeystore:privateKeystore name:[m_nameField text] emailAddr:[m_emailField text] keyId:identityKey.keyId];
    
    [[self navigationController] popViewControllerAnimated:YES];
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
