//
//  MDProgressHUD+Custom.h
//  LionsClub
//
//  Created by Luka Gabric on 3/25/13.
//
//


#import "MBProgressHUD.h"


@interface MBProgressHUD (L)


+ (MBProgressHUD *)showProgressForView:(UIView *)view;
+ (void)hideProgressForView:(UIView *)view;


@end