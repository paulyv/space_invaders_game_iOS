//
//  MyScene.m
//  oma_invaders
//
//  Created by Pauli Varelius on 30/10/13.
//  Copyright (c) 2013 Pauli Varelius. All rights reserved.
//

#import "MyScene.h"
#define ARC4RANDOM_MAX      0x100000000

@interface MyScene () <SKPhysicsContactDelegate>
//@property (nonatomic) SKSpriteNode * player; // turha rivi, ei käytössä
@end

// Collision detection
static const uint32_t bulletCategory     =  0x1 << 0;       // playerBullet
static const uint32_t monsterCategory    =  0x1 << 1;       // Monster

// Kills and bullets
static int bullet_num = 0;
static int kill_num = 0;

@implementation MyScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        /* Setup your scene here */
        self.backgroundColor = [SKColor blackColor];
        [self addMonster:CGPointMake(0, self.frame.size.height - 40), 1];
        [self addMonster:CGPointMake(self.frame.size.width, self.frame.size.height - 80), 2];
        [self addMonster:CGPointMake(0, self.frame.size.height - 120), 1];
        [self addMonster:CGPointMake(self.frame.size.width, self.frame.size.height - 160), 2];
        [self addPlayer];
        [self addBackground];
        
        // Level 1 label
        SKLabelNode *level1 = [SKLabelNode labelNodeWithFontNamed:@"chalkDuster"];
        level1.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        level1.text = @"LEVEL 1";
        level1.fontSize = 30;
        [self addChild:level1];
        [level1 runAction: [SKAction sequence:@[[SKAction rotateByAngle:18.84 duration:1],
                                                [SKAction waitForDuration:0.7],
                                                [SKAction removeFromParent]]]];
        
        // Add physics
        self.physicsWorld.gravity = CGVectorMake(0,0);
        self.physicsWorld.contactDelegate = self;
        
    }
    return self;
}

// Avaruustaustan lisäys methodi
-(void)addBackground{
    SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"starscape"];
    bg.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    bg.name = @"background";
    bg.zPosition = -1;
    [self addChild:bg];
    
}

// Avaruustaustan getter
- (SKNode *)backgroundNode
{
    return [self childNodeWithName:@"background"];
}

// Kills labelin lisäys methodi
-(void)addKillCount {
    NSString *kills_text = [NSString stringWithFormat:@"Kills: %i", kill_num];
    SKLabelNode *kills = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    kills.name = @"kills_text";
    kills.fontSize = 20;
    kills.position = CGPointMake(250, 5);
    kills.text = kills_text;
    [self addChild:kills];
}
// Kills labelin getter
- (SKNode *)killsNode
{
    return [self childNodeWithName:@"kills_text"];
}

// Monsterien lisäys. Ottaa pisteen ja kumpaan suuntaan lähtee liikkumaan ensin
-(void)addMonster:(CGPoint)point, int direction {
    
    CGPoint piste = point;
    int suunta = direction;
    SKSpriteNode * monster = [SKSpriteNode spriteNodeWithImageNamed:@"Monster"];
    monster.xScale = 0.2;
    monster.yScale = 0.2;
    monster.name = @"monsteri";
    monster.position = piste;
    
    // Add physics
    monster.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:monster.size];
    monster.physicsBody.dynamic = YES;
    monster.physicsBody.categoryBitMask = monsterCategory;
    monster.physicsBody.contactTestBitMask = bulletCategory;
    monster.physicsBody.collisionBitMask = 0;
    
    // Moving Left to Right Action
    if(suunta == 1){
        SKAction * actionMoveRight = [SKAction moveTo:CGPointMake(self.frame.size.width, monster.position.y) duration:1];
        
        SKAction *actionMoveLeft = [SKAction moveTo:CGPointMake(0, monster.position.y) duration:1];
        SKAction *Move = [SKAction sequence:@[actionMoveRight,actionMoveLeft]];
        [monster runAction:[SKAction repeatActionForever:Move]];
        [self addChild:monster];
        
    }else{
        
        SKAction * actionMoveLeft = [SKAction moveTo:CGPointMake(0, monster.position.y) duration:1];
        SKAction * actionMoveRight = [SKAction moveTo:CGPointMake(self.frame.size.width, monster.position.y) duration:1];
        
        SKAction *Move = [SKAction sequence:@[actionMoveLeft,actionMoveRight]];
        [monster runAction:[SKAction repeatActionForever:Move]];
        [self addChild:monster];
    }
    
    // Venttaillaan random aika ja ammutaan
    SKAction *shoot = [SKAction sequence:@[[SKAction waitForDuration:floorf(((double)arc4random() / ARC4RANDOM_MAX) * 6.3f) + 3.3], [SKAction performSelector:@selector(MonsterShoot) onTarget:self]]];
    [monster runAction:[SKAction repeatActionForever:shoot]];
    
}
// Lisätään pelaaja ruudun alareunaan
-(void)addPlayer {
    
    SKSpriteNode * player = [SKSpriteNode spriteNodeWithImageNamed:@"Ship"];
    player.position = CGPointMake(self.frame.size.width/2, 50);
    player.xScale = 0.2;
    player.yScale = 0.2;
    player.name = @"player";
    [self addChild:player];
    
}
// Pelaajan getter
- (SKNode *)playerNode
{
    return [self childNodeWithName:@"player"];
}
// Pelaajan ampuminen eli bulletti
-(void)playerShoot {
    
    SKNode *p1 = [self playerNode];
    
    if(bullet_num == 0){
        SKSpriteNode *bullet = [SKSpriteNode spriteNodeWithImageNamed:@"Bullet"];
        bullet.name = @"bullet";
        bullet.position = CGPointMake(p1.position.x, p1.position.y);
        bullet.xScale = 0.05;
        bullet.yScale = 0.05;
        
        // Add physics
        
        bullet.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bullet.size];
        bullet.physicsBody.dynamic = YES;
        bullet.physicsBody.categoryBitMask = bulletCategory;
        bullet.physicsBody.contactTestBitMask = monsterCategory;
        bullet.physicsBody.collisionBitMask = 0;
        bullet.physicsBody.usesPreciseCollisionDetection = YES;
        
        [self addChild:bullet];
        [self addBulletParticle];
        bullet_num = 1;
    }
}
// Bullet particle
-(void)addBulletParticle {
    SKNode *bulletNode = [self bulletNode];
    SKEmitterNode *trail = [SKEmitterNode orb_emitterNamed:@"bulletParticle"];
    trail.name = @"BulletParticle";
    trail.targetNode = self;
    trail.position = CGPointMake(bulletNode.position.x, bulletNode.position.y);
    [self addChild:trail];
    
}
// Bullet particlen getter
- (SKNode *)bulletParticleNode
{
    return [self childNodeWithName:@"BulletParticle"];
}
// Player shoot bullet getter
- (SKNode *)bulletNode
{
    return [self childNodeWithName:@"bullet"];
}

// Mitä käy kun ruutua klikataan eri kohdista

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view]; // Huom. self.view -> vasen yläkulma 0,0 nyt
    
    SKNode *p1 = [self playerNode];
    
    // Siirrä playeriä x-akselilla klikattuun pisteeseen
    if(point.y > 480){
        SKAction * actionMovePlayer = [SKAction moveTo:CGPointMake(point.x, 50) duration:1];
        [p1 runAction:actionMovePlayer];
    }
    
    // Jos touch vähän ylemmäs -> ammu
    if(point.y < 480) {
        [self playerShoot];
    }
    
}
// Jos collison bulletin ja monsterin välillä niin poista molemmat & particlet myös
- (void)projectile:(SKSpriteNode *)bullet didCollideWithMonster:(SKSpriteNode *)monster {
    NSLog(@"Hit");
    bullet_num = 0;
    kill_num = kill_num + 1;
    
    SKNode *bulletParticle = [self bulletParticleNode];
    
    SKEmitterNode *explosion = [SKEmitterNode orb_emitterNamed:@"explosionParticle2"];
    explosion.targetNode = self;
    explosion.position = CGPointMake(monster.position.x, monster.position.y);
    
    // Remove bulletP, bullet and monster
    [bulletParticle removeFromParent];
    [bullet removeFromParent];
    [monster removeFromParent];
    
    // Run explosion particle action for 1sec and then remove
    [self addChild:explosion];
    [explosion runAction: [SKAction sequence:@[[SKAction waitForDuration:0.7],
                                               [SKAction removeFromParent]]]];
    
}

// Collision detection bullet vs monster. (on vähän hämärän peitossa, mutta toimii)
- (void)didBeginContact:(SKPhysicsContact *)contact
{
    // 1
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    // 2
    if ((firstBody.categoryBitMask & bulletCategory) != 0 &&
        (secondBody.categoryBitMask & monsterCategory) != 0)
    {
        [self projectile:(SKSpriteNode *) firstBody.node didCollideWithMonster:(SKSpriteNode *) secondBody.node];
    }
    
}




-(void)MonsterShoot {
    //haetaan kaikki monsteri nodet ja ammutaan niiden sijainnista.
    [self enumerateChildNodesWithName:@"monsteri" usingBlock:^(SKNode *node, BOOL *stop) {
        
        SKEmitterNode *trail = [SKEmitterNode orb_emitterNamed:@"MonsterBullet"];
        trail.name = @"MonsterBulletParticle";
        trail.targetNode = self;
        trail.position = CGPointMake(node.position.x, node.position.y);
        
        [self addChild:trail];
    }];
    
}

// Monster Bullet particle
-(void)addMonsterBulletParticle {
    [self enumerateChildNodesWithName:@"Monsterbullet" usingBlock:^(SKNode *node, BOOL *stop) {
        SKEmitterNode *trail = [SKEmitterNode orb_emitterNamed:@"bulletParticle"];
        trail.name = @"MonsterBulletParticle";
        trail.targetNode = self;
        trail.position = CGPointMake(node.position.x, node.position.y);
        [self addChild:trail];
    }];
}
// Monster Bullet particle getter
- (SKNode *)MonsterParticleNode
{
    return [self childNodeWithName:@"MonsterBulletParticle"];
}

-(void)addWinLabel {
    
    // Level 1 win label
    SKLabelNode *win = [SKLabelNode labelNodeWithFontNamed:@"chalkDuster"];
    win.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    win.text = @"YOU WIN!";
    win.fontSize = 30;
    [self addChild:win];
    
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
    // kaikille tarvittaville nodeille getterit
    SKNode *background = [self backgroundNode];
    SKNode *bullet = [self bulletNode];
    SKNode *kills = [self killsNode];
    SKNode *bulletParticle = [self bulletParticleNode];
    
    int kills_count = 0;    // Vertaa static kill_num muuttujaan
    
    // Bulletin ja bullet particlen liikuttaminen ylös ruudulla
    if (bullet.position.y - 50 > self.frame.size.height) {
        [bullet removeFromParent];
        [bulletParticle removeFromParent];
        bullet_num = 0;
    }else {
        bullet.position = CGPointMake(bullet.position.x, bullet.position.y + 10);
        bulletParticle.position = CGPointMake(bullet.position.x, bullet.position.y);
    }
    
    // backgrounding scrollaus
    if(background.position.y > 0 ){
        background.position = CGPointMake(background.position.x, background.position.y - 3);
    }else{
        background.position = CGPointMake(background.position.x, self.frame.size.height);
    }
    
    if(kills_count <= kill_num){    // Jos kills_count on vähemmän kuin kills_num eli vihu tapettu -> pävitä
        [kills removeFromParent];
        [self addKillCount];
        kills_count++;
    }
    
    // Käydään läpi kaikki monster bulletit ja liikutetaan niitä alas tai poistetaan ruudulta.
    [self enumerateChildNodesWithName:@"MonsterBulletParticle" usingBlock:^(SKNode *node, BOOL *stop) {
        if(node.position.y > 0){
            node.position = CGPointMake(node.position.x, node.position.y - 10);
            
        }else{
            [node removeFromParent];
        }
    }];
    
    // Lisätään voiton kunniaksi win label esiin
    if(kill_num == 4) {
        [self addWinLabel];
    }
    
}




@end


