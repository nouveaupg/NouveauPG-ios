//
//  AppDelegate.m
//  NouveauPG
//
//  Created by John Hill on 5/1/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "AppDelegate.h"
#import "RecipientsViewController.h"
#import "UserIDPacket.h"
#import "OpenPGPPacket.h"
#import "OpenPGPMessage.h"
#import "OpenPGPPublicKey.h"
#import "Recipient.h"
#import "RecipientDetails.h"
#import "UserIDPacket.h"
#import "OpenPGPSignature.h"
#import "Identity.h"
#import "Message.h"

#import "NSString+Base64.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize recipients = _recipients;
@synthesize identities = _identities;
@synthesize messages = _messages;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    //self.window.backgroundColor = [UIColor whiteColor];
    //[self.window makeKeyAndVisible];
    NSManagedObjectContext *ctx = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Recipient"
                                              inManagedObjectContext:ctx];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    self.recipients = [ctx executeFetchRequest:fetchRequest error:&error];
    NSLog(@"Loaded %lu recipients (public key certificates) from datastore.",(unsigned long)[self.recipients count]);
    
    if (error) {
        NSLog(@"NSError: %@",[error description]);
    }
    
    fetchRequest = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription entityForName:@"Identity"
                                              inManagedObjectContext:ctx];
    [fetchRequest setEntity:entity];
    self.identities = [ctx executeFetchRequest:fetchRequest error:&error];
    NSLog(@"Loaded %lu identities (private keystores) from datastore.",(unsigned long)[self.identities count]);
    
    for( Identity *eachIdentity in self.identities ) {
        OpenPGPMessage *keystoreMessage = [[OpenPGPMessage alloc]initWithArmouredText: eachIdentity.privateKeystore];
        if ([keystoreMessage validChecksum]) {
            for (OpenPGPPacket *eachPacket in [OpenPGPPacket packetsFromMessage:keystoreMessage]) {
                OpenPGPPublicKey *newKey = [[OpenPGPPublicKey alloc]initWithEncryptedPacket:eachPacket];
                if ([eachPacket packetTag] == 5) {
                    NSLog(@"Loaded new primary keyid: %@ (%ld-bit RSA)",newKey.keyId,(long)newKey.publicKeySize);
                    eachIdentity.primaryKeystore = newKey;
                }
                else if( [eachPacket packetTag] == 7 ) {
                    NSLog(@"Loaded new encryption subkey keyid: %@ (%ld-bit RSA)",newKey.keyId,(long)newKey.publicKeySize);
                    eachIdentity.encryptionKeystore = newKey;
                }
            }
        }
    }
    
    
    
    if (error) {
        NSLog(@"NSError: %@",[error description]);
    }
    
    fetchRequest = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:ctx];
    
    [fetchRequest setEntity:entity];
    self.messages = [ctx executeFetchRequest:fetchRequest error:&error];
    NSLog(@"Loaded %lu messages from datastore.",(unsigned long)[self.messages count]);
    
    for ( Message *eachMessage in self.messages ) {
        OpenPGPMessage *encryptedMessage = [[OpenPGPMessage alloc]initWithArmouredText: eachMessage.body];
        if ([encryptedMessage validChecksum]) {
            for (OpenPGPPacket *eachPacket in [OpenPGPPacket packetsFromMessage:encryptedMessage]) {
                if ([eachPacket packetTag] == 1) {
                    NSLog(@"Packet Tag 1");
                    unsigned char *ptr = (unsigned char *)[[eachPacket packetData] bytes];
                    ptr += 3;
                    if (*ptr == 3) {
                        NSString *keyId = [NSString stringWithFormat:@"%02x%02x%02x%02x",*(ptr+5),*(ptr+6),*(ptr+7),*(ptr+8)];
                        
                        for (Identity *eachIdentity in self.identities ) {
                            if ([[eachIdentity.primaryKeystore keyId] isEqualToString:keyId] || [[eachIdentity.encryptionKeystore keyId] isEqualToString:keyId]) {
                                eachMessage.keyId = eachIdentity.primaryKeystore.keyId;
                            }
                        }
                    }
                    
                }
            }
        }
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)addRecipientWithCertificate:(NSString *)certData {
    
    OpenPGPMessage *certMessage = [[OpenPGPMessage alloc] initWithArmouredText:certData];
    if ([certMessage validChecksum]) {
        NSArray *packets = [OpenPGPPacket packetsFromMessage:certMessage];
        UserIDPacket *userId = nil;
        OpenPGPPublicKey *primaryPublicKey;
        OpenPGPPublicKey *publicSubkey;
        
        OpenPGPSignature *userIdSig;
        OpenPGPSignature *subkeySig;
        
        for (OpenPGPPacket *eachPacket in packets) {
            if ([eachPacket packetTag] == 6) {
                primaryPublicKey = [[OpenPGPPublicKey alloc]initWithPacket:eachPacket];
            }
            else if( [eachPacket packetTag] == 14) {
                publicSubkey = [[OpenPGPPublicKey alloc]initWithPacket:eachPacket];
            }
            else if ( [eachPacket packetTag] == 13 ) {
                userId = [[UserIDPacket alloc]initWithPacket:eachPacket];
            }
            else if( [eachPacket packetTag] == 2 ) {
                OpenPGPSignature *signature = [[OpenPGPSignature alloc]initWithPacket:eachPacket];
                if (signature.signatureType == 0x13) {
                    userIdSig = signature;
                }
                else if(signature.signatureType == 0x18 ) {
                    subkeySig = signature;
                }
                NSLog(@"Signature type: %lx",(long)signature.signatureType);
            }
        }
        
        // check the public key certificate for errors before importing
        
        NSManagedObjectContext *ctx = [self managedObjectContext];
        Recipient *newRecipient = [NSEntityDescription insertNewObjectForEntityForName:@"Recipient" inManagedObjectContext:ctx];
        newRecipient.userId = [userId stringValue];
        newRecipient.certificate = certData;
        
        RecipientDetails *details = [NSEntityDescription insertNewObjectForEntityForName:@"RecipientDetails" inManagedObjectContext:ctx];
        details.publicKeyAlgo = [NSString stringWithFormat:@"%ld-bit RSA",(long)primaryPublicKey.publicKeySize];
        details.keyId = [[primaryPublicKey keyId] uppercaseString];
        newRecipient.details = details;
        
        NSRange firstBracket = [[userId stringValue] rangeOfString:@"<"];
        if (firstBracket.location != NSNotFound) {
            NSString *nameOnly = [[userId stringValue]substringToIndex:firstBracket.location];
            NSRange secondBracket =[[userId stringValue] rangeOfString:@">"];
            NSUInteger len = secondBracket.location - firstBracket.location - 1;
            NSString *emailOnly = [[userId stringValue]substringWithRange:NSMakeRange(firstBracket.location+1, len)];

            details.userName = nameOnly;
            details.email = emailOnly;
        }
        else {
            // If the UserID doesn't conform to RFC 2822, we don't attempt to pull out the e-mail address
            details.userName = [userId stringValue];
        }
        
        NSMutableArray *editable = [[NSMutableArray alloc]initWithArray:self.recipients];
        
        [editable addObject:newRecipient];
        
        self.recipients = editable;
        
        [self saveContext];
        
        /*
        NSString *alertText = [NSString stringWithFormat:@"Do you wish to add the public key certificate for User ID \"%@\" to your recipient list?",[userId stringValue]];
        
        m_pendingItem = newRecipient;
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Add recipient?" message:alertText delegate:nil cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [alert setDelegate:self];
        [alert show];
         */
    }
}

- (void)addIdentityWithPublicCertificate: (NSString*)publicCertificate privateKeystore: (NSString *)keystore name: (NSString *)userId emailAddr:(NSString *)email keyId: (NSString *)keyid {
    
    NSManagedObjectContext *ctx = [self managedObjectContext];
    Identity *newIdentity = [NSEntityDescription insertNewObjectForEntityForName:@"Identity" inManagedObjectContext:ctx];
    newIdentity.name = userId;
    newIdentity.email = email;
    newIdentity.keyId = keyid;
    newIdentity.privateKeystore = keystore;
    newIdentity.publicCertificate = publicCertificate;
    newIdentity.created = [NSDate date];
    
    NSMutableArray *editable = [[NSMutableArray alloc]initWithArray:self.identities];
    [editable addObject:newIdentity];
    self.identities = editable;
    
    [self saveContext];
}

- (void)addMessageToStore:(NSString *)message {
    Message *newMessage = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:[self managedObjectContext]];
    newMessage.body = message;
    newMessage.created = [NSDate date];
    newMessage.edited = [NSDate date];
    
    NSMutableArray *editable = [[NSMutableArray alloc]initWithArray:self.messages];
    [editable addObject:newMessage];
    self.messages = editable;
    
    [self saveContext];
}

- (bool)addIdentityWithKeystore: (NSString *)privateKeystore password: (NSString *)passwd; {
    
    Identity *newIdentity = [NSEntityDescription insertNewObjectForEntityForName:@"Identity" inManagedObjectContext:[self managedObjectContext]];
    newIdentity.privateKeystore = [[NSString alloc]initWithString:privateKeystore];
    newIdentity.created = [NSDate date];
    
    OpenPGPMessage *message = [[OpenPGPMessage alloc]initWithArmouredText:privateKeystore];
    
    if ([message validChecksum]) {
        UserIDPacket *userIdPacket;
        for (OpenPGPPacket *eachPack in [OpenPGPPacket packetsFromMessage:message] ) {
            switch ([eachPack packetTag]) {
                case 5:
                    newIdentity.primaryKeystore = [[OpenPGPPublicKey alloc]initWithEncryptedPacket:eachPack];
                    break;
                case 7:
                    newIdentity.encryptionKeystore = [[OpenPGPPublicKey alloc]initWithEncryptedPacket:eachPack];
                    break;
                case 13:
                    userIdPacket = [[UserIDPacket alloc]initWithPacket:eachPack];
                    break;
                    
                default:
                    break;
            }
        }
        
        if (newIdentity.primaryKeystore) {
            if(![newIdentity.primaryKeystore decryptKey:passwd]) {
                NSLog(@"Import identity - Could not decrypt primary key with password: %@",passwd);
                return false;
            }
        }
        else {
            NSLog(@"Import identity - Primary key not found.");
            return false;
        }
        
        if (newIdentity.encryptionKeystore) {
            if(![newIdentity.encryptionKeystore decryptKey:passwd]) {
                NSLog(@"Import identity - Could not decrypt encryption subkey with password: %@",passwd);
                return false;
            }
        }
        else {
            NSLog(@"Import identity - Encryption subkey not found.");
            return false;
        }
        
        NSRange emailRange = [[userIdPacket stringValue] rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
        NSString *remainder = [[userIdPacket stringValue]substringFromIndex:emailRange.location+1];
        NSRange emailEndMark = [remainder rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
        
        newIdentity.name = [[userIdPacket stringValue]substringToIndex:emailRange.location];
        newIdentity.email = [remainder substringToIndex:emailEndMark.location];
        newIdentity.keyId = [[newIdentity.primaryKeystore keyId] uppercaseString];
        
        NSLog(@"Username: %@",newIdentity.name);
        NSLog(@"E-mail: %@",newIdentity.email);
        
        OpenPGPPacket *publicKeyPacket = [newIdentity.primaryKeystore exportPublicKey];
        OpenPGPPacket *publicSubkeyPacket = [newIdentity.encryptionKeystore exportPublicKey];
        
        NSMutableArray *packets = [[NSMutableArray alloc]initWithCapacity:5];
        [packets addObject:publicKeyPacket];
        [packets addObject:userIdPacket];
        [packets addObject:publicSubkeyPacket];
        
        OpenPGPPacket *userIdSig = [OpenPGPSignature signUserId:[userIdPacket stringValue] withPublicKey:newIdentity.primaryKeystore];
        [packets addObject:userIdSig];
        
        OpenPGPPacket *subkeySig = [OpenPGPSignature signSubkey:newIdentity.encryptionKeystore withPrivateKey:newIdentity.primaryKeystore];
        [packets addObject:subkeySig];
        
        NSMutableData *certificateData = [[NSMutableData alloc]initWithCapacity:2000];
        for (OpenPGPPacket *eachPacket in packets) {
            [certificateData appendData:[eachPacket packetData]];
        }
        
        unsigned char *ptr = (unsigned char *)[certificateData bytes];
        
        // RFC 4880
        
        long crc = 0xB704CEL;
        for (int i = 0; i < [certificateData length]; i++) {
            crc ^= (*(ptr+i)) << 16;
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
        [stringBuilder appendString:[certificateData base64EncodedString]];
        [stringBuilder appendFormat:@"\n=%@\n-----END PGP PUBLIC KEY BLOCK-----",[crcData base64EncodedString]];
        
        newIdentity.publicCertificate = [[NSString alloc]initWithString:stringBuilder];
        
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSMutableArray *editable = [[NSMutableArray alloc]initWithArray:app.identities];
        [editable addObject:newIdentity];
        app.identities = editable;
        
        [self saveContext];
        
        return true;
    }
    return false;
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSError *error;
        if([[self managedObjectContext] save:&error]) {
            NSLog(@"Stored certificate.");
            
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            NSMutableArray *editable = [[NSMutableArray alloc]initWithArray:app.recipients];
            
            Recipient *pendingRecipient = (Recipient *)m_pendingItem;
            [editable addObject:pendingRecipient];
            
            app.recipients = editable;
            
            UITabBarController *tabController = (UITabBarController *)self.window.rootViewController;
            [tabController setSelectedIndex:0];
            
        }
        else {
            NSLog(@"%@", [error description]);
        }
    }
    else {
        [[self managedObjectContext] reset];
    }
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"NouveauPG" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"NouveauPG.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
