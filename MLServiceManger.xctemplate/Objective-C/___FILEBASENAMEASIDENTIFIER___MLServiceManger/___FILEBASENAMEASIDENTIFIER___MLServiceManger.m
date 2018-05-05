//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright © ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

#import "___VARIABLE_MLServiceManger___MLServiceManger.h"

@interface ___VARIABLE_MLServiceManger___MLServiceManger()

@property (nonatomic, strong) NSMutableDictionary *allServicesDict; //{NSString : NSArray}
@property (nonatomic, strong) NSRecursiveLock *lock;

@end

@implementation ___VARIABLE_MLServiceManger___MLServiceManger

+ (instancetype)sharedManager
{
    static id sharedManager = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}


- (void)registerService:(Protocol *)service implClass:(Class)implClass
{
    NSParameterAssert(service != nil);
    NSParameterAssert(implClass != nil);

    if (![implClass conformsToProtocol:service]) {
        if (self.enableException) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ module does not comply with %@ protocol", NSStringFromClass(implClass), NSStringFromProtocol(service)] userInfo:nil];
        }
        return;
    }

    NSArray *serviceList = [self getValidServiceStr:service];
    if (!serviceList) {
        if (self.enableException) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ protocol has been registed extraordinarily", NSStringFromProtocol(service)] userInfo:nil];
        }
        return;
    }

    NSString *key = NSStringFromProtocol(service);
    NSString *serviceStr = NSStringFromClass(implClass);

    NSMutableArray *newList = [NSMutableArray arrayWithArray:serviceList];
    BOOL isContain = NO;
    for (NSString *proS in newList) {
        if ([proS isEqualToString:serviceStr]) {
            isContain = YES;
            break;
        }
    }
    if (isContain) {
        if (self.enableException) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ protocol has been registed", NSStringFromProtocol(service)] userInfo:nil];
        }
        return;
    }
    [newList addObject:serviceStr];
    NSArray *valueArray = [NSArray arrayWithArray:newList];

    if (key.length > 0 && valueArray.count > 0) {
        [self.lock lock];
        [self.allServicesDict addEntriesFromDictionary:@{key:valueArray}];
        [self.lock unlock];
    }
}

- (id)createService:(Protocol *)service
{
    if (![self checkValidService:service]) {
        if (self.enableException) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ protocol does not been registed", NSStringFromProtocol(service)] userInfo:nil];
        }
    }

    Class implClass = [self serviceImplClass:service];

    return [[implClass alloc] init];
}

- (NSArray *)createServiceList:(Protocol *)service
{
    NSMutableArray *serviceArray = [NSMutableArray array];
    if (![self checkValidService:service]) {
        if (self.enableException) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ protocol does not been registed", NSStringFromProtocol(service)] userInfo:nil];
        }
    }
    NSArray *serviceList = [self getValidServiceStr:service];
    for (NSString *serviceStr in serviceList) {
        Class implClass = NSClassFromString(serviceStr);
        [serviceArray addObject:[[implClass alloc] init]];
    }
    return [NSArray arrayWithArray:serviceArray];
}


#pragma mark - private
- (Class)serviceImplClass:(Protocol *)service
{
    NSArray *serviceList = [self getValidServiceStr:service];
    if (serviceList) {
        if (serviceList.count > 0) {
            NSString *serviceImpl = [serviceList lastObject];
            return NSClassFromString(serviceImpl);
        }
        return nil;
    }
    return nil;
}

- (BOOL)checkValidService:(Protocol *)service
{
    NSArray *serviceList = [self getValidServiceStr:service];
    if (serviceList) {
        if (serviceList.count > 0) {
            return YES;
        }
        return NO;
    }
    return NO;
}
//如果获取不到，则返回一个空的数组
- (NSArray *)getValidServiceStr:(Protocol *)serviceStr
{
    id serviceList = [[self servicesDict] objectForKey:NSStringFromProtocol(serviceStr)];
    if (!serviceList) {
        return [NSArray array];
    }
    if ([serviceList isKindOfClass:[NSArray class]]) {
        return [NSArray arrayWithArray:serviceList];
    }
    return nil;
}

- (NSMutableDictionary *)allServicesDict
{
    if (!_allServicesDict) {
        _allServicesDict = [NSMutableDictionary dictionary];
    }
    return _allServicesDict;
}

- (NSRecursiveLock *)lock
{
    if (!_lock) {
        _lock = [[NSRecursiveLock alloc] init];
    }
    return _lock;
}

- (NSDictionary *)servicesDict
{
    [self.lock lock];
    NSDictionary *dict = [self.allServicesDict copy];
    [self.lock unlock];
    return dict;
}



@end
