//
//  EmojiCollectionView.swift
//  ISEmojiView
//
//  Created by Beniamin Sarkisyan on 01/08/2018.
//

import Foundation
import UIKit

/// emoji view action callback delegate
internal protocol EmojiCollectionViewDelegate: AnyObject {
    
    /// did press a emoji button
    ///
    /// - Parameters:
    ///   - emojiView: the emoji view
    ///   - emoji: a emoji
    ///   - selectedEmoji: the selected emoji
    func emojiViewDidSelectEmoji(emojiView: EmojiCollectionView, emoji: Emoji, selectedEmoji: String)
    
    /// changed section
    ///
    /// - Parameters:
    ///   - category: current category
    ///   - emojiView: the emoji view
    func emojiViewDidChangeCategory(_ category: Category, emojiView: EmojiCollectionView)
    
}

/// A emoji keyboard view
internal class EmojiCollectionView: UIView {
    
    // MARK: - Public variables
    
    /// the delegate for callback
    internal weak var delegate: EmojiCollectionViewDelegate?
    
    /// long press to pop preview effect like iOS10 system emoji keyboard, Default is true
    internal var isShowPopPreview = true
    
    internal var emojis: [EmojiCategory]! {
        didSet {
            collectionView.reloadData()
        }
    }
    
    // MARK: - Private variables
    
    private var scrollViewWillBeginDragging = false
    private var scrollViewWillBeginDecelerating = false
    private let emojiCellReuseIdentifier = "EmojiCell"
    
    private lazy var emojiPopView: EmojiPopView = {
        let emojiPopView = EmojiPopView()
        emojiPopView.delegate = self
        emojiPopView.isHidden = true
        return emojiPopView
    }()
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(EmojiCollectionCell.self, forCellWithReuseIdentifier: emojiCellReuseIdentifier)
            collectionView.register(EmojiSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: EmojiSectionHeaderView.reuseIdentifier)
            collectionView.register(EmptyCollectionViewCell.self, forCellWithReuseIdentifier: EmptyCollectionViewCell.reuseIdentifier)
        }
    }
    
    // MARK: - Override variables
    
    internal override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: frame.size.height)
    }

    
    // MARK: - Public
    
    public func popPreviewShowing() -> Bool {
        return !self.emojiPopView.isHidden;
    }
    
    // MARK: - Init functions
    
    static func loadFromNib(emojis: [EmojiCategory]) -> EmojiCollectionView {
        let nibName = String(describing: EmojiCollectionView.self)
        
        guard let nib = Bundle.podBundle.loadNibNamed(nibName, owner: nil, options: nil) as? [EmojiCollectionView] else {
            fatalError()
        }
        
        guard let view = nib.first else {
            fatalError()
        }
        
        view.emojis = emojis
        view.setupView()
        view.createLayout()
        return view
    }
    
    // MARK: - Override functions
    
    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard point.y < 0 else {
            return super.point(inside: point, with: event)
        }
        
        return point.y >= -TopPartSize.height
    }
    
    // MARK: - Internal functions
    
    internal func updateRecentsEmojis(_ emojis: [Emoji]) {
        self.emojis[0].emojis = emojis
        collectionView.reloadSections(IndexSet(integer: 0))
    }
    
    internal func scrollToCategory(_ category: Category) {
        guard var section = emojis.firstIndex(where: { $0.category == category }) else {
            return
        }
        
        if category == .recents && emojis[section].emojis.isEmpty {
            section = emojis.firstIndex(where: { $0.category == Category.smileysAndPeople })!
        }
        
        let indexPath = IndexPath(item: 0, section: section)
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
    }
    
    internal func createLayout()
    {
        // Not flow layout, but our custom layout
        let customLayout = HorizontalHeaderFlowLayout()
        customLayout.itemSpacing = 12
        customLayout.sectionSpacing = 25
        customLayout.itemSize = CGSize(width: 32, height: 26)
        collectionView.collectionViewLayout = customLayout
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 20)
        
    }
    
}

// MARK: - UICollectionViewDataSource

extension EmojiCollectionView: UICollectionViewDataSource {
    
    internal func numberOfSections(in collectionView: UICollectionView) -> Int {
        return emojis.count
    }
    
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            if emojis[section].emojis.count == 0 {
                return 8
            } else {
                let totalcells = 8
                let emojies = emojis[section].emojis.count
                if emojies < totalcells {
                    return totalcells
                } else {
                    return emojis[section].emojis.count
                }
            }
        } else {
            return emojis[section].emojis.count
        }
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 && emojis[indexPath.section].emojis.count <= 8 {
            if indexPath.row < emojis[indexPath.section].emojis.count {
                let emojiCategory = emojis[indexPath.section]
                let emoji = emojiCategory.emojis[indexPath.item]
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emojiCellReuseIdentifier, for: indexPath) as! EmojiCollectionCell
                
                if let selectedEmoji = emoji.selectedEmoji {
                    cell.setEmoji(selectedEmoji)
                } else {
                    cell.setEmoji(emoji.emoji)
                }
                
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptyCollectionViewCell.reuseIdentifier, for: indexPath) as! EmptyCollectionViewCell
                return cell
            }
        } else {
            
            let emojiCategory = emojis[indexPath.section]
            let emoji = emojiCategory.emojis[indexPath.item]
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emojiCellReuseIdentifier, for: indexPath) as! EmojiCollectionCell
            
            if let selectedEmoji = emoji.selectedEmoji {
                cell.setEmoji(selectedEmoji)
            } else {
                cell.setEmoji(emoji.emoji)
            }
            
            return cell
        }
    }
    
    internal func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: EmojiSectionHeaderView.reuseIdentifier, for: indexPath) as! EmojiSectionHeaderView
            let category = emojis[indexPath.section].category
            headerView.configure(with: category?.title ?? "")
            return headerView
        }
        return UICollectionReusableView()
    }
}

// MARK: - UICollectionViewDelegate

extension EmojiCollectionView: UICollectionViewDelegate {
    
    internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == 0 && emojis[indexPath.section].emojis.count <= 8 {
            if emojis[indexPath.section].emojis.count <= 0 {
                return
            } else {
                if indexPath.row < emojis[indexPath.section].emojis.count {
                    emojiPressed(at: indexPath)
                } else {
                    return
                }
            }
        } else {
            emojiPressed(at: indexPath)
        }
        
    }
    
    func emojiPressed(at indexPath:IndexPath) {
        guard emojiPopView.isHidden else {
            dismissPopView(false)
            return
        }
        
        let emojiCategory = emojis[indexPath.section]
        let emoji = emojiCategory.emojis[indexPath.item]
        
        delegate?.emojiViewDidSelectEmoji(emojiView: self, emoji: emoji, selectedEmoji: emoji.selectedEmoji ?? emoji.emoji)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if !scrollViewWillBeginDecelerating && !scrollViewWillBeginDragging {
            return
        }
        
        if let indexPath = collectionView.indexPathsForVisibleItems.min() {
            let emojiCategory = emojis[indexPath.section]
            delegate?.emojiViewDidChangeCategory(emojiCategory.category, emojiView: self)
        }
    }

}

// MARK: - UICollectionViewDelegateFlowLayout

extension EmojiCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 90, height: 14)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        var inset = UIEdgeInsets.zero
        
        if let recentsEmojis = emojis.first(where: { $0.category == Category.recents }) {
            if (!recentsEmojis.emojis.isEmpty && section != 0) || (recentsEmojis.emojis.isEmpty && section > 1) {
                inset.left = 15
            }
        }
        
        if section == 0 {
            inset.left = 3
        }
        
        if section == emojis.count - 1 {
            inset.right = 4
        }
        
        return inset
    }
    
}

// MARK: - UIScrollView

extension EmojiCollectionView {

    internal func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollViewWillBeginDragging = true
    }
    
    internal func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        scrollViewWillBeginDecelerating = true
    }
    
    internal func scrollViewDidScroll(_ scrollView: UIScrollView) {
        dismissPopView(false)
    }
    
    internal func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollViewWillBeginDragging = false
    }
    
    internal func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewWillBeginDecelerating = false
    }

}

// MARK: - EmojiPopViewDelegate

extension EmojiCollectionView: EmojiPopViewDelegate {
    
    internal func emojiPopViewShouldDismiss(emojiPopView: EmojiPopView) {
        dismissPopView(true)
    }
    
}

// MARK: - Private functions

extension EmojiCollectionView {
    
    private func setupView() {
        let emojiLongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(emojiLongPressHandle))
        addGestureRecognizer(emojiLongPressGestureRecognizer)
        
        addSubview(emojiPopView)
    }
    
    @objc private func emojiLongPressHandle(sender: UILongPressGestureRecognizer) {
        func longPressLocationInEdge(_ location: CGPoint) -> Bool {
            let edgeRect = collectionView.bounds.inset(by: collectionView.contentInset)
            return edgeRect.contains(location)
        }
        
        guard isShowPopPreview else { return }
        
        let location = sender.location(in: collectionView)
        
        guard longPressLocationInEdge(location) else {
            dismissPopView(true)
            return
        }
        
        guard let indexPath = collectionView.indexPathForItem(at: location) else {
            return
        }
        
        guard let attr = collectionView.layoutAttributesForItem(at: indexPath) else {
            return
        }
    
        let emojiCategory = emojis[indexPath.section]
        let emoji = emojiCategory.emojis[indexPath.item]
        
        if sender.state == .ended && emoji.emojis.count == 1 {
            dismissPopView(true)
            return
        }
        
        emojiPopView.setEmoji(emoji)
        
        let cellRect = attr.frame
        let cellFrameInSuperView = collectionView.convert(cellRect, to: self)
        let emojiPopLocation = CGPoint(
            x: cellFrameInSuperView.origin.x - ((TopPartSize.width - BottomPartSize.width) / 2.0) + 5,
            y: cellFrameInSuperView.origin.y - TopPartSize.height - 10
        )
        emojiPopView.move(location: emojiPopLocation, animation: sender.state != .began)
    }
    
    private func dismissPopView(_ usePopViewEmoji: Bool) {
        emojiPopView.dismiss()
        
        let currentEmoji = emojiPopView.currentEmoji
        if !currentEmoji.isEmpty && usePopViewEmoji {
            self.delegate?.emojiViewDidSelectEmoji(emojiView: self, emoji: Emoji(emojis: emojiPopView.emojiArray), selectedEmoji: currentEmoji)
        }
        
        emojiPopView.currentEmoji = ""
    }
    
}
