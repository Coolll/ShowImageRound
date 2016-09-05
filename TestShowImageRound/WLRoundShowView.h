//
//  WLRoundShowView.h
//  TestShowImageRound
//
//  Created by 龙培 on 16/8/30.
//  Copyright © 2016年 龙培. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ShowViewDelegate <NSObject>

- (void)getDouchIndex:(NSInteger)index;

@end

@interface WLRoundShowView : UIView

/*
 *  contentArray
 */
@property (nonatomic,strong) NSArray *imageArray;

/*
 *  URLs
 */
@property (nonatomic,strong) NSArray *urlArray;

/*
 *  time
 */
@property (nonatomic,assign) CGFloat timeIntevel;

@property (nonatomic,assign) id<ShowViewDelegate> delegate;

@end
