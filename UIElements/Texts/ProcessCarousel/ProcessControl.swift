import Foundation
import UIKit
import Styles

public protocol ProcessControlDelegate {
    
    func addItemToEnd()
    func addItemAt(at index: Int)
    func removeItem(at index: Int)
    func rejectRemoval(at index: Int)
    func editItem(at index: Int)
    func editScript()
    func moveItem(at fromIndex: Int, to toIndex: Int)
}

public enum ProcessControlElementState {
    
    case planned
    case running
    case suspended
    case completed
    case canceled
}
public protocol ProcessControlDataSource {
    
    var process: ProcessControlScript { get }
    var styleOfScript: TextStyle { get }
    
    func styleOfItems(for state: ProcessControlElementState) -> (deselected: TextStyle, selected: TextStyle)
}

public protocol ProcessControlScript {
    
    var title: String? { get set }
    var steps: [ProcessControlStep]? { get set }
}

public protocol ProcessControlStep {
    
    var title: String { get set }
    var order: Int { get set }
    var state: ProcessControlElementState { get set }
    var movable: Bool { get set }
    var removable: Bool { get set }
}

public struct ProcessToControl: ProcessControlScript {
    
    public var title: String?
    public var steps: [ProcessControlStep]?
    
    public init(title: String?, steps: [ProcessControlStep]?){
        self.title = title
        self.steps = steps
    }
}

public struct ProcessStepToControl: ProcessControlStep {
    
    public var title: String
    public var order: Int
    public var state: ProcessControlElementState
    public var movable: Bool
    public var removable: Bool
    
    public init(title: String, order: Int, state: ProcessControlElementState, movable: Bool, removable: Bool) {
        self.title = title
        self.order = order
        self.state = state
        self.movable = movable
        self.removable = removable
    }
}

// MARK: - Class
@IBDesignable
public class ProcessControl: UIControl, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
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
        
        guard dataExists() else {
            
            print ("There is no data")
            return
        }
        
        configure()
        cleanUp()
        addLongPressObserver()
        registerNibs()
    }
    
    // MARK: - Inputs
    public var delegate: ProcessControlDelegate! = nil
    public var datasource: ProcessControlDataSource! = nil {
        didSet {
            buildCellSizesCache()
        }
    }
    
    @IBInspectable var arrowTintColor: UIColor = Colors.neutral
    @IBInspectable var addTintColor: UIColor = Colors.attention
    @IBInspectable var removeTintColor: UIColor = .darkGray
    @IBInspectable var lockTintColor: UIColor = Colors.denial
    @IBInspectable var acceptableWidthForTextOfOneLine: CGFloat = 60
    
    private let stepCellNibName = "StepCollectionViewCell"
    private let stepCellIdentificator = "step"
    
    private let goalViewNibName = "GoalCollectionReusableView"
    private let goalViewIdentificator = "goal"
    
    // MARK: - Cell width management
    var cellWidths: [CGFloat] = []
    var cellWidthTemporal: [CGFloat]?
    var collectionViewSizeChanged: Bool = false
    
    var cellHeightCoefficient: CGFloat = 1
    
    func buildCellSizesCache () {
        
        cellWidths.removeAll()
        
        datasource.process.steps?.forEach {
            
            let cellWidth: CGFloat = StepCollectionViewCell.getCellSize(for: $0.title, style: datasource.styleOfItems(for: $0.state).deselected, height: (collectionView.bounds.height * cellHeightCoefficient), acceptableWidthForTextOfOneLine: acceptableWidthForTextOfOneLine).width
            cellWidths.append(cellWidth)
        }
    }
    
    // MARK: - State
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
    
    var collectionState: CollectionState = .normal {
        
        didSet { setCollectionViewMode() }
    }
    
    // MARK: - Data check
    func dataExists() -> Bool {
        return true //datasource.process != nil
    }
    
    // Mark: - Outputs
    
    // MARK: - CleanUp
    func cleanUp() {
        
        cellWidths.removeAll()
        cellWidthTemporal = nil
    }
    
    // MARK: - Configure
    func configure() {
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.allowsMultipleSelection = false
    }
    
    func registerNibs() {
        
        collectionView.register(UINib(nibName: stepCellNibName, bundle: Bundle(for: type(of: self))), forCellWithReuseIdentifier: stepCellIdentificator)
        
        collectionView.register(UINib(nibName: goalViewNibName, bundle: Bundle(for: type(of: self))), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: goalViewIdentificator)
    }
    
    // MARK: - Gestures handling
    let longPressGestureRecognizer = UILongPressGestureRecognizer()
    
    func addLongPressObserver() {
        longPressGestureRecognizer.addTarget(self, action: #selector(handleLongPress(_:)))
        longPressGestureRecognizer.minimumPressDuration = 0.6
        longPressGestureRecognizer.delegate = self
        longPressGestureRecognizer.requiresExclusiveTouchType = true
        longPressGestureRecognizer.delaysTouchesBegan = false
        self.collectionView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    var selectedCellCenter = CGPoint.zero
    var gestureFirstPoint = CGPoint.zero
    
    var δX: CGFloat = 0.0
    var δY: CGFloat = 0.0
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer){
        
        switch gesture.state {
            
        case UIGestureRecognizerState.began:
            
            collectionState.next()
            
            guard collectionState == .rearrangement else { break }
            
            guard
                let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)),
                let center = collectionView.layoutAttributesForItem(at: selectedIndexPath)?.center
                else { break }
            
            cellWidthTemporal = cellWidths
            
            selectedCellCenter = center
            gestureFirstPoint = gesture.location(in: collectionView)
            
            δX = selectedCellCenter.x - gestureFirstPoint.x
            δY = selectedCellCenter.y - gestureFirstPoint.y
            
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
            
        case UIGestureRecognizerState.changed:
            
            guard collectionState == .rearrangement,
                let view = gesture.view
                else { break }
            
            let newPoint = CGPoint(x: (gesture.location(in: view).x + δX), y: (gesture.location(in: view).y + δY))
            
            collectionView.updateInteractiveMovementTargetPosition(newPoint)
            
            
        case UIGestureRecognizerState.ended:
            
            collectionView.endInteractiveMovement()
            
            guard collectionState == .rearrangement else { break }
            
            performBatchUpdates()
            
            collectionState = .normal
            
            cellWidthTemporal = nil
            
            δX = 0.0
            δY = 0.0
            
            
        default:
            
            collectionView.cancelInteractiveMovement()
            collectionState = .normal
            
            δX = 0.0
            δY = 0.0
        }
    }
}

// MARK: - Collection View Datasource and Delegate
extension ProcessControl: UICollectionViewDelegate, UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasource.process.steps?.count ?? 0
    }
    
    // MARK: - Cells (Represent Steps)
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: stepCellIdentificator, for: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? StepCollectionViewCell,
            let step = datasource.process.steps?[indexPath.item] else { return }
        
        let styles = datasource.styleOfItems(for: step.state)
        
        cell.configure(title: step.title, deselectedTextStyle: styles.deselected, selectedTextStyle: styles.selected, movable: step.movable, removable: step.removable, isTheFirstCell: (indexPath.item == 0), arrowTintColor: arrowTintColor, addTintColor: addTintColor, removeTintColor: removeTintColor, lockTintColor: lockTintColor, delegate: self)
        cell.cellState = collectionState
        cell.tag = indexPath.item
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.left, animated: true)
    }
    
    
    // MARK: - Footer (Represents Goal)
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return collectionState == .normal
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier:
            goalViewIdentificator, for: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        guard let view = view as? ProcessCollectionReusableView else { return }
        
        view.configure(title: datasource.process.title, textStyle: datasource.styleOfScript, arrowTintColor: arrowTintColor, addTintColor: addTintColor, lockTintColor: lockTintColor, delegate: self, isTheOnlyElement: datasource.process.steps?.count == 0)
        
        view.viewState = collectionState
    }
    
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
}


// MARK: - Layout
extension ProcessControl: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellHeight = collectionView.bounds.height * cellHeightCoefficient
        var cellWidth: CGFloat = 0.0
        
        if let cellWidthTemporal = cellWidthTemporal {
            
            cellWidth = cellWidthTemporal[indexPath.item]
            
        } else {
            
            if cellWidths.count == 0 { buildCellSizesCache() }
            cellWidth = cellWidths[indexPath.item]
        }
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let footerHeight = collectionView.bounds.height * cellHeightCoefficient
        let footerSize: CGSize = ProcessCollectionReusableView.getViewSize(for: datasource.process.title, height: footerHeight, style: datasource.styleOfScript, acceptableWidthForTextOfOneLine: acceptableWidthForTextOfOneLine)
        
        return footerSize
    }
}

// MARK: - Reorder
extension ProcessControl {
    
    // Chek if the cell is movable
    public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        guard let cell = (collectionView.cellForItem(at: indexPath) as? StepCollectionViewCell) else { return false }
        return cell.movable
    }
    
    // Perform move action
    public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        if self.longPressGestureRecognizer.state == .ended {
            
            // Update external data
            cellWidths = cellWidthTemporal ?? []
            cellWidthTemporal = nil
            delegate.moveItem(at: sourceIndexPath.item, to: destinationIndexPath.item)
            return
            
        } else {
            if let temp = cellWidthTemporal?.remove(at: sourceIndexPath.item) {
                cellWidthTemporal?.insert(temp, at: destinationIndexPath.item)
            }
        }
    }
}

// Flow layout adaptation
extension UICollectionViewFlowLayout {
    
    override open func invalidationContext(forInteractivelyMovingItems targetIndexPaths: [IndexPath], withTargetPosition targetPosition: CGPoint, previousIndexPaths: [IndexPath], previousPosition: CGPoint) -> UICollectionViewLayoutInvalidationContext {
        
        let context = super.invalidationContext(forInteractivelyMovingItems: targetIndexPaths, withTargetPosition: targetPosition, previousIndexPaths: previousIndexPaths, previousPosition: previousPosition)
        
        guard let collectionView = collectionView,
            let previousFirstIndexPath = previousIndexPaths.first,
            let targetFirstIndexPath = targetIndexPaths.first
            else { return context }
        
        if previousFirstIndexPath.item != targetFirstIndexPath.item {
            
            collectionView.dataSource?.collectionView!(collectionView, moveItemAt: previousFirstIndexPath, to: targetFirstIndexPath)
        }
        
        return context
    }
    
    override open func invalidationContextForEndingInteractiveMovementOfItems(toFinalIndexPaths indexPaths: [IndexPath], previousIndexPaths: [IndexPath], movementCancelled: Bool) -> UICollectionViewLayoutInvalidationContext {
        
        return super.invalidationContextForEndingInteractiveMovementOfItems(toFinalIndexPaths: indexPaths, previousIndexPaths: previousIndexPaths, movementCancelled: movementCancelled)
    }
    
    /* Add interactively moving item attributes if needed
     override open func layoutAttributesForInteractivelyMovingItem(at indexPath: IndexPath, withTargetPosition position: CGPoint) -> UICollectionViewLayoutAttributes {
     let attributes = super.layoutAttributesForInteractivelyMovingItem(at: indexPath, withTargetPosition: position)
     
     attributes.alpha = 0.6
     
     return attributes
     }
     */
}

// MARK: - Rotation & Trait collection change
extension ProcessControl {
    
    public func updateLayout() {
        
        collectionViewSizeChanged = true
        
        cellWidths.removeAll()
        cellWidthTemporal = nil
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
    }
    
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateLayout()
    }
}

// MARK: - Service methods
extension ProcessControl {
    
    func performBatchUpdates() {
        
        self.collectionView.performBatchUpdates(
            { [weak self] in self?.collectionView.reloadSections(NSIndexSet(index: 0) as IndexSet)
            }, completion: { (finished:Bool) -> Void in
        })
    }
    
    func setCollectionViewMode() {
        
        if collectionState != .normal {
            collectionView.selectItem(at: nil, animated: true, scrollPosition: [])
        }
        
        collectionView.visibleCells.forEach {
            guard let cell = $0 as? StepCollectionViewCell else { return }
            cell.cellState = collectionState
            cell.isTheFirstCell = (collectionView.indexPath(for: cell)?.item == 0)
        }
        
        collectionView.visibleSupplementaryViews(ofKind: UICollectionElementKindSectionFooter).forEach {
            guard let footer = $0 as? ProcessCollectionReusableView else { return }
            footer.viewState = collectionState
        }
        
        collectionView.visibleSupplementaryViews(ofKind: UICollectionElementKindSectionHeader).forEach {
            guard let header = $0 as? HeaderCollectionReusableView else { return }
            header.viewState = collectionState
        }
    }
}

// MARK: - Actions delegate
extension ProcessControl: StepCollectionViewCellDelegate {
    
    func serviceButtonPressed(at index: Int) {
        
        guard collectionState == .editing else { return }
        delegate.addItemAt(at: index)
    }
    
    func removeButtonPressed(at index: Int, removable: Bool) {
        
        guard collectionState == .editing else { return }
        removable ? delegate.removeItem(at: index) : delegate.rejectRemoval(at: index)
    }
    
    func labelDoubleTapped(at index: Int, with gestureRecognizer: UIGestureRecognizer) {
        delegate.editItem(at: index)
    }
}

extension ProcessControl: ProcessCollectionReusableViewDelegate {
    func serviceButtonPressed() {
        delegate.addItemToEnd()
    }
    
    func labelDoubleTapped() {
        delegate.editScript()
    }
}
