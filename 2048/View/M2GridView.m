//
//  M2GridView.m
//  m2048
//
//  Created by Danqing on 3/21/14.
//  Copyright (c) 2014 Danqing. All rights reserved.
//

#import "M2GridView.h"
#import "M2Grid.h"

@implementation M2GridView

- (instancetype)init
{
  NSInteger side = GSTATE.dimension * GSTATE.tileSize;
  CGFloat verticalOffset = [[UIScreen mainScreen] bounds].size.height - GSTATE.verticalOffset;
  return [self initWithFrame:CGRectMake(GSTATE.horizontalOffset, verticalOffset - side, side, side)];
}


+ (UIImage *)gridImageWithGrid:(M2Grid *)grid
{
  UIView *backgroundView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  
  M2GridView *view = [[M2GridView alloc] init];
  [backgroundView addSubview:view];
  
  [grid forEach:^(M2Position position) {
    CALayer *layer = [CALayer layer];
    CGPoint point = [GSTATE locationOfPosition:position];
    
    CGRect frame = layer.frame;
    frame.size = CGSizeMake(GSTATE.tileSize, GSTATE.tileSize);
    frame.origin = CGPointMake(point.x, [[UIScreen mainScreen] bounds].size.height - point.y - GSTATE.tileSize);
    layer.frame = frame;
    
    [backgroundView.layer addSublayer:layer];
  } reverseOrder:NO];
  
  return [M2GridView snapshotWithView:backgroundView];
}


+ (UIImage *)gridImageWithOverlay
{
  UIView *backgroundView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  backgroundView.backgroundColor = [UIColor clearColor];
  backgroundView.opaque = NO;
  
  M2GridView *view = [[M2GridView alloc] init];
  //view.backgroundColor = [[GSTATE backgroundColor] colorWithAlphaComponent:0.8];
  [backgroundView addSubview:view];
  
  return [M2GridView snapshotWithView:backgroundView];
}


+ (UIImage *)snapshotWithView:(UIView *)view
{
  // This is a little hacky, but is probably the best generic way to do this.
  // [UIColor colorWithPatternImage] doesn't really work with SpriteKit, and we need
  // to take a retina-quality screenshot. But then in SpriteKit we need to shrink the
  // corresponding node back to scale 1.0 in order for it to display properly.
  UIGraphicsBeginImageContextWithOptions(view.frame.size, view.opaque, 0.0);
  [[view layer] renderInContext:UIGraphicsGetCurrentContext()];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return image;
}

@end
