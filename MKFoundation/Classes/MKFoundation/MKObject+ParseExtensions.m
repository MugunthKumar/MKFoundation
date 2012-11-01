//
//  MKObject+ParseExtensions.m
//  MKFoundation
//
//  Created by Mugunth Kumar (@mugunthkumar) on 24/7/2012.
//  Copyright (C) 2011-2020 by Steinlogic Consulting And Training Pte Ltd.

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

//  As a side note on using this code, you might consider giving some credit to me by
//	1) linking my website from your app's website
//	2) or crediting me inside the app's credits page
//	3) or a tweet mentioning @mugunthkumar
//	4) A paypal donation to mugunth.kumar@gmail.com
//
//  A note on redistribution
//	if you are re-publishing after editing, please retain the above copyright notices

#import "MKObject+ParseExtensions.h"
#import <objc/runtime.h>

@implementation MKObject (Parse)


-(PFObject*) pfObject {
  
  PFObject *object = [PFObject objectWithClassName:NSStringFromClass([self class])];
  
  unsigned int outCount, i;
  
  objc_property_t *properties = class_copyPropertyList([self class], &outCount);
  for(i = 0; i < outCount; i++) {
    objc_property_t property = properties[i];
    const char *propName = property_getName(property);
    if(propName) {
      NSString *propertyName = [NSString stringWithUTF8String:propName];
      NSValue *value = [self valueForKey:propertyName];

      if ([value isKindOfClass:[MKObject class]]) {
        value = (NSValue*) [(MKObject*)value pfObject];
      }
      if (value && (id)value != [NSNull null]) {
        [object setValue:value forKey:propertyName];
      }
    }
  }
  free(properties);
  return object;
}

+(id) objectFromPFObject:(PFObject*) pfObject {
 
  Class klass = NSClassFromString([pfObject className]);
  if(!klass) {
   
    NSLog(@"Class %@ is not available in target", [pfObject className]);
    return nil;
  }
  
  NSObject *objcObject = [[klass alloc] init];
  
  NSArray *propertyArray = [[NSArray alloc] initWithObjects:@"objectId", @"updatedAt", @"createdAt", @"className", nil ];
  [propertyArray enumerateObjectsUsingBlock:^(id property, NSUInteger idx, BOOL *stop) {
    id value = [pfObject valueForKey:property];
   
    if([objcObject respondsToSelector:NSSelectorFromString(property)]) {
        [objcObject setValue:[pfObject valueForKey:property] forKey:property];
    }else{
        NSLog(@"Class %@ doesn't define a property by name %@", [pfObject className], property);
    }
  }];
  
  NSArray *keysArray = [pfObject allKeys];
  [keysArray enumerateObjectsUsingBlock:^(id key, NSUInteger idx, BOOL *stop) {
    
    id value = [pfObject valueForKey:key];
    if([objcObject respondsToSelector:NSSelectorFromString(key)]) {

      if ([value isKindOfClass:[MKObject class]]) {
        value = [MKObject objectFromPFObject:value];
      }
      
      [objcObject setValue:value forKey:key];
    } else {
      
      NSLog(@"Class %@ doesn't define a property by name %@", [pfObject className], key);
    }
  }];
  
  return objcObject;
}

@end
