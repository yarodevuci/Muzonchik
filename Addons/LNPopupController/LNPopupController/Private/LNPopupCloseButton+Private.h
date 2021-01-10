//
//  LNPopupCloseButton+Private.h
//  LNPopupController
//
//  Created by Leo Natan on 13/11/2016.
//  Copyright © 2015-2020 Leo Natan. All rights reserved.
//

#import <LNPopupController/LNPopupCloseButton.h>
#import <LNPopupController/LNPopupContentView.h>

@interface LNPopupCloseButton ()

@property (nonatomic, weak) LNPopupContentView* popupContentView;

- (void)_setStyle:(LNPopupCloseButtonStyle)style;
- (void)_setButtonContainerStationary;
- (void)_setButtonContainerTransitioning;

@end
