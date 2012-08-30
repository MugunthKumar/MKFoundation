//
//  MKObject+XMLExtensions.m
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


#import "MKObject+XMLExtensions.h"
#import <objc/runtime.h>

Class property_getClass( objc_property_t property )
{
	const char * attrs = property_getAttributes( property );
	if ( attrs == NULL )
		return ( NULL );
  
	static char buffer[256];
	const char * e = strchr( attrs, ',' );
	if ( e == NULL )
		return ( NULL );
  
	int len = (int)(e - attrs);
	memcpy( buffer, attrs, len );
	buffer[len] = '\0';
  
  NSMutableString *prop = [[NSString stringWithCString:buffer encoding:NSUTF8StringEncoding] mutableCopy];
  [prop replaceOccurrencesOfString:@"T@" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [prop length])];
  [prop replaceOccurrencesOfString:@"\"" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [prop length])];
  
	return ( NSClassFromString(prop) );
}

static NSMutableArray *knownClasses;

@implementation MKObject (XMLExtensions)

+(void) initialize {
  
  if(!knownClasses)
    knownClasses = [NSMutableArray array];
}

+(void) registerKnownClass:(Class) class {
  
  [knownClasses addObject:class];
}

#pragma -
#pragma XML Stuff

-(id) initWithXMLString:(NSString *)xmlString {
  
  NSError *error = nil;
  DDXMLElement *xmlElement = [[[DDXMLDocument alloc] initWithXMLString:xmlString
                                                               options:0
                                                                 error:&error] rootElement];
  
  if(!xmlElement) {
    
    NSLog(@"XML Parsing error: %@", error);
    return nil;
  }
  return [self initWithDDXMLElement:xmlElement];
}

-(id) initWithDDXMLElement:(DDXMLElement*) element
{
  if(element == nil) return nil;
  if((self = [self init])) {
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for(i = 0; i < outCount; i++) {
      objc_property_t property = properties[i];
      const char *propName = property_getName(property);
      
      if(propName) {
        NSString *propertyName = [NSString stringWithUTF8String:propName];
        NSArray *array = [element elementsForName:propertyName];
        
        id value = nil;
        if([array count] > 0)
          value = [array objectAtIndex:0];
        
        Class class = property_getClass(property);
        if([knownClasses containsObject:class]) {
          
          value = [[class alloc] initWithDDXMLElement:value];
          [self setValue:value forKey:propertyName];
        } else {
          
          [self setValue:[value stringValue] forKey:propertyName];
        }
      }
    }
  }
  
  return self;
}

-(DDXMLDocument*) xmlRepresentation {
  
  return [self xmlRepresentationWithName:NSStringFromClass([self class])];
}

-(DDXMLDocument*) xmlRepresentationWithName:(NSString*) name {
  
  DDXMLDocument *doc = [[DDXMLDocument alloc] initWithXMLString:[NSString stringWithFormat:@"<%@/>", name]
                                                        options:0
                                                          error:nil];
  DDXMLElement *rootElement = [doc rootElement];
  unsigned int outCount, i;
  
  objc_property_t *properties = class_copyPropertyList([self class], &outCount);
  for(i = 0; i < outCount; i++) {
    objc_property_t property = properties[i];
    const char *propName = property_getName(property);
    if(propName) {
      NSString *propertyName = [NSString stringWithUTF8String:propName];
      NSValue *value = [self valueForKey:propertyName];
      
      if([value isKindOfClass:[MKObject class]]) {
        
        DDXMLDocument *childDoc = [((MKObject*)value) xmlRepresentationWithName:propertyName];
        DDXMLElement *childElement = [[childDoc rootElement] copy];
        [rootElement addChild:childElement];
      }
      else if (value && (id)value != [NSNull null]) {
        
        char firstChar = [propertyName characterAtIndex:0];
        if((firstChar >= 'A' && firstChar <= 'Z') || (firstChar >= 'a' && firstChar <= 'z')) {
          //unicode and numbers causes occasional problems with DDXMLNode
          DDXMLNode *node = [DDXMLNode elementWithName:propertyName stringValue:[value description]];
          [rootElement addChild:node];
        }
      }
    }
  }
  
  free(properties);
  return doc;
}
@end
