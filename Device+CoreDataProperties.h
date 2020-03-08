//
//  Device+CoreDataProperties.h
//  
//
//  Created by 曾钊 on 2020/3/7.
//
//

#import "Device+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Device (CoreDataProperties)

+ (NSFetchRequest<Device *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *brand;
@property (nullable, nonatomic, copy) NSString *hostname;
@property (nullable, nonatomic, copy) NSString *ipAddress;
@property (nullable, nonatomic, copy) NSString *mac;

@end

NS_ASSUME_NONNULL_END
