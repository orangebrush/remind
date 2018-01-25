//
//  UIViewController+CKBasicHeader.m
//  BatourTool
//
//  Created by mac on 17/3/15.
//  Copyright © 2017年 GRSource. All rights reserved.
//

#import "UIViewController+CKBasicHeader.h"
#import <objc/runtime.h>


@implementation UIViewController (CKBasicHeader)

-(CKCylinderReversibleHeader *) ckBasicHeader
{
//    if([self isKindOfClass:[UINavigationController class]] || [self isKindOfClass:[UIPageViewController class]])
//        return nil;

    if([NSStringFromClass(self.class) hasPrefix:@"UI"])
        return nil;
    
    CKCylinderReversibleHeader * finalHeader = nil;
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for(i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if(propName) {
            NSString *propertyName = [NSString stringWithCString:propName
                                                        encoding:[NSString defaultCStringEncoding]];
            id propertyValue = [self valueForKey:propertyName];
            if([propertyValue isKindOfClass:[UIScrollView class]])
            {
                UIScrollView * scrollView = (UIScrollView *) propertyValue;
                if([scrollView.mj_header isKindOfClass:[CKCylinderReversibleHeader class]])
                {
                    CKCylinderReversibleHeader * header = (CKCylinderReversibleHeader *)scrollView.mj_header;
                    if(header)
                    {
                        finalHeader = header;
                        break;
                    }
                }
            }
        }
    }
    free(properties);
    
    if(finalHeader == nil)
    {
        for (UIView * emView in self.view.subviews) {
            if([emView isKindOfClass:[UIScrollView class]])
            {
                UIScrollView * scrollView = (UIScrollView *) emView;
                if([scrollView.mj_header isKindOfClass:[CKCylinderReversibleHeader class]])
                {
                    CKCylinderReversibleHeader * header = (CKCylinderReversibleHeader *)scrollView.mj_header;
                    if(header)
                    {
                        finalHeader = header;
                        break;
                    }
                }
            }
        }
    }
    
    return finalHeader;
}


-(CKCylinderReversibleFooter *) ckBasicFooter;
{
    if([NSStringFromClass(self.class) hasPrefix:@"UI"])
        return nil;
    
    CKCylinderReversibleFooter * finalFooter = nil;
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for(i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if(propName) {
            NSString *propertyName = [NSString stringWithCString:propName
                                                        encoding:[NSString defaultCStringEncoding]];
            id propertyValue = [self valueForKey:propertyName];
            if([propertyValue isKindOfClass:[UIScrollView class]])
            {
                UIScrollView * scrollView = (UIScrollView *) propertyValue;
                if([scrollView.mj_footer isKindOfClass:[CKCylinderReversibleFooter class]])
                {
                    CKCylinderReversibleFooter * footer = (CKCylinderReversibleFooter *)scrollView.mj_footer;
                    if(footer)
                    {
                        finalFooter = footer;
                        break;
                    }
                }
            }
        }
    }
    free(properties);
    
    if(finalFooter == nil)
    {
        for (UIView * emView in self.view.subviews) {
            if([emView isKindOfClass:[UIScrollView class]])
            {
                UIScrollView * scrollView = (UIScrollView *) emView;
                if([scrollView.mj_footer isKindOfClass:[CKCylinderReversibleFooter class]])
                {
                    CKCylinderReversibleFooter * footer = (CKCylinderReversibleFooter *)scrollView.mj_footer;
                    if(footer)
                    {
                        finalFooter = footer;
                        break;
                    }
                }
            }
        }
    }
    
    return finalFooter;
}

@end
