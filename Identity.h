//
//  Identity.h
//  NouveauPG
//
//  Created by John Hill on 6/23/14.
//  Copyright (c) 2014 John Hill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Identity : NSManagedObject

@property (nonatomic, retain) NSString * privateKeystore;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * publicCertificate;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * keyId;

@end
