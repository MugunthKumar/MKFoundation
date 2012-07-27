//
//  SMObject.m
//  MKFoundation
//
//  Created by Mugunth Kumar (@mugunthkumar) on 27/7/2012.
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

#import "MKObject.h"
#import <objc/runtime.h>


@implementation MKObject

#pragma --
#pragma KVC stuff

-(NSDictionary*) objectAsDictionary {
  
  NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:0];
  
  unsigned int outCount, i;
  
  objc_property_t *properties = class_copyPropertyList([self class], &outCount);
  for(i = 0; i < outCount; i++) {
    objc_property_t property = properties[i];
    const char *propName = property_getName(property);
    if(propName) {
      NSString *propertyName = [NSString stringWithUTF8String:propName];
      NSValue *value = [self valueForKey:propertyName];
      
      if (value && (id)value != [NSNull null]) {
        [dict setValue:value forKey:propertyName];
      }
    }
  }
  free(properties);
  
  return dict;
}

-(id) initWithJSONString:(NSString*) string {
  
  return [self initWithJSONData:[string dataUsingEncoding:NSUTF16StringEncoding]];
}
-(id) initWithJSONData:(NSData*) data {
  
  NSError *error = nil;
  id jsonDict = [NSJSONSerialization JSONObjectWithData:data
                                  options:NSJSONReadingAllowFragments
                                    error:&error];
  if(!jsonDict) {
    
    NSLog(@"%@", error);
    return nil;
  }
  
  if(![jsonDict isKindOfClass:[NSDictionary class]]) {
    
    NSLog(@"Attempting to pass a JSON array to an object. Try enumerating the array instead.");
    return nil;
  }
    
  if((self = [self initWithDictionary:jsonDict])) {
    
  }
  
  return self;
}

-(id) initWithDictionary:(NSDictionary*) jsonObject
{
  if(jsonObject == nil) return nil;
  if((self = [self init]))
  {
    [self setValuesForKeysWithDictionary:jsonObject];
  }
  return self;
}


-(void) setNilValueForKey:(NSString*) key {
  
  // subclass implementation should set the correct key value mappings for custom keys
  NSLog(@"An attempt was made to set key: %@ to nil through KVC. Ignoring…", key);
}

- (id)valueForUndefinedKey:(NSString *)key
{
  // subclass implementation should provide correct key value mappings for custom keys
  NSLog(@"Undefined Key: %@", key);
  return nil;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
  // subclass implementation should set the correct key value mappings for custom keys
  NSLog(@"Undefined Key: %@", key);
}

#pragma --
#pragma JSON stuff

- (NSString *)jsonString
{
  NSError *error = nil;
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self objectAsDictionary] options:0 error:&error];
  return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (NSString *)prettyJsonString
{
  NSError *error = nil;
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self objectAsDictionary] options:NSJSONWritingPrettyPrinted error:&error];
  return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

-(NSString*) description {
  
  return [self prettyJsonString];
}
@end
