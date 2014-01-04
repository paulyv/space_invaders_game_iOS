//
//  MainScene.m
//  oma_invaders
//
//  Created by Pauli Varelius on 31/10/13.
//  Copyright (c) 2013 Pauli Varelius. All rights reserved.
//

#import "MainScene.h"
#import "MyScene.h"

@interface MainScene ()

@end

@implementation MainScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        self.backgroundColor = [SKColor blackColor];
        
        SKLabelNode *topic = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        topic.text = @"SPACE INVADERS";
        topic.fontSize = 31;
        topic.position = CGPointMake(self.frame.size.width/2, self.frame.size.height - 80);
        [self addChild:topic];
        
        SKLabelNode *play = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        play.text = @"Play!";
        play.fontSize = 20;
        play.position = CGPointMake(self.frame.size.width/2, self.frame.size.height - 480);
        [self addChild:play];
        
        SKSpriteNode *logo = [SKSpriteNode spriteNodeWithImageNamed:@"logo"];
        logo.xScale = 0.5;
        logo.yScale = 0.5;
        logo.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        [self addChild:logo];
        
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    SKScene *gameScene = [[MyScene alloc]initWithSize:self.size];
    SKTransition *door = [SKTransition doorsOpenVerticalWithDuration:1];
    [self.view presentScene:gameScene transition:door];
    
    
}


@end
