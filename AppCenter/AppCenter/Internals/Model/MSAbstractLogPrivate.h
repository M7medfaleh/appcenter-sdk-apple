#import <Foundation/Foundation.h>

static NSString *const kMSBooleanTypedPropertyType = @"boolean";
static NSString *const kMSDateTimeTypedPropertyType = @"dateTime";
static NSString *const kMSDevice = @"device";
static NSString *const kMSDistributionGroupId = @"distributionGroupId";
static NSString *const kMSDoubleTypedPropertyType = @"double";
static NSString *const kMSLongTypedPropertyType = @"long";
static NSString *const kMSSId = @"sid";
static NSString *const kMSStringTypedPropertyType = @"string";
static NSString *const kMSType = @"type";
static NSString *const kMSTypedPropertyValue = @"value";
static NSString *const kMSTimestamp = @"timestamp";
static NSString *const kMSUserId = @"userId";

@interface MSAbstractLog ()

/**
 * List of transmission target tokens that this log should be sent to.
 */
@property(nonatomic) NSSet *transmissionTargetTokens;

@end
