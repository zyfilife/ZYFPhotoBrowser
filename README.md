# ZYFPhotoBrowser

### 特色

- 图片视图复用

### 如何使用

```swift
override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    var photos = [ZYFPhoto]()
    var i = 0
    for item in collectionView.visibleCells {
        guard let cell = item as? CollectionViewCell else {
            return
        }
        let photo = ZYFPhoto(image: cell.imageView.image!, index: i, sourceImageView: cell.imageView)
        i += 1
        photos.append(photo)
    }
    let photoBrowser = ZYFPhotoBrowser()
    photoBrowser.photos = photos
    photoBrowser.firstShowIndex = indexPath.row
    photoBrowser.show()
}
```
