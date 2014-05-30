//
//  M2Tile.m
//  m2048
//
//  Created by Danqing on 3/16/14.
//  Copyright (c) 2014 Danqing. All rights reserved.
//

#include <stdlib.h>

#import "GeometricTile.h"
#import "Cell.h"

@implementation GeometricTile {
    /// Значение геометрической фигуры (2, 4, 8, ...)
    NSString *_value;

    /** Pending actions for the tile to execute. */
    NSMutableArray *_pendingActions;
}


# pragma mark - Tile creation

+ (GeometricTile *)insertNewTileToCell:(Cell *)cell
{
    GeometricTile *tile = [[GeometricTile alloc] init];

    // The initial position of the tile is at the center of its cell. This is so because when
    // scaling the tile, SpriteKit does so from the origin, not the center. So we have to scale
    // the tile while moving it back to its normal position to achieve the "pop out" effect.
    CGPoint origin = [GSTATE locationOfPosition:cell.position];
    tile.anchorPoint = CGPointMake(0.5, 0.5);
    tile.position = origin;
//    tile.position = CGPointMake(origin.x + GSTATE.tileSize / 2, origin.y + GSTATE.tileSize / 2);
    [tile setScale:0];

    NSLog(@"tile: %.0f %.0f", tile.position.x, tile.position.y);
    
    cell.tile = tile;
    return tile;
}

- (instancetype)init
{
    if (self = [super initWithImageNamed:@"2"]) {
        // Initiate pending actions queue.
        _pendingActions = [[NSMutableArray alloc] init];

        // Вводим немного разнообразия: на экране могут появляться не только ячейки типа 2, но и 4
        self.level = arc4random_uniform(100) < 95 ? 1 : 2;

        [self refreshValue];
    }
    return self;
}

# pragma mark - Public methods

- (void)removeFromParentCell
{
    // Check if the tile is still registered with its parent cell, and if so, remove it.
    // We don't really care about self.cell, because that is a weak pointer.
    if (self.cell.tile == self) self.cell.tile = nil;
}

- (BOOL)hasPendingMerge
{
    // A move is only one action, so if there are more than one actions, there must be
    // a merge that needs to be committed. If things become more complicated, change
    // this to an explicit ivar or property.
    return _pendingActions.count > 1;
}

- (void)commitPendingActions
{
    [self runAction:[SKAction sequence:_pendingActions]];
    [_pendingActions removeAllObjects];
}

- (BOOL)canMergeWithTile:(GeometricTile *)tile
{
    if (!tile) return NO;
    return [GSTATE isLevel:self.level mergeableWithLevel:tile.level];
}

- (NSInteger)mergeToTile:(GeometricTile *)tile
{
    // Cannot merge with thin air. Also cannot merge with tile that has a pending merge.
    // For the latter, imagine we have 4, 2, 2. If we move to the right, it will first
    // become 4, 4. Now we cannot merge the two 4's.
    if (!tile || [tile hasPendingMerge]) return 0;

    NSInteger newLevel = [GSTATE mergeLevel:self.level withLevel:tile.level];
    if (newLevel > 0) {
        // 1. Move self to the destination cell.
        [self moveToCell:tile.cell];

        // 2. Remove the tile in the destination cell.
        [tile removeWithDelay];

        // 3. Update value and pop.
        [self updateLevelTo:newLevel];
        [_pendingActions addObject:[self pop]];
    }
    return newLevel;
}

- (NSInteger)merge3ToTile:(GeometricTile *)tile andTile:(GeometricTile *)furtherTile
{
    if (!tile || [tile hasPendingMerge] || [furtherTile hasPendingMerge]) return 0;

    NSUInteger newLevel = MIN([GSTATE mergeLevel:self.level withLevel:tile.level],
                              [GSTATE mergeLevel:tile.level withLevel:furtherTile.level]);
    if (newLevel > 0) {
        // 1. Move self to the destination cell AND move the intermediate tile to there too.
        [tile moveToCell:furtherTile.cell];
        [self moveToCell:furtherTile.cell];

        // 2. Remove the tile in the destination cell.
        [tile removeWithDelay];
        [furtherTile removeWithDelay];

        // 3. Update value and pop.
        [self updateLevelTo:newLevel];
        [_pendingActions addObject:[self pop]];
    }
    return newLevel;
}

- (void)updateLevelTo:(NSInteger)level
{
    self.level = level;
    [_pendingActions addObject:[SKAction runBlock:^{
                                    [self refreshValue];
                                }]];
}

- (void)refreshValue
{
    long value = [GSTATE valueForLevel:self.level];
    _value = [NSString stringWithFormat:@"%ld", value];

    self.texture = [GSTATE textureForLevel:self.level];
}

- (void)moveToCell:(Cell *)cell
{
    [_pendingActions addObject:[SKAction moveBy:[GSTATE distanceFromPosition:self.cell.position
                                                                  toPosition:cell.position]
                                       duration:GSTATE.animationDuration]];
    self.cell.tile = nil;
    cell.tile      = self;
}

- (void)removeAnimated:(BOOL)animated
{
    [self removeFromParentCell];
    // @TODO: fade from center.
    if (animated) [_pendingActions addObject:[SKAction scaleTo:0 duration:GSTATE.animationDuration]];
    [_pendingActions addObject:[SKAction removeFromParent]];
    [self commitPendingActions];
}

- (void)removeWithDelay
{
    [self removeFromParentCell];
    SKAction *wait   = [SKAction waitForDuration:GSTATE.animationDuration];
    SKAction *remove = [SKAction removeFromParent];
    [self runAction:[SKAction sequence:@[wait, remove]]];
}

# pragma mark - SKAction helpers

- (SKAction *)pop
{
    CGFloat  d         = 0.15 * GSTATE.tileSize;
    SKAction *wait     = [SKAction waitForDuration:GSTATE.animationDuration / 3];
    SKAction *enlarge  = [SKAction scaleTo:1.3 duration:GSTATE.animationDuration / 1.5];
    SKAction *move     = [SKAction moveBy:CGVectorMake(-d, -d) duration:GSTATE.animationDuration / 1.5];
    SKAction *restore  = [SKAction scaleTo:1 duration:GSTATE.animationDuration / 1.5];
    SKAction *moveBack = [SKAction moveBy:CGVectorMake(d, d) duration:GSTATE.animationDuration / 1.5];

    return [SKAction sequence:@[wait, [SKAction group:@[enlarge, move]],
                                [SKAction group:@[restore, moveBack]]]];
}

@end
