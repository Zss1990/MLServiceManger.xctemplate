//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright © ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface ___VARIABLE_MLServiceManger___MLServiceManger : NSObject
@property (nonatomic, assign) BOOL  enableException;

+ (instancetype)sharedManager;

- (void)registerService:(Protocol *)service implClass:(Class)implClass;
//新建一个最后注册协议的服务对象
- (id)createService:(Protocol *)service;
//新建所有注册过协议的服务对象
- (NSArray *)createServiceList:(Protocol *)service;
@end
