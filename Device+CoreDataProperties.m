//
//  Device+CoreDataProperties.m
//  
//
//  Created by 曾钊 on 2020/3/7.
//
//

#import "Device+CoreDataProperties.h"

@implementation Device (CoreDataProperties)

+ (NSFetchRequest<Device *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Device"];
}

@dynamic brand;
@dynamic hostname;
@dynamic ipAddress;
@dynamic mac;

@end
