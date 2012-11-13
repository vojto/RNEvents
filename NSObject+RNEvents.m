//
//  NSObject+RNEvents.m
//  Zone
//
//  Created by Vojtech Rinik on 10/22/12.
//
//

#import "NSObject+RNEvents.h"

@implementation NSObject (RNEvents)

- (void)trigger:(NSString *)eventName {
    NSString *identifier = [self _eventIdentifier:eventName];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    NSNotification *notification = [NSNotification notificationWithName:identifier object:self];
    [center postNotification:notification];
}

- (void)on:(NSString *)eventName block:(void (^)(void))handler {
    NSString *identifier = [self _eventIdentifier:eventName];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:identifier object:self queue:nil usingBlock:^(NSNotification *note) {
        handler();
    }];
}

- (void)on:(NSString *)eventName object:(id)object selector:(SEL)selector {
    NSString *identifier = [self _eventIdentifier:eventName];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:identifier object:nil queue:nil usingBlock:^(NSNotification *note) {
        [object performSelector:selector withObject:self];
    }];
}

#pragma mark - Private

- (NSString *)_eventIdentifier:(NSString *)eventName {
    return [NSString stringWithFormat:@"%p_%@", self, eventName];
}

@end
