//
//  NSObject+RNEvents.h
//  Zone
//
//  Created by Vojtech Rinik on 10/22/12.
//
//

#import <Foundation/Foundation.h>

@interface RNEventBus : NSObject 

+ (RNEventBus *)sharedBus;
+ (void)trigger:(NSString *)eventName;
+ (void)on:(NSString *)eventName block:(void(^)(void))handler;
+ (void)on:(NSString *)eventName object:(id)object selector:(SEL)selector;
+ (void)off:(NSString *)eventName;

@end

@interface NSObject (RNEvents)

@property (readonly) NSMutableDictionary *_eventObservers;

- (void)trigger:(NSString *)eventName;
- (void)trigger:(NSString *)eventName data:(id)data;
- (void)on:(NSString *)eventName block:(void(^)(id data))handler;
- (void)on:(NSString *)eventName object:(id)object selector:(SEL)selector;
- (void)off:(NSString *)eventName;

@end
