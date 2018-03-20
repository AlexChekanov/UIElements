import Foundation
import UIKit
import Styles

@IBDesignable
public final class HeadersCarouselControl: UIControl {
    
    @IBOutlet public weak var collectionView: UICollectionView!
    
    public var constantElementsWidth: CGFloat = 0
    
    var heightCorrectionConstant: CGFloat = 0
    var maximumCellHeight: CGFloat {
        return self.collectionView.bounds.height + heightCorrectionConstant
    }
    
    public var acceptableWidthForTextOfOneLine: CGFloat = 100
    
    public var attentionColor = UIColor.orange
    public var denialColor = UIColor.red
    public var neutralAction = UIColor.gray
    
    public struct HeaderElement {
        
        var title: String
        var deselectedTextStyle: TextStyle
        var selectedTextStyle: TextStyle
        var movable: Bool
        var removable: Bool
        
        public init(title: String, deselectedTextStyle: TextStyle, selectedTextStyle: TextStyle, movable: Bool, removable: Bool) {
            
            self.title = title
            self.deselectedTextStyle = deselectedTextStyle
            self.selectedTextStyle = selectedTextStyle
            self.movable = movable
            self.removable = removable
        }
    }
    
    public struct GroupElement {
        
        var title: String
        var textStyle: TextStyle
        var removable: Bool
    }
    
    enum CollectionState {
        case normal
        case editing
        case rearrangement
        
        mutating func next() {
            switch self {
            case .normal:
                self = .editing
            case .editing:
                self = .rearrangement
            case .rearrangement:
                self = .normal
            }
        }
    }
    
    public var headerElements: [HeaderElement] = [] {
        
        didSet {
            collectionView.reloadData()
        }
    }
    
    public var groupElement: GroupElement?
    
    private var headerCellIdentifier = "cell"
    
    
    var collectionState: CollectionState = .normal {
        
        didSet {
            setCollectionViewMode()
        }
    }
    
    // Gesture Recognizer
    let lpgr = UILongPressGestureRecognizer()
    
    var selectedCellCenter = CGPoint.zero
    var gestureFirstPoint = CGPoint.zero
    
    var δX: CGFloat = 0.0
    var δY: CGFloat = 0.0
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        loadFromNib()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(UINib(nibName: "HeaderCollectionViewCell", bundle: Bundle(for: type(of: self))), forCellWithReuseIdentifier: headerCellIdentifier)
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
        
        addLongPressObserver()
    }
}

extension HeadersCarouselControl: UIGestureRecognizerDelegate {
    
    func addLongPressObserver() {
        lpgr.addTarget(self, action: #selector(handleLongPress(_:)))
        lpgr.minimumPressDuration = 0.5
        lpgr.delegate = self
        lpgr.delaysTouchesBegan = false
        self.collectionView?.addGestureRecognizer(lpgr)
    }
    
    // MARK: - Gestures handeling
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer){
        
        
        switch(gesture.state) {
            
        case UIGestureRecognizerState.began:
            
            collectionState.next()
            
            guard collectionState == .rearrangement else { break }
            
            guard let selectedIndexPath = self.collectionView?.indexPathForItem(at: gesture.location(in: self.collectionView)) else { break }
            
            //tmpDatas = datas
            
            selectedCellCenter = (collectionView?.layoutAttributesForItem(at: selectedIndexPath)?.center)!
            gestureFirstPoint = gesture.location(in: self.collectionView)
            
            δX = selectedCellCenter.x - gestureFirstPoint.x
            δY = selectedCellCenter.y - gestureFirstPoint.y
            
            collectionView?.beginInteractiveMovementForItem(at: selectedIndexPath)
            
            
        case UIGestureRecognizerState.changed:
            
            guard collectionState == .rearrangement else { break }
            
            let newPoint = CGPoint(x: (gesture.location(in: gesture.view!).x + δX), y: (gesture.location(in: gesture.view!).y + δY))
            
            collectionView?.updateInteractiveMovementTargetPosition(newPoint)
            
            
        case UIGestureRecognizerState.ended:
            
            collectionView?.endInteractiveMovement()
            
            guard collectionState == .rearrangement else { break }
            
            performBatchUpdates()
            
            collectionState = .normal
            
            //tmpDatas = nil
            
            δX = 0.0
            δY = 0.0
            
            
        default:
            
            
            collectionView?.cancelInteractiveMovement()
            
            //performBatchUpdates()
            
            collectionState = .normal
            
            δX = 0.0
            δY = 0.0
        }
    }
}

// Mark: - Service methods

extension HeadersCarouselControl {
    
    func performBatchUpdates() {
        self.collectionView?.performBatchUpdates(
            { self.collectionView?.reloadSections(NSIndexSet(index: 0) as IndexSet)
        }, completion: { (finished:Bool) -> Void in
            
        })
    }
    
    
    func setCollectionViewMode() {
        
        collectionView?.visibleCells.forEach {
            guard let cell = $0 as? HeaderCollectionViewCell else { return }
            cell.cellState = collectionState
        }
        
        //        collectionView?.visibleSupplementaryViews(ofKind: UICollectionElementKindSectionFooter).forEach {
        //            //let footer = $0 as! GoalFooter
        //            footer.viewState = collectionState
        //        }
        //
        //        collectionView?.visibleSupplementaryViews(ofKind: UICollectionElementKindSectionHeader).forEach {
        //            //let header = $0 as! GoalHeader
        //            header.viewState = collectionState
        //        }
    }
}

extension HeadersCarouselControl: UICollectionViewDelegate, UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return headerElements.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: headerCellIdentifier, for: indexPath) as! HeaderCollectionViewCell
        
        let headerElement = headerElements[indexPath.item]
        
        cell.configure(title: headerElement.title,
                       movable: headerElement.movable,
                       removable: headerElement.removable,
                       deselectedTextStyle: headerElement.deselectedTextStyle,
                       selectedTextStyle: headerElement.selectedTextStyle,
                       constantElementsWidth: constantElementsWidth, acceptableWidthForTextOfOneLine: acceptableWidthForTextOfOneLine,
                       maximumHeight: maximumCellHeight,
                       isTheFirstCell: indexPath.item == 0,
                       attentionColor: attentionColor,
                       denialColor: denialColor,
                       neutralAction: neutralAction)
        
        cell.tag = indexPath.item
        cell.delegate = self
        
        return cell
    }
    
    
    //    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    //
    //        // Configure the cell
    //        guard let cell = cell as? HeaderCollectionViewCell, indexPath.item < headerElements.count else { return }
    //
    //
    //
    //    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let cell = (collectionView.cellForItem(at: indexPath)) as? HeaderCollectionViewCell else { return }
        cell.updateTitle()
        collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.left, animated: true)
    }
    
    public  func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = (collectionView.cellForItem(at: indexPath)) as? HeaderCollectionViewCell else { return }
        cell.updateTitle()
    }
}

extension HeadersCarouselControl: HeadersCarouselControlDelegate {
    
    public func xButtonPressed(at index: Int) {
        
        print ("Element at \((index)): Should be deleted")
    }
    
    public func plusButtonPressed(at index: Int) {
        print ("Insert task before the element at \((index))")
    }
    
    public func lockButtonPressed(at index: Int) {
        print ("It's locked element at \((index))")
    }
}

public protocol HeadersCarouselControlDelegate {
    
    func xButtonPressed(at index: Int)
    func plusButtonPressed(at index: Int)
    func lockButtonPressed(at index: Int)
    
}

// Orientation & Trait
extension HeadersCarouselControl {
    
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
    }
    
    
    
    
    
    
}

/*
 import UIKit
 
 private let reuseCellIdentifier = "Step"
 private let reuseFooterIdentifier = "Goal"
 
 
 class ProcessVC: UICollectionViewController, UIGestureRecognizerDelegate {
 
 
 
 
 // MARK: - Footer (Represents Goal)
 
 override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
 
 return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: reuseFooterIdentifier, for: indexPath) as! GoalFooter
 }
 
 
 override func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
 guard let view = view as? GoalFooter else { return }
 
 view.object = goal
 view.viewState = collectionState
 }
 
 
 // MARK: - UICollectionViewDelegate
 
 /*
 // Uncomment this method to specify if the specified item should be highlighted during tracking
 override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
 return true
 }
 */
 
 /*
 // Uncomment this method to specify if the specified item should be selected
 override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
 return true
 }
 */
 
 /*
 // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
 override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
 return false
 }
 
 override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
 return false
 }
 
 override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
 
 }
 */
 
 //MARK: - Memory Management
 
 
 override func didReceiveMemoryWarning() {
 super.didReceiveMemoryWarning()
 // Dispose of any resources that can be recreated.
 }
 
 /*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
 }
 
 
 // MARK: - Layout
 
 extension ProcessVC: UICollectionViewDelegateFlowLayout {
 
 func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
 
 guard (self.collectionView?.bounds.height != nil) else { return CGSize.zero }
 
 let cellHeight = (self.collectionView?.bounds.height)!*0.8
 var cellWidth: CGFloat = 0.0
 
 if let tmpDatas = tmpDatas {
 
 cellWidth = tmpDatas[indexPath.item]
 
 } else {
 
 if datas.count == 0 { buildCellSizesCache() }
 cellWidth = datas[indexPath.item]
 }
 
 return CGSize(width: cellWidth, height: cellHeight)
 }
 
 func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
 
 guard ((self.collectionView?.bounds.height) != nil) else { return CGSize.zero }
 
 let footerHeight = (self.collectionView?.bounds.height)!*0.8
 let footer = GoalFooter()
 let footerSize: CGSize = footer.getFooterSize(fromText: goal.title, withHeight: footerHeight)
 
 return footerSize
 }
 }
 
 
 // MARK: - Reorder
 
 extension ProcessVC {
 
 // Chek if the cell is movable
 
 override func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
 
 guard let cell = (collectionView.cellForItem(at: indexPath) as? StepCell) else  { return false }
 
 return cell.canBeMoved
 }
 
 // Perform move action
 
 override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath,
 to destinationIndexPath: IndexPath) {
 
 if #available(iOS 9.0, *) {
 
 if self.lpgr.state == .ended {
 
 // Update external data
 datas = tmpDatas!
 tmpDatas = nil
 
 data.moveItem(at: sourceIndexPath.item, to: destinationIndexPath.item)
 tasks = (data.currentGoal?.tasks)!
 
 return
 } else {
 
 let temp = tmpDatas!.remove(at: sourceIndexPath.item)
 tmpDatas!.insert(temp, at: destinationIndexPath.item)
 }
 }
 }
 }
 
 extension UICollectionViewFlowLayout {
 
 @available(iOS 9.0, *)
 open override func invalidationContext(forInteractivelyMovingItems targetIndexPaths: [IndexPath], withTargetPosition targetPosition: CGPoint, previousIndexPaths: [IndexPath], previousPosition: CGPoint) -> UICollectionViewLayoutInvalidationContext {
 
 let context = super.invalidationContext(forInteractivelyMovingItems: targetIndexPaths, withTargetPosition: targetPosition, previousIndexPaths: previousIndexPaths, previousPosition: previousPosition)
 
 if previousIndexPaths.first!.item != targetIndexPaths.first!.item {
 collectionView?.dataSource?.collectionView?(collectionView!, moveItemAt: previousIndexPaths.first!, to: targetIndexPaths.last!)
 }
 
 return context
 }
 
 open override func invalidationContextForEndingInteractiveMovementOfItems(toFinalIndexPaths indexPaths: [IndexPath], previousIndexPaths: [IndexPath], movementCancelled: Bool) -> UICollectionViewLayoutInvalidationContext {
 
 return super.invalidationContextForEndingInteractiveMovementOfItems(toFinalIndexPaths: indexPaths, previousIndexPaths: previousIndexPaths, movementCancelled: movementCancelled)
 }
 
 @available(iOS 9.0, *)
 open override func layoutAttributesForInteractivelyMovingItem(at indexPath: IndexPath, withTargetPosition position: CGPoint) -> UICollectionViewLayoutAttributes {
 let attributes = super.layoutAttributesForInteractivelyMovingItem(at: indexPath, withTargetPosition: position)
 
 attributes.alpha = 0.6
 
 return attributes
 }
 }
 
 
 // MARK: - Rotation
 
 
 //  extension UICollectionViewFlowLayout {
 //    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
 //        let oldBounds = collectionView?.bounds
 //        if newBounds.width != oldBounds?.width {
 //
 //
 //            //            let delegate = collectionView?.delegate as? ProcessVC
 //            //            delegate?.datas.removeAll()
 //            //            delegate?.tmpDatas = nil
 //
 //            //collectionView?.reloadData()
 //
 //            return true
 //        }
 //        return false
 //    }
 //  }
 
 extension ProcessVC {
 
 override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
 super.viewWillTransition(to: size, with: coordinator)
 collectionViewSizeChanged = true
 
 self.datas.removeAll()
 self.tmpDatas = nil
 self.collectionViewLayout.invalidateLayout()
 }
 
 override func viewWillLayoutSubviews() {
 super.viewWillLayoutSubviews()
 
 if collectionViewSizeChanged {
 
 self.collectionView?.layoutIfNeeded()
 }
 }
 
 override func viewDidLayoutSubviews() {
 super.viewDidLayoutSubviews()
 
 
 if collectionViewSizeChanged && self.collectionState != .rearrangement {
 
 performBatchUpdates()
 }
 
 
 collectionViewSizeChanged = false
 }
 }
 
 
 // Mark: - Service methods
 
 extension ProcessVC {
 
 
 func performBatchUpdates() {
 
 
 
 self.collectionView?.performBatchUpdates(
 { self.collectionView?.reloadSections(NSIndexSet(index: 0) as IndexSet)
 }, completion: { (finished:Bool) -> Void in
 
 })
 }
 
 
 func setCollectionViewMode() {
 
 collectionView?.visibleCells.forEach {
 let cell = $0 as! StepCell
 cell.cellState = collectionState
 }
 
 collectionView?.visibleSupplementaryViews(ofKind: UICollectionElementKindSectionFooter).forEach {
 let footer = $0 as! GoalFooter
 footer.viewState = collectionState
 }
 
 collectionView?.visibleSupplementaryViews(ofKind: UICollectionElementKindSectionHeader).forEach {
 let header = $0 as! GoalHeader
 header.viewState = collectionState
 }
 }
 }
 
 */
