//
//  PKCircularLayout.swift
//  FearFighter
//
//  Created by Praveen on 19/12/16.
//  Copyright © 2016 CBT Systems. All rights reserved.
//

import UIKit


class CircularCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
    // 1
    var anchorPoint = CGPoint(x: 0.5, y: 0.5)
    //
    
    var angle: CGFloat = 0 {
        // 2
        didSet {
            zIndex = Int(angle * 1000000)
            transform = CGAffineTransform(rotationAngle: angle )
            
        }
    }
    // 3
    override func copy(with zone: NSZone? = nil) -> Any {
        let copiedAttributes: CircularCollectionViewLayoutAttributes = super.copy(with :zone) as! CircularCollectionViewLayoutAttributes
        copiedAttributes.anchorPoint = self.anchorPoint
        copiedAttributes.angle = self.angle
        return copiedAttributes
    }
    
    
    
    
}




class PKCircularLayout: UICollectionViewLayout {

     public var centre:CGPoint = CGPoint(x:100, y:100)
//    public var centre:CGPoint?
    public var radius:CGFloat  = 100.0
    public var itemSize:CGSize  =   CGSize(width:60, height:60)
    public var angularSpacing:CGFloat   =   200.0
    public var mirrorX:Bool =   false
    public var mirrorY:Bool =   false
    public var rotateItems:Bool =   true
    
      override init(){
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    var angleOfEachItem:CGFloat =  20
    var angleforSpacing:CGFloat =   100
    var circumference:CGFloat   =   100
    var cellCount      =   15
    var maxNoOfCellsInCircle:CGFloat = 20
    var startAngle:CGFloat  =   CGFloat(M_PI)
    var endAngle:CGFloat    =   0
    
    
    public func initWith(centre:CGPoint, radius:CGFloat, itemSize:CGSize, angularSpacing:CGFloat){
        self.centre = centre
        self.radius = radius
        self.itemSize = itemSize
        self.angularSpacing =   angularSpacing
    }
    
    public func setStartAngle(startAngle:CGFloat, endAngle:CGFloat){
        self.startAngle =   startAngle
        self.endAngle   =   endAngle
        
        if(self.startAngle == CGFloat(2*M_PI)){
            self.startAngle =   2*CGFloat(M_PI) - CGFloat(M_PI/180)
        }
        if(self.endAngle == CGFloat(2*M_PI)){
            self.endAngle =   2*CGFloat(M_PI) - CGFloat(M_PI/180)
        }
    }
    
    override func prepare() {
        super.prepare()
        cellCount = self.collectionView!.numberOfItems(inSection: 0)
        circumference   =   abs((self.startAngle - self.endAngle) * self.radius)
        maxNoOfCellsInCircle    =   circumference/(max((self.itemSize.width), (self.itemSize.height)) + self.angularSpacing/2)
        angleOfEachItem =   abs(self.startAngle - self.endAngle)/maxNoOfCellsInCircle
    }
    
    override var collectionViewContentSize: CGSize {
//        return CGSize(width: (collectionView!.frame.width ),
//                      height:( CGFloat(collectionView!.numberOfItems(inSection: 0)) * (self.itemSize.height)) + 300)
        let visibleAngle:CGFloat    =   abs(self.startAngle - self.endAngle)
        let remainingItemsCount =  CGFloat(cellCount) > maxNoOfCellsInCircle ? (CGFloat(cellCount) - maxNoOfCellsInCircle) : 0
        let scrollaleContentWidth = (remainingItemsCount + 1) * angleOfEachItem * self.radius/(2*CGFloat(M_PI)/visibleAngle)
        let height = self.radius + (max(self.itemSize.width, self.itemSize.height/2))
        let size    = CGSize(width: height, height: 170 + scrollaleContentWidth + (self.collectionView?.bounds.size.height)!)
//      print(size)
        return size
    }
    
    
     override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = CircularCollectionViewLayoutAttributes(forCellWith: indexPath)
        var offset:CGFloat = ((self.collectionView?.contentOffset.y)! as CGFloat) //- (CGFloat(cellCount/4) * self.itemSize.width )
        offset = offset == 0 ? 1 : offset as CGFloat
        let offsetPartInMPI = offset/circumference as CGFloat
        let zoffsetAngle =  (2 * M_PI)
        let angle:CGFloat =    CGFloat(zoffsetAngle)  * offsetPartInMPI
        let offsetAngle =   angle as CGFloat
        
        attributes.size =   self.itemSize
        let mirrorX =   self.mirrorX ? -1 : 1 as CGFloat
        let mirrorY =   self.mirrorY ? -1 : 1 as CGFloat
        let resultCosf  =   cosf(Float(indexPath.item) * Float(angleOfEachItem) - Float(offsetAngle) + Float(angleOfEachItem/2.0) - Float(self.startAngle))

        let x   =   self.centre.x  + mirrorX * self.radius * CGFloat(resultCosf)
        let resultSinf  =   sinf(Float(indexPath.item) * Float(angleOfEachItem) - Float(offsetAngle) + Float( angleOfEachItem/2) - Float(self.startAngle))
        let y   =   (self.centre.y) + offset + mirrorY * self.radius * CGFloat(resultSinf)
        
//        let cellCurrentAngle    =   CGFloat(indexPath.item) * angleOfEachItem + angleOfEachItem/2 - offsetAngle
//        if (cellCurrentAngle >= -angleOfEachItem/2 && cellCurrentAngle <= CGFloat(abs(self.startAngle - self.endAngle) + angleOfEachItem/2)){
//            attributes.alpha    =   1
//        }
//        else{
//            attributes.alpha    =   0
//        }
//        
        attributes.alpha    =   1
        attributes.center   =   CGPoint(x:x, y:y)
        attributes.zIndex   =   cellCount - indexPath.item
//      attributes.transform    =   CGAffineTransform(rotationAngle: cellCurrentAngle - CGFloat(M_PI/2))
        return attributes
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes: [UICollectionViewLayoutAttributes] = []
        
        for i in 0..<cellCount {
//        let indexPath = IndexPath
                let cellAtrributes:UICollectionViewLayoutAttributes = self.layoutAttributesForItem(at: IndexPath(item:i, section: 0))!
                if (rect.intersects(cellAtrributes.frame)){
                     attributes.append(self.layoutAttributesForItem(at: IndexPath(item: i, section: 0))!)
                }
            }
            return attributes
    }
    
     override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
        attributes?.center   =   CGPoint(x:(self.centre.x) + (self.collectionView?.contentOffset.x)! , y: (self.centre.y) + (self.collectionView?.contentOffset.y)!)
        attributes?.transform   =   CGAffineTransform(scaleX:0.5, y: 0.5)
        attributes?.alpha   =   0.5
        return attributes;
    }
    
     override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
        attributes?.center   =   CGPoint(x:(self.centre.x) + (self.collectionView?.contentOffset.x)! , y: (self.centre.y) + (self.collectionView?.contentOffset.y)!)
        attributes?.transform = CGAffineTransform(scaleX: 0.5, y: 0.5);
        attributes?.alpha   =   0.5
        return attributes;
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
}
