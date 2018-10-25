#import "MSAppDelegateForwarder.h"
#import "MSCustomApplicationDelegate.h"
#import "MSUtility+Application.h"

static NSString *const kMSIsAppDelegateForwarderEnabledKey = @"AppCenterAppDelegateForwarderEnabled";

// Original selectors with special handling.
static NSString *const kMSOpenURLSourceApplicationAnnotation = @"application:openURL:sourceApplication:annotation:";
static NSString *const kMSOpenURLOptions = @"application:openURL:options:";

// Singleton instance.
static MSAppDelegateForwarder *sharedInstance = nil;

@implementation MSAppDelegateForwarder

- (instancetype)init {
  if ((self = [super init])) {
#if !TARGET_OS_OSX
    self.deprecatedSelectors = @{kMSOpenURLOptions : kMSOpenURLSourceApplicationAnnotation};
#endif
  }
  return self;
}

+ (instancetype)sharedInstance {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [self new];
  });
  return sharedInstance;
}

+ (void)resetSharedInstance {
  sharedInstance = [self new];
}

- (Class)originalClassForSetDelegate {
  return [MSApplication class];
}

#pragma mark - Custom Application

- (void)custom_setDelegate:(id<MSApplicationDelegate>)delegate {

  // Swizzle only once.
  static dispatch_once_t delegateSwizzleOnceToken;
  dispatch_once(&delegateSwizzleOnceToken, ^{
    // Swizzle the delegate object before it's actually set.
    [[MSAppDelegateForwarder sharedInstance] swizzleOriginalDelegate:delegate];
  });

  // Forward to the original `setDelegate:` implementation.
  IMP originalImp = [MSAppDelegateForwarder sharedInstance].originalSetDelegateImp;
  if (originalImp) {
    ((void (*)(id, SEL, id<MSApplicationDelegate>))originalImp)(self, _cmd, delegate);
  }
}

#pragma mark - Custom UIApplicationDelegate

#if !TARGET_OS_OSX

/*
 * Those methods will never get called but their implementation will be used by swizzling. Those implementations will run within the
 * delegate context. Meaning that `self` will point to the original app delegate and not this forwarder.
 */
- (BOOL)custom_application:(UIApplication *)application
                   openURL:(NSURL *)url
         sourceApplication:(nullable NSString *)sourceApplication
                annotation:(id)annotation {
  BOOL result = NO;
  IMP originalImp = NULL;

  // Forward to the original delegate.
  [[MSAppDelegateForwarder sharedInstance].originalImplementations[NSStringFromSelector(_cmd)] getValue:&originalImp];
  if (originalImp) {
    result = ((BOOL(*)(id, SEL, UIApplication *, NSURL *, NSString *, id))originalImp)(self, _cmd, application, url, sourceApplication,
                                                                                       annotation);
  }

  // Forward to custom delegates.
  return [[MSAppDelegateForwarder sharedInstance] application:application
                                                      openURL:url
                                            sourceApplication:sourceApplication
                                                   annotation:annotation
                                                returnedValue:result];
}

- (BOOL)custom_application:(UIApplication *)application
                   openURL:(nonnull NSURL *)url
                   options:(nonnull NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
  BOOL result = NO;
  IMP originalImp = NULL;

  // Forward to the original delegate.
  [[MSAppDelegateForwarder sharedInstance].originalImplementations[NSStringFromSelector(_cmd)] getValue:&originalImp];
  if (originalImp) {
    result = ((BOOL(*)(id, SEL, UIApplication *, NSURL *, NSDictionary<UIApplicationOpenURLOptionsKey, id> *))originalImp)(
        self, _cmd, application, url, options);
  }

  // Forward to custom delegates.
  return [[MSAppDelegateForwarder sharedInstance] application:application openURL:url options:options returnedValue:result];
}
#endif

@end
