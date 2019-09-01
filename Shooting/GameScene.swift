//
//  GameScene.swift
//  Shooting
//
//  Created by Daichi Hayashi on 2019/08/31.
//  Copyright © 2019 Daichi Hayashi. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    var vc: GameViewController!
    var lifeLabelNode = SKLabelNode() // ライフ表示用ラベル
    var scoreLabelNode = SKLabelNode() // スコア表示用ラベル
    // ライフ用プロパティ
    var life: Int = 0 {
        didSet {
            self.lifeLabelNode.text = "LIFE: \(life)"
        }
    }
    // スコア用プロパティ
    var score: Int = 0 {
        didSet {
            self.scoreLabelNode.text = "SCORE: \(score)"
        }
    }
    
    var myShip = SKSpriteNode()
    var enemyRate: CGFloat = 0.0 // 敵の表示倍率用変数
    var enemySize = CGSize(width: 0.0, height: 0.0) // 敵のほ表示サイズ用変数
    var timer: Timer?
    
    let motionMgr = CMMotionManager()
    var accelarationX: CGFloat = 0.0
    
    // カテゴリビットマスクの定義
    let myShipCategory: UInt32 = 0b0001
    let missileCategory: UInt32 = 0b0010
    let enemyCategory: UInt32 = 0b0100
    
    override func didMove(to view: SKView) {
        var sizeRate: CGFloat = 0.0
        var myShipSize = CGSize(width: 0.0, height: -1.0)
        let offsetY = frame.height / 20
        
        // 画面への重力設定
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        self.myShip.physicsBody?.contactTestBitMask = self.enemyCategory
        self.myShip.physicsBody?.isDynamic = true
        
        // 画像ファイルの読み込み
        self.myShip = SKSpriteNode(imageNamed: "myShip")
        // myShip を幅の1/5にするための倍率を求める
        sizeRate = (frame.width / 5)/self.myShip.size.width
        // myShip のサイズを計算する
        myShipSize = CGSize(width: self.myShip.size.width * sizeRate, height: self.myShip.size.height * sizeRate)
        // myShip のサイズを設定する
        self.myShip.scale(to: myShipSize)
        // myShip の表示位置を設定する
        self.myShip.position = CGPoint(x: 0, y: (-frame.height/2) + offsetY + myShipSize.height/2)
        
        // myShip への物理ボディ、カテゴリビットマスク、衝突ビットマスクの設定
        self.myShip.physicsBody = SKPhysicsBody(rectangleOf: self.myShip.size)
        self.myShip.physicsBody?.categoryBitMask = self.myShipCategory
        self.myShip.physicsBody?.collisionBitMask = self.enemyCategory
        self.myShip.physicsBody?.contactTestBitMask = self.enemyCategory
        self.myShip.physicsBody?.isDynamic = true
        // シーンに myShip を追加する．
        addChild(self.myShip)
        
        // 敵の画像ファイル読み込み
        let tempEnemy = SKSpriteNode(imageNamed: "enemy1")
        // 敵を幅の10%にするための倍率を求める
        enemyRate = (frame.width/10)/tempEnemy.size.width
        // 敵のサイズを計算
        enemySize = CGSize(width: tempEnemy.size.width * enemyRate, height: tempEnemy.size.height * enemyRate)
        // 敵を表示するメソッドmoveEnemyを1秒毎に呼び出し
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in self.moveEnemy()})
        
        // 加速度センサーの取得間隔を設定取得処理
        motionMgr.accelerometerUpdateInterval = 0.05
        // 加速度センサーの変更値取得
        motionMgr.startAccelerometerUpdates(to: OperationQueue.current!) { (val, _) in
            guard let unwrapVal = val else {
                return
            }
            let acc = unwrapVal.acceleration
            self.accelarationX = CGFloat(acc.x)
            print(acc.x)
        }
        
        // ライフの作成
        self.life = 3
        self.lifeLabelNode.fontName = "HelveticaNeue-Bold"
        self.lifeLabelNode.fontColor = UIColor.white
        self.lifeLabelNode.fontSize = 30
        self.lifeLabelNode.position = CGPoint(x: frame.width/2 - (self.lifeLabelNode.frame.width + 20), y: frame.height/2 - (self.lifeLabelNode.frame.height * 3))
        addChild(self.lifeLabelNode)
        // スコアのヒョ次
        self.score = 3
        self.scoreLabelNode.fontName = "HelveticaNeue-Bold"
        self.scoreLabelNode.fontColor = UIColor.white
        self.scoreLabelNode.fontSize = 30
        self.scoreLabelNode.position = CGPoint(x: -frame.width/2 + self.scoreLabelNode.frame.width, y: frame.height/2 - (self.scoreLabelNode.frame.height * 3))
        addChild(self.scoreLabelNode)
    }
    
    // シーンの更新
    override func didSimulatePhysics() {
        let pos = self.myShip.position.x + self.accelarationX * 30
        if pos > frame.width / 2 - self.myShip.frame.width/2 {return}
        if pos < -frame.width / 2 + self.myShip.frame.width/2 {return}
        self.myShip.position.x = pos
    }
    
    // 敵を表示するメソッド
    func moveEnemy() {
        let enemyNames = ["enemy1", "enemy2", "enemy3"]
        let idx = Int.random(in: 0 ..< 3)
        let selectedEnemy = enemyNames[idx]
        let enemy = SKSpriteNode(imageNamed: selectedEnemy)
        
        // 敵のサイズを設定する
        enemy.scale(to: enemySize)
        // 敵のx方向の位置を生成
        let xPos = (frame.width/CGFloat.random(in: 1...5)) - frame.width/2
        // 敵の位置を設定する
        enemy.position = CGPoint(x: xPos, y: frame.height/2)
        
        // 敵への物理ボディ、カテゴリビットマスクの設定
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody?.categoryBitMask = enemyCategory
        enemy.physicsBody?.isDynamic = true
        // シーンに敵を表示する
        addChild(enemy)
        
        // 指定した位置まで2秒で移動させる
        let move = SKAction.moveTo(y: -frame.height/2, duration: 2.0)
        // 親からノードを削除
        let remove = SKAction.removeFromParent()
        // アクションを連続して実行する
        enemy.run(SKAction.sequence([move, remove]))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        // 画像ファイルの読み込み
        let missile = SKSpriteNode(imageNamed: "missile")
        // ミサイルの発射位置の作成
        let missilePos = CGPoint(x: self.myShip.position.x, y: self.myShip.position.y + (self.myShip.size.height/2) - (missile.size.height/2))
        // ミサイル発射位置の設定
        missile.position = missilePos
        
        // ミサイルの物理ボディ、カテゴリビットマスク、衝突ビットマスクの設定
        missile.physicsBody = SKPhysicsBody(rectangleOf: missile.size)
        missile.physicsBody?.categoryBitMask = self.missileCategory
        missile.physicsBody?.collisionBitMask = self.missileCategory
        missile.physicsBody?.contactTestBitMask = self.enemyCategory
        missile.physicsBody?.isDynamic = true
        // シーンにミサイルを追加する
        addChild(missile)
        // 指定した位置まで移動する
        let move = SKAction.moveTo(y: frame.height + missile.size.height, duration: 0.5)
        // 親からノードを削除
        let remove = SKAction.removeFromParent()
        // アクションを連続して実行する
        missile.run(SKAction.sequence([move, remove]))
    }
    
    // 衝突時のメソッド
    func didBegin(_ contact: SKPhysicsContact) {
        // 衝突したノードの削除
        contact.bodyA.node?.removeFromParent()
        contact.bodyB.node?.removeFromParent()
        
        // 炎のパーティクルの読み込みと表示
        let explosion = SKEmitterNode(fileNamed: "explosion")
        explosion?.position = contact.bodyA.node?.position ?? CGPoint(x: 0, y: 0)
        addChild(explosion!)
        
        // 炎のパーティクルアニメーションを0.5秒表示して削除
        self.run(SKAction.wait(forDuration: 0.5)) {
            explosion?.removeFromParent()
        }
        
        // ミサイルが的にあたっときの処理
        if contact.bodyA.categoryBitMask == missileCategory || contact.bodyB.categoryBitMask == missileCategory {
            self.score += 10
        }
        // myShip が爆発したときの処理
        if contact.bodyA.categoryBitMask == myShipCategory || contact.bodyB.categoryBitMask == myShipCategory {
            self.life -= 1
            // 1病後にrestart
            self.run(SKAction.wait(forDuration: 1)) {
                self.restart()
            }
        }
    }
    
    // リスタート処理
    func restart() {
        if self.life <= 0 {
            // start画面に戻る
            vc.dismiss(animated: true, completion: nil)
        }
        // ライフが1以上ならmyShipを再表示
        addChild(self.myShip)
    }
}
