//
//  AppDelegate.h
//  NouveauPG
//
//  Created by John Hill on 5/1/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Recipient.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate> {
    NSManagedObject *m_pendingItem;
}

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (copy,nonatomic) NSArray *recipients;
@property (copy,nonatomic) NSArray *identities;
@property (copy,nonatomic) NSArray *messages;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (Recipient *)addRecipientWithCertificate:(NSString *)certData;
- (void)addMessageToStore:(NSString *)message;
- (bool)saveObjectToCloud: (NSManagedObject *)object;
- (void)deleteCloudObject: (NSString *)keyId recordType:(NSString *)type;
- (bool)addIdentityWithKeystore: (NSString *)privateKeystore password: (NSString *)passwd;
- (void)addIdentityWithPublicCertificate: (NSString*)publicCertificate privateKeystore: (NSString *)keystore name: (NSString *)userId emailAddr:(NSString *)email keyId: (NSString *)keyid;

- (void)registerCloudSubscriptions: (UIApplication *)application;
- (void)startSyncFromCloud;

@end
