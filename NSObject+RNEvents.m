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

@implementation RNEventBus

+ (RNEventBus *)sharedBus {
    static RNEventBus *_sharedInstance;

    @synchronized(self) {
        if (!_sharedInstance)
            _sharedInstance = [[RNEventBus alloc] init];
        return _sharedInstance;
    }
}

+ (void)trigger:(NSString *)eventName {
    [[self sharedBus] trigger:eventName];
}

+ (void)trigger:(NSString *)eventName data:(id)data {
    [[self sharedBus] trigger:eventName data:data];
}

+ (void)on:(NSString *)eventName block:(void (^)(id data))handler {
    [[self sharedBus] on:eventName block:handler];
}

+ (void)on:(NSString *)eventName object:(id)object selector:(SEL)selector {
    [[self sharedBus] on:eventName object:object selector:selector];
}

+ (void)off:(NSString *)eventName {
    [[self sharedBus] off:eventName];
}

@end

@implementation NSObject (RNEvents)

- (void)trigger:(NSString *)eventName {
    [self trigger:eventName data:[NSNull null]];
}

- (void)trigger:(NSString *)eventName data:(id)data {
    NSString *identifier = [self _eventIdentifier:eventName];

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    NSDictionary *userInfo = @{@"data": data};
    NSNotification *notification = [NSNotification notificationWithName:identifier object:self userInfo:userInfo];
    [center postNotification:notification];
}

- (void)on:(NSString *)eventName block:(void (^)(id data))handler {
    NSString *identifier = [self _eventIdentifier:eventName];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    id observer = [center addObserverForName:identifier object:self queue:nil usingBlock:^(NSNotification *note) {
        NSDictionary *userInfo = [note userInfo];
        id data = userInfo[@"data"];
        handler(data);
    }];
    [self _addObserver:observer forIdentifier:identifier];
}

- (void)on:(NSString *)eventName object:(id)object selector:(SEL)selector {
    NSString *identifier = [self _eventIdentifier:eventName];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    id observer = [center addObserverForName:identifier object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSDictionary *userInfo = [note userInfo];
        id data = userInfo[@"data"];

        NSMethodSignature *signature = [object methodSignatureForSelector:selector];
        NSInteger argCount = [signature numberOfArguments] - 2;
        if (argCount == 1) {
            [object performSelector:selector withObject:self];
        } else if (argCount == 2) {
            [object performSelector:selector withObject:self withObject:data];
        } else {
            [NSException raise:@"Unsupported number of arguments" format:@"%d", argCount];
        }
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
