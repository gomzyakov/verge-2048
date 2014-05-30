//
//  M2Cell.h
//  m2048
//
//  Created by Danqing on 3/17/14.
//  Copyright (c) 2014 Danqing. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GeometricTile;

@interface Cell : NSObject

/// Расположение ячейки
@property (nonatomic) M2Position position;

/// Плитка с геометрической фигурой, отображаемая в ячейке
@property (nonatomic, strong) GeometricTile *tile;

/**
   Возвращает новую ячейку, инициализированную в заданной позиции.
   @param position The position of the cell.
 */
- (instancetype)initWithPosition:(M2Position)position;

@end
