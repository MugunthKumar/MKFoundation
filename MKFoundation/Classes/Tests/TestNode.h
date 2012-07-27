//
//  MKTestParseObject2.h
//  MKParseHelper
//
//  Created by Mugunth on 27/7/12.
//  Copyright (c) 2012 Steinlogic Consulting and Training Pte Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MKObject.h"

#import "MKObject+ParseExtensions.h"

@class TestLeaf;

@interface TestNode : MKObject
@property (strong, nonatomic) NSString *secondGreeting;
@property (strong, nonatomic) TestLeaf *embeddedObject;
@end
