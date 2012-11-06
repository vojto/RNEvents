//
//  NSObject+RNEvents.h
//  Zone
//
//  Created by Vojtech Rinik on 10/22/12.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (RNEvents)

- (void)trigger:(NSString *)eventName;
- (void)on:(NSString *)eventName block:(void(^)(void))handler;
- (void)on:(NSString *)eventName object:(id)object selector:(SEL)selector;

@end
