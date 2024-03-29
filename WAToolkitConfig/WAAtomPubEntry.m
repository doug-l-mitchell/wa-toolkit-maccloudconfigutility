/*
 Copyright 2010 Microsoft Corp
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "WAAtomPubEntry.h"
#import "WAXMLHelper.h"

@implementation WAAtomPubEntry

- (id)initWithNode:(xmlNodePtr)node
{
    if((self = [super init]))
    {
        _node = node;
    }
    
    return self;
}

- (NSString *)identity
{
    return [WAXMLHelper getElementValue:_node name:@"id"];
}

- (void)processContentPropertiesWithBlock:(void (^)(NSString *key, NSString *value, BOOL *stop))block
{
    [WAXMLHelper performXPath:@"_default:content/m:properties/*" onNode:_node block:^(xmlNodePtr child, BOOL* stop) {
        xmlChar *xmlValue = xmlNodeGetContent(child);
        NSString *name = [NSString stringWithUTF8String:(const char*)child->name];
        NSString *value = [NSString stringWithUTF8String:(const char*)xmlValue];
        xmlFree(xmlValue);
        block(name, value, stop);
    }];
}

- (id)objectForKey:(id)aKey
{
	__block NSString* result;
	
	[self processContentPropertiesWithBlock:^(NSString *key, NSString *value, BOOL *stop) 
	 {
		 if([key isEqualToString:aKey])
		 {
			 result = [value copy];
			 *stop = YES;
		 }
	 }];
	
	return [result autorelease];
}

- (NSDictionary *)toDictionary
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:20];
	
	[self processContentPropertiesWithBlock:^(NSString *key, NSString *value, BOOL *stop) 
	{
		[dict setObject:value forKey:key];
	}];
	 
	return dict;
}

@end
