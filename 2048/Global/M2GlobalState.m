//
//  M2GlobalState.m
//  m2048
//
//  Created by Danqing on 3/16/14.
//  Copyright (c) 2014 Danqing. All rights reserved.
//

#import "M2GlobalState.h"

#define kBestScore @"Best Score"

@interface M2GlobalState ()

@property (nonatomic, readwrite) NSInteger      dimension;
@property (nonatomic, readwrite) NSInteger      winningLevel;
@property (nonatomic, readwrite) NSInteger      tileSize;
@property (nonatomic, readwrite) NSInteger      horizontalOffset;
@property (nonatomic, readwrite) NSInteger      verticalOffset;
@property (nonatomic, readwrite) NSTimeInterval animationDuration;

@end


@implementation M2GlobalState

+ (M2GlobalState *)state
{
    static M2GlobalState *state = nil;

    static dispatch_once_t once;
    dispatch_once(&once, ^{
                      state = [[M2GlobalState alloc] init];
                  });

    return state;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self setupDefaultState];
        [self loadGlobalState];
    }
    return self;
}

- (void)setupDefaultState
{
    NSDictionary *defaultValues = @{kBestScore: @0};
    [Settings registerDefaults:defaultValues];
}

- (void)loadGlobalState
{
    self.dimension         = 4;
    self.animationDuration = 0.1;
    self.horizontalOffset  = [self __horizontalOffset];
    self.verticalOffset    = [self __verticalOffset];
    self.needRefresh       = NO;
}

- (NSInteger)tileSize
{
    return 80;
}

- (NSInteger)__horizontalOffset
{
    CGFloat width = self.dimension * self.tileSize;
    return ([[UIScreen mainScreen] bounds].size.width - width) / 2 + self.tileSize;
}

- (NSInteger)__verticalOffset
{
    CGFloat height = self.dimension * self.tileSize;
    return ([[UIScreen mainScreen] bounds].size.height - height) / 2 + self.tileSize;
}

- (NSInteger)winningLevel
{
    NSInteger level = 11;
    if (self.dimension == 3) return level - 1;
    if (self.dimension == 5) return level + 2;
    return level;
}

- (BOOL)isLevel:(NSInteger)level1 mergeableWithLevel:(NSInteger)level2
{
    return level1 == level2;
}

- (NSInteger)mergeLevel:(NSInteger)level1 withLevel:(NSInteger)level2
{
    if (![self isLevel:level1 mergeableWithLevel:level2]) return 0;
    return level1 + 1;
}

- (NSInteger)valueForLevel:(NSInteger)level
{
    NSInteger value = 1;
    for (NSInteger i = 0; i < level; i++) {
        value *= 2;
    }
    return value;
}

# pragma mark - Appearance

- (SKTexture *)textureForLevel:(NSInteger)level
{
    long     value      = [GSTATE valueForLevel:level];
    NSString *imageName = [NSString stringWithFormat:@"%ld", value];

    return [SKTexture textureWithImage:[UIImage imageNamed:imageName]];

}

# pragma mark - Position to point conversion

- (CGPoint)locationOfPosition:(M2Position)position
{
    CGFloat xLocation = position.y * GSTATE.tileSize;
    CGFloat yLocation = position.x * GSTATE.tileSize;

    return CGPointMake(xLocation + self.horizontalOffset,
                       yLocation + self.verticalOffset);
}

- (CGVector)distanceFromPosition:(M2Position)oldPosition toPosition:(M2Position)newPosition
{
    CGFloat unitDistance = GSTATE.tileSize;
    return CGVectorMake((newPosition.y - oldPosition.y) * unitDistance,
                        (newPosition.x - oldPosition.x) * unitDistance);
}

@end
