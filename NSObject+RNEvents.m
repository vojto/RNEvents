//
//  NSObject+RNEvents.m
//  Zone
//
//  Created by Vojtech Rinik on 10/22/12.
//
//

#import <objc/runtime.h>
#import "NSObject+RNEvents.h"

static void *RNEventsEventObserversKey;

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
    id observer = [center addObserverForName:identifier object:self queue:nil usingBlock:^(NSNotification *note) {
        handler();
    }];
    [self _addObserver:observer forIdentifier:identifier];
}

- (void)on:(NSString *)eventName object:(id)object selector:(SEL)selector {
    NSString *identifier = [self _eventIdentifier:eventName];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    id observer = [center addObserverForName:identifier object:nil queue:nil usingBlock:^(NSNotification *note) {
        [object performSelector:selector withObject:self];
    }];
    [self _addObserver:observer forIdentifier:identifier];
}

- (void)_addObserver:(id)observer forIdentifier:(NSString *)name {
    NSMutableDictionary *observers = self._eventObservers;
    NSMutableArray *eventObservers = [observers objectForKey:name];
    if (!eventObservers) {
        eventObservers = [[NSMutableArray alloc] init];
        [observers setObject:eventObservers forKey:name];
    }
    [eventObservers addObject:observer];
}

- (void)_removeObserverForIdentifier:(NSString *)name {
    NSMutableArray *observers = [self._eventObservers objectForKey:name];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    for (id observer in observers) {
        [center removeObserver:observer];
    }
    [observers removeAllObjects];
}

- (void)off:(NSString *)eventName {
    NSString *identifier = [self _eventIdentifier:eventName];
    [self _removeObserverForIdentifier:identifier];
}

#pragma mark - Private

- (NSString *)_eventIdentifier:(NSString *)eventName {
    return [NSString stringWithFormat:@"%p_%@", self, eventName];
}

- (NSMutableDictionary *)_eventObservers {
    NSMutableDictionary *observers = objc_getAssociatedObject(self, &RNEventsEventObserversKey);
    if (observers == nil) {
        observers = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(self, &RNEventsEventObserversKey, observers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return observers;
}

@end
