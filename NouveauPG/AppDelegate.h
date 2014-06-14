//
//  AppDelegate.h
//  NouveauPG
//
//  Created by John Hill on 5/1/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (assign,nonatomic) NSArray *recipients;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)addRecipientWithCertificate:(NSString *)certData;

@end
