//
//  IdenticonView.h
//  IndenticonDemo
//
//  Created by John Hill on 5/31/14.
//  Copyright (c) 2014 John Hill. All rights reserved.
//

#import <UIKit/UIKit.h>

#define PATCH_GRIDS 5

void drawPatch( CGContextRef gtx, CGRect rect, int patch, int turn, bool invert, CGColorRef fillColor, CGColorRef backColor );

@interface IdenticonView : UIView {
    NSInteger m_identiconCode;
}

-(void)setIdenticonCode:(NSInteger)identiconCode;
-(NSInteger)identiconCode;

@end
