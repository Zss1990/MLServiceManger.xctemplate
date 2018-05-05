//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright © ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MLBeeHiveDATA(sectname) __attribute((used, section("__DATA,"#sectname" ")))

//使用该该宏进行一对一的协议注册，如：@MLServiceMangera(GAServiceProtocol_Login,GALoginService)
//ML_REGISTER_SERVICE 不能与类同名
#define ML_RESTER_SERVICE(servicename,impl) \
class MLServiceMangera; char * k##servicename##_service MLBeeHiveDATA(MLResters) = "{ \""#servicename"\" : \""#impl"\"}";


@interface ___VARIABLE_MLServiceManger___MLAnnotation : NSObject

@end
