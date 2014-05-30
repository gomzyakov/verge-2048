//
//  M2GlobalState.h
//  m2048
//
//  Created by Danqing on 3/16/14.
//  Copyright (c) 2014 Danqing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "M2Position.h"
#import <SpriteKit/SpriteKit.h>

#define GSTATE [M2GlobalState state]
#define Settings [NSUserDefaults standardUserDefaults]
#define NotifCtr [NSNotificationCenter defaultCenter]

@interface M2GlobalState : NSObject

@property (nonatomic, readonly) NSInteger      dimension;
@property (nonatomic, readonly) NSInteger      winningLevel;
@property (nonatomic, readonly) NSInteger      tileSize;
@property (nonatomic, readonly) NSInteger      horizontalOffset;
@property (nonatomic, readonly) NSInteger      verticalOffset;
@property (nonatomic, readonly) NSTimeInterval animationDuration;

@property (nonatomic) BOOL needRefresh;

/** The singleton instance of state. */
+ (M2GlobalState *)state;

/** Refreshes global state to reflect user choice. */
- (void)loadGlobalState;

/**
 * Whether the two levels can merge with each other to form another level.
 * This behavior is commutative.
 *
 * @param level1 The first level.
 * @param level2 The second level.
 * @return YES if the two levels are actionable with each other.
 */
- (BOOL)isLevel:(NSInteger)level1 mergeableWithLevel:(NSInteger)level2;

/**
 * The resulting level of merging the two incoming levels.
 *
 * @param level1 The first level.
 * @param level2 The second level.
 * @return The resulting level, or 0 if the two levels are not actionable.
 */
- (NSInteger)mergeLevel:(NSInteger)level1 withLevel:(NSInteger)level2;

/**
 * The numerical value of the specified level.
 *
 * @param level The level we are interested in.
 * @return The numerical value of the level.
 */
- (NSInteger)valueForLevel:(NSInteger)level;

/**
 Возвращает текстуру, для заданного уровня.
 @param level Заданный уровень.
 */
- (SKTexture *)textureForLevel:(NSInteger)level;

/**
 * The starting location of the position.
 *
 * @param position The position we are interested in.
 * @return The location in points, relative to the grid.
 */
- (CGPoint)locationOfPosition:(M2Position)position;

- (CGVector)distanceFromPosition:(M2Position)oldPosition toPosition:(M2Position)newPosition;

@end
