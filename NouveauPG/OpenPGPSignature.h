//
//  OpenPGPSignature.h
//  UITest
//
//  Created by John Hill on 10/7/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenPGPPacket.h"
#import "OpenPGPPublicKey.h"

@interface OpenPGPSignature : OpenPGPPacket {
    NSData *m_hashedSubpacketData;
    NSData *m_unhashedSubpacketData;
    NSData *m_signature;
}

@property NSInteger signatureVersion;
@property NSInteger signatureType;
@property NSInteger publicKeyAlgo;
@property NSInteger hashAlgo;

- (id) initWithPacket: (OpenPGPPacket *)packet;
+(OpenPGPPacket *)signWithUserId:(NSString *)userId publicKey: (OpenPGPPublicKey *)key;
+(OpenPGPPacket *)signSubkey: (OpenPGPPublicKey *)subkey withPrivateKey:(OpenPGPPublicKey *)signingKey;
+(OpenPGPPacket *)signUserId: (NSString *)userId withPublicKey: (OpenPGPPublicKey *)key;
-(bool) validateWithPublicKey: (OpenPGPPublicKey *)signingKey userId: (NSString *)uid;
-(bool) validateSubkey: (OpenPGPPublicKey *)subkey withSigningKey: (OpenPGPPublicKey *)signingKey;

@end
