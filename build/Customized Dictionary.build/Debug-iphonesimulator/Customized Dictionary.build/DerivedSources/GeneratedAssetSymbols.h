#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The "Words" asset catalog image resource.
static NSString * const ACImageNameWords AC_SWIFT_PRIVATE = @"Words";

#undef AC_SWIFT_PRIVATE
