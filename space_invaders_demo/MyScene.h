//
//  MyScene.h
//  oma_invaders
//

//  Copyright (c) 2013 Pauli Varelius. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>



@interface MyScene : SKScene


@end

// Nää tarvitaan sks particleja varten

@interface SKEmitterNode (fromFile)
+(instancetype)orb_emitterNamed:(NSString*)name;
@end

@implementation SKEmitterNode (fromFile)

+(instancetype)orb_emitterNamed:(NSString*)name{
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle]
                                                       pathForResource:name ofType:@"sks"]];
}
@end

